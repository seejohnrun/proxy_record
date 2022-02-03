require 'active_support/core_ext/class'
require_relative 'collection_proxy'

module ProxyRecord
  class Proxy
    class_attribute :data_model_class, instance_predicate: false

    class << self
      private

      def wrap(o)
        case o
        when data_model_class then new(o)
        when ActiveRecord::Relation then CollectionProxy.new(o) { |e| wrap(e) }
        else raise "Cannot wrap #{o}"
        end
      end

      def data_model_eval(&block)
        data_model_class.class_eval(&block)
      end
    end

    private_class_method :data_model_class, :data_model_class=, :new

    def initialize(data_model)
      @data_model = data_model
    end

    private

    def data_model
      @data_model
    end
  end
end
