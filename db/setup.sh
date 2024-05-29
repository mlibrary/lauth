#!/usr/bin/env bash

directory=$(dirname "$0")

while getopts u:p:h:P:arb option
do
    case "${option}"
        in
        u)u=${OPTARG};;
        p)p=${OPTARG};;
        h)h=${OPTARG};;
        P)P=${OPTARG};;
        a)all="true";;
        k)keys="true";;
        r)root="false";;
        b)debug="true";;
    esac
done

shift "$(($OPTIND-1))"
d=$@
database="${d:=lauth}"

user="${u:=root}"
password="${p:=}"
host="${h:=localhost}"
port="${P:=3306}"

if [[ $debug == "true" ]]; then
  echo "directory : $directory"
  echo "     user : $user"
  echo " password : $password"
  echo "     host : $host"
  echo "     port : $port"
  echo " database : $database"
  echo " add data : ${all:=false}"
  echo " use root : ${root:=true}"
  echo ""
fi


if [[ $root == "true" ]]; then
  mariadb -u root --host=$host --port=$port -e "CREATE DATABASE ${database} DEFAULT CHARACTER SET utf8"
  mariadb -u root --host=$host --port=$port -e "GRANT ALL ON ${database}.* TO ${user}@'%' IDENTIFIED by '${password}'"
fi

mariadb --user=$user --host=$host --port=$port --password=$password $database < "$directory/tables.sql"

if [[ $all == "true" ]]; then
  mariadb --user=$user --host=$host --port=$port --password=$password $database < "$directory/root.sql"
  mariadb --user=$user --host=$host --port=$port --password=$password $database < "$directory/keys.sql"
  mariadb --user=$user --host=$host --port=$port --password=$password $database < "$directory/test-fixture.sql"
  mariadb --user=$user --host=$host --port=$port --password=$password $database < "$directory/network.sql"
  mariadb --user=$user --host=$host --port=$port --password=$password $database < "$directory/delegation.sql"
  mariadb --user=$user --host=$host --port=$port --password=$password $database < "$directory/projection.sql"
elif [[ $keys == "true" ]]; then
  mariadb --user=$user --host=$host --port=$port --password=$password $database < "$directory/keys.sql"
fi
