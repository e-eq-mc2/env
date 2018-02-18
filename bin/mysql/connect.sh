HOST=
USERNAME=
PASSWORD=

while :
do
  echo "########"
  date
  mysql -h $HOST -P 3306 -u $USERNAME -p$PASSWORD -e "SHOW FULL PROCESSLIST; SELECT SLEEP(1);"
done
