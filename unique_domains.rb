class UniqueDomains
  DOMAINS_FILE_NAME = "./domains.txt"
  def self.execute(file_name)
    File.new(DOMAINS_FILE_NAME, "w") unless File.file?(DOMAINS_FILE_NAME)
    last_file_domain = `tail -n 1 #{DOMAINS_FILE_NAME}`
    last_file_domain = last_file_domain === '' ? nil : last_file_domain.strip
    last_domain = nil

    puts "Reading zone file creating a unique list of domains. This can take a long time"
    File.open(file_name, 'r').each do |line|
      words = line.split(' ')
      next if words[1] != 'NS'
      domain = words.first
      if last_file_domain && last_file_domain != domain
        next
      else
        last_file_domain = nil
      end

      if last_domain == domain
        next
      end

      File.write(DOMAINS_FILE_NAME, "#{domain}\n", mode: 'a')
      last_domain = domain
    end
  end
end
