require 'spec_helper'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String :first_name
  String :last_name
end

describe "Example repository" do
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

  let(:repository) { UsersRepository.new }

  let(:user) { User.new(first_name: 'John',
                        last_name: 'Smith') }

  it "saves and finds an object" do
    repository.put(user)

    found_user = repository.find(user.id)

    expect(found_user.id).to eq(user.id)
    expect(found_user.first_name).to eq('John')
    expect(found_user.last_name).to eq('Smith')
  end

  it "updates an object" do
    repository.put(user)
    user.change_first_name('Bill')

    repository.update(user)

    found_user = repository.find(user.id)
    expect(found_user.first_name).to eq('Bill')
    expect(found_user.last_name).to eq('Smith')
  end

  it "deletes an object" do
    repository.put(user)

    repository.delete(user)
    found_user = repository.find(user.id)
    expect(found_user).to eq(nil)
  end
end
