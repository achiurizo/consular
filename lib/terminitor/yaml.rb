require 'yaml'

module Terminitor
  # This class holds the legacy YAML sytnax for Terminitor
  class Yaml
    attr_accessor :file
    
    # Load in the Yaml file...
    # @param [String] Path to termfile
    def initialize(path)
      @file = YAML.load File.read(path)
    end
    
    # Returns yaml file as Terminitor formmatted hash
    # @return [Hash] Hash format of termfile
    def to_hash
      combined = @file.inject({}) do |base, item| 
        item = {item.keys.first => {:commands => item.values.first, :options => {}}}
        base.merge!(item)
        base
      end # merge the array of hashes.
       { :setup => nil, :windows => { 'default' => {:tabs => combined} } }
    end

  end
end
