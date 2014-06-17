require_relative '03_searchable'
require 'active_support/inflector'
require 'debugger'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    @class_name.constantize
  end

  def table_name
    # ...
    @class_name.constantize.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :class_name => name.to_s.camelcase,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :class_name => name.to_s.singularize.camelcase,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  # Phase IVb
  
  # belongs_to(
  # :user, 
  # class_name: 'User',
  # foreign_key: :user_id,
  # primary_key: :id
  # )
    
  def belongs_to(name, options = {})
    local_options = BelongsToOptions.new(name, options)
    define_method(name) do 
      #local_options = BelongsToOptions.new(name, options)
      
      #save belongs in assoc_options hash
      #@assoc_options[name] = options
      
      key_val = self.send(local_options.foreign_key)
      local_options
        .model_class
        .where(local_options.primary_key => key_val)
        .first
    end
    self.assoc_options[name] = local_options
  end
  
  # has_many(
    # :cats,
    # class_name: 'Cat',
    # foreign_key: :owner_id,
    # primary_key: :id
  # )

  def has_many(name, options = {})
    self_class_name = self.name
    local_options = HasManyOptions.new(name, self_class_name, options)
    define_method(name) do
      key_val = self.send(local_options.primary_key)
      local_options
        .model_class
        .where(local_options.foreign_key => key_val)
    end
    self.assoc_options[name] = local_options
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
