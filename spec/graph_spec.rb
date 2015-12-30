require "spec_helper"
require_relative "../lib/graph"

describe Graph do
  let(:input1) { "AB5, BC4, CD8, DC8, DE6, AD5, CE2, EB3, AE7, KL2" }
  let(:input2) { "AB, BC, CD, DC, DE, AD, CE, EB, AE, KL" }
  let(:input1_data) {
    {
      :A=>{:children=>{:B=>{:length=>5}, :D=>{:length=>5}, :E=>{:length=>7}}},
      :B=>{:children=>{:C=>{:length=>4}}},
      :C=>{:children=>{:D=>{:length=>8}, :E=>{:length=>2}}},
      :D=>{:children=>{:C=>{:length=>8}, :E=>{:length=>6}}},
      :E=>{:children=>{:B=>{:length=>3}}},
      :K=>{:children=>{:L=>{:length=>2}}},
      :L=>{:children=>{}}
    }
  }
  let(:input2_data) {
    {
      :A=>{:children=>{:B=>{:length=>1}, :D=>{:length=>1}, :E=>{:length=>1}}},
      :B=>{:children=>{:C=>{:length=>1}}},
      :C=>{:children=>{:D=>{:length=>1}, :E=>{:length=>1}}},
      :D=>{:children=>{:C=>{:length=>1}, :E=>{:length=>1}}},
      :E=>{:children=>{:B=>{:length=>1}}},
      :K=>{:children=>{:L=>{:length=>1}}},
      :L=>{:children=>{}}
    }
  }
  let(:graph1) { Graph.new input1 }
  let(:graph2) { Graph.new input2 }
  let(:paths_from_A) {
    [
      "AB5-BC4-CD8-DC8",
      "AB5-BC4-CD8-DC8-CE2-EB3",
      "AB5-BC4-CD8-DE6-EB3",
      "AB5-BC4-CE2-EB3",
      "AD5-DC8-CD8",
      "AD5-DC8-CD8-DE6-EB3-BC4",
      "AD5-DC8-CD8-DE6-EB3-BC4-CE2",
      "AD5-DC8-CE2-EB3-BC4-CD8",
      "AD5-DC8-CE2-EB3-BC4-CD8-DE6",
      "AD5-DC8-CE2-EB3-BC4",
      "AD5-DE6-EB3-BC4-CD8-DC8",
      "AD5-DE6-EB3-BC4-CD8-DC8-CE2",
      "AD5-DE6-EB3-BC4-CD8",
      "AD5-DE6-EB3-BC4-CE2",
      "AE7-EB3-BC4-CD8-DC8",
      "AE7-EB3-BC4-CD8-DC8-CE2",
      "AE7-EB3-BC4-CD8-DE6",
      "AE7-EB3-BC4-CE2"
    ]
  }
  let(:paths_from_B) {
    [
      "BC4-CD8-DC8",
      "BC4-CD8-DC8-CE2-EB3",
      "BC4-CD8-DE6-EB3",
      "BC4-CE2-EB3"
    ]
  }
  let(:paths_from_C) {
    [
      "CD8-DC8",
      "CD8-DC8-CE2-EB3-BC4",
      "CD8-DE6-EB3-BC4",
      "CD8-DE6-EB3-BC4-CE2",
      "CE2-EB3-BC4-CD8-DC8",
      "CE2-EB3-BC4-CD8-DE6",
      "CE2-EB3-BC4" 
    ]
  }
  let(:paths_from_D) {
    [
      "DC8-CD8",
      "DC8-CD8-DE6-EB3-BC4",
      "DC8-CD8-DE6-EB3-BC4-CE2",
      "DC8-CE2-EB3-BC4-CD8",
      "DC8-CE2-EB3-BC4-CD8-DE6",
      "DC8-CE2-EB3-BC4",
      "DE6-EB3-BC4-CD8-DC8",
      "DE6-EB3-BC4-CD8-DC8-CE2",
      "DE6-EB3-BC4-CD8",
      "DE6-EB3-BC4-CE2"
    ]
  }
  let(:paths_from_E) {
    [
      "EB3-BC4-CD8-DC8",
      "EB3-BC4-CD8-DC8-CE2",
      "EB3-BC4-CD8-DE6",
      "EB3-BC4-CE2"
    ]
  }
  let(:paths_from_K) { ["KL2"] }
  let(:paths_from_L) { [""] }
  before do
    # nothing
  end

  describe "#data" do
    it "returns data in hash format from given string of comma seperated edges"do
      expect(graph1.data).to eq(input1_data)
    end
  end

  describe "#all_possible_paths_from AND #display_paths" do
    it "returns all possible paths from given node" do
      expect(Path.display_paths(graph1.all_possible_paths_from(:A))).to eq(paths_from_A)
      expect(Path.display_paths(graph1.all_possible_paths_from(:B))).to eq(paths_from_B)
      expect(Path.display_paths(graph1.all_possible_paths_from(:C))).to eq(paths_from_C)
      expect(Path.display_paths(graph1.all_possible_paths_from(:D))).to eq(paths_from_D)
      expect(Path.display_paths(graph1.all_possible_paths_from(:E))).to eq(paths_from_E)
      expect(Path.display_paths(graph1.all_possible_paths_from(:K))).to eq(paths_from_K)
      expect(Path.display_paths(graph1.all_possible_paths_from(:L))).to eq(paths_from_L)
    end
  end

  describe "#route_length" do
   it "returns the route length of given route in text format" do
     expect(graph1.route_length("A-B-C")).to eq(9)
     expect(graph1.route_length("A-D")).to eq(5)
     expect(graph1.route_length("A-D-C")).to eq(13)
     expect(graph1.route_length("A-E-B-C-D")).to eq(22)

     expect(graph2.route_length("A-B-C")).to eq(2)
     expect(graph2.route_length("A-D")).to eq(1)
     expect(graph2.route_length("A-D-C")).to eq(2)
     expect(graph2.route_length("A-E-B-C-D")).to eq(4)
   end
   it "raise error with message 'No Such Route' if no such route exists" do
     expect { graph1.route_length "A-E-D" }.to raise_error(RuntimeError, "No Such Route")
   end
  end

  describe "#paths_between_two_nodes" do
    it "returns all paths between two given nodes" do
      paths_between_C_and_C = [
        [{:from=>:C, :to=>:D, :length=>8}, {:from=>:D, :to=>:C, :length=>8}],
        [{:from=>:C, :to=>:D, :length=>8}, {:from=>:D, :to=>:C, :length=>8}, {:from=>:C, :to=>:E, :length=>2},
          {:from=>:E, :to=>:B, :length=>3}, {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:C, :to=>:D, :length=>8}, {:from=>:D, :to=>:E, :length=>6}, {:from=>:E, :to=>:B, :length=>3},
          {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:C, :to=>:E, :length=>2}, {:from=>:E, :to=>:B, :length=>3}, {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:C, :to=>:E, :length=>2}, {:from=>:E, :to=>:B, :length=>3}, {:from=>:B, :to=>:C, :length=>4},
          {:from=>:C, :to=>:D, :length=>8}, {:from=>:D, :to=>:C, :length=>8}]
      ]
      paths_between_A_and_C = [
        [{:from=>:A, :to=>:B, :length=>5}, {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:A, :to=>:B, :length=>5}, {:from=>:B, :to=>:C, :length=>4}, {:from=>:C, :to=>:D, :length=>8},
          {:from=>:D, :to=>:C, :length=>8}],
        [{:from=>:A, :to=>:D, :length=>5}, {:from=>:D, :to=>:C, :length=>8}],
        [{:from=>:A, :to=>:D, :length=>5}, {:from=>:D, :to=>:C, :length=>8}, {:from=>:C, :to=>:D, :length=>8},
          {:from=>:D, :to=>:E, :length=>6}, {:from=>:E, :to=>:B, :length=>3}, {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:A, :to=>:D, :length=>5}, {:from=>:D, :to=>:C, :length=>8}, {:from=>:C, :to=>:E, :length=>2},
          {:from=>:E, :to=>:B, :length=>3}, {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:A, :to=>:D, :length=>5}, {:from=>:D, :to=>:E, :length=>6}, {:from=>:E, :to=>:B, :length=>3},
          {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:A, :to=>:D, :length=>5}, {:from=>:D, :to=>:E, :length=>6}, {:from=>:E, :to=>:B, :length=>3},
          {:from=>:B, :to=>:C, :length=>4}, {:from=>:C, :to=>:D, :length=>8}, {:from=>:D, :to=>:C, :length=>8}],
        [{:from=>:A, :to=>:E, :length=>7}, {:from=>:E, :to=>:B, :length=>3}, {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:A, :to=>:E, :length=>7}, {:from=>:E, :to=>:B, :length=>3}, {:from=>:B, :to=>:C, :length=>4},
          {:from=>:C, :to=>:D, :length=>8}, {:from=>:D, :to=>:C, :length=>8}]
      ]
      expect(graph1.paths_between_two_nodes(:C, :C)).to eq(paths_between_C_and_C)
      expect(graph1.paths_between_two_nodes(:A, :C)).to eq(paths_between_A_and_C)

    end
  end

  describe "#shortest_paths_between_two_nodes" do
    it "returns shortest paths between two nodes" do
      shortest_paths_between_A_and_C = [
        [{:from=>:A, :to=>:B, :length=>5}, {:from=>:B, :to=>:C, :length=>4}],
        [{:from=>:A, :to=>:D, :length=>5}, {:from=>:D, :to=>:C, :length=>8}]
      ]
      shortest_paths_between_B_and_B = [
        [{:from=>:B, :to=>:C, :length=>4}, {:from=>:C, :to=>:E, :length=>2}, {:from=>:E, :to=>:B, :length=>3}]
      ]
      expect(graph1.shortest_paths_between_two_nodes(:A, :C)).to eq(shortest_paths_between_A_and_C)
      expect(graph1.shortest_paths_between_two_nodes(:B, :B)).to eq(shortest_paths_between_B_and_B)
    end
  end

  describe "#bfs_traverse_from" do
    it "retuns resultant graph data on BFS traversal from given node as root node" do
      graph1_on_bfs_traversal_from_A = {
        :A=>{:children=>{:B=>{:length=>5}, :D=>{:length=>5}, :E=>{:length=>7}}, :parent=>nil, :distance=>0},
        :B=>{:children=>{:C=>{:length=>4}}, :parent=>:A, :distance=>5},
        :C=>{:children=>{:D=>{:length=>8}, :E=>{:length=>2}}, :parent=>:B, :distance=>9},
        :D=>{:children=>{:C=>{:length=>8}, :E=>{:length=>6}}, :parent=>:A, :distance=>5},
        :E=>{:children=>{:B=>{:length=>3}}, :parent=>:A, :distance=>7},
        :K=>{:children=>{:L=>{:length=>2}}, :parent=>nil, :distance=>nil},
        :L=>{:children=>{}, :parent=>nil, :distance=>nil}
      }
      graph2_on_bfs_traversal_from_A = {
        :A=>{:children=>{:B=>{:length=>1}, :D=>{:length=>1}, :E=>{:length=>1}}, :parent=>nil, :distance=>0},
        :B=>{:children=>{:C=>{:length=>1}}, :parent=>:A, :distance=>1},
        :C=>{:children=>{:D=>{:length=>1}, :E=>{:length=>1}}, :parent=>:B, :distance=>2},
        :D=>{:children=>{:C=>{:length=>1}, :E=>{:length=>1}}, :parent=>:A, :distance=>1},
        :E=>{:children=>{:B=>{:length=>1}}, :parent=>:A, :distance=>1},
        :K=>{:children=>{:L=>{:length=>1}}, :parent=>nil, :distance=>nil},
        :L=>{:children=>{}, :parent=>nil, :distance=>nil}
      }
      expect(graph1.bfs_traverse_from :A).to eq(graph1_on_bfs_traversal_from_A)
      expect(graph2.bfs_traverse_from :A).to eq(graph2_on_bfs_traversal_from_A)
    end
  end

  describe "#dfs_traverse" do
    it "retuns resultant graph data on DFS traversal" do
      graph_on_dfs_traversal = {
        :A=>{:children=>{:B=>{:length=>5}, :D=>{:length=>5}, :E=>{:length=>7}}, :parent=>nil, :color=>:black, :discover=>1, :finish=>10},
        :B=>{:children=>{:C=>{:length=>4}}, :parent=>:A, :color=>:black, :discover=>2, :finish=>9},
        :C=>{:children=>{:D=>{:length=>8}, :E=>{:length=>2}}, :parent=>:B, :color=>:black, :discover=>3, :finish=>8},
        :D=>{:children=>{:C=>{:length=>8}, :E=>{:length=>6}}, :parent=>:C, :color=>:black, :discover=>4, :finish=>7},
        :E=>{:children=>{:B=>{:length=>3}}, :parent=>:D, :color=>:black, :discover=>5, :finish=>6},
        :K=>{:children=>{:L=>{:length=>2}}, :parent=>nil, :color=>:black, :discover=>11, :finish=>14},
        :L=>{:children=>{}, :parent=>:K, :color=>:black, :discover=>12, :finish=>13}
      }
      expect(graph1.dfs_traverse).to eq(graph_on_dfs_traversal)
    end
  end

  # following are developer specific tests
  context "Developer Specific Tests" do
    describe "#construct_graph_data_from_text" do
    end
  end
end

