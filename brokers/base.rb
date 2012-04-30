require 'mechanize'
require 'nokogiri'
require 'yaml'
require 'hashie'

module Brokers
  class Base
    def initialize
      @mech = Mechanize.new
    end
    
    def read_credentials!(key)
      creds_filename = File.dirname(__FILE__) + '/credentials.yml'
      creds = Hashie::Mash.new YAML.load(File.open(creds_filename))
      @credentials = creds[key]
    end
    
    protected
    def as_f(str)
      str.gsub(/[^\d\.\-]/,'').to_f
    end
  
    def as_i(str)
      str.gsub(/[^\d\.\-]/,'').to_i
    end
    
    def now_string
      Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
    end
  end
end
