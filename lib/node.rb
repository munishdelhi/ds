class Node
  PROPERTIES = %i(key color discover finish)
  COLORS = %i(white gray black)

  attr_reader *PROPERTIES

  # Hash with each key-value pair representing a child
  attr_reader :children  

  def self.hash_to_node(hash)
    node = self.new
    hash.keys do |key|
      node.public_send(key.to_s.to_sym, hash[key])  # if PROPERTIES.include? key.to_s.to_sym
    end
  end

  def initialize(*args)
    args.each_index do |index|
      self.public_send(PROPERTIES[index], args[index])
    end

    self.children = {}
  end

  def add_child(child_key, edge_length)
    child_key = child_key.to_s.to_sym
    edge_length = edge_length.to_i

    raise "Child node with same key already exists" if self.children[child_key].blank?
    self.children[child_key] = {:length => edge_length}

    children.last
  end

  def key(key)
    key = key.to_s.to_sym
    self[:key] = key
  end

  def color(value)
    value = value.to_s.to_sym
    if COLORS.include? value
      self[:color] = value
    else
      raise "Incorrect Color Value"
    end
  end

  def discover(value)
    value = value.to_i
    self[:discover] = value
  end

  def finish(value)
    value = value.to_i
    self[:finish] = value
  end

  # Example: {:key => :A, :color => :white, :discover => 0, :finish => 0, :children => {:B => {:length => 5}, :C => {:length => 15}}
  def to_hash
    node = {}
    PROPERTIES.each_index do |index|
      node[PROPERTIES[index]] = self.public_send(PROPERTIES[index])
    end

    children.each_key do |key|
      node[:children][key] = children[key]
    end

    node
  end
end

