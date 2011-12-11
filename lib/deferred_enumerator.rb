require "deferred_enumerable"
require "deferred_enum/enumerable"

class DeferredEnumerator < Enumerator
  include ::DeferredEnumerable
end