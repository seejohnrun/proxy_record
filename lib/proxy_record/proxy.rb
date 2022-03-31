require 'active_support/core_ext/class'
require_relative 'collection_proxy'

module ProxyRecord
  class Proxy
    class_attribute :data_model_class, instance_predicate: false

    class << self
      private

      def wrap(o)
        ProxyRecord.wrap(o)
      end

      def inherited(model_class)
        if data_model_class
          data_model_class.proxy_record_class = model_class
          model_class.const_set(:DataModel, data_model_class)

          if model_class.name
            data_model_class.table_name = model_class.name.pluralize.underscore
          end
        end
      end

      def instance_proxy_delegate(*m)
        m.each do |method_name|
          define_method(method_name) do |*args, &block|
            ProxyRecord.wrap(data_model.public_send(method_name, *args, &block))
          end
        end
      end

      def class_proxy_delegate(*m)
        m.each do |method_name|
          define_singleton_method(method_name) do |*args, &block|
            wrap(data_model_class.public_send(method_name, *args, &block))
          end
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
