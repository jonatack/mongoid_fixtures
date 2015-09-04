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

1.  Create a class that has Mongoid::Document as a mixin.
    For example:    
    
        class City # should be in single form      
          include Mongoid::Document    
          field :population, type: Integer
          field :demonym, type: String
          field :settled, type: Integer
          field :consolidated, type: Integer
          field :population, type: Integer
          field :custom_attributes, type: Array
          field :state, type: String
        end
2.  Define a fixtures yml in /test/fixtures/ with a plural form of the class
    For example /test/fixtures/cities.yml:    
    
        :new_york_city:
          population: 9_000_000
          demonym: New Yorker
          settled: 1624
          consolidated: 1989
          custom_attributes:
            - boroughs: ['Manhattan', 'The Bronx', 'Brooklyn', 'Queens', 'Staten Island']
          state: New York
        :terrytown:
          state: Lousiana
          population: 24_000

    This library also supports nested attributes. Document on that will be provided when I get some time.
    
3.  Invoke `MongoidFixtures::load(City)`
4.  The above method invocation will load all test fixture instances of City objects defined in /test/fixtures/cities.yml
5.  Use your fixtures!

        cities = MongoidFixtures::load(City)
        puts cities # returns {
                    #     :new_york_city=>#<City _id: 55e920cde13823757a000000, 
                    #     population: 9000000, demonym: "New Yorker", settled: 1624, 
                    #     consolidated: 1989, custom_attributes:  
                    #     [{"boroughs"=>["Manhattan", "The Bronx",
                    #     "Brooklyn", "Queens", "Staten Island"]}], 
                    #      state: "New York">, :terrytown=>#<City _id: 55e920cde13823757a000001, 
                    #     population: 24000, demonym: nil, 
                    #     settled: nil, consolidated: nil,
                    #     custom_attributes: nil, state: "Lousiana">
                    #}



## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nycjv321/mongoid_fixtures.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

