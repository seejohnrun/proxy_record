require 'active_support/core_ext/class'
require_relative 'collection_proxy'

module ProxyRecord
  class Proxy
    class_attribute :data_model_class, instance_predicate: false

    class << self
      private

      def class_proxy_delegate(*m)
        m.each do |method_name|
          define_singleton_method(method_name) do
            wrap(data_model_class.public_send(method_name))
          end
        end
      end

      # TODO try to move to ProxyRecord
      def wrap(o)
        case o
        when data_model_class then new(o)
          # TODO there is a bug here since the relation won't always be the same type
        when ActiveRecord::Relation then CollectionProxy.new(o) { |e| wrap(e) }
        when Integer, String then o
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
