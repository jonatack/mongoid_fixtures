module EmbedUtils
  def self.create_embedded_instance(clazz, hash, instance)
    embed = clazz.new
    hash.each do |key, value|
      embed.send("#{key}=", value)
    end
    embed.send("#{find_embed_parent_class(embed)}=", instance)
    embed
  end

  def self.find_embed_parent_class(embed)
    relations = embed.relations

    relations.each do |name, relation|
      if relation.relation.eql? Mongoid::Relations::Embedded::In
        return name
      end
    end
    raise 'Unable to find parent class'
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
end