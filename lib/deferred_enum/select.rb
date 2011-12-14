class DeferredEnumerator::Select < DeferredEnumerator #:nodoc:all
  def initialize(obj, filter = nil)
    @_filter = filter
    super(obj)
  end

  def each
    return super unless block_given?

    super { |e| yield(e) if !@_filter || @_filter.call(e) }
  end
end