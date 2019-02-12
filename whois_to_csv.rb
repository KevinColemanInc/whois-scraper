require 'whois-parser'
require 'whois'

class WhoisToCSV
  def self.lock(path)
    # We need to check the file exists before we lock it.
    if File.exist?(path)
      File.open(path).flock(File::LOCK_EX)
    end
  
    # Carry out the operations.
    yield
  
    # Unlock the file.
    File.open(path).flock(File::LOCK_UN)
  end

  def self.write(out_json)
    File.open("whois_results.csv", 'a') { |f| 
      f.flock(File::LOCK_EX)
      f.puts(out_json.values.join('|'))
    }
  end

  def self.execute(domain, tld)
    out_json = nil
    retry_counter = 0
    begin
      record = Whois.whois("KITCHENTABLESET.com")#{domain}.#{tld}")
      parser = record.parser
      out_json = {
        created_on: parser.created_on,
        nameserver: parser.nameservers&.first&.name,
        registrar: parser.registrar&.url,
        expires_on: parser.expires_on,
        registered: parser.registered?,
        domain: domain,
        status: :success,
        reason: nil
      }
    rescue StandardError => ex
      puts ex
      puts ex.message
      sleep(5)
      retry if retry_counter < 2 # retry twice
      retry_counter += 1
      out_json = { domain: domain, status: :failure, reason: ex.message }
    end

    write(out_json)
    raise "FAILURE #{domain}" if out_json[:status] == :failure
    return nil
  end
end