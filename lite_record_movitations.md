I've been experimenting within this repository with new ways to define and
interact with `ActiveRecord` models that allow for more isolation (for more
details on this, please see `README.md`).

# First attempt: `ProxyRecord`

I started out by making this library, and the core idea is that we want to
be able to give developers more control over how their classes are used
throughout their application. Proxy record does this by defining a clean
class and hiding all of the data model implementation details inside of
locals. So instead of a regular `ActiveRecord` model, you'd make something
like:

``` ruby
class User < ProxyRecord[ApplicationRecord]
  def self.by_login(login)
    ar_model = data_model_class.find_by_login(login)
    ProxyRecord.wrap(ar_model)
  end
end

User.first # NoMethodError
User.by_login('john') # => User instance
```

The benefit of this approach is it's really clean. It keeps the data model
totally separate of the application model and any calls between the two
need to be explicit actions by the developer. Yay!

The downside is that it's really easy to make a mistake and export one of the
inner data classes by missing the call to `wrap`, thus kinda reinventing the
same problem we were trying to avoid. When these data models do leak, they are
especially hard to detect because the use of one could be something as simple
as a method returning the result of a private call to `where`.

Another downside arguably is that pretty much every one of the methods defined
on these application models is going to need to touch the data model classes
and that's just a lot of calls to the same underlying object. There are some
pretty tricky ways to avoid this but they all involve `method_missing` and
a series of kinda unfortunate trade-offs.

# Second attempt: private methods

Pretty much from the beginning I've been saying to myself "hey self, I wish
we could just take all of those AR public methods and make them private!"

The benefit of this approach is that we could make an ActiveRecord object
that's a straightforward drop-in replacement for existing AR::Base subclasses.
This would mean it would be really easy for applications to change between
the two and migrate onto these other classes.

We'd also be able to solve the data leaking problem above, because since in
`ActiveRecord` the data and application models are the same thing, there's
essentially nothing to leak. Other parts of the code can get handles on
objects, but since the methods are private they won't be able to do anything
with them they shouldn't be able to anyway.

So I went and implemented a really hacky version of this and I noticed two
problems:

- `ActiveRecord::Relation` exposes a ton of surface area inside of
  `ActiveRecord` and we essentially can't make that surface area private
  because if we did even the classes that had generated the relation
  wouldn't be able to access the methods on it.

- The implementation in Rails gets very bad very quickly. So much of Rails
  relies on these methods being public and uses them as such.

# Third (this) attempt: LiteRecord

So after spending a few nights hacking on private methods, I got _really_
excited about the results in my sample applications. The library was able
to drop in and replace `AR::Base` and pointed me directly to a bunch of places
I was reaching into models I definitely should not have been. I was hooked!

I really liked the benefits of the clean classes in `ProxyRecord`, and I
liked the ergonomics and privacy-related guarantees of the private method
approach. Then I started thinking, what if I combined the two and
implemented a light drop-in version of `ActiveRecord` implemented _in terms
of_ `ProxyRecord`.

The benefits here are that, if we designed it correctly, we could make classes
that behave just like `AR::Base` subclasses, have none of the extra methods
we don't want, AND we can guard against the cases where `AR::Relation` gives
too much access by just replacing it with another collection class. Turns out
we already have one here in the form of `ProxyRecord::Collection`.

After spending a night hacking on this I fell in love with the idea. The
changes here represent a relative formalization of the concepts I built on my
first pass.

# Usage

``` ruby
class User < ProxyRecord[ApplicationRecord]
  # by default ProxyRecord subclasses have pretty much no methods, LiteRecord
  # adds them back with our own definitions that mask the details of AR
  include LiteRecord

  def self.create_with_login(login)
    # Despite no call to ProxyRecord.wrap, this returns a User not an AR::Base
    # subclass. The `create!` we're calling here is actually the `LiteRecord`
    # definition of create, which calls and wraps the original.
    create!(login: login)
  end

  def salutation
    # Here we're caling a private method `login` which is a private form of
    # the AR::Base attribute method for the same
    "hello #{login}"
  end
end

User.create! # NoMethodError (private)
user = User.create_with_login('john') => # User

user.login # NoMethodError (private)
user.salutation # => "hello john"
```
