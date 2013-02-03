
require 'ise'
require 'nokogiri'

module ISE

  class Symbol < XMLFile

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
    def rename_pins!

      pins.each do |pin|

        yield get_pin_name(pin)

      end

    end

  end

end
