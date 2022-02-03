module ProxyRecord
  class CollectionProxy
    def initialize(collection)
      @collection = collection
    end

    include Enumerable

    def each(&block)
      @collection.each do |record|
        yield ProxyRecord.wrap(record)
      end
    end
  end
end
