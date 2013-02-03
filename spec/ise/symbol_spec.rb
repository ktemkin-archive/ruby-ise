require 'ise'

describe ISE::Project do
 
  #Operate on the sample symbol file.
  subject { ISE::Symbol.load(File.expand_path('../test_data/symbol.sym', __FILE__)) }

  describe ".pins" do 

    it "should return a list of each pin in the design" do


    end

  end

end
