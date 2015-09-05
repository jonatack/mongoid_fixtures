# MongoidFixtures
Fixtures for Ruby without Rails for Mongoid.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_fixtures'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_fixtures

## Example Usage

1.  Define some Mongoid Documents

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

2.  Definefixtures  in /test/fixtures/ with a plural form of the class

    /test/fixtures/cities.yml:    
    
        :new_york_city:
          name: New York City
          :population:
            total: 9_000_000
            rank: 1
            density: 10,756.0/km2
            msa: 20,092,883
            csa: 23,632,722
            source: U.S. Census (2014)
          demonym: New Yorker
          settled: 1624
          consolidated: 1989
          custom_attributes:
            - boroughs: ['Manhattan', 'The Bronx', 'Brooklyn', 'Queens', 'Staten Island']
          state: :new_york
          geo_uri_scheme: :new_york_city
        :terrytown:
          name: Terrytown
          state: :louisiana
          :population:
            total: 24_000
          geo_uri_scheme: :terrytown

    /test/fixtures/states.yml:   
        
        :new_york:
          name: New York
          :population:
            total: 20_000_000
          demonym: New Yorker
          capital: Albany
          motto: Excelsior
          admission_to_union: July 26th, 1788
          time_zone: "Eastern: UTC -5/-4"
        :louisiana:
          name: Louisiana
          :population:
            total: 4_700_000
          demonym: Louisianian
          capital: Baton Rouge
          motto: Union, Justice, Confidence
          admission_to_union: April 30th, 1812
          time_zone: "Central: UTC −6/−5"


    /test/fixtures/geourischemes.yml

        :terrytown:
          x: -90.029444
          y: 29.902222
          z: 3.9624
        :new_york_city:
          x: -74.0059
          y: 40.7127
          z: 0.6096
            

    You may notice attributes that represent relationships are automatically converted to
    the corresponding ruby objects based on the provided id. Currently, this library supports
    1-N referenced, 1-1 referenced, and  1-1 embedded relationships. Later versions will
    support 1-N embedded relationships.
    
3.  Invoke `MongoidFixtures::load(City)`
4.  The above method invocation will load all test fixture instances of City objects defined
    in /test/fixtures/cities.yml as well as dependent objects
5.  Use your fixtures!

        cities = MongoidFixtures::load(City)
        puts cities # {:new_york_city=>#<City _id: 55eb5cb8e1382316ac000004, name: "New York City", time_zone: nil, demonym: "New Yorker", settled: 1624, consolidated: 1989, custom_attributes: [{"boroughs"=>["Manhattan", "The Bronx", "Brooklyn", "Queens", "Staten Island"]}], geo_uri_scheme_id: BSON::ObjectId('55eb5cb8e1382316ac000006'), _type: "City", state_id: BSON::ObjectId('55eb5cb8e1382316ac000000')>, :terrytown=>#<City _id: 55eb5cb8e1382316ac00000a, name: "Terrytown", time_zone: nil, demonym: nil, settled: nil, consolidated: nil, custom_attributes: nil, geo_uri_scheme_id: BSON::ObjectId('55eb5cb8e1382316ac000005'), _type: "City", state_id: BSON::ObjectId('55eb5cb8e1382316ac000002')>}

    In the DB:
      
        /* 0 */
        {
            "_id" : ObjectId("55eb4adae1382309c5000003"),
            "x" : -90.029444,
            "y" : 29.902222,
            "z" : 3.9624
        }

        /* 1 */
        {
            "_id" : ObjectId("55eb4adae1382309c5000004"),
            "x" : -74.0059,
            "y" : 40.7127,
            "z" : 0.6096
        }

        /* 0 */
        {
            "_id" : ObjectId("55eb5cb8e1382316ac000000"),
            "_type" : "State",
            "name" : "New York",
            "population" : {
                "_id" : ObjectId("55eb5cb8e1382316ac000001"),
                "total" : 20000000
            },
            "demonym" : "New Yorker",
            "capital" : "Albany",
            "motto" : "Excelsior",
            "admission_to_union" : "July 26th, 1788",
            "time_zone" : "Eastern: UTC -5/-4"
        }

        /* 1 */
        {
            "_id" : ObjectId("55eb5cb8e1382316ac000002"),
            "_type" : "State",
            "name" : "Louisiana",
            "population" : {
                "_id" : ObjectId("55eb5cb8e1382316ac000003"),
                "total" : 4700000
            },
            "demonym" : "Louisianian",
            "capital" : "Baton Rouge",
            "motto" : "Union, Justice, Confidence",
            "admission_to_union" : "April 30th, 1812",
            "time_zone" : "Central: UTC −6/−5"
        }

        /* 2 */
        {
            "_id" : ObjectId("55eb5cb8e1382316ac000004"),
            "_type" : "City",
            "name" : "New York City",
            "population" : {
                "_id" : ObjectId("55eb5cb8e1382316ac000007"),
                "total" : 9000000,
                "rank" : 1,
                "density" : "10,756.0/km2",
                "msa" : 20092883,
                "csa" : 23632722,
                "source" : "U.S. Census (2014)"
            },
            "demonym" : "New Yorker",
            "settled" : 1624,
            "consolidated" : 1989,
            "custom_attributes" : [
                {
                    "boroughs" : [
                        "Manhattan",
                        "The Bronx",
                        "Brooklyn",
                        "Queens",
                        "Staten Island"
                    ]
                }
            ],
            "state_id" : ObjectId("55eb5cb8e1382316ac000000"),
            "geo_uri_scheme_id" : ObjectId("55eb5cb8e1382316ac000006")
        }

        /* 3 */
        {
            "_id" : ObjectId("55eb5cb8e1382316ac00000a"),
            "_type" : "City",
            "name" : "Terrytown",
            "state_id" : ObjectId("55eb5cb8e1382316ac000002"),
            "population" : {
                "_id" : ObjectId("55eb5cb8e1382316ac00000b"),
                "total" : 24000
            },
            "geo_uri_scheme_id" : ObjectId("55eb5cb8e1382316ac000005")
        }


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nycjv321/mongoid_fixtures.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

