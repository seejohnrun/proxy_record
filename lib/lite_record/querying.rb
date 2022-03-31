require_relative './scope'

module LiteRecord
  module Querying
    private

    def create!(*attributes)
      created_record = data_model_class.create!(*attributes)
      ProxyRecord.wrap(created_record)
    end

    def first
      ProxyRecord.wrap(data_model_class.first)
    end

    def last
      ProxyRecord.wrap(data_model_class.last)
    end

    def where(*where_attributes)
      ar_scope = data_model_class.where(*where_attributes)
      Scope.new(ar_scope)
    end
  end
end
