require 'yaml'

module Terminitor
  # This class holds the legacy YAML sytnax for Terminitor
  class Yaml
    attr_accessor :file
    
    # Load in the Yaml file...
    def initialize(path)
      @file = YAML.load File.read(path)
    end
    
    # Returns yaml file as Terminitor formmatted hash
    def to_hash
      combined = @file.inject({}) {|base, item| base.merge!(item) ; base } # merge the array of hashes.
      { :setup => nil, :windows => { 'default' => combined } }
    end

  end
end
