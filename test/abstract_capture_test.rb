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
    asserts_topic.equivalent_to <<-OUTPUT
window :size => [10, 20], :name => "main window" do
    tab :settings => "Grass" do
    end

end

window :size => [14, 30], :name => "another window" do
    tab :settings => "Yello" do
    end

end

OUTPUT

  end
end