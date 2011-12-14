class DeferredEnumerator::Map < DeferredEnumerator #:nodoc:all
  def initialize(obj, map = nil)
    @_map = map
    super(obj)
  end

  def each
    return super unless block_given?

    super { |e| yield(@_map ? @_map.call(e) : e) }
  end
end