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

psql -h localhost -U "${USER}" "${DB}" < "$FILE"

insert=`ruby "$DIR"/admin_password.rb admin admin`
echo $insert | psql -h localhost -U "${USER}" "${DB}"
