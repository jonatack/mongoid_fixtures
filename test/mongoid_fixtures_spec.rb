require_relative '../lib/mongoid_fixtures'
require 'mongoid'
require 'rspec'

Mongoid.load!(File.join(File.expand_path('../..', __FILE__), "/config.yml"), :development)

class GeopoliticalDivision
  include Mongoid::Document
  field :name, type: String
  field :time_zone, type: String
  field :demonym, type: String
  field :settled, type: Integer
  field :consolidated, type: Integer
  field :custom_attributes, type: Array
  belongs_to :geo_uri_scheme
  embeds_one :population
end

class Population
  include Mongoid::Document

  field :total, type: Integer
  field :rank, type: Integer
  field :density, type: String
  field :msa, type: Integer
  field :csa, type: Integer
  field :source, type: String
  embedded_in :geopolitical_division

end

class City < GeopoliticalDivision
  include Mongoid::Document
  belongs_to :state
end

class State < GeopoliticalDivision
  include Mongoid::Document

  field :motto, type: String
  field :admission_to_union, type: String

  has_many :cities

end

class GeoUriScheme
  include Mongoid::Document

  field :x, type: Float
  field :y, type: Float
  field :z, type: Float

  alias :longitude :x
  alias :latitude :y
  alias :altitude :z
end

describe MongoidFixtures do
  describe '::load' do
    it 'loads fixtures into the db and returns a hash of the fixtures' do
      MongoidFixtures::load(State).should_not be_nil
    end
  end

  describe '::load(City)' do
    it 'loads City fixture data into the db and returns a hash of all cities' do
      cities = MongoidFixtures::load(City)
      cities.should_not be_nil
      new_york_city = cities[:new_york_city]
      new_york_city.should_not be_nil
      new_york_city.state.should be_a State
      new_york_city.geo_uri_scheme.should be_a GeoUriScheme
      new_york_city.population.should be_a Population
      population = new_york_city.population
      population.total.should eq 9000000
      population.rank.should eq 1
      population.density.should eq '10,756.0/km2'
      population.msa.should eq  20092883
      population.csa.should eq  23632722
      population.source.should eq  'U.S. Census (2014)'


      terrytown = cities[:terrytown]
      terrytown.should_not be_nil
      terrytown.state.should be_a State
      terrytown.geo_uri_scheme.should be_a GeoUriScheme

    end
  end

  describe '::load(GeoURIScheme)' do
    it 'loads GeoURIScheme fixture data into the db and returns a hash of all GeoUriSchemes' do
      MongoidFixtures::load(GeoUriScheme)
      MongoidFixtures::load(GeoUriScheme).should_not be_nil
      terrytown = MongoidFixtures::load(GeoUriScheme)[:terrytown]
      terrytown._id.should_not be_nil

      terrytown.x.should eq(-90.029444)
      terrytown.y.should eq(29.902222)
      terrytown.z.should eq(3.9624)
    end
  end
end