require 'mysql2'
require 'awesome_print'

$stdout.sync = true
$stderr.sync = true

def submit(client, query)
  results = client.query(query)

  puts "----"
  puts "Query(#{Time.now}): #{query}"
  puts "Resulut:"
  return if results.nil?

  results.each do |row|
    ap row
  end

  results
end

def connect
  host     = "aurora-test.csifi3o3ntjn.ap-northeast-1.rds.amazonaws.com"
  port     = 3306
  username = "root"
  password = "root0000"
  connect_timeout = 5
  client = Mysql2::Client.new(
    :host => host, 
    :port => port, 
    :username => username, 
    :password => password,
    :connect_timeout => connect_timeout
  )
end

def setup
  client = connect

  query = %q{SHOW databases}
  submit(client, query)

  query = %q{USE test}
  submit(client, query)

  query = %q{SELECT table_name FROM information_schema.tables WHERE table_name = 'aws'}
  result = submit(client, query)

  query = %q{DROP TABLE aws}
  submit(client, query)

  query = %q{CREATE TABLE aws(id INT NOT NULL PRIMARY KEY, name VARCHAR(255))}
  submit(client, query)

  client
end


client = nil
100000.times do |i|
  begin
    sleep 1
    client = setup if client.nil?
    query = %Q{INSERT INTO aws VALUES(#{i}, 'test#{i}')}
    submit(client, query)

    query = %q{SELECT * FROM aws ORDER BY id DESC LIMIT 1}
    submit(client, query)
  rescue Exception => e
    puts "Error(#{Time.now}): #{e}"
    client = nil
  end
end

query = %q{SELECT * FROM aws}
submit(client, query)
