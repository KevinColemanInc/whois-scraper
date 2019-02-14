require 'whois-parser'
require 'whois'

class WhoisToCSV
  def self.write(out_json)
    File.open("./out/whois_results_#{Thread.current.object_id}.csv", 'a') { |f| 
      f.puts(out_json.values.join('|'))
    }
  end

  def self.execute(domain, tld)
    out_json = nil
    retry_counter = 0
    begin
      record = Whois.whois("#{domain.strip}.#{tld}")
      parser = record.parser
      out_json = {
        domain: domain,
        status: :success,
        reason: nil,
        created_on: parser.created_on,
        nameserver: parser.nameservers&.first&.name,
        registrar: parser.registrar&.url,
        expires_on: parser.expires_on,
        registered: parser.registered?
      }
      puts "success - #{domain}"
    rescue Whois::AttributeNotImplemented => ex
      out_json = { domain: domain, status: :failure, reason: ex.message }
    rescue StandardError => ex
      puts ex
      puts ex.message
      sleep(5)
      retry if retry_counter < 2 # retry twice
      puts 'HARD FAILURE ' + domain
      retry_counter += 1
      out_json = { domain: domain, status: :failure, reason: ex.message }

    File.open("./failure/#{domain}.json", 'a') { |f| 
      f.puts(out_json.to_json)
    }
    end

    write(out_json)
    raise "FAILURE #{domain}" if out_json[:status] == :failure
    return nil
  end
end