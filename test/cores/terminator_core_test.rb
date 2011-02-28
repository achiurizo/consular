require File.expand_path('../../teststrap', __FILE__)

on_platform 'linux' do
  context "TerminatorCore" do
    helper(:fake_exec_success) { IO.popen("true").read }
    setup do
      @xdotool = `which xdotool`.chomp
      # stub xdotool invocations and termfile loading
      any_instance_of(Terminitor::TerminatorCore) do |core|
        stub(core).load_termfile('/path/to') { true }
        stub(core).window_id { "1" }
        stub(core).execute { |cmd| puts "Would run \"#{cmd}\"" }
      end
    end
    
    setup { @core = Terminitor::TerminatorCore.new('/path/to') }

    context "open_tab" do
      setup do
        mock(@core).execute("#{@xdotool} key --window 1 ctrl+shift+t") { fake_exec_success }
      end
      asserts("opens a new tab") { @core.open_tab }
    end

    context "open_window" do
      setup do
        mock(@core).execute("#{@xdotool} key --window 1 ctrl+shift+i") { fake_exec_success }
      end
      asserts("opens a new window") { @core.open_window }
    end

    context "execute_command" do
      setup do
        mock(@core).execute("#{@xdotool} type --window 1 \"hasta\n\"") { fake_exec_success }
      end
      asserts("executes command") { @core.execute_command('hasta') }
    end
  end
end
