module Terminitor
  # KDE Konsole Core for Terminitor
  # This Core manages all the interaction with Konsole's dbus interface 
  class KonsoleCore < AbstractCore
    def initialize(path)
      super
      bus = DBus::SessionBus.instance
      @konsole_service = bus.service("org.kde.konsole")
      @konsole = get_konsole
    end
 
    # Executes the Command
    # execute_command 'cd /path/to', {}
    def execute_command(cmd, options = {})
      # add carriange return if missing, otherwise the command won't be executed
      cmd += "\n" if (cmd =~ /\n\Z/).nil?
      options[:in].sendText(cmd)
    end

    # Opens a new tab and returns itself.
    def open_tab
      session_number = @konsole.newSession
      session_object = @konsole_service.object("/Sessions/#{session_number}")
      session_object.introspect
      session_object["org.kde.konsole.Session"]
    end

    # Opens a new window and returns the tab object.
    def open_window
      session_number = @konsole.currentSession
      session_object = @konsole_service.object("/Sessions/#{session_number}")
      session_object.introspect
      session_object["org.kde.konsole.Session"]
    end

    protected

    def get_konsole
     begin
        konsole_object = @konsole_service.object("/Konsole")
        konsole_object.introspect
        return konsole_object["org.kde.konsole.Konsole"]
      rescue DBus::Error => e
        if e.dbus_message.error_name =="org.freedesktop.DBus.Error.ServiceUnknown"
          system "konsole"
          sleep(2)
          retry
        else
          raise e
        end
      end
    end
  end
end
