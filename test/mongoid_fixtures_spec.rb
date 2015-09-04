require_relative '../lib/mongoid_fixtures'
require 'mongoid'

Mongoid.load!("#{File.dirname(__FILE__)}/../config/mongoid.yml", :development)

class TestClass
  include Mongoid::Document

  field :a, type: String
  field :b, type: String
end

MongoidFixtures::load TestClass