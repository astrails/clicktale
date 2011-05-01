require 'active_support'
require 'astrails/clicktale/controller'
require 'astrails/clicktale/helper'

module Astrails
  module Clicktale

    def self.init
      ActionController::Base.append_view_path(File.dirname(__FILE__) + "/../../app/views") if ActionController::Base.respond_to?(:append_view_path)
      ActionController::Base.send(:include, Astrails::Clicktale::Controller)
      ActionView::Base.send(:include, Astrails::Clicktale::Helper)
    end

    CONFIG = HashWithIndifferentAccess.new
    begin
      conffile = File.join(Rails.root, "config", "clicktale.yml")
      conf = YAML.load(File.read(conffile))
      CONFIG.merge!(conf[Rails.env])
    rescue
      puts "*" * 50
      puts "#{conffile} can not be loaded:"
      puts $!
      puts "*" * 50
    end

  end
end
