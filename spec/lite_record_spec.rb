require 'spec_helper'

describe LiteRecord do
  let(:user_klass) do
    Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end
      include LiteRecord
    end
  end

  describe '.create' do
    it 'should create a new record with the specified params and return a wrapped object' do
      assert_method_private(user_klass, :create!)

      expect(user_klass.send(:create!, login: 'foo')).to be_a(user_klass)
    end
  end

  describe '.first' do
    it 'should provide a private first method that returns a wrapped object or nil' do
      assert_method_private(user_klass, :first)

      expect(user_klass.send(:first)).to be_nil

      user_klass.send(:data_model_class).create!(login: 'foo')
      expect(user_klass.send(:first)).to be_a(user_klass)
    end
  end

  describe '.last' do
    it 'should provide a private last method that returns a wrapped object or nil' do
      assert_method_private(user_klass, :last)

      expect(user_klass.send(:last)).to be_nil

      user_klass.send(:data_model_class).create!(login: 'foo')
      expect(user_klass.send(:last)).to be_a(user_klass)
    end
  end

  describe '.where' do
    it 'should return a ProxyRecord::Scope of individual objects' do
      assert_method_private(user_klass, :where)

      scope = user_klass.send(:where, login: 'foo')
      expect(scope).to be_a(LiteRecord::Scope)

      expect(scope.to_a).to be_empty

      user_klass.send(:data_model_class).create!(login: 'foo')
      scope = user_klass.send(:where, login: 'foo')
      expect(scope.to_a.count).to eq(1)
      expect(scope.to_a.first).to be_a(user_klass)
    end

    it 'should be able to continue to refine a ProxyRecord::Scope' do
      user_klass.send(:data_model_class).create!(login: 'foo')

      expect(user_klass.send(:where, login: 'foo').to_a.count).to eq(1)
      expect(user_klass.send(:where, login: 'foo').where(id: 100).to_a.count).to eq(0)
    end

    it 'should be able to use prepared statement wheres' do
      user_klass.send(:data_model_class).create!(login: 'foo')

      expect(user_klass.send(:where, 'login LIKE ?', 'fo%').to_a.count).to eq(1)
    end
  end

  def assert_method_private(obj, method_name)
    expect(obj).not_to respond_to(method_name)
    expect(obj.respond_to?(method_name, true)).to eq(true)
  end

  # Ensure that the passed method is private, and call it
  def call_private_method(obj, method_name, *args)
    obj.send(method_name, *args)
  end
end
