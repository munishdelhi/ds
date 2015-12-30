# The Path is an Array but its elements are of the form:
# {:from => :A, :to => :B, :length => 20}
# So, we define Path as subclass of Array with some additional methods
# Inherited Array methods are used as-it-is unless we require some specialized behavior
class Path < Array

  PATH_CONNECTOR = "-"

  # singleton methods
  def self.new_path_element(from, to, length = 1)
    {:from => from, :to => to, :length => length}
  end

  # Note: As Path is subclass of Array, this method is not required
  def self.element_from(element)
    element[:from]
  end
  
  # Note: As Path is subclass of Array, this method is not required
  def self.element_to(element)
    element[:to]
  end

  # Note: As Path is subclass of Array, this method is not required
  def self.element_length(element)
    element[:length]
  end

  # returns {:from => :A, :to => :B, :length => :5} from AB5
  def self.text_to_path_element(str, options = {})
    str.strip!

    from_size = options[:from_size] || 1
    to_size = options[:to_size] || 1
    length_size = options[:length_size] || 1

    # extract elements
    from = str[0, from_size]
    to = str[from_size, to_size]
    length = str[from_size + to_size, length_size]
    # make default length as 1
    if length == ""
      length = 1
    end

    {:from => from.to_sym, :to => to.to_sym, :length => length.to_i}
  end

  # returns AB5 from {:from => :A, :to => :B, :length => :5}
  def self.path_element_to_text(path_element)
    %Q(#{path_element[:from].to_s}#{path_element[:to].to_s}#{path_element[:length].to_s})
  end

  def self.display_paths(set_of_paths = Marshal.load(Marshal.dump self.latest_paths))
    paths = []
    set_of_paths.each do |individual_path|
      path_text = individual_path.to_text
      paths << path_text
    end

    paths
  end

  # Sort paths, array of Path objects, in ASC order
  # It doesn't modify the passed object
  def self.sort_paths(paths)
    paths = paths.sort do |x, y|
      x.path_length <=> y.path_length
    end
  end

  # instance methods

  # Calculate length of given path, based on length of each edge
  # path is an object of Path class
  def path_length
    path = self
    distance = 0
    path.each do |elem|
      distance += elem[:length]
    end

    distance
  end

  def to_text
    path = [] # textual form of Path
    self.each do |elem|
      elem_text = Path.path_element_to_text(elem)
      path << elem_text
    end

    path.join(PATH_CONNECTOR)
  end
end

