class SqliteManager

  DB_LOCATION = "./domains.db"

  def setup
    db.execute <<-SQL
      create table domains (
        domain varchar(150),
        nameserver varchar(150),
        registrar varchar(50),
        expires_on DATETIME,
        created_on DATETIME,
        registered boolean,
        reason varchar(200),
        success boolean,
      );
    SQL
  end

  def db
    @db ||= SQLite3::Database.new DB_LOCATION
  end

  def add_domain(domain_info)
    db.execute("INSERT INTO domains (#{domain_info.keys.join(', ')}) 
                VALUES (?, ?, ?, ?)", domain_info.values)
  end
end
