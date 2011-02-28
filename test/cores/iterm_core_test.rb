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

    asserts "#terminal_process calls System Events" do
      core = topic.dup
      mock(core).app('System Events') { mock!.application_processes.returns("iTerm.app" => true) }
      core.terminal_process
    end

    context "#open_tab" do

      should "return the current tab" do
        core = topic.dup
        mock(core).current_terminal.stub!.sessions.stub!.end.
          stub!.make(:new => :session).stub!.
          exec(:command => ENV['SHELL'])
        core.open_tab
      end

    end

    context "#open_window" do
    
      should "return the last tab" do
        core = topic.dup
        mock(core).terminal.stub!.make(:new=>:terminal).
          stub!.sessions.stub!.end.stub!.make(:new=>:session).
          stub!.exec(:command => ENV['SHELL'])
        core.open_window
      end
    end
    
    asserts "#return_last_tab returns the last tab" do
     core = topic.dup
     mock(core).current_terminal.stub!.sessions.stub!.
       last.stub!.get.returns(true)
     core.return_last_tab
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

