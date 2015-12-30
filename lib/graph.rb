require_relative 'path'

class Graph
  attr_accessor :text, :data, :latest_paths, :latest_paths_root

  def initialize(txt)
    # puts "Input Nodes: #{txt}"

    # set instance variables
    @text = txt
    @data = {}
    @latest_paths = nil
    @latest_paths_root = nil

    # construct graph and set it in @data
    construct_graph_data_from_text
  end
 
  # Calculate route length, based on length of each edge
  # Input: "A-E-C-B"
  def route_length(txt_route)
    distance = 0
    route = txt_route.split(Path::PATH_CONNECTOR)
    route.map! { |node| node.to_sym }
    route.each_index do |index|
      if index <= (route.length - 2)
       from = route[index]
       to = route[index + 1]
       edge = data[from][:children][to]
       if edge
         distance += edge[:length]
       else
         raise "No Such Route"
       end
      end
    end
    # puts "Path: #{txt_route}, Length = #{distance}"

    distance
  end

  def bfs_traverse_from(root_node)
    root_node = root_node.to_s.to_sym

    # initialize
    bfs_graph = Marshal.load(Marshal.dump(self.data))
    bfs_graph.keys.each do |key|
      bfs_graph[key][:parent] = nil
      bfs_graph[key][:distance] = nil
    end
    bfs_graph[root_node][:distance] = 0

    # traverse
    queue = []
    queue.push root_node
    while queue.length != 0
      parent = queue.shift
      bfs_graph[parent][:children].keys.each do |child|
        unless bfs_graph[child][:distance]
          bfs_graph[child][:parent] = parent
          bfs_graph[child][:distance] = bfs_graph[parent][:distance] + (bfs_graph[parent][:children][child][:length] || 1)
          queue.push child
        end
      end
    end
    # puts "BFS Graph: #{bfs_graph.inspect}"

    bfs_graph
  end

  def dfs_traverse
    # initialize
    dfs_graph = Marshal.load(Marshal.dump(self.data))
    dfs_graph.keys.each do |key|
      dfs_graph[key][:parent] = nil
      dfs_graph[key][:color] = :white
      dfs_graph[key][:discover] = nil
      dfs_graph[key][:finish] = nil
    end

    # traverse
    global_time = 0
    dfs_graph.keys.each do |key|
      if dfs_graph[key][:color] == :white
        global_time = dfs_visit(key, dfs_graph, global_time)
      end
    end
    # puts "DFS Graph: #{dfs_graph.inspect}"

    dfs_graph
  end

  def all_possible_paths_from(root_node)
    # resetting latest_paths_root and latest_paths
    self.latest_paths_root = root_node.to_s.to_sym
    self.latest_paths = []

    # generating paths
    traverse_level_down(latest_paths_root, latest_paths, Path.new)

    # removing duplicate paths
    # duplicates are created when we try to traverse down a node whose more than one 
    # "node to child node" paths are already part as elements in current path
    latest_paths.uniq!

    latest_paths
  end

  def paths_between_two_nodes(starting_node, ending_node)
    starting_node = starting_node.to_s.to_sym
    ending_node = ending_node.to_s.to_sym

    paths = all_possible_paths_from(starting_node)

    # trunctating individual path for given ending_node
    truncated_paths = []
    paths.each do |path|
      path.each_index do |index|
        if path[index][:to] == ending_node
          truncated_paths << path[0..index] unless truncated_paths.include? path[0..index]
        end
      end
    end

    truncated_paths
  end

  def shortest_paths_between_two_nodes(starting_node, ending_node)
    starting_node = starting_node.to_s.to_sym
    ending_node = ending_node.to_s.to_sym

    paths = paths_between_two_nodes(starting_node, ending_node)
    paths = Path.sort_paths(paths)

    shortest_paths = []
    paths.each do |path|
      if path.length == paths[0].length
        shortest_paths << path
      else
        return shortest_paths
      end
    end

    shortest_paths
  end

  private

  # Example: 
  # Input Nodes: AB5, BC4, CD8, DC8, DE6, AD5, CE2, EB3, AE7, KL2
  # Generated Graph: {
  # :A=>{:children=>{:B=>{:length=>5}, :D=>{:length=>5}, :E=>{:length=>7}}},
  # :B=>{:children=>{:C=>{:length=>4}}},
  # :C=>{:children=>{:D=>{:length=>8}, :E=>{:length=>2}}},
  # :D=>{:children=>{:C=>{:length=>8}, :E=>{:length=>6}}},
  # :E=>{:children=>{:B=>{:length=>3}}}
  # :K=>{:children=>{:L=>{:length=>2}}}
  # :L=>{:children=>{}}}
  # }
  def construct_graph_data_from_text(txt = text)
    nodes = txt.split(",")
    nodes.each do |elem|
      edge = Path.text_to_path_element(elem)
      unless data[edge[:from]].class.to_s == 'Hash'
        # node wasn't present in hash
        data[edge[:from]] = {:children => {}}
      end
      unless data[edge[:to]].class.to_s == 'Hash'
        # node wasn't present in hash
        data[edge[:to]] = {:children => {}}
      end
      unless data[edge[:from]][:children][edge[:to]].to_s == 'Hash'
        # node wasn't present in hash
        data[edge[:from]][:children][edge[:to]] = {}
      end
      data[edge[:from]][:children][edge[:to]][:length] = edge[:length]
    end
    # puts "Graph: #{data.inspect}"

    data
  end

  def traverse_level_down(current_node, paths, current_path)
    current_path_original = current_path
    if data[current_node][:children].keys.length > 0
      data[current_node][:children].keys.each do |child_node|
        current_path = Marshal.load(Marshal.dump current_path_original)
        elem_path = Path.new_path_element(current_node, child_node, data[current_node][:children][child_node][:length])
        if current_path.include? elem_path
          # path terminates
          paths << current_path
        else
          current_path << elem_path
          traverse_level_down(child_node, paths, current_path)
        end
      end
    else
      paths << current_path
    end

  end

  def dfs_visit(node_key, dfs_graph, global_time)
    # setting the given node
    global_time += 1
    dfs_graph[node_key][:discover] = global_time
    dfs_graph[node_key][:color] = :gray

    # setting its children
    dfs_graph[node_key][:children].keys.each do |child_key|
      if dfs_graph[child_key][:color] == :white
        dfs_graph[child_key][:parent] = node_key
        global_time = dfs_visit(child_key, dfs_graph, global_time)
      end
    end

    # after all children are set
    global_time += 1
    dfs_graph[node_key][:finish] = global_time
    dfs_graph[node_key][:color] = :black  # setting color to :black just has visual significance

    global_time
  end
end

