require File.expand_path('../../teststrap',__FILE__)

if platform?("darwin") # Only run test if it's darwin
  context "MacCapture" do
    # Stub out the initialization
    setup do
      @terminal = Object.new
      any_instance_of(Terminitor::MacCapture) do |core|
        stub(core).app('Terminal.app') { @terminal  }
      end 
    end
    setup { @mac_capture = Terminitor::MacCapture.new() }

    context "capture_windows" do 
      setup do 
        window, tab = Object.new, Object.new
        stub(@terminal).windows.stub!.get { [window]}
        stub(window).tabs.stub!.get {[tab]}
        stub(window).visible.stub!.get { true }
        mock(@mac_capture).object_options(window) { {:window_option => true} }
        mock(@mac_capture).object_options(tab)    { {:tab_option => true} }        
        # any_instance_of(Terminitor::MacCapture) {|core| stub(core).object_options(anything) { {} }}
      end
      setup { @mac_capture.capture_windows}
      asserts_topic.equals [{:tabs=>[{:options=>{:tab_option=>true}}], :options=>{:window_option=>true}}]
    end

    context "object_options" do
      setup do
        @object = Object.new
        stub(@object).class_.stub!.get { :window }
        stub(@object).bounds.stub!.get { [10,20,30,40]}
      end
      setup { @mac_capture.object_options(@object) }
      asserts_topic.equals { {:bounds => [10,20,30,40]} }
    end
  end
else
  context "MacCore" do
    puts "Nothing to do, you are not on OSX"
  end
end