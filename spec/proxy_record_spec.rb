require 'spec_helper'

describe ProxyRecord do
  it 'should not have access to model class methods' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base])

    expect(klass).not_to respond_to(:count)
  end

  it 'should be able to call class methods on the proxy class' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      def self.count_proxy
        data_model_class.count
      end
    end

    expect(klass.count_proxy).to eq(0)
  end

  it 'should not have access to model instance methods' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      def self.build
        wrap(data_model_class.new)
      end
    end

    expect(klass.build).not_to respond_to(:login)
  end

  it 'should be able to call instance methods on the proxy class' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      def login_proxy
        data_model.login
      end

      def self.build
        wrap(data_model_class.new(login: 'result'))
      end
    end

    expect(klass.build.login_proxy).to eq('result')
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

      def self.build
        wrap(data_model_class.new)
      end
    end

    expect(klass.private_methods).to include(:wrap, :data_model_class, :new)
    expect(klass.build.private_methods).to include(:data_model)
  end

  it 'should be able to wrap collections and call enumerable methods on them' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      def self.create
        wrap(data_model_class.create)
      end

      def self.all
        wrap(data_model_class.all)
      end
    end

    klass.create

    collection_proxy = klass.all
    expect(collection_proxy.count).to eq(1)
    expect(collection_proxy.first).to be_a(klass)
  end

  it 'should be able to delegate method calls via a normal delegate call' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      delegate :login, to: :data_model

      def self.build(login)
        wrap(data_model_class.new(login: login))
      end
    end

    random_login = SecureRandom.hex
    expect(klass.build(random_login).login).to eq(random_login)
  end

  it 'should be able to set up wrap delegates at the class level' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      class_proxy_delegate :create
    end

    expect(klass.create).to be_a(klass)
  end

  it 'should be able to set up wrap delegates for collection-returning class methods' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      class_proxy_delegate :all, :create
    end

    created = klass.create
    expect(klass.all.count).to eq(1)
    expect(klass.all.first).to be_a(klass)
  end

  it 'should be able to use class_proxy_delegate for methods that return primitives' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      class_proxy_delegate :count
    end

    expect(klass.count).to eq(0)
  end

  it 'should be able to set up wrap delegates at the instance level' do
    klass = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
      end

      class_proxy_delegate :create
      instance_proxy_delegate :login
    end

    expect(klass.create(login: 'john').login).to eq('john')
  end

  it 'should be able to set up wrap delegates for collection-returning instance methods' do
    post_class = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'posts'
        belongs_to :user, class_name: 'User::DataModel'
      end

      class_proxy_delegate :create
    end
    Object.const_set(:Post, post_class)

    user_class = Class.new(ProxyRecord[ActiveRecord::Base]) do
      data_model_eval do
        self.table_name = 'users'
        has_many :posts, class_name: 'Post::DataModel', foreign_key: :user_id
      end

      class_proxy_delegate :create
      instance_proxy_delegate :posts

      def create_post
        ProxyRecord.wrap(data_model.posts.create)
      end
    end
    Object.const_set(:User, user_class)

    user = user_class.create
    post = user.create_post
    expect(post).to be_a(post_class)

    expect(user.posts.count).to eq(1)
    expect(user.posts.first).to be_a(post_class)
  ensure
    Object.send(:remove_const, :Post) rescue nil
    Object.send(:remove_const, :User) rescue nil
  end
end
