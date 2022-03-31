require_relative '../proxy_record/collection_proxy'

module LiteRecord
  module Querying
    private

    def first
      ProxyRecord.wrap(data_model_class.first)
    end

    def last
      ProxyRecord.wrap(data_model_class.last)
    end

    def where(*where_attributes)
      ar_scope = data_model_class.where(*where_attributes)
      ProxyRecord::CollectionProxy.new(ar_scope)
    end

    def refine_scope(scope, *where_attributes)
      ar_scope = scope.instance_variable_get(:@collection).where(*where_attributes)
      ProxyRecord::CollectionProxy.new(ar_scope)
    end
  end
end
