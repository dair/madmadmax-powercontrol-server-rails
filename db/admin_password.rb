#!/usr/bin/env ruby

require 'digest/sha3'

login = ARGV[0]
password = ARGV[1]

hash1 = Digest::SHA3.hexdigest(password + ':' + login)

hash2 = Digest::SHA3.hexdigest(hash1 + ':' + login)

puts "insert into \"user\" (name, status, hash) values ('#{login}', 'A', '#{hash2}');"
