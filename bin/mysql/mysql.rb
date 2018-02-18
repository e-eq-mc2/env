require 'mysql2'

$stdout.sync = true
$stderr.sync = true

USERNAME = 
PASSWORD = 
WRITER_ENDPOINT = 
READER_ENDPOINT = 

DB       = "test"
NUM_ROWS = 10000

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

  #puts "----"
  #puts "Query(#{Time.now}): #{q}"
  puts "Resulut:"
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

def insert(client, base: 0)
  q = "INSERT INTO #{DB}.table_a VALUES "
  NUM_ROWS.times do |r|
    id = base + r
    q += "(#{id}, 'test #{id} #{Time.now}')#{r < NUM_ROWS-1 ? ',' : ''}"
  end
  query(client, q)

  q = "INSERT INTO #{DB}.table_b VALUES "
  NUM_ROWS.times do |r|
    id = base + r
    q += "(#{id}, 'test #{id} #{Time.now}')#{r < NUM_ROWS-1 ? ',' : ''}"
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
reader_endpoint = READER_ENDPOINT

client_w = connect(writer_endpoint)
client_r = connect(reader_endpoint)
setup_tables(client_w)

10000.times do |i|
  insert(client_w, base: i * NUM_ROWS)
end

query(client_w, "BEGIN")
#update(client_w)
query(client_w, "COMMIT")

#sleep 1

puts  "######### Writer ###########"
#query(client_w, "SELECT * FROM #{DB}.table_a ORDER BY id DESC LIMIT 1")
#query(client_w, "SELECT * FROM #{DB}.table_b ORDER BY id DESC LIMIT 1")

puts  "######### Reader ###########"
query(client_w, "BEGIN")

#results = query(client_r, "SELECT #{DB}.table_a.id,#{DB}.table_b.id FROM #{DB}.table_a,#{DB}.table_b WHERE #{DB}.table_a.name = #{DB}.table_b.name AND #{DB}.table_a.name = 'test #{NUM_ROWS-1}'")

#results = query(client_r, "SELECT * FROM (SELECT #{DB}.table_a.id AS a_id,#{DB}.table_b.id AS b_id FROM #{DB}.table_a INNER JOIN #{DB}.table_b ON #{DB}.table_a.name = #{DB}.table_b.name) AS table_ab ORDER BY a_id DESC LIMIT 1")

#results.each do |row|
#  p row
#end

query(client_r, "SELECT * FROM #{DB}.table_a ORDER BY id DESC LIMIT 1")
query(client_r, "SELECT * FROM #{DB}.table_b ORDER BY id DESC LIMIT 1")

query(client_r, "SELECT * FROM #{DB}.table_a ORDER BY id DESC LIMIT 1")

query(client_w, "COMMIT")
