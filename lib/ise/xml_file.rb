
require 'nokogiri'

module ISE

  #
  # Module which implements the functionality used to wrap an ISE XML file.
  #
  class XMLFile

      #
      # Creates a new ISE Project from an XML string or file object. 
      #
      def initialize(xml, filename)
        @xml = Nokogiri.XML(xml)
        @filename = filename
        @base_path = File.dirname(filename)
      end

      #
      # Factory method which creates a new instance from an XML file.
      #
      def self.load(file_path)
        new(File::read(file_path), file_path)
      end

      #
      # Writes the project to disk, saving any changes.
      #
      def save(file_path=@filename)
        File::write(file_path, @xml)
      end
    
  end

end
