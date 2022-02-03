require_relative 'proxy_record/proxy'

# TODO move this into a module
require 'active_record'
class ActiveRecord::Base
  class_attribute :proxy_record_class, instance_predicate: false
end

module ProxyRecord
  def self.[](data_model_parent_class)
    data_model_class = Class.new(data_model_parent_class)

    klass = Class.new(Proxy)
    klass.send(:data_model_class=, data_model_class)
    klass
  end
end
