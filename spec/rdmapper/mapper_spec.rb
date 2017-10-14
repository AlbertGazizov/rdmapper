require 'spec_helper'

describe Rdmapper::Mapper do
  class Person
    attr_reader :first_name, :last_name

    def initialize(first_name:, last_name:)
      @first_name = first_name
      @last_name  = last_name
    end

    def change_first_name(first_name)
      @first_name = first_name
    end
  end

  class Mapper
    include Rdmapper::Mapper

    def build_object(hash)
      Person.allocate.tap do |p|
        p.instance_variable_set(:@first_name, hash[:first_name])
        p.instance_variable_set(:@last_name, hash[:last_name])
      end
    end

    def build_hash(object)
      { first_name: object.first_name,
        last_name: object.last_name }
    end
  end

  let(:mapper) { Mapper.new }

  it "converts hash to object" do
    hash = { first_name: 'John',
             last_name: 'Smith' }

    object = mapper.to_object hash

    expect(object.first_name).to eq 'John'
    expect(object.last_name).to eq 'Smith'
  end

  it "converts object to hash" do
    object = Person.new first_name: 'John',
                        last_name: 'Smith'

    hash = mapper.to_hash object

    expect(hash).to eq(first_name: 'John',
                       last_name: 'Smith')
  end

  it "returns hash with updated attributes" do
    hash = { first_name: 'John',
             last_name: 'Smith' }

    object = mapper.to_object hash

    object.change_first_name('Bill')

    hash = mapper.to_hash object

    expect(hash).to eq(first_name: 'Bill')
  end
end
