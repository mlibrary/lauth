#!/usr/bin/env bash

directory=$(dirname "$0")

while getopts u:p:h:P: option
do
    case "${option}"
        in
        u)u=${OPTARG};;
        p)p=${OPTARG};;
        h)h=${OPTARG};;
        P)P=${OPTARG};;
    esac
done

shift "$(($OPTIND-1))"
d=$@
database="${d:=lauth}"

user="${u:=root}"
password="${p:=}"
host="${h:=localhost}"
port="${P:=3306}"

echo "directory : $directory"
echo "     user : $user"
echo " password : $password"
echo "     host : $host"
echo "     port : $port"
echo " database : $database"

mysql --user=$user --host=$host --port=$port --password=$password $database < "$directory/tables.sql"
mysql --user=$user --host=$host --port=$port --password=$password $database < "$directory/root.sql"
mysql --user=$user --host=$host --port=$port --password=$password $database < "$directory/keys.sql"