require_relative '../lib/mongoid_fixtures/version'
require 'yaml'
require 'singleton'
require 'linguistics'

module MongoidFixtures

  class Loader
    include Singleton

    attr_accessor :fixtures, :path

    def initialize
      @fixtures = {}
    end

    def self.load
      fix = MongoidFixtures::Loader.instance
      fixture_names = Dir[File.join(File.expand_path('../..', __FILE__), "#{path}/*.yml")]

      fixture_names.each do |fixture|
        fix.fixtures[File.basename(fixture, '.*')] = YAML.load_file(fixture)
      end
      fix
    end

    def self.path=(var)
      Loader.instance.path = var
    end

    def self.path
      Loader.instance.path
    end
  end

  Linguistics.use(:en)
  Loader::path = 'test/fixtures'
  Loader::load

  def self.load(clazz)
    fixture_instances = Loader.instance.fixtures[clazz.to_s.downcase.en.plural] # get class name
    instances = {}
    if fixture_instances.nil?
      raise "Could not find instances for #{clazz}"
    end
    fixture_instances.each do |key, fixture_instance|
      instance = clazz.new
      fields = fixture_instance.keys
      fields.each do |field|

        value = fixture_instance[field]
        field_label = field.to_s.capitalize
        field_clazz = resolve_class_ignore_plurality(field_label)

        # If the current value is a symbol then it respresents another fixture.
        # Find it and store its id
        if value.is_a? Symbol or value.nil?
          relations = instance.relations
          if relations.include? field
            if relations[field].relation.eql? Mongoid::Relations::Referenced::In or relations[field].relation.eql? Mongoid::Relations::Referenced::One
              instance.send("#{field}=", self.load(field_clazz)[value])
            else
              # instance[field] = self.load(field_clazz)[value].id # embedded fields?
              raise "#{instance} relationship not defined: #{relations[field].relation}"
            end
          else
            raise 'Symbol doesn\'t reference relationship'
          end

          # If the current value is an array find each fixture_instance and get its document to serialize
          # This approach (should) assume nested documents. This will be addressed in later versions
        elsif value.is_a? Array
          values = []
          value.each do |v|
            if field_clazz.nil?
              values << v
            else
              values << self.load(field_clazz)[v].as_document
            end
          end
          instance[field] = values
        elsif value.is_a? Hash
          # take hash convert it to object and serialize it
          embedded_object = field_clazz.new
          value.each do |key, value|
            embedded_object.send("#{key}=", value)
          end
          embedded_object.geopolitical_division = instance
          instance[field] = value
        # else just set the field
        else
          instance[field] = value
        end
      end


      instance = create_or_save_instance(instance)
      instances[key] = instance # store it based on its key name
    end
    instances
  end

  def self.insert_embedded_ids(instance)
    attributes = instance.attributes.select { |key, value| !key.to_s.eql?('_id') }

    attributes.each do |key, value|
      if attributes[key].is_a? Hash
        unless instance.send(key)._id.nil?
          attributes[key]['_id'] = instance.send(key)._id
        end
      else
        attributes[key] = value
      end
    end
    attributes
  end

  def self.flatten_attributes(attributes)
    flattened_attributes = {}
    attributes.each do |key, values|
      if values.is_a? Hash
        values.each do |value, inner_value|
          flattened_attributes["#{key}.#{value}"] = inner_value
        end
      else
        flattened_attributes[key] = values
      end
    end
    flattened_attributes
  end

  def self.create_or_save_instance(instance)
    attributes = instance.attributes.select { |key, value| !key.to_s.eql?('_id') }
    flattened_attributes = flatten_attributes(attributes)
    if instance.class.where(flattened_attributes).exists?
      instance = instance.class.where(flattened_attributes).first
    else
      insert_embedded_ids(instance)
      instance.save! # auto serialize the document
    end
    instance
  end

  def self.resolve_class_ignore_plurality(class_name)
    class_name = class_name.split('_').map(&:capitalize).join('')
    if class_exists?(class_name) then
      Kernel.const_get(class_name)
    else
      if class_exists?(class_name[0, (class_name.size - 1)]) then
        Kernel.const_get(class_name[0, (class_name.size - 1)])
      else
        nil
      end
    end
  end

  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
  rescue NameError
    return false
  end

end
