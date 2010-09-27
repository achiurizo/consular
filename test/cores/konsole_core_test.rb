require File.expand_path('../../teststrap',__FILE__)
if platform?('linux')
  require 'dbus'
  context "KonsoleCore" do
    # Stub out the initialization
    setup do
      bus = Object.new
      @konsole_service = Object.new
      @konsole = Object.new
      mock(DBus::SessionBus).instance { bus }
      mock(bus).service("org.kde.konsole") { @konsole_service }
      any_instance_of(Terminitor::KonsoleCore) do |core|
        stub(core).get_konsole { @konsole }
        stub(core).load_termfile('/path/to')  { true }
      end
    end
    setup { @konsole_core = Terminitor::KonsoleCore.new('/path/to') }

    context "open_tab" do
      setup do
        mock(@konsole).newSession { 1 }
        session_object = { "org.kde.konsole.Session" => Object.new }
        mock(@konsole_service).object("/Sessions/1") { session_object }
        mock(session_object).introspect { true }
      end
      asserts("returns last tab") { @konsole_core.open_tab }
    end

    context "open_window" do
      setup do
        mock(@konsole).currentSession { 2 }
        session_object = { "org.kde.konsole.Session" => Object.new }
        mock(@konsole_service).object("/Sessions/2") { session_object }
        mock(session_object).introspect { true }
      end
      asserts("returns last tab") { @konsole_core.open_window }
    end

    context "execute_command" do
      @tab = Object.new
      context "carriage return missing" do
        setup do
          mock(@tab).sendText("hasta\n") { true }
        end
        asserts("executes command") { @konsole_core.execute_command('hasta', :in => @tab) }
      end

      context "carriage return present" do
        setup do
          mock(@tab).sendText("hasta\n") { true }
        end
        asserts("executes command") { @konsole_core.execute_command("hasta\n", :in => @tab) }
      end
    end
  end
end
