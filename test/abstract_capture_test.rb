require File.expand_path('../teststrap', __FILE__)

context "AbstractCapture" do
  context "capture_settings" do 
    setup do
      @capture = Terminitor::AbstractCapture.new()
      any_instance_of(Terminitor::AbstractCapture) do |core|
        stub(core).capture_windows  { [
          {:options => {:size => [10,20], :name => "main window"}, 
           :tabs => [
             {:options => {:settings => "Grass"}}
             ]},
          {:options => {:size => [14,30], :name => "another window"},
           :tabs => [{:options => {:settings => "Yello"}}]}
        ] }
      end
    end
    
    setup { @capture.capture_settings() }
    asserts_topic.matches %r{window .* do}
    asserts_topic.matches %r{tab .* do\s+end}
    asserts_topic.matches %r{\:name \=\> "main window"}
    asserts_topic.matches %r{\:size \=\> \[10\, 20\]}
    asserts_topic.matches %r{\:settings \=\> "Grass"}
    asserts_topic.matches %r{\:name \=\> "another window"}
    asserts_topic.matches %r{\:size \=\> \[14, 30\]}
    asserts_topic.matches %r{\:settings \=\> "Yello"}
  end
end
