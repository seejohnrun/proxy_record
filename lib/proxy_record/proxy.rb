require 'active_support/core_ext/class'

module ProxyRecord
  class Proxy
    class_attribute :data_model_class, instance_predicate: false
    private_class_method :data_model_class, :data_model_class=

    def self.wrap(o)
      case o
      when data_model_class then new(o)
      else raise 'Cannot wrap'
      end
    end

    def self.data_model_eval(&block)
      data_model_class.class_eval(&block)
    end

    class << self
      private :new
    end

    def initialize(data_model)
      @data_model = data_model
    end

    private

    def data_model
      @data_model
    end
  end
end
