module DeferredEnumerable
  include Enumerable

  # Passes each element of the collection to the given block.
  # The method returns true if the block never returns false or nil.
  def all?(&blk) # :yields: obj
    blk ||= proc { |e| e }
    each { |entry| return false unless blk.call(entry) }
    true
  end

  # Passes each element of the collection to the given block.
  # The method returns true if the block ever returns a value other than false or nil.
  def any?(&blk) # :yields: obj
    blk ||= proc { |e| e }
    each { |entry| return true if blk.call(entry) }
    false
  end

  # Passes each element of the collection to the given block.
  # The method returns true if the block never returns true for all elements.
  # If the block is not given, none? will return true only if none of the collection members is true.
  def none?(&blk)
    blk ||= proc { |e| e }
    each { |entry| return false if blk.call(entry) }
    true
  end

  # Returns a new enumerator with the results of running block once for every element in enum.
  def collect(&block) # :yields: obj
    return self unless block_given?

    DeferredEnumerator::Map.new(self, block)
  end
  alias map collect

  # Returns a enumerator containing all elements of enum for which block is not false
  def select(&block) # :yields: obj
    return self unless block_given?

    DeferredEnumerator::Select.new(self, block)
  end
  alias find_all select

  # Returns a enumerator containing all elements of enum for which block is false
  def reject(&block) # :yields: obj
    return self unless block_given?

    select { |e| !block.call(e) }
  end

  # Returns a new enumerator that is a one-dimensional flattening of this enumerator (recursively).
  # That is, for every element that is an Enumerable, extract its elements into the new enumerator.
  # If the optional level argument determines the level of recursion to flatten.
  def flatten(level = nil)
    do_recursion, next_level = if level.is_a?(Fixnum)
      [level > 0, level - 1]
    else
      [true, nil]
    end

    DeferredEnumerator.new do |yielder|
      each do |entry|
        if entry.is_a?(Enumerable) && do_recursion
          entry.defer.flatten(next_level).each { |nested| yielder << nested }
        else
          yielder << entry
        end
      end
    end # Enumerator.new
  end # def flatten

  # Returns a new enumerator with the concatenated results of running block once for every element in enum.
  def flat_map(&blk) # :yields: obj
    return flatten unless block_given?

    flatten.collect(&blk)
  end
  alias collect_concat flat_map

  # Calls block for each element of enum repeatedly n times or forever if none or nil is given.
  # If a non-positive number is given or the collection is empty, does nothing.
  # Returns nil if the loop has finished without getting interrupted.
  #
  # Unlike <tt>Enumerable#cycle</tt> <tt>DeferredEnumerable#cycle</tt> DOES NOT save elements in an internal array.
  #
  # If no block is given, an enumerator is returned instead.
  def cycle(n = nil) # :yields: obj
    cycles_num = n.is_a?(Fixnum) ? n : nil

    enum = DeferredEnumerator.new do |yielder|
      while cycles_num.nil? || cycles_num > 0
        each { |entry| yielder << entry }

        cycles_num -= 1 if cycles_num
      end
    end

    unless block_given?
      enum
    else
      enum.each { |e| yield(e) }

      nil
    end
  end

  # Drops first n elements from enum, and returns rest elements in an enumerator.
  def drop(n)
    raise TypeError, 'Integer (> 0) expected' unless n.is_a?(Fixnum) && n > 0

    DeferredEnumerator.new do |yielder|
      each { |entry| yielder << entry if (n -= 1) < 0}
    end
  end

  # Returns first n elements from enum.
  def take(n)
    raise TypeError, 'Integer (> 0) expected' unless n.is_a?(Fixnum) && n > 0

    DeferredEnumerator.new do |yielder|
      each { |entry| yielder << entry if (n -= 1) >= 0 }
    end
  end

  # Drops elements up to, but not including, the first element for which the block returns nil
  # or false and returns an enumerator containing the remaining elements.
  def drop_while # :yields: obj
    return self unless block_given?

    DeferredEnumerator.new do |yielder|
      keep = false
      each do |entry|
        keep ||= !yield(entry)

        yielder << entry if keep
      end
    end
  end

  # Passes elements to the block until the block returns <code>nil</code> or <code>false</code>,
  # then stops iterating and returns an enumerator of all prior elements.
  def take_while # :yields: obj
    return self unless block_given?

    DeferredEnumerator.new do |yielder|
      each do |entry|
        break unless yield(entry)

        yielder << entry
      end
    end
  end

  # Returns an array of every element in enum for which <code>Pattern === element</code>.
  # If the optional <code>block</code> is supplied, each matching element is passed to it,
  # and the block's result is stored in the output array.
  def grep(pattern, &blk) # :yields: obj
    filtered = select { |obj| pattern === obj }

    block_given? ?
        filtered.collect(&blk) :
        filtered
  end

  # Returns <code>true</code> if any member of <code>enum</code> equals <code>obj</code>.
  # Equality is tested using <code>==</code>.
  def include?(obj) # :yields: obj
    any? { |e| obj == e }
  end
  alias member? include?

  # Returns two enums, the first containing the elements of enum for which the block evaluates to true, the second containing the rest.
  def partition # :yields: obj
    super.map(&:defer)
  end

  # Returns an enumerator containing the items in enum sorted,
  # either according to their own <=> method,
  # or by using the results of the supplied block.
  def sort
    super.defer
  end

  # Sorts enum using a set of keys generated by mapping the values in enum through the given block.
  def sort_by
    super.defer
  end

  # Takes one element from <i>enum</i> and merges corresponding
  # elements from each <i>enumerables</i>. This generates a sequence of
  # <em>n</em>-element arrays, where <em>n</em> is one more than the
  # count of arguments.  The length of the resulting sequence will be
  # <code>enum#size</code>. If the size of any argument is less than
  # <code>enum#size</code>, <code>nil</code> values are supplied. If
  # a block is given, it is invoked for each output array, otherwise
  # an enumerator of arrays is returned.
  def zip(*enumerables)
    return super if block_given?

    raise TypeError, 'Zip accepts only enumerables' unless enumerables.all? { |e| e.is_a?(Enumerable) }

    deferred = enumerables.map(&:defer)

    DeferredEnumerator.new do |yielder|
      each do |entry|
        ary = [entry]

        deferred.each do |enum|
          ary << begin
            enum.next
          rescue StopIteration
            nil
          end
        end

        yielder << ary
      end
    end
  end

  # Returns a enumerator with all nil elements removed.
  def compact
    reject(&:nil?)
  end

  # Appends the <code>enumerables</code> to self.
  def concat(*enumerables)
    raise TypeError, 'DeferredEnumerabler#concat accepts only enumerables' unless enumerables.all? { |e| e.is_a?(Enumerable) }

    DeferredEnumerator.new do |yielder|
      [self, *enumerables].each do |enum|
        enum.each { |entry| yielder << entry }
      end
    end
  end
  alias chain concat
  alias + concat

  # Appends the <code>element</code> to end of enumerator
  def push(element)
    concat([element])
  end
  alias << push

  # Returns a new enumerator by removing duplicate values in self.
  def uniq
    values = {}

    select { |entry|
      value = block_given? ? yield(entry) : entry

      unless values.has_key?(value)
        values.store(value, true)
      end
    }
  end
end

require "deferred_enumerator"
require "deferred_enum/enumerable"