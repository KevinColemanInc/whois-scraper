require 'whois-parser'
require 'whois'

class WhoisWorker
  include Sidekiq::Worker
  def perform(domain)
    file_name = "out/#{domain}"
    return if File.file?(file_name)
    out_json = nil
    retry_counter = 0
    begin
      record = Whois.whois(domain)
      parser = record.parser
      out_json = {
        created_on: parser.created_on,
        nameserver: parser.nameservers&.first,
        registrar: parser.registrar,
        expires_on: parser.expires_on,
        registered: parser.registered?,
        domain: domain,
      }.to_json
    rescue StandardError => ex
      sleep(5)
      retry if retry_counter < 2 # retry twice
      retry_counter += 1
      out_json = { domain: domain, status: :failure, reason: ex.message }.to_json
    end

    File.open(file_name, 'w') { |file| file.write(out_json) }
  end
end