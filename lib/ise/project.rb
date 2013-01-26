
require 'nokogiri'
require 'ise'

module ISE

  class Project 
  
    OutputNameProperty = 'Output File Name'
    TopLevelFileProperty = 'Implementation Top File'


    #
    # Creates a new ISE Project from an XML string or file object. 
    #
    def initialize(xml, base_path)
      @xml = Nokogiri.XML(xml)
      @base_path = File.dirname(base_path)
    end


    #
    # Factory method which creates a new Project from a project file.
    #
    def self.load(file_path)
      new(File::read(file_path), file_path)
    end

  
    #
    # Returns the value of a project property.
    #
    def get_property(name)

      #Retreive the value of the node with the given property.
      node = get_property_node(name)
      node.attribute("value").value

    end

    #
    # Sets the value of an ISE project property.
    #
    def set_property(name, value, mark_non_default=true)
 
      #Set the node's property, as specified.
      node = get_property_node(name)
      node.attribute("value").value = value

      #If the mark non-default option is set, mark the state is not a default value.
      node.attribute("valueState").value = 'non-default' if mark_non_default

    end

    #
    # Returns a path to the top-level file in the given project. 
    #
    # absoulute_path: If set when the project file's path is known, an absolute path will be returned.
    #
    def top_level_file(absolute_path=true)
     
      path = get_property(TopLevelFileProperty)

      #If the absolute_path flag is set, and we know how, expand the file path.
      if absolute_path
        path = File.expand_path(path, @base_path) 
      end

      #Return the relevant path.
      path

    end

    #
    # Returns the best-guess path to the most recently generated bit file,
    # or nil if we weren't able to find one.
    #
    def bit_file

      #Find an absolute path at which the most recently generated bit file should reside.
      name = get_property(OutputNameProperty)
      name = File.expand_path("#{name}.bit", @base_path)

      #If it exists, return it.
      File::exists?(name) ? name : nil

    end

    private

    #
    # Retreives the node with the given property name.
    #
    def get_property_node(name)
      @xml.at_css("property[xil_pn|name=\"#{name}\"]")
    end


  end


end
