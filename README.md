# Rdmapper [![Build Status](https://travis-ci.org/AlbertGazizov/rdmapper.png)](https://travis-ci.org/AlbertGazizov/rdmapper)


Rdmapper is a library for implementing the Mapper in the DataMapper pattern on Ruby

### Usage

Let's say you have a User object:
```ruby
  class User
    attr_reader :id, :first_name, :last_name

    def initialize(first_name:, last_name:)
      @first_name = first_name
      @last_name  = last_name
    end

    def change_first_name(first_name)
      @first_name = first_name
    end
  end
```


Create mapper class and declare two build_object and build_hash methods:
```ruby
class UserMapper
  include Rdmapper::Mapper

  def build_object(hash)
    User.allocate.tap do |p|
      p.instance_variable_set(:@id, hash[:id])
      p.instance_variable_set(:@first_name, hash[:first_name])
      p.instance_variable_set(:@last_name, hash[:last_name])
    end
  end

  def build_hash(object)
    { first_name: object.first_name,
      last_name: object.last_name }
  end
end
```

Now use this mapper in your Repository class to map entity to hash and vise versa:
```ruby
  class UsersRepository
    def initialize(db = DB, mapper = UserMapper.new)
      @mapper = mapper
      @db = db
    end

    def put(user)
      hash = @mapper.to_hash(user)
      id = @db[:users].insert(hash)
      user.instance_variable_set(:@id, id)
      user
    end

    def find(id)
      hash = @db[:users].where(id: id).first
      return nil unless hash
      @mapper.to_object hash
    end

    def update(user)
      hash = @mapper.to_hash(user)
      @db[:users].where(id: user.id).update(hash)
      user
    end

    def delete(user)
      @db[:users].where(id: user.id).delete
    end
  end
```
Note that DB is an Sequel object which provides convenient interface for accessing the database. For full example see repository_example_spec.rb


## Author
Albert Gazizov, [@deeper4k](https://twitter.com/deeper4k)