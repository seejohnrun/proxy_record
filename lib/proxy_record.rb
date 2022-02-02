require 'active_support/core_ext/class'

module ProxyRecord
  def self.ar_superclass
    Object
  end

  def self.[](underlying_class)
    klass = Class.new(Proxy)
    klass.underlying_class = underlying_class
    klass
  end

  class Proxy
    class_attribute :underlying_class, instance_predicate: false

    attr_reader :underlying_instance

    def initialize(underlying)
      @underlying_instance = underlying
    end
  end
end
