#!/bin/bash

set -x
set -e

USER=f14_power
DB=f14_power
PWD=f14_power_gfhjkm

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FILE="$DIR/f14_power.sql"


export PGPASSWORD="${PWD}"
dropdb -h localhost -U "${USER}" "${DB}"

createdb -h localhost -U "${USER}" -E UTF-8 "${DB}"

cat "$FILE" | sed "s/__DATABASE_NAME__/${DB}/g" | psql -h localhost -e -U "${USER}" "${DB}"

insert=`ruby "$DIR"/admin_password.rb admin admin`
echo $insert | psql -h localhost -e -U "${USER}" "${DB}"

echo "Creating default parameters"
cat "$DIR"/parameters.sql | psql -h localhost -e -U "${USER}" "${DB}"

