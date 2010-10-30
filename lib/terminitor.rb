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
  when %r{linux}
    require 'dbus'
    autoload :KonsoleCore,    'terminitor/cores/konsole_core'
    autoload :KonsoleCapture, 'terminitor/capture/konsole_capture'    
  end
end
