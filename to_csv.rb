require 'csv'

csv_keys = %i[created_on
              nameserver
              registrar
              expires_on
              registered
              domain]
CSV.open("output.csv", "wb") do |csv|
  csv << csv_keys

  Dir.foreach('/out') do |item|
    next if item == '.' or item == '..'
    json = Json.parse(File.read(item))
    csv << csv_keys.map { |key| json[key] }
  end
end
