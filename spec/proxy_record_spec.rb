require_relative '../lib/proxy_record'
require 'securerandom'

describe ProxyRecord do
  it 'should not have access to underlying class methods' do
    underlying_class = Class.new do
      def self.foo
      end
    end

    overlying_class = Class.new(ProxyRecord[underlying_class])

    expect(overlying_class).not_to respond_to(:foo)
  end

  it 'should be able to call class methods on the overlying class' do
    underlying_class = Class.new do
      def self.foo
        'result'
      end
    end

    overlying_class = Class.new(ProxyRecord[underlying_class]) do
      def self.foo_proxy
        underlying_class.foo
      end
    end

    expect(overlying_class.foo_proxy).to eq('result')
  end

  it 'should not have access to underlying instance methods' do
    underlying_class = Class.new do
      def foo
      end
    end

    overlying_class = Class.new(ProxyRecord[underlying_class])

    instance = overlying_class.new(underlying_class.new)

    expect(instance).not_to respond_to(:foo)
  end

  it 'should be able to call instance methods on the overlying class' do
    underlying_class = Class.new do
      def foo
        'result'
      end
    end

    overlying_class = Class.new(ProxyRecord[underlying_class]) do
      def foo_proxy
        underlying_instance.foo
      end
    end

    instance = overlying_class.new(underlying_class.new)

    expect(instance.foo_proxy).to eq('result')
  end
end
