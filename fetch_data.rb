$: << File.dirname(__FILE__)

require 'rubygems'
require 'brokers/trade_freedom'
require 'brokers/scotia_itrade'

positions = []

tf = Brokers::TradeFreedom.new
puts "Logging in to #{tf}..."
tf.login!
puts "Getting positions from #{tf}..."
tf_positions = tf.get_positions

if tf_positions.size < 1
  $stderr.puts "FAILED TO GET DATA FROM #{tf}!"
  exit 1
end

puts "Got #{tf_positions.size} positions from #{tf}."
positions += tf_positions
tf.logout!
puts "Logging out from #{tf}..."

sit = Brokers::ScotiaITrade.new
puts "Logging in to #{sit}..."
sit.login!
puts "Getting positions from #{sit}..."
sit_positions = sit.get_positions

if sit_positions.size < 1
  $stderr.puts "FAILED TO GET DATA FROM #{sit}!"
  exit 1
end

puts "Got #{sit_positions.size} positions #{sit}."
positions += sit_positions
sit.logout!
puts "Logging out from #{sit}..."


filename = Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')+'.yml'
File.open(File.dirname(__FILE__)+'/data/'+filename, 'w') do |f|
  f.puts positions.to_yaml
end

puts "Total Value: $#{positions.inject(0){|tot,pos| tot + pos[:value]}}"
