require 'sinatra'
require 'haml'
require 'json'
require 'ruby-debug'

get '/' do
  holdings = []
  Dir['../data/*.yml'].each do |f|
    holdings << {:data => YAML.load(File.read(f))}
  end
  
  @history = {:x => [], :y => []}

  first = nil
  holdings.each do |h|
    data = h[:data]
    total = data.inject(0){|tot,pos| tot + pos[:value]}
    first = total unless first
    @history[:x] << Time.parse(data.first[:time]).to_i
    @history[:y] << total
  end
  
  current = {}
  holdings.last[:data].each do |h|
    ticker = h[:ticker] || "$$$"
    current[ticker] ||= 0
    current[ticker] += h[:value]
  end
  
  @current = {:values => current.values, 
              :legend => current.keys}
  
  haml :glint
end