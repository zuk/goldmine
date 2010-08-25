require 'mechanize'
require 'nokogiri'
require 'active_support'

require 'yaml'

module Brokers
  class Base
    def initialize
      @mech = Mechanize.new
    end
    
    def read_credentials!(key)
      creds_filename = File.dirname(__FILE__) + '/credentials.yml'
      @credentials = HashWithIndifferentAccess.new(YAML.load(File.open(creds_filename)))[key]
    end
    
    protected
    def as_f(str)
      str.gsub(/[^\d\.\-]/,'').to_f
    end
  
    def as_i(str)
      str.gsub(/[^\d\.\-]/,'').to_i
    end
  end
end