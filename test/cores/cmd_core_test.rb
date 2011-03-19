require File.expand_path('../../teststrap', __FILE__)

on_platform 'mingw32', 'win32', 'mswin32' do

  context "CmdCore" do
    setup do
        any_instance_of(Terminitor::CmdCore) do |core|
        stub(core).load_termfile('/path/to') { true }
        stub(core).window_id { "1" }
      end
    end
    setup { Terminitor::CmdCore.new('/path/to') }
    

    context "open_window" do
      setup{ topic.open_window }  #topic is switched from cmdcore to windowsconsole.
      asserts_topic.kind_of(Terminitor::WindowsConsole)
      denies("window id is nil"){ topic.pid.nil? }
      asserts("killed window returns id"){topic.kill!}
    end


    #currently same thing, we emulate tab as window.
    context "open_tab" do
      setup{ topic.open_tab } 
      asserts_topic.kind_of(Terminitor::WindowsConsole)
      denies("window id is nil"){ topic.pid.nil? }
      asserts("killed window returns id"){topic.kill!}
    end


    context "execute" do
      hookup { @window = topic.open_window }
      hookup { mock(@window).send_command("hello\n") { true }}
      asserts("can execute") { topic.execute_command "hello", :in=>@window }
      asserts("that can kill window after execute") { @window.kill! }
    end
  end
end
