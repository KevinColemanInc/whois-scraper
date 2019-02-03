require 'whois-parser'
require 'whois'

class QueueWorker
  include Sidekiq::Worker
  def perform
    domains.each do |domain|
      WhoisWorker.perform_later(domain)
    end
  end
end