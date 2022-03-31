require 'spec_helper'

describe LiteRecord do
  class Post < ProxyRecord[ActiveRecord::Base]
    include LiteRecord

    data_model_eval do
      def self.name
        'Post'
      end

      def self.model_name
        ActiveModel::Name.new(self, nil, 'Post')
      end
    end
  end

  after :all do
    Object.send(:remove_const, :Post)
  end

  let(:user_klass) do
    Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users' # automatically populated in apps
        def self.name
          'User' # TODO figure this out, shouldn't be hard
        end

        def self.model_name
          ActiveModel::Name.new(self, nil, 'User')
        end
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

  describe '.validates' do
    it 'should be able to transparently add rails validations' do
      call_private_method(user_klass, :validates, :login, presence: true)
    end

    it 'should actually obey those validations on save!' do
      call_private_method(user_klass, :validates, :login, presence: true)

      instance = user_klass.send(:create!, login: 'foo')
      instance.send(:login=, nil)

      expect {
        instance.send(:save!)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '.validate' do
    it 'should be able to validate with a method defined on the model class' do
      user_klass.class_eval do
        validate :validate_login_is_foo

        private

        def validate_login_is_foo
          errors.add(:base, 'uhoh') unless login == 'foo'
        end
      end

      user_klass.send(:create!, login: 'foo') # valid

      expect {
        user_klass.send(:create!, login: 'boo') # invalid
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'attribute methods' do
    it 'should create private attribute getter methods' do
      instance = user_klass.send(:create!, login: 'foo')
      expect(call_private_method(instance, :login)).to eq('foo')
    end

    it 'should create private attribute setter methods' do
      instance = user_klass.send(:create!, login: 'foo')
      expect(call_private_method(instance, :login=, 'boo')).to eq('boo')
    end

    it 'should be able to make private methods public easily' do
      user_klass.class_eval do
        public :login
      end

      instance = user_klass.send(:create!, login: 'foo')
      expect(instance.login).to eq('foo')
    end

    it 'should be able to define public replacements and call super (methods defined in module)' do
      user_klass.class_eval do
        def login
          "~~#{super}~~"
        end
      end

      instance = user_klass.send(:create!, login: 'foo')
      expect(instance.login).to eq('~~foo~~')
    end
  end

  describe '#save!' do
    it 'should be able to call save! from within an instance' do
      instance = user_klass.send(:create!, login: 'foo')

      call_private_method(instance, :login=, 'boo')
      return_value = call_private_method(instance, :save!)

      expect(return_value).to eq(true)

      expect(user_klass.send(:where, login: 'boo').count).to eq(1)
    end
  end

  describe '#destroy' do
    it 'should be able to call destroy from within an instance' do
      instance = user_klass.send(:create!, login: 'foo')
      call_private_method(instance, :destroy)

      expect(user_klass.send(:where, login: 'foo')).to be_empty
    end
  end

  describe '#has_many' do
    it 'should be able to define and use a has_many' do
      user_klass.class_eval do
        has_many :posts, dependent: :destroy
      end

      instance = user_klass.send(:create!, login: 'foo')

      expect(call_private_method(instance, :posts).to_a).to eq([])

      Post.send(:create!, user_id: instance.send(:data_model).id) # TODO next thing to handle

      instance.send(:data_model).send(:reload) # TODO not need this
      expect(call_private_method(instance, :posts).count).to eq(1)
      expect(call_private_method(instance, :posts).to_a.first).to be_a(Post)
    end
  end

  def assert_method_private(obj, method_name)
    expect(obj).not_to respond_to(method_name)
    expect(obj.respond_to?(method_name, true)).to eq(true)
  end

  # Ensure that the passed method is private, and call it
  def call_private_method(obj, method_name, *args)
    assert_method_private(obj, method_name)
    obj.send(method_name, *args)
  end
end
