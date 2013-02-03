
require 'ise'
require 'nokogiri'
require 'enumerator'

module ISE

  #
  # Class representing an ISE symbol file.
  #
  class Symbol < XMLFile

    PIN_NAME_REGEX = /^([A-Za-z0-9_]+)(\(([0-9]+)\:([0-9]+)\))?$/

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
    # Special constructor used for creating deep copies of
    # this object. We use this to clone the inner XML AST.
    #
    def initialize_copy(source)
      super
      @xml = @xml.clone
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
    # Iterates over each attribute present in the given symbol.
    #
    def each_attribute
      
      #If we weren't passed a block, return an enumerator referencing this function.
      return enum_for(:each_attribute) unless block_given?

      #Yield each of the known attributes in turn.
      @xml.css("symbol attr").each do |attr|
        yield attr.attribute('name').value, attr.attribute('value').value
      end

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
    # Iterates over all of the I/O pins in the given design, providing their names
    # as well as their node objects.
    #
    def each_pin_with_name

      #If we weren't passed a block, return an enumerator referencing this function.
      return enum_for(:each_pin_with_name) unless block_given?

      #Otherwise, yield each pin with its name.
      each_pin do |pin|
        yield pin, get_pin_name(pin)
      end

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

    #
    # Adjusts the "bounds" of the given bus-- its maximum and minimum pin numbers-- in-place.
    #
    # node: The node whose value should be adjusted.
    # left: The left bound. This is typically higher than the right bound, but doesn't have to be.
    # right: The right bound. 
    #
    def set_pin_bounds!(node, left, right)
   
      #Extract the base name of the pin, removing any existing bounds.
      name, _, _ =  parse_pin_name(get_pin_name(node))

      #And adjust the pin's name to feature the new bounds.
      set_pin_name(node, "#{name}(#{left}:#{right})")
    
    end

    #
    # Adjusts the "bounds" of the given bus so the bus is of the provided width
    # by modifying the bus's upper bound. If the node is not a bus, it will be
    # made into a bus whose right bound is 0.
    #
    # node: The node to be modified.
    # width: The width to apply.
    #
    def set_pin_width!(node, width)

      #Get the components of the given bus' name.
      _, left, right = parse_pin_name(get_pin_name(node))

      #If the pin wasn't initially a bus, make it one.
      left  ||= 0
      right ||= 0

      #If our right bound is greater than our left one, adjust it.
      if right > left
        right = left + width - 1
      #Otherwise, adjust the left width.
      else
        left = right + width - 1
      end

      #Set the pin's bounds.
      set_pin_bounds!(node, left, right)

    end

    private

    #
    # Break a schematic-format pin name into three elements, and return them.
    # Returns a list including: 1) the base name, 2) the range's left bound, and 3) the range's right bound.
    #
    def parse_pin_name(name)
      components = PIN_NAME_REGEX.match(name)
      return components[1], components[3].to_i, components[4].to_i
    end


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
