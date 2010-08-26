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
puts "Got #{tf_positions.size} positions from #{tf}."
positions += tf_positions
tf.logout!
puts "Logging out from #{tf}..."

sit = Brokers::ScotiaITrade.new
puts "Logging in to #{sit}..."
sit.login!
puts "Getting positions from #{sit}..."
sit_positions = sit.get_positions
puts "Got #{sit_positions.size} positions #{sit}."
positions += sit_positions
sit.logout!
puts "Logging out from #{sit}..."


puts positions.to_yaml