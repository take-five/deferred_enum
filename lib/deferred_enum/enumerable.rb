module Enumerable
  def defer(method_id = :each)
    DeferredEnumerator.new(self, method_id)
  end
end