require 'mysql2'

$stdout.sync = true
$stderr.sync = true

USERNAME = 
PASSWORD = 
WRITER_ENDPOINT = 

DB       = "test"
NUM_ROWS = 5

def connect(_host)
  host     = _host
  port     = 3306
  username = USERNAME
  password = PASSWORD
  connect_timeout = 30
  client = Mysql2::Client.new(
    :host => host,
    :port => port,
    :username => username,
    :password => password,
    :connect_timeout => connect_timeout
  )
end

def query(client, q)
  results = client.query(q, :cast => false)

  puts "----"
  puts "Query(#{Time.now}): #{q}"
  #puts "Resulut:"
  return if results.nil?

  results.each do |row|
    p row
  end

  results
end

def setup_tables(client)
  query(client, "DROP DATABASE IF EXISTS #{DB}")
  query(client, "CREATE DATABASE #{DB}")
  query(client, "SHOW databases")
  query(client, "DROP TABLE IF EXISTS #{DB}.table_a")
  query(client, "DROP TABLE IF EXISTS #{DB}.table_b")
  query(client, "CREATE TABLE #{DB}.table_a(id INT NOT NULL PRIMARY KEY, name VARCHAR(255))")
  query(client, "CREATE TABLE #{DB}.table_b(id INT NOT NULL PRIMARY KEY, name VARCHAR(255))")
end

def insert(client)
  q = "INSERT INTO #{DB}.table_a VALUES "
  NUM_ROWS.times do |r|
    q += "(#{r}, 'test #{r}')#{r < NUM_ROWS-1 ? ',' : ''}"
  end
  query(client, q)

  q = "INSERT INTO #{DB}.table_b VALUES "
  NUM_ROWS.times do |r|
    q += "(#{r}, 'test #{r}')#{r < NUM_ROWS-1 ? ',' : ''}"
  end
  query(client, q)
end

def update(client)
  NUM_ROWS.times do |r|
    q = "UPDATE #{DB}.table_a SET id = id + 10000 WHERE id = #{r}"
    query(client, q)
  end

  NUM_ROWS.times do |r|
    q = "UPDATE #{DB}.table_b SET id = id + 20000 WHERE id = #{r}"
    query(client, q)
  end
end

writer_endpoint = WRITER_ENDPOINT
client_w = connect(writer_endpoint)
#setup_tables(client_w)
#insert(client_w)

loop do
  begin
    sleep 1
    client_w = connect(writer_endpoint) if client_w.nil?

    query(client_w, "SHOW FULL PROCESSLIST")

    client_w.close()
    client_w = nil

    #query(client_w, "SELECT * FROM #{DB}.table_a ORDER BY id DESC LIMIT 1")
    #query(client_w, "select AURORA_VERSION();")
    #query(client_w, 'select @@aurora_version;')
  rescue Interrupt
    abort
  rescue Exception => e
    puts "Error(#{Time.now}): #{e}"
    client_w = nil
    retry
  end
end
