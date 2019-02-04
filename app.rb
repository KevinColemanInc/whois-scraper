require 'fileutils'
require 'csv'

FileUtils.mkdir_p 'out'

zone_file = ARGV[1] || 'zone_file'

puts "starting to fetch #{domains.length}"
domains.peach do |domain|
  WhoisWorker.new(domain).execute
end

puts "finished fetching #{domains.length}"

ToCSV.process

puts "finished processing to csv"
