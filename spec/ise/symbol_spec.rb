require 'ise'

describe ISE::Symbol do
 
  #Operate on the sample symbol file.
  subject { ISE::Symbol.load(File.expand_path('../test_data/symbol.sym', __FILE__)) }

  #Provide an example node for some tests to operate on.
  let(:node) { subject.pins.first }

  #Get a reference to the Symbol's internal XML.
  let(:xml) { subject.instance_variable_get(:@xml) }

  def pin_should_exist(name)
    xml.at_css("symbol graph attrtext[type=\"pin #{name}\"]").should_not be_nil, "Pin #{name} should exist, but does not."
  end

  describe ".name" do
    it "should return the symbol's name" do
      subject.name.should == "BusMux16"
    end
  end

  describe ".name=" do
    it "should set the symbol's name" do
      subject.name = "NewName"
      subject.name.should == "NewName"
    end
  end

  describe ".has_attribute?" do
    context "when provided with an existing attribute" do
      it"should return true" do
        subject.has_attribute?(:BusWidth).should be_true
      end
    end
    
    context "when provided with an attribute that does not exist" do
      it "should return false" do
        subject.has_attribute?(:SomethingElse).should be_false
      end
    end
  end

  describe ".get_attribute" do
    it "should return the value of the provided attribute" do
      subject.get_attribute(:BusWidth).should == '8'
    end
  end

  describe ".set_attribute" do
    it "should set the value of the provided attribute" do
      subject.set_attribute(:BusWidth, 3)
      subject.get_attribute(:BusWidth).should == '3'
    end
  end

  describe ".each_attribute" do
    #TODO: better test that doesn't require enumerator funcitonality?
    it "should iterate over each of the attributes in the file" do
      subject.each_attribute.to_a.should == [['BusWidth', '8']]
    end
  end

  describe ".pins" do 
    it "should return a list of each pin in the design" do
      #Generate a list of expected pin names.
      expected_names = (0..15).map { |n| "i#{n}(7:0)" }
      expected_names |= ['sel(3:0)', 'o(7:0)'] 

      #Get a list of pin names in the design.
      pin_names = subject.pins.collect { |p| p.attribute("name").value }
      pin_names.should == expected_names
    end
  end

  describe ".rename_pin" do
    it "should change the name of the provided pin" do
      subject.set_pin_name(node, 'a(1:0)') 
      node.attribute('name').value.should == 'a(1:0)'
    end

    it "should change the name of any pin labels referencing the pin" do
      subject.set_pin_name(node, 'a(1:0)') 
      pin_should_exist('a(1:0)')
    end
  end

  describe ".set_pin_bounds!" do

    it "should change the boundaries of the given pin to match its arguments" do
      subject.set_pin_bounds!(node, 14, 3)
      pin_should_exist('i0(14:3)')
    end

  end

  describe ".set_pin_width!" do

    context "when provided with an MSB-to-the-left range" do
      it "should move the upper (left) bound to create the correct width" do
        subject.set_pin_width!(node, 4)
        pin_should_exist('i0(3:0)')
      end
    end

    context "when provided with an LSB-to-the-left range" do
      it "should move the upper (right) bound to create the correct width" do
        
        #Create an LSB-to-the-left range.
        subject.set_pin_name(node, 'i0(0:7)')

        subject.set_pin_width!(node, 4)
        pin_should_exist('i0(0:3)')
      end
    end

    context "when provided with a non-bus" do
      it "should create a bus that is bounded at zero" do
       
        #Create a non-bus input.
        subject.set_pin_name(node, 'i')

        subject.set_pin_width!(node, 10)
        pin_should_exist('i(9:0)')

      end
    end
  end


end
