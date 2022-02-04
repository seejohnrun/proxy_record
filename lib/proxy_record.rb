require_relative 'proxy_record/proxy'
require 'active_record'

# A class_attribute to grab the proxy class for a given data model
ActiveRecord::Base.class_attribute :proxy_record_class, instance_predicate: false

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
