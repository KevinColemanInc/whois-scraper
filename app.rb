require 'fileutils'
require 'pmap'
require './unique_domains'
require './to_csv'
require './whois_to_json'

# Set arguments
args = Hash[ ARGV.flat_map{|s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) } ]

file_name  = args['zone_file'] || './com.zone'
tld        = args['tld'] || 'com'
threads    = args['c'] || 5
chunk_size = args['chunk_size'] || 5_000

FileUtils.mkdir_p './out'
UniqueDomains.execute(file_name) unless args.key?('skip-unique-domains')

puts "Running whois to json."

File.open(UniqueDomains::DOMAINS_FILE_NAME, 'r') do |file|
  file.lazy.each_slice(chunk_size) do |chunks|
    chunks.peach(threads) do |domain|
      WhoisToJson.execute(domain, tld)
    end
  end
end

puts "Finished fetching whois"

ToCSV.process

puts "finished processing to csv"
