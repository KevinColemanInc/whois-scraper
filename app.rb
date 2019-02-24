require 'fileutils'
require 'pmap'
require './unique_domains'
require './to_csv'
require './whois_to_csv'

# Set arguments
args = Hash[ ARGV.flat_map{|s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) } ]

file_name  = args['zone_file'] || './com.zone'
tld        = args['tld'] || 'com'
threads    = args['c']&.to_i || 35
chunk_size = args['chunk_size'] || 5_000
retry_failures = args['retry']

FileUtils.mkdir_p './out'
FileUtils.mkdir_p './failure'

puts "Running whois to csv."

if retry_failures
  puts 'retrying failures'
  Dir["./failure/*"].peach(threads) do |domain|
    File.delete(domain)
    WhoisToCSV.execute(domain.split('/').last, tld)
  end
else
  UniqueDomains.execute(file_name) unless args.key?('skip-unique-domains')
  File.open(UniqueDomains::DOMAINS_FILE_NAME, 'r') do |file|
    file.lazy.each_slice(chunk_size) do |chunks|
      chunks.peach(threads) do |domain|
        WhoisToCSV.execute(domain, tld)
      end
    end
  end
end

puts "Finished fetching whois"

ToCSV.process

puts "finished processing to csv"
