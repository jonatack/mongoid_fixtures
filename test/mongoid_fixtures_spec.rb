require_relative '../lib/mongoid_fixtures'
require 'mongoid'
require 'rspec'

Mongoid.load!(File.join(File.expand_path('../..', __FILE__), "/config.yml"), :development)

class GeopoliticalDivision
  include Mongoid::Document
  field :name, type: String
  field :population, type: Integer
  field :time_zone, type: String
  field :demonym, type: String
  field :settled, type: Integer
  field :consolidated, type: Integer
  field :population, type: Integer
  field :custom_attributes, type: Array
end

class City < GeopoliticalDivision
  include Mongoid::Document
  belongs_to :state
end

class State
  include Mongoid::Document

  field :motto, type: String
  field :admission_to_union, type: String

  has_many :cities

end

describe MongoidFixtures do
  describe '::load' do
    it 'loads fixtures into the db and returns a hash of the fixtures' do
      MongoidFixtures::load(State).should_not be_nil
      MongoidFixtures::load(City).should_not be_nil
    end
  end
end