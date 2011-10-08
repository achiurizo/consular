lib_dir = File.expand_path("..", __FILE__)
$:.unshift( lib_dir ) unless $:.include?( lib_dir )
      
require 'consular/version'
require 'consular/core'
require 'consular/dsl'

module Consular
end
