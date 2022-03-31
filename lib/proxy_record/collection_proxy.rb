module ProxyRecord
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

    def each(&block)
      @collection.each do |record|
        yield ProxyRecord.wrap(record)
      end
    end
  end
end
