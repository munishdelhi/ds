require "spec_helper"
require_relative "../lib/path"

describe Path do
  describe ".new_path_element" do
    it "returns a new hash for given 'from', 'to', and 'length'" do
      expect(Path.new_path_element(:A, :B, 10)).to eq({:from=>:A, :to=>:B, :length=>10})
      expect(Path.new_path_element("A", "B", 10)).to eq({:from=>"A", :to=>"B", :length=>10})
    end
    it "returns a new hash for given 'from', 'to', and default 'length' of 1" do
      expect(Path.new_path_element(:A, :B)).to eq({:from=>:A, :to=>:B, :length=>1})
      expect(Path.new_path_element("A", "B")).to eq({:from=>"A", :to=>"B", :length=>1})
    end
  end

  describe ".element_from" do
    it "returns value corresponding from 'from' key" do
      expect(Path.element_from({:from=>:A, :to=>:B, :length=>10})).to eq(:A)
      expect(Path.element_from({:from=>"A", :to=>"B", :length=>10})).to eq("A")
    end
  end

  describe ".element_to" do
    it "returns value corresponding from 'to' key" do
      expect(Path.element_to({:from=>:A, :to=>:B, :length=>10})).to eq(:B)
      expect(Path.element_to({:from=>"A", :to=>"B", :length=>10})).to eq("B")
    end
  end

  describe ".element_length" do
    it "returns value corresponding from 'length' key" do
      expect(Path.element_length({:from=>:A, :to=>:B, :length=>10})).to eq(10)
    end
  end

  describe ".text_to_path_element" do
    it "converts textual representation of path element to its hash representation" do
      expect(Path.text_to_path_element "AB5").to eq({:from => :A, :to => :B, :length => 5})
      expect(Path.text_to_path_element "AB50", :length_size => 2).to eq({:from => :A, :to => :B, :length => 50})
      expect(Path.text_to_path_element "A1B5", :from_size => 2).to eq({:from => :A1, :to => :B, :length => 5})
      expect(Path.text_to_path_element "AB15", :to_size => 2).to eq({:from => :A, :to => :B1, :length => 5})
      expect(Path.text_to_path_element "A11B1500", :from_size => 3, :to_size => 2, :length_size => 3).to eq({:from => :A11, :to => :B1, :length => 500})
    end
  end

  describe ".path_element_to_text" do
    it "converts hash representation of path element to textual representation" do
      expect(Path.path_element_to_text :from => :A, :to => :B, :length => 5).to eq("AB5")
      expect(Path.path_element_to_text :from => :A1, :to => :B, :length => 5).to eq("A1B5")
      expect(Path.path_element_to_text :from => :A, :to => :B1, :length => 5).to eq("AB15")
      expect(Path.path_element_to_text :from => :A, :to => :B, :length => 500).to eq("AB500")
    end
  end

  describe ".display_paths" do
    it "returns an Array with textual representation of each path" do
      # path1 with path_length 40
      path1 = Path.new
      path1 << Path.new_path_element(:A, :B, 10)
      path1 << Path.new_path_element(:B, :C, 20)
      path1 << Path.new_path_element(:C, :D, 10)
      # path2 with path_length 4
      path2 = Path.new
      path2 << Path.new_path_element(:A, :B, 1)
      path2 << Path.new_path_element(:B, :C, 2)
      path2 << Path.new_path_element(:C, :D, 1)
      # path3 with path_length 0
      path3 = Path.new
      # path4 with path_length 100
      path4 = Path.new
      path4 << Path.new_path_element(:A, :B, 100)

      paths = [path1, path2, path3, path4]

      expect(Path.display_paths paths).to eq(["AB10-BC20-CD10", "AB1-BC2-CD1", "", "AB100"])
    end
  end

  describe ".sort_paths" do
    it "sorts paths in ASC order of their path_length" do
      # path1 with path_length 40
      path1 = Path.new
      path1 << Path.new_path_element(:A, :B, 10)
      path1 << Path.new_path_element(:B, :C, 20)
      path1 << Path.new_path_element(:C, :D, 10)
      # path2 with path_length 4
      path2 = Path.new
      path2 << Path.new_path_element(:A, :B, 1)
      path2 << Path.new_path_element(:B, :C, 2)
      path2 << Path.new_path_element(:C, :D, 1)
      # path3 with path_length 0
      path3 = Path.new
      # path4 with path_length 100
      path4 = Path.new
      path4 << Path.new_path_element(:A, :B, 100)

      paths = [path1, path2, path3, path4]
      expected_path = [path3, path2, path1, path4]

      expect(Path.sort_paths(paths)).to eq(expected_path)
    end
  end

  describe "#path_length" do
    it "returns path length of given path" do
      path = Path.new
      path << Path.new_path_element(:A, :B, 10)
      path << Path.new_path_element(:B, :C, 20)
      expect(path.path_length).to eq(30)
      expect(Path.new.path_length).to eq(0)
    end
    it "doesn't check for correctness of path and return cumulative length of all elements" do
      path = Path.new
      path << Path.new_path_element(:A, :B, 10)
      path << Path.new_path_element("Munish", "Goyal", 20)
      expect(path.path_length).to eq(30)
    end
  end

  describe "#to_text" do
    it "returns text representation of a given path" do
      path1 = Path.new
      path1 << Path.new_path_element(:A, :B, 10)
      path1 << Path.new_path_element(:B, :C, 2)
      path1 << Path.new_path_element(:C, :D)
      path1 << Path.new_path_element(:M, :N, 10)
      expect(path1.to_text).to eq("AB10-BC2-CD1-MN10")
    end

    it "return empty string from empty path" do
      expect(Path.new.to_text).to eq("")
    end
  end

  # following are developer specific tests
  context "Developer Specific Tests" do
  end
end

