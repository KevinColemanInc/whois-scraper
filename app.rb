require 'fileutils'
require 'pmap'
require './unique_domains'
require './to_csv'
require './whois_to_json'

CHUNKSIZE = 5_000
THREADS = 5

FileUtils.mkdir_p './out'
args = Hash[ ARGV.flat_map{|s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) } ]

file_name = args['file_name'] || './com.zone'
tld = args['tld'] || 'com'
UniqueDomains.execute(file_name) unless args['skip-unique-domains']

puts "Running whois to json."

chunked_domains = []
File.open(UniqueDomains::DOMAINS_FILE_NAME, 'r').each do |line|
  chunked_domains << line
  next if chunked_domains.length < CHUNKSIZE
  chunked_domains.peach(THREADS) do |domain|
    WhoisToJson.execute(domain, tld)
  end
  chunked_domains = []
end

puts "Finished fetching whois"

ToCSV.process

puts "finished processing to csv"
