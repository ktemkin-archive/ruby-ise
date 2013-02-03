require 'ise'

describe ISE::Symbol do
 
  #Operate on the sample symbol file.
  subject { ISE::Symbol.load(File.expand_path('../test_data/symbol.sym', __FILE__)) }

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

    #Provide an example node to operate on.
    let(:node) { subject.pins.first }

    #Get a reference to the Symbol's internal XML.
    let(:xml) { subject.instance_variable_get(:@xml) }

    it "should change the name of the provided pin" do
      subject.set_pin_name(node, 'a(1:0)') 
      node.attribute('name').value.should == 'a(1:0)'
    end

    it "should change the name of any pin labels referencing the pin" do
      #Change the first pin to a(1:0), a name that does not already exist in the design;
      #then verify that that new name exists.
      subject.set_pin_name(node, 'a(1:0)') 
      xml.at_css('symbol graph attrtext[type="pin a(1:0)"]').should_not be_nil
    end

  end


end
