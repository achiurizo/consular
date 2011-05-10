require File.expand_path('../../teststrap',__FILE__)

on_platform "darwin" do 

  context "ItermCore" do
    setup do
      any_instance_of(Terminitor::ItermCore) do |core|
        stub(core).app('iTerm')           { mock!.terminals { true } }
        stub(core).load_termfile('/path/to') { true }
      end
     @iterm_core = Terminitor::ItermCore.new('/path/to')  
    end

    context "#open_tab" do

      should "open a new tab" do
        core = topic.dup
        mock(core).current_terminal.stub!.launch_(:session => 'New session')
        core.open_tab
      end.equals(nil)

    end
    
    asserts "#execute_command executes" do
      core = topic.dup
      mock(core).active_window.stub!.write(:text => "hasta").returns(true)
      core.execute_command('hasta')
    end
    
    asserts "#active_window gives window" do
      core = topic.dup
      mock(core).current_terminal.stub!.current_session.stub!.get.returns(true)
      core.active_window
    end
  end
end

