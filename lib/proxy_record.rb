require_relative 'proxy_record/proxy'

module ProxyRecord
  def self.[](data_model_parent_class)
    data_model_class = Class.new(data_model_parent_class)

    klass = Class.new(Proxy)
    klass.send(:data_model_class=, data_model_class)
    klass
  end
end
