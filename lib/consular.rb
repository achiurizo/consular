lib_dir = File.expand_path("..", __FILE__)
$:.unshift( lib_dir ) unless $:.include?( lib_dir )

require 'consular/version'
require 'consular/core'
require 'consular/dsl'
require 'consular/cli'

module Consular

  class << self
    attr_accessor :global_path, :default_editor

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

    # Returns the global script path. If not set,
    # defaults to ~/.config/consular
    #
    # @param [String] path
    #   File name in path
    #
    # @return [String] global script path
    #
    # @api public
    def global_path(path = nil)
      root = @global_path || File.join(ENV['HOME'],'.config','consular')
      File.join root, (path || '')
    end

    # Configure Consular options.
    #
    # @param [Proc] block
    #   Configuration block
    #
    # @example
    #
    #   Consular.configure do |c|
    #     c.global_path    = '~/.consular'
    #     c.default_editor = 'vim'
    #   end
    #
    # @api public
    def configure(&block)
      yield self
    end

  end
end
