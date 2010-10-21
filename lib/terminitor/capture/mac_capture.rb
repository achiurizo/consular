module Terminitor
  # Captures terminal windows and tabs for Mac OS X 
  class MacCapture < AbstractCapture
    include Appscript
    
    # Defines what options of window or tab to capture and how
    # just in case we'll need to get other properties
    OPTIONS_MASK = {
      :window => {
        :bounds => "bounds"
      },
      :tab => {
        :settings => "current_settings.name"
      }
    }
    
    # Initialize @terminal with Terminal.app, Load the Windows, store the Termfile
    # Terminitor::MacCore.new('/path')
    def initialize
      @terminal = app('Terminal.app')
    end

    # Returns settings of currently opened windows and tabs.    
    def capture_windows
      windows = []
      # for some reason terminal.windows[] contain duplicated elements
      @terminal.windows.get.uniq.each do |window| 
        if window.visible.get
          tabs = window.tabs.get.inject([]) do |tabs, tab|
            tabs << {:options => object_options(tab)}
          end
          windows << {:options => object_options(window), :tabs => tabs}
        end
      end
      windows
    end
    
    # Returns hash of options of window or tab
    def object_options(object)
      options = {}
      class_ =  object.class_.get
      if class_ && OPTIONS_MASK[class_]
        OPTIONS_MASK[class_].each_pair do |option, getter|
          value = object.instance_eval(getter).get
          options[option] = value
        end
      end
      options
    end
  end
end