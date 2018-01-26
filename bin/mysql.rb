require 'mysql2'

$stdout.sync = true
$stderr.sync = true

DB = "test"
NUM = 5

def connect(_host)
  host     = _host
  port     = 3306
  username = ""
  password = ""
  connect_timeout = 5
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
  NUM.times do |r|
    q += "(#{r}, 'test #{r}')#{r < NUM-1 ? ',' : ''}"
  end
  query(client, q)

  q = "INSERT INTO test.table_b VALUES "
  NUM.times do |r|
    q += "(#{r}, 'test #{r}')#{r < NUM-1 ? ',' : ''}"
  end
  query(client, q)
end

def update(client)
  NUM.times do |r|
    q = "UPDATE #{DB}.table_a SET id = id + 10000 WHERE id = #{r}"
    query(client, q)
  end

  NUM.times do |r|
    q = "UPDATE #{DB}.table_b SET id = id + 20000 WHERE id = #{r}"
    query(client, q)
  end
end

writer = ""
reader = ""
#reader = ""

client_w = connect(writer)
client_r = connect(reader)
setup_tables(client_w)

insert(client_w)

query(client_w, "BEGIN")
update(client_w)
query(client_w, "COMMIT")

#sleep 1

puts  "######### Writer ###########"
#query(client_w, "SELECT * FROM test.table_a ORDER BY id DESC LIMIT 1")
#query(client_w, "SELECT * FROM test.table_b ORDER BY id DESC LIMIT 1")

puts  "######### Reader ###########"
query(client_w, "BEGIN")

#results = query(client_r, "SELECT test.table_a.id,test.table_b.id FROM test.table_a,test.table_b WHERE test.table_a.name = test.table_b.name AND test.table_a.name = 'test #{NUM-1}'")

#results = query(client_r, "SELECT * FROM (SELECT test.table_a.id AS a_id,test.table_b.id AS b_id FROM test.table_a INNER JOIN test.table_b ON test.table_a.name = test.table_b.name) AS table_ab ORDER BY a_id DESC LIMIT 1")

#results.each do |row|
#  p row
#end

query(client_r, "SELECT * FROM test.table_a ORDER BY id DESC LIMIT 1")
query(client_r, "SELECT * FROM test.table_b ORDER BY id DESC LIMIT 1")

query(client_r, "SELECT * FROM test.table_a ORDER BY id DESC LIMIT 1")

query(client_w, "COMMIT")
