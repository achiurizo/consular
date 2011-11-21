module Consular
  # Defines the abstract definition of a core. This needs to be
  # subclassed and have the appropriate methods defined so that
  # the CLI runner knows how to execute the Termfile on
  # each core. You will need to add the core to Consular like so:
  #
  #   Consular.add_core self
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
      raise NotImplementedError, ".setup! needs to be defined for it to be ran by `consular setup`"
    end

    # Method called by the runner to execute the Termfile
    # on the core.
    #
    # @api public
    def process!
      raise NotImplementedError, ".process! needs to be defined for it to be ran by `consular start`"
    end

    class << self
      # Checks to see if the current system/terminal is the right
      # one to use for this core. This is called by the CLI to check
      # if a particular core should be used.
      #
      # @return [Boolean] Whether the current system is valid.
      #
      # @api public
      def valid_system?
        raise NotImplementedError, ".valid_system? needs to be defined for Consular to determine what system is belongs to."
      end

      # Captures the current terminal settings for the system. It will
      # return a hash format like that of Consular::DSL so that Consular
      # can write it back out into a Termfile.
      #
      # @return [Hash] Consular style hash.
      #
      # @api public
      def capture!
        raise NotImplementedError, "capture! is currently unavailable for this core."
      end
    end

  end
end
