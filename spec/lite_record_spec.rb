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
    it 'should return a ProxyRecord::CollectionProxy of individual objects' do
      assert_method_private(user_klass, :where)

      scope = user_klass.send(:where, login: 'foo')
      expect(scope).to be_a(ProxyRecord::CollectionProxy)

      expect(scope.to_a).to be_empty

      user_klass.send(:data_model_class).create!(login: 'foo')
      scope = user_klass.send(:where, login: 'foo')
      expect(scope.to_a.count).to eq(1)
      expect(scope.to_a.first).to be_a(user_klass)
    end

    it 'should be able to continue to refine a ProxyRecord::CollectionProxy' do
      assert_method_private(user_klass, :refine_scope)

      user_klass.send(:data_model_class).create!(login: 'foo')

      scope = user_klass.send(:where, login: 'foo')
      expect(scope.count).to eq(1)

      scope = user_klass.send(:refine_scope, scope, id: 100)
      expect(scope.count).to eq(0)
    end

    it 'should be able to use prepared statement wheres' do
      user_klass.send(:data_model_class).create!(login: 'foo')

      expect(user_klass.send(:where, 'login LIKE ?', 'fo%').to_a.count).to eq(1)
    end

    it 'should be able to use basic enumerator methods on scopes' do
      user_klass.send(:data_model_class).create!(login: 'foo')

      scope = user_klass.send(:where, login: 'foo')
      expect(scope.first).to be_a(user_klass)
      expect(scope.last).to be_a(user_klass)
      expect(scope.count).to be_a(Integer)
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
