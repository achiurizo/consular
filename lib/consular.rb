lib_dir = File.expand_path("..", __FILE__)
$:.unshift( lib_dir ) unless $:.include?( lib_dir )
      
require 'consular/version'
require 'consular/core'
require 'consular/dsl'
require 'consular/cli'

module Consular

  class << self

    # Returns all avaialble cores.
    #
    # @return [Array<Core>] Consular cores.
    #
    # @api semipublic
    def cores
      @cores ||= []
    end

    # Add a core to Consular.
    #
    # @param [Core] klass
    #   Core to add.
    #
    # @example
    #   Consular.add_core Consular::Cores::OSX
    #
    # @api semipublic
    def add_core(klass)
      cores << klass
    end

  end
end
