module LiteRecord
  # Represents an in-progress scope on a given model.
  #
  # Note that this object is MUCH more limited than AR::Relation. This is
  # intentional. If we defined methods here like `destroy_all` they'd either:
  #
  # * be private and thus not be callable from anywhere useful
  # * be public and defeat the purpose of this library
  class Scope
    def initialize(scope)
      @scope = scope
    end

    def where(*where_attributes)
      @scope = @scope.where(*where_attributes)
      self
    end

    def to_a
      @scope.map { |o| ProxyRecord.wrap(o) }
    end
  end
end
