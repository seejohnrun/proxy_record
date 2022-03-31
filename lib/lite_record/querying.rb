require_relative '../proxy_record/collection_proxy'

module LiteRecord
  module Querying
    private

    # Returns the first record
    def first
      ProxyRecord.wrap(data_model_class.first)
    end

    # Returns the last record
    def last
      ProxyRecord.wrap(data_model_class.last)
    end

    # Returns a ProxyRecord::CollectionProxy with the given conditions
    def where(*where_attributes)
      ar_scope = data_model_class.where(*where_attributes)
      ProxyRecord::CollectionProxy.new(ar_scope)
    end

    # Refines & returns a new ProxyRecord::CollectionProxy adding the given
    # conditions to the current scope
    def refine_scope(scope, *where_attributes)
      ar_scope = scope.instance_variable_get(:@collection).where(*where_attributes)
      ProxyRecord::CollectionProxy.new(ar_scope)
    end
  end
end
