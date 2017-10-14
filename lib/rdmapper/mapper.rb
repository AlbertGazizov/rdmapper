module Rdmapper::Mapper
  STATE_FIELD = :@rdmapper_original_hash

  def to_object(hash)
    object = build_object(hash)
    object.instance_variable_set(STATE_FIELD, hash)
    object
  end

  def to_hash(object)
    hash = build_hash(object)

    return hash unless object.instance_variable_defined?(STATE_FIELD)

    original_hash = object.instance_variable_get(STATE_FIELD)
    select_changes(original_hash, hash)
  end

  private

  def build_object(hash)
    raise NotImplementedError, 'build_object should be defined in derived class'
  end

  def build_hash(hash)
    raise NotImplementedError, 'build_hash should be defined in derived class'
  end

  def select_changes(original_hash, new_hash)
    changes_hash = {}
    new_hash.each do |column, value|
      previous_value = original_hash[column]
      if original_hash.has_key?(column) && value_changed?(previous_value, value)
        changes_hash[column] = value
      end
    end
    changes_hash
  end

  def value_changed?(prev_value, new_value)
    prev_value != new_value
  end
end
