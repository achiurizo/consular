require 'rubygems'
require File.expand_path('../terminitor/yaml', __FILE__)
require File.expand_path('../terminitor/dsl', __FILE__)
require File.expand_path('../terminitor/runner', __FILE__)
require File.expand_path('../terminitor/abstract_core', __FILE__)
require File.expand_path('../terminitor/cli', __FILE__)

module Terminitor
  autoload :Version, File.expand_path('../terminitor/version', __FILE__)
  autoload :MacCore, File.expand_path('../terminitor/cores/mac_core', __FILE__)
end