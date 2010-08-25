$: << File.dirname(__FILE__)

require 'rubygems'
require 'brokers/trade_freedom'
require 'brokers/scotia_itrade'

positions = []

# tf = Brokers::TradeFreedom.new
# puts "Logging in to TradeFreedom..."
# tf.login!
# puts "Getting positions..."
# tf_positions = tf.get_positions
# puts "Got #{tf_positions.size} positions."
# positions += tf_positions
# tf.logout!
# puts "Logging out..."

sit = Brokers::ScotiaITrade.new
puts "Logging in to #{sit}..."
sit.login!
puts "Getting positions..."
sit_positions = sit.get_positions
puts "Got #{sit_positions.size} positions."
positions += sit_positions
sit.logout!
puts "Logging out..."


puts positions.to_yaml