require 'whois-parser'
require 'whois'

class WhoisToJson
  def self.execute(domain, tld)
    file_name = "out/#{domain}"
    return if File.file?(file_name)
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

    file_name = "FAILURE#{file_name}" if out_json[:status] == :failure

    File.open(file_name, 'w') { |file| file.write(out_json.to_json) }
    raise "FAILURE #{domain}" if out_json[:status] == :failure
    return nil
  end
end