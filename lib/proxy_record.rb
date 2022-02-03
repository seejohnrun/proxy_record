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

  def self.wrap(o)
    case o
    when ActiveRecord::Base then o.class.proxy_record_class.send(:new, o)
    when ActiveRecord::Relation then CollectionProxy.new(o)
    else o # non-AR types fall through
    end
  end
end
