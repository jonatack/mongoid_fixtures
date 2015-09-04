require_relative '../lib/mongoid_fixtures'
require 'mongoid'
require 'rspec'

Mongoid.load!("#{File.dirname(__FILE__)}/../config.yml", :development)

class City
  include Mongoid::Document

  field :population, type: Integer
  field :demonym, type: String
  field :settled, type: Integer
  field :consolidated, type: Integer
  field :population, type: Integer
  field :custom_attributes, type: Array
  field :state, type: String

end


describe MongoidFixtures do
  describe '::load' do
    it 'loads fixtures into the db and returns a hash of the fixtures' do
      MongoidFixtures::load(City).should_not be_nil
    end
  end
end