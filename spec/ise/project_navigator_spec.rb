
require 'ise'

describe ISE::ProjectNavigator do

  describe "#most_recent_project_path" do

    subject { ISE::ProjectNavigator }
   
    #Adjust the preference file location so it points to the test-data preference file.
    let(:preference_file) { File.expand_path('../test_data/ISE.conf', __FILE__) }
    before(:each) { ISE::ProjectNavigator.set_preference_file(preference_file) }

    it "should return the path of the most recently edited ISE project file" do
      subject.most_recent_project_path.should == "/home/ktemkin/Documents/Projects/ISESymbolLibrary/MSI_Components/MSI_Components.xise" 
    end

  end

end
