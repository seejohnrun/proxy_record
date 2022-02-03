module ProxyRecord
  class CollectionProxy
    def initialize(collection, &wrap_proc)
      @collection = collection
      @wrap_proc = wrap_proc
    end

    include Enumerable

    def each(&block)
      @collection.each do |record|
        yield @wrap_proc.call(record)
      end
    end
  end
end
