require_relative '../lib/mongoid_fixtures/version'
require 'yaml'
require 'singleton'
require 'linguistics'

module MongoidFixtures
  class Loader
    include Singleton

    attr_accessor :fixtures

    def initialize
      @fixtures = {}
    end

    def self.load
      fix = MongoidFixtures::Loader.instance
      fixture_names = Dir[File.join(File.dirname(__FILE__), '../config/fixtures/*.yml')]

      fixture_names.each do |fixture|
        fix.fixtures[File.basename(fixture, '.*')] = YAML.load_file(fixture)
      end
      fix
    end

  end

  Linguistics.use( :en )
  Loader::load

  def self.load(clazz)
    instances = Loader.instance.fixtures[clazz.to_s.downcase.en.plural] # get class name
    posts = {}
    instances.each do |key, instance|
      post = clazz.new
      fields = instance.keys
      fields.each do |field|

        value = instance[field]
        field_label = field.to_s.capitalize
        clazz = if class_exists?(field_label) then
                  Kernel.const_get(field_label)
                else
                  if class_exists?(field_label[0, (field_label.size - 1)]) then
                    Kernel.const_get(field_label[0, (field_label.size - 1)])
                  else
                    nil
                  end
                end

        if value.is_a? Symbol
          post[field] = clazz.load(Loader.instance.fixtures([field.en.plural]))[value].id
        elsif value.is_a? Array
          values = []
          value.each do |v|
            if clazz.nil?
              values << v
            else
              values << clazz.load(Loader.instance.fixtures([field]))[v].as_document
            end
          end
          post[field] = values
        else
          post[field] = value
        end
      end
      post.save!
      posts[key] = post
    end
    posts
  end

  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
  rescue NameError
    return false
  end

end
