require File.expand_path('../../teststrap',__FILE__)

if platform?("darwin") # Only run test if it's darwin
  context "MacCore" do
    setup do
      any_instance_of(Terminitor::MacCore) do |core|
        stub(core).app('Terminal')           { mock!.windows { true } }
        stub(core).load_termfile('/path/to') { true }
      end
     @mac_core = Terminitor::MacCore.new('/path/to')  
    end

    asserts "#terminal_process calls System Events" do
      core = topic.dup
      mock(core).app('System Events') { mock!.application_processes.returns("Terminal.app" => true) }
      core.terminal_process
    end

    context "#open_tab" do

      should "return the last tab" do
        core = topic.dup
        mock(core).return_last_tab  { true }
        mock(core).terminal_process { mock!.keystroke('t', :using => :command_down) }
        core.open_tab
      end

      should "return last tab with options" do
        core = topic.dup
        mock(core).set_options(true, :option1 => '1', :option2 => '2')
        mock(core).return_last_tab.times(2) { true }
        mock(core).terminal_process { mock!.keystroke('t', :using => :command_down) }
        core.open_tab(:option1 => '1', :option2 => '2')
      end
    end

    context "#open_window" do

      should "return the last tab" do
        core = topic.dup
        mock(core).return_last_tab  { true }
        mock(core).terminal_process { mock!.keystroke('n', :using => :command_down) }
        core.open_window
      end

      should "open window with options" do
        core, window, tab = topic.dup, stub!, stub!
        mock(core).set_options(window, :bounds => '1')
        mock(core).set_options(tab, :settings => "2")
        mock(core).active_window    { window  }
        mock(core).return_last_tab  { tab     }.times(2)
        mock(core).terminal_process { mock!.keystroke('n', :using => :command_down) }
        core.open_window :bounds => '1', :settings => '2'
      end
    end

    asserts "#return_last_tab returns the last tab" do
     core, tab = topic.dup, mock!
     mock(tab).get { true }
     mock(core).active_window { mock!.tabs.returns([tab]) }
     core.return_last_tab
    end

    asserts "#execute_command executes" do
      core = topic.dup
      mock(core).active_window { mock!.do_script("hasta", :in => :la_vista).returns(true) }
      core.execute_command('hasta', :in => :la_vista)
    end

    asserts "#active_window gives window" do
      window, app_object = Object.new, Object.new
      mock(app_object).get     { {:frontmost => true}  }
      mock(window).properties_ { app_object            }
      any_instance_of(Terminitor::MacCore) do |core|
        stub(core).app('Terminal')           { stub!.windows { stub!.get.returns([window]) }  }
        stub(core).load_termfile('/path/to') { true }
      end
      Terminitor::MacCore.new('/path/to').active_window
    end


    context "set_options" do 
      setup do 
        @object, @terminal, @windows= 3.times.collect { Object.new }
        stub(@terminal).windows { @windows }
        any_instance_of(Terminitor::MacCore) do |core|
          stub(core).app('Terminal')           { @terminal }
          stub(core).load_termfile('/path/to') { true      }
        end
      end
      
      should "apply known valid settings" do
        stub(@terminal).settings_sets { { :valid_settings => true } }
        stub(@object).current_settings.stub!.set(anything) { true }
        Terminitor::MacCore.new('/path/to').set_options(@object, :settings => :valid_settings)
      end

      context "invalid settings" do
        should "return a error message that" do
          stub(@terminal).settings_sets {{:invalid_settings => true}}
          stub(Object).raise 
          stub(@object).current_settings.stub!.set(anything) { raise Appscript::CommandError.new("code","error","object","reference", "command") }
          capture(:stdout) { Terminitor::MacCore.new('/path/to').set_options(@object, :settings => :invalid_settings) }
        end.matches %r{Error: invalid settings}
      end

      context "name option" do
        should "ignore :name" do
          capture(:stdout) { Terminitor::MacCore.new('/path/to').set_options(@object, :name => 'hihi') }
        end.matches ""
      end

      context "bounds" do

        should "set bounds" do
          stub(@object).bounds.stub!.set(true)
          stub(@object).frame.stub!.set(true)
          stub(@object).position.stub!.set(true)
          Terminitor::MacCore.new('/path/to').set_options(@object, :bounds => true)
        end

      end
      
      context "unknown option" do
        
        should "return a message" do
          stub(Object).raise 
          stub(@object).unknown_option.stub!.set(anything) { raise Appscript::CommandError.new("code","error","object","reference", "command") }
          capture(:stdout) { Terminitor::MacCore.new('/path/to').set_options(@object, :unknown_option => true)}
        end.matches %r{Error}

      end
  
      context "selected" do
        should "set :selected" do
          mock(@object).selected.mock!.set(true)
          core = Terminitor::MacCore.new('/path/to')
          core.set_options(@object, :selected => true)
          core.set_delayed_options
        end
      end

      context "miniaturized" do
        should "set :miniaturized" do
          mock(@object).miniaturized.mock!.set(true)
          core = Terminitor::MacCore.new('/path/to')
          core.set_options(@object, :miniaturized => true)
          core.set_delayed_options
        end
      end

    end

  end
else
  context "MacCore" do
    puts "Nothing to do, you are not on OSX"
  end
end
