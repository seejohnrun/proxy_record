module LiteRecord
  # Represents an in-progress scope on a given model.
  #
  # Note that this object is MUCH more limited than AR::Relation. This is
  # intentional. If we defined methods here like `destroy_all` they'd either:
  #
  # * be private and thus not be callable from anywhere useful
  # * be public and defeat the purpose of this library
  #
  # We have to treat this class as if it could be exported to another place
  # by return and be used (it likely will).
  class Scope
    def initialize(scope)
      @scope = scope
    end

    def to_a
      @scope.map { |o| ProxyRecord.wrap(o) }
    end

    def first
      ProxyRecord.wrap(@scope.first)
    end

    def last
      ProxyRecord.wrap(@scope.last)
    end
  end
end
