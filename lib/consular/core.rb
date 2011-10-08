module Consular
  # Defines the abstract definition of a core. This needs to be
  # subclassed and have the appropriate methods defined so that
  # the CLI runner knows how to execute the Termfile on
  # each core.
  #
  class Core
    attr_accessor :termfile

    # Instantiated the hash from the Termfile into the
    # core.
    #
    # @param [String] path
    #   Path to Termfile
    #
    # @api public
    def initialize(path)
      @termfile = Consular::DSL.new(path).to_hash
    end

    # Method called by runner to execute the Termfile setup
    # on the core.
    #
    # @api public
    def setup!
      raise NotImplementedError, ".setup! needs to be defined for it to be ran by `terminitor setup`"
    end

    # Method called by the runner to execute the Termfile
    # on the core.
    #
    # @api public
    def process!
      raise NotImplementedError, ".process! needs to be defined for it to be ran by `terminitor start`"
    end

  end
end
