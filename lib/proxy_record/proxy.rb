require 'active_support/core_ext/class'

module ProxyRecord
  class Proxy
    class_attribute :data_model_class, instance_predicate: false

    class << self
      private

      def wrap(o)
        case o
        when data_model_class then new(o)
        else raise 'Cannot wrap'
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
