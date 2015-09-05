# MongoidFixtures
Fixtures for Ruby without Rails for Mongoid.

There are only two dependencies: 'linguistics' to provide plurality conversion and mongoid for obvious reasons


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid_fixtures'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_fixtures

## Usage

1.  Create a class or classes that have Mongoid::Document defined as a mixin.
    For example:    
    
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

2.  Define a fixtures yml in /test/fixtures/ with a plural form of the class
    For example /test/fixtures/cities.yml:    
    
        :new_york_city:
          name: New York City
          population: 9_000_000
          demonym: New Yorker
          settled: 1624
          consolidated: 1989
          custom_attributes:
            - boroughs: ['Manhattan', 'The Bronx', 'Brooklyn', 'Queens', 'Staten Island']
          state: :new_york
        :terrytown:
          name: Terrytown
          state: :louisiana
          population: 24_000

    and /test/fixtures/states.yml:   
        
        :new_york:
          name: New York
          population: 20_000_000
          demonym: New Yorker
          capital: Albany
          motto: Excelsior
          admission_to_union: July 26th, 1788
          time_zone: "Eastern: UTC -5/-4"
        :louisiana:
          name: Louisiana
          population: 4_700_000
          demonym: Louisianian
          capital: Baton Rouge
          motto: Union, Justice, Confidence
          admission_to_union: April 30th, 1812
          time_zone: "Central: UTC −6/−5"
            

    You may notice that referred attributes are automatically referenced for you. 
    This allows you to effortlessly maintain object references in yml and transfer 
    them to a db.  Currently, this library only supports 1-n referenced relationships. 
    Later versions will support other relationships (e.g. 1-1 embedded and 1-n embedded)
    
3.  Invoke `MongoidFixtures::load(City)`
4.  The above method invocation will load all test fixture instances of City objects defined in /test/fixtures/cities.yml
5.  Use your fixtures!

        cities = MongoidFixtures::load(City)
        puts cities # returns {
                    #:new_york_city=>#<City _id: 55ea7bb6b943cdcc3ab4aed4, name:
                    # "New York City", population: 9000000, time_zone: nil
                    # , demonym: "New Yorker", settled: 1624, 
                    # consolidated: 1989, custom_attributes: 
                    # [{"boroughs"=>["Manhattan", "The Bronx", "Brooklyn", 
                    # "Queens", "Staten Island"]}], _type: "City", 
                    # state_id: BSON::ObjectId('55ea7bb5b943cdcc3ab4aed2')>, 
                    # :terrytown=>#<City _id: 55ea7bb6b943cdcc3ab4aed5, 
                    # name: "Terrytown", population: 24000, 
                    # time_zone: nil, demonym: nil, settled: nil, consolidated: nil, 
                    # custom_attributes: nil, _type: "City", 
                    # state_id: BSON::ObjectId('55ea7bb5b943cdcc3ab4aed3')>
                    # }
    
    In the DB:
      
        /* 0 */
        {
            "_id" : ObjectId("55ea7bb6b943cdcc3ab4aed4"),
            "_type" : "City",
            "name" : "New York City",
            "population" : 9000000,
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
            "state_id" : ObjectId("55ea7bb5b943cdcc3ab4aed2")
        }
        
        /* 1 */
        {
            "_id" : ObjectId("55ea7bb6b943cdcc3ab4aed5"),
            "_type" : "City",
            "name" : "Terrytown",
            "state_id" : ObjectId("55ea7bb5b943cdcc3ab4aed3"),
            "population" : 24000
        }


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nycjv321/mongoid_fixtures.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

