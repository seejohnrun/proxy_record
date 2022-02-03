require 'spec_helper'

describe ProxyRecord do
  it 'should not have access to model class methods' do
    model_parent_class = Class.new do
      def self.foo
      end
    end

    klass = Class.new(ProxyRecord[model_parent_class])

    expect(klass).not_to respond_to(:foo)
  end

  it 'should be able to call class methods on the proxy class' do
    model_parent_class = Class.new do
      def self.foo
        'result'
      end
    end

    klass = Class.new(ProxyRecord[model_parent_class]) do
      def self.foo_proxy
        data_model_class.foo
      end
    end

    expect(klass.foo_proxy).to eq('result')
  end

  it 'should not have access to model instance methods' do
    model_parent_class = Class.new do
      def foo
      end
    end

    klass = Class.new(ProxyRecord[model_parent_class])

    instance = klass.wrap(klass.send(:data_model_class).new)

    expect(instance).not_to respond_to(:foo)
  end

  it 'should be able to call instance methods on the proxy class' do
    model_parent_class = Class.new do
      def foo
        'result'
      end
    end

    klass = Class.new(ProxyRecord[model_parent_class]) do
      def foo_proxy
        data_model.foo
      end
    end

    instance = klass.wrap(klass.send(:data_model_class).new)

    expect(instance.foo_proxy).to eq('result')
  end

  it 'should be able to run a model block for an AR::Base subclass' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      class << self
        def total_count
          data_model_class.count
        end
      end
    end

    expect(klass.total_count).to eq(0)
  end

  it 'should be able to create & wrap an individual record' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      class << self
        def create
          wrap(data_model_class.create(login: 'foo'))
        end
      end
    end

    expect(klass.create).to be_a(klass)
  end

  it 'should not have public methods for accessing data_model_class or model' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end
    end

    expect(klass).not_to respond_to(:data_model_class)
    expect(klass.wrap(klass.send(:data_model_class).new).private_methods).to include(:data_model)
  end
end
