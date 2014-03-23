require 'base64'

class Db < ActiveRecord::Base
    
    def self.checkCredentials(id, hash)
        rows = connection.select_all(%Q{select hash, status from "user" where name = #{sanitize(id)}})
        if (rows.to_ary().size != 1)
            return nil
        end

        server_hash = rows[0]["hash"] # that's h(h(p + N + l) + l)
        if hash == server_hash
            if rows[0]["status"] == 'A'
                return 'A'
            else
                return 'U'
            end
        else
            return nil
        end
    end

    def self.addUser(oldid, id, hash)
        transaction do
            rows = connection.select_all(%Q{select hash from "user" where name = #{sanitize(oldid)}})
            
            calc_hash = Digest::SHA2.hexdigest(hash + id)
            
            if rows.to_ary.size > 0
                connection.update(%Q{update "user" set hash = #{sanitize(hash)}, name = #{sanitize(id)} where name = #{sanitize(oldid)}})
            else
                connection.insert(%Q{insert into "user" (name, hash) values (#{sanitize(id)}, #{sanitize(hash)})})
            end
        end
    end

    def self.getAllUsers()
        rows = connection.select_all(%Q{select name, status from "user" order by name asc})
        return rows
    end

    def self.getUser(name)
        rows = connection.select_all(%Q{select name, status from "user" where name = #{sanitize(name)}})
        ret = nil
        if rows.to_ary.size == 1
            ret = rows[0]
        end
        return ret
    end

    def self.getAllKnownDevices()
        rows = connection.select_all(%Q{select id, name, type from device where name is not null order by name asc})
        return rows
    end

    def self.getAllUnknownDevices()
        rows = connection.select_all(%Q{select id from device where name is null order by id asc})
        return rows
    end

    def self.getDevice(id)
        rows = connection.select_all(%Q{select id, name, type from device where id = #{sanitize(id)}})
        ret = nil
        if rows.to_ary.size == 1
            ret = rows[0]
        end
        return ret
    end

    def self.addDevice(id, name, type)
        transaction do
            rows = connection.select_all(%Q{select name from device where id = #{sanitize(id)}})
            
            if rows.to_ary.size > 0
                connection.update(%Q{update device set name = #{sanitize(name)}, type = #{sanitize(type)} where id = #{sanitize(id)}})
            else
                connection.insert(%Q{insert into device (id, name, type) values (#{sanitize(id)}, #{sanitize(name)}, #{sanitize(type)})})
            end
        end
    end

    def self.mapImage()
        rows = connection.select_all(%Q{select map, content_type from map})
        ret = nil
        if rows.to_ary.size == 1
            encoded = rows[0]["map"]
            coded = ActiveRecord::Base.connection.unescape_bytea(encoded)
            ret = {:map => Base64.decode64(coded), :content_type => rows[0]["content_type"]}
        end
        return ret
    end

    def self.mapCoords()
        rows = connection.select_all(%Q{select latitude, longitude from map})
        ret = nil
        if rows.to_ary.size == 1
            ret = rows[0]
        end
        return ret
    end

    def self.setMap(raw, content_type, longitude, latitude)
        transaction do
            fields = {}
            if not raw.nil?
                coded = Base64.encode64(raw)
                encoded = ActiveRecord::Base.connection.escape_bytea(coded)
                fields["map"] = sanitize(encoded)
            end
            if not content_type.nil?
                fields["content_type"] = sanitize(content_type)
            end
            if longitude != 0 and latitude != 0
                fields["longitude"] = sanitize(longitude)
                fields["latitude"] = sanitize(latitude)
            end
            
            dbcoords = mapCoords()
            if dbcoords.nil?
                connection.insert(%Q{insert into map (} + fields.keys.join(', ') + %Q{) values (} + fields.values.join(', ') + %Q{)})
            else
                connection.update(%Q{update map set } + fields.map {|k,v| k + ' = ' + v}.join(', '))
            end
        end
    end

    def self.points(ids, time)
        clauses = []
        if not ids.nil? and ids.length > 0
            clauses.push('device_id in (' + ids.join(', ') + ')')
        end
        if time > 0
            clauses.push('dt > to_timestamp(' + time.to_s + ')')
        end
        sql = 'select device_id, EXTRACT(epoch FROM dt) as dt, latitude, longitude from point'
        if not clauses.empty?
            sql = sql + ' where ' + clauses.join(' and ')
        end
        sql += ' order by device_id asc, dt asc'

        rows = connection.select_all(sql)
        ret = {}
        for row in rows
            dev_id = row["device_id"]
            if ret[dev_id].nil?
                ret[dev_id] = {}
            end
            ret[dev_id][Float(row['dt'])] = {:y => Float(row['latitude']), :x => Float(row['longitude'])}
        end
        return ret
    end
end

