
require 'ise'
require 'nokogiri'

module ISE

  class Symbol < XMLFile

    #
    # Get the name of the given schematic symbol;
    # this also indicates which component this symbol is meant to wrap.
    #
    def name
      @xml.css('symbol').attribute('name').value
    end

    #
    # Sets the name of the given schematic symbol;
    # adjusting the name of the 
    #
    def name=(new_name)
      @xml.css('symbol').attribute('name').value = new_name
    end

    #
    # Returns a true-like value if the symbol has the given attribute.
    #
    def has_attribute?(name)
      attribute_value_object(name)
    end
    alias_method :include?, :has_attribute?

    #
    # Gets the value of the provided Symbol attribute. 
    #
    def get_attribute(name)
      attribute_value_object(name).value
    end

    #
    # Sets the value of the provided Symbol attribute.
    #
    def set_attribute(name, new_value)
      attribute_value_object(name).value = new_value.to_s
    end
    
    #Allow the indexing operator to be used to access attributes.
    alias_method :[], :get_attribute
    alias_method :[]=, :set_attribute

    #
    # Returns an array of I/O pins present on the given symbol.
    # 
    def pins
      @xml.css("symbol pin")
    end

    #
    # Iterates over all of the I/O pins in the given design.
    #
    def each_pin(&block)

      #If no block was provided, return an enumerator.
      return pins.to_enum unless block

      #Otherwise, iterate over the pins.
      pins.each(&block)

    end

    #
    # Renames each of the pins in the design according to a rule.
    #
    # Requires a block, which should accept a pin name and provide the
    # pin's new name.
    #
    def rename_pins!
      pins.each { set_pin_name(yield get_pin_name(pin)) }
    end
    
    #
    # Returns the name of a given pin, given its node.
    #
    def get_pin_name(node)
      node.attribute("name").value
    end

    #
    # Sets name of the pin represented by the given node, updating all values 
    #
    def set_pin_name(node, name)

      return unless node.name == "pin"

      #Change the name of any pin-label "text attributes" that reference the given pin.
      original_name = get_pin_name(node)

      #Retrieve a collection of all attributes that match the pin's original name...
      pin_labels = @xml.css("symbol graph attrtext[attrname=\"PinName\"][type=\"pin #{original_name}\"]")

      #And modify them so they now match the new node's name.
      pin_labels.each { |pin| pin.attribute('type').value = "pin #{name}" }

      #Finally, set the name of the node itself.
      node.attribute("name").value = name
      
    end

    private

    #
    # Returns a reference to the XML attribute that corresponds to the _value_
    # of an ISE _symbol_ attribute. (If that's not a confusing clash of nomenclature, what is?)
    #
    def attribute_value_object(name)
  
      #Ensure we have a string- this allows us to use symbols as attribute names, as well.
      #This is more idiomatic.
      name = name.to_s

      #Get the node that corresponds to the given attribute, if it exists.
      node = @xml.at_css("symbol attr[name=\"#{name}\"]")

      #If the node exists, return its value; otherwise, return nil.
      return node ? node.attribute('value') : nil

    end

  end

end
