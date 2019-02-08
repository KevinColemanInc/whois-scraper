require 'csv'

class ToCSV
  CSV_FILE_NAME = 'output.csv'
  def self.process()
    File.new(CSV_FILE_NAME, "w")
    csv_keys = %w[created_on
                  nameserver
                  registrar
                  expires_on
                  registered
                  domain]
    CSV.open(CSV_FILE_NAME, "wb") do |csv|
      csv << csv_keys

      Dir.foreach('./out') do |item|
        next if item == '.' or item == '..'
        json = JSON.parse(File.read("./out/#{item}"))
        csv << csv_keys.map { |key| json[key] }
      end
    end
  end
end
