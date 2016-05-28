#!/bin/bash

set -x
set -e

USER=mm_power
DB=mm_power
PWD=mm_power_gfhjkm

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FILE="$DIR/mm_power.sql"


export PGPASSWORD="${PWD}"
dropdb -h localhost -U "${USER}" "${DB}" || true

createdb -h localhost -U "${USER}" -E UTF-8 "${DB}"

cat "$FILE" | sed "s/__DATABASE_NAME__/${DB}/g" | psql -h localhost -e -U "${USER}" "${DB}"

insert=`ruby "$DIR"/admin_password.rb admin admin`
echo $insert | psql -h localhost -e -U "${USER}" "${DB}"

echo "Creating default parameters"
cat "$DIR"/parameters.sql | psql -h localhost -e -U "${USER}" "${DB}"

