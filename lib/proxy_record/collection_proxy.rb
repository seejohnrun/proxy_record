module ProxyRecord
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
  class CollectionProxy
    def initialize(collection)
      @collection = collection
    end

    include Enumerable

    def first
      ProxyRecord.wrap(@collection.first)
    end

    def last
      ProxyRecord.wrap(@collection.last)
    end

    def count
      @collection.count
    end

    def empty?
      @collection.empty?
    end

    def each(&block)
      @collection.each do |record|
        yield ProxyRecord.wrap(record)
      end
    end
  end
end
