require 'yaml'

holdings = []
Dir['data/*.yml'].each do |f|
  holdings << {:data => YAML.load(File.read(f))}
end

first = nil
holdings.each do |h|
  data = h[:data]
  total = data.inject(0){|tot,pos| tot + pos[:value]}
  first = total unless first
  puts "%s\t$%.2f\t%6.2f%" % [data.first[:time].to_s, total, ((total - first)/total)*100]
end
