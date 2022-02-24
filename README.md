# ProxyRecord

## Motivation

`ActiveRecord` is a tremendously powerful and popular ORM for Rails, but some
of the access patterns that result from using it can lead to a difficulty for
teams in larger codebases to define clear public interfaces for their models.

For example, when defining `User` as a subclass of `ActiveRecord::Base`,
external methods like `.destroy_all`, `.update_all` are exposed to the entire
application. We're left unable to create clear contracts for our models, and
as a result we see a bunch of code in views, controllers, and other models
reaching directly into methods which aren't intended to be used. Some particular
common cases:

  * Views and controllers calling `where(...)` on an association to further
    scope it, instead of utilizing appropriate named scopes or model methods.

  * Public interfaces for classes are made larger by default, so rather than
    having to test the correct path, we test all of them (or add linters) for
    fear that new developers might use the wrong path for an operation.

  * When certain fields need additional behavior on modification, we can't
    tightly control the path to updates so we end up having to rely on hooks
    like `after_create` to do additional processing.

The way that `ActiveRecord` works is pretty desirable for a smaller application,
but as the project & teams grow, the more we fall into usage patterns which can
make things harder to maintain.

This library is a proof-of-concept of what it might look like to introduce
a layer in front of the data model, giving developers tighter control over
how their objects are used.

## Usage

To create a model, instead of subclassing directly from `ApplicationRecord`,
you should subclass from `ProxyRecord[ApplicationRecord]`. Additional
validations and associations can be defined inside of a `data_model_eval` block
like this:

``` ruby
class User < ProxyRecord[ApplicationRecord]
  data_model_eval do
    validates :name, presence: true
    has_many :posts, foreign_key: 'user_id', class_name: 'Post::DataModel'
  end
end
```

This new class, `User` doesn't come with any methods by default, which means
when you want to provide access to underlying data model methods, you need
to create them yourself. You can access the underlying data model via the
`data_model` local.

``` ruby
class User < ProxyRecord[ApplicationRecord]
  # ...

  def display_name
    "#{data_model.name} (#{data_model.login})
  end
end
```

You can also define class methods, and access the underlying data model class
via `data_model_class` like so:

``` ruby
class User < ProxyRecord[ApplicationRecord]
  # ...

  def self.recent_user_count
    data_model_class.where('accessed_at > ?', 1.hour.ago).count
  end
end
```

### Wrapping objects

Sometimes you'll need to be able to return an `ActiveRecord` object, and in
those cases you'll want to wrap with the appropriate `ProxyRecord` class. For
that you can use `ProxyRecord.wrap`:

``` ruby
class User < ProxyRecord[ApplicationRecord]
  # ...

  def create_post(title:)
    post_data_model = data_model.posts.create(title: title)
    ProxyRecord.wrap(post_data_model) # Returns a `Post`
  end
end
```

### Delegates

You'll often want to be able to create direct delegates for underlying methods,
and to reduce the tedious nature of delegating and potentially wrapping
the response, you can use `class_proxy_delegate` and `instance_proxy_delegate`
to automatically wrap delegated methods:

``` ruby
class User < ProxyRecord[ApplicationRecord]
  # ..

  class_proxy_delegate :create

  instance_proxy_delegate :login, :posts
end

user = User.create # Returns a User, subclass of ProxyRecord::Proxy
user.login
user.posts # Returns a ProxyRecord::ProxyCollection[Post]
```
