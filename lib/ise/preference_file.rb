
require 'cgi'
require 'inifile'

module ISE

  #
  # Represents a set of ISE Project Navigator Preferences.
  #
  class PreferenceFile < IniFile

    #
    # Determines the location of the ISE preferences file.
    # TODO: Generalize to work on Windows?
    #
    def self.ise_preference_file_path
      "~/.config/Xilinx/ISE.conf"
    end

    #
    # Loads an ISE preference file.
    #
    def self.load(filename=nil, opts={})
   
      #If no filename was specified, use the default ISE preference file.
      filename ||= File.expand_path(ise_preference_file_path)

      #Parse the preference file as an INI file.
      super

    end

    #
    # Sets the value of a key in a hash-of-hashes via a unix-style path.
    #
    # path: The path to the target key, in a unix-style path structure. See example below.
    # value: The value to put into the key.
    # target: The hash to operate on. If target isn't provided, we work with the base INI.
    #
    # Example:
    #
    #   set_by_path('foo/bar/tab', 3, a) would set
    #   a[foo][bar][tab] = 3; setting foo and bar to 
    # 
    #
    def set_by_path(path, value, target=@ini)

      #Split the path into its components.
      keys = path.split('/')  

      #Traverse the path, creating any "folders" necessary along the way.
      until keys.one?
        target[keys.first] = {} unless target[keys.first].is_a?(Hash)
        target = target[keys.shift]
      end
     
      #And finally, place the value into the appropriate "leaf".
      target[keys.shift] = value

    end

    #
    # Gets the value of a key in a hash-of-hashes via a unix-style path.
    #
    # path: The path to the target key, in a unix-style path structure. See example below.
    # target: The hash to operate on. If target isn't provided, we work with the base INI.
    #
    # Example:
    #
    #   set_by_path('foo/bar/tab', 3, a) would set
    #   a[foo][bar][tab] = 3; setting foo and bar to 
    # 
    #
    def get_by_path(path, target=@ini)

      #Split the path into its components...
      keys = path.split('/')

      #And traverse the hasn until we've fully navigated the path.
      target = target[keys.shift] until keys.empty?

      #Returns the final value.
      target

    end

    #
    # Processes a given name-value pair, adding them
    # to the current INI database.
    #
    # Code taken from the 'inifile' gem.
    #
    def process_property(property, value)
      
      value.chomp!

      #If either the property or value are empty (or contain invalid whitespace),
      #abort.
      return if property.empty? and value.empty?
      return if value.sub!(%r/\\\s*\z/, '')

      #Strip any leading/trailing characters.
      property.strip!
      value.strip!

      #Raise an error if we have an invalid property name.
      parse_error if property.empty?

      #Parse ISE's value into a path.
      set_by_path(CGI::unescape(property), unescape_value(value.dup), current_section)

      #And continue processing the property and value.
      property.slice!(0, property.length)
      value.slice!(0, value.length)

      #Return nil.
      nil
    
    end

  end

end
