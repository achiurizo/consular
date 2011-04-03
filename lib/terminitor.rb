lib_dir = File.expand_path("..", __FILE__)
$:.unshift( lib_dir ) unless $:.include?( lib_dir )
      
require 'terminitor/yaml'
require 'terminitor/dsl'
require 'terminitor/runner'
require 'terminitor/abstract_core'
require 'terminitor/cli'
require 'terminitor/abstract_capture'

module Terminitor
  autoload :Version, 'terminitor/version'
  case RUBY_PLATFORM.downcase
  when %r{darwin}
    require 'appscript'
    autoload :MacCore,        'terminitor/cores/mac_core'
    autoload :MacCapture,     'terminitor/capture/mac_capture'  
    autoload :ItermCore,      'terminitor/cores/iterm_core'
    autoload :ItermCapture,   'terminitor/capture/iterm_capture' 
  when %r{linux}
    require 'dbus'
    autoload :KonsoleCore,    'terminitor/cores/konsole_core'
    autoload :KonsoleCapture, 'terminitor/capture/konsole_capture'
    autoload :TerminatorCore, 'terminitor/cores/terminator_core'
    autoload :TerminatorCapture, 'terminitor/capture/terminator_capture'
  when %r{mswin|mingw}
	require 'windows/process'
	require 'windows/handle'
	require 'win32/process'
	require 'windows/window'

	require 'terminitor/cores/cmd_core/input'
	require 'terminitor/cores/cmd_core/windows_console'
	autoload :CmdCore, 'terminitor/cores/cmd_core/cmd_core'
  end
end
