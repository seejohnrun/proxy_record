require 'active_support/core_ext/class'

module ProxyRecord
  def self.ar_superclass
    Object
  end

  def self.[](model_class)
    ar_model_class = Class.new(model_class)

    klass = Class.new(Proxy)
    klass.send(:model_class=, ar_model_class)
    klass
  end

  class Proxy
    class_attribute :model_class, instance_predicate: false
    private_class_method :model_class, :model_class=

    def self.wrap(o)
      case o
      when model_class then new(o)
      else raise 'Cannot wrap'
      end
    end

    def self.model(&block)
      model_class.class_eval(&block)
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
