require "deferred_enumerable"
require "deferred_enum/enumerable"

class DeferredEnumerator < Enumerator
  include ::DeferredEnumerable

  require "deferred_enum/map"
  require "deferred_enum/select"
end