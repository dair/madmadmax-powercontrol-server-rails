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

    def self.addDevice(id, desc)
        transaction do
            rows = connection.select_all(%Q{select id, name from device where id = #{sanitize(id)}})
            
            if rows.to_ary.size > 0
                connection.update(%Q{update device set description = #{sanitize(desc)} where id = #{sanitize(id)}})
            else
                connection.insert(%Q{insert into device (id, description) values (#{sanitize(id)}, #{sanitize(desc)})})
            end
        end
    end

    def self.editDevice(id, name, type)
        connection.update(%Q{update device set name = #{name.nil? ? "NULL": sanitize(name)}, type = #{type.nil? ? "NULL" : sanitize(type)} where id = #{sanitize(id)}})
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

    def self.addDeviceMsg(id, type, msg, t)
        repeat = true
        while repeat
            begin
                connection.insert("insert into device_ping (device_id, dt_device, msg_type, message) values (#{sanitize(id)}, TIMESTAMP WITHOUT TIME ZONE 'epoch' + #{sanitize(t)} * INTERVAL '1 second', #{sanitize(type)}, #{sanitize(msg)})")
                repeat = false
            rescue ActiveRecord::InvalidForeignKey
                addDevice(id, nil, nil)
            end
        end
    end

    def self.addDeviceData(id, lat, lon, spd, t)
        repeat = true
        while repeat
            begin
                connection.insert("insert into point (device_id, latitude, longitude, speed, dt) values (#{sanitize(id)}, #{sanitize(lat)}, #{sanitize(lon)}, #{sanitize(spd)}, TIMESTAMP WITHOUT TIME ZONE 'epoch' + #{sanitize(t)} * INTERVAL '1 second' )")
                repeat = false
            rescue ActiveRecord::InvalidForeignKey
                addDevice(id, nil, nil)
            end
        end
        return true
    end

    def self.getAllParameters()
        all_params = connection.select_all("select id, name from parameter")
        res = {}
        for row in all_params
            res[row["id"]] = {"name" => row["name"]}
        end
        return res
    end

    def self.getCommonParameters()
        res = getAllParameters()
        cmds = connection.select_all("select command.id as id, command_data.param_id as param_id, command_data.value as value from command, command_data where command.device_id is NULL and command.id = command_data.id order by command.id desc")

        for row in cmds
            if res.has_key?(row["param_id"]) and not res[row["param_id"]].has_key?("value")
                res[row["param_id"]]["value"] = row["value"]
            end
        end
        return res
    end

    def self.getParametersForDevice(dev_id, id)
        cmds = connection.select_all("select command.id as id, command_data.param_id as param_id, command_data.value as value from command, command_data where command.id >= #{sanitize(id)} and (command.device_id = #{sanitize(dev_id)} or command.device_id is null) and command.id = command_data.id order by command.id desc")
        res = getAllParameters()
        max_id = 0
        for row in cmds
            row_id = row["id"].to_i
            puts row_id.class.name
            if row_id > max_id
                max_id = row_id
            end

            if res.has_key?(row["param_id"]) and not res[row["param_id"]].has_key?("value")
                res[row["param_id"]]["value"] = row["value"]
            end
        end
        res["cmd_id"] = max_id
        return res
    end

    def self.writeParams(dev_id, username, params)
        transaction do
            sql = %Q{insert into command (device_id, user_name) values (#{sanitize(dev_id)}, #{sanitize(username)}) returning id}
            cmds = connection.select_all(sql)
            id = cmds[0]['id']

            params.each do |key, value|
                sql= %Q{insert into command_data (id, param_id, value) values (#{id}, #{sanitize(key)}, #{sanitize(value)})}
                connection.insert(sql)
            end

            return id
        end
    end

    def self.useFuelCode(code, dev_id)
        transaction do
            sql = %Q{select dev_id, amount from fuel_code where code = #{sanitize(code)}}
            rows = connection.select_all(sql)
            if rows.rows.empty?
                return -1 # no code
            end
            unless rows[0]['dev_id'].nil?
                return 0 #used code
            end
            sql = %Q{update fuel_code set dev_id = #{sanitize(dev_id)}, dt = now() where code = #{sanitize(code)} and dev_id is null returning amount}
            upds = connection.select_all(sql)
            if upds.rows.empty?
                return -1
            else
                return upds[0]['amount']
            end
        end
    end

    def self.getAllFuelCodes()
        sql = %Q{select fuel_code.code, fuel_code.amount, fuel_code.dev_id, fuel_code.dt, device.name from fuel_code left outer join device on fuel_code.dev_id = device.id}
        ret = connection.select_all(sql)
        return ret.to_hash
    end

    def self.addFuelCodes(codes)
        transaction do
            for row in codes
                code = row['code']
                amount = row['amount']
                sql = %Q{insert into fuel_code (code, amount) values (#{row['code']}, #{row['amount']})}
                connection.insert(sql)
            end
        end
    end

    def self.checkCodeExists(code)
        r = connection.select_all("select code, amount from fuel_code where code = #{sanitize(code.to_s)}")
        return (not r.rows.empty?)
    end

    def self.addDeviceStat(dev_id, t, stat)
        transaction do
            stat.each do |k,v|
                sql = "insert into device_stat (dev_id, dt, key, value) values (#{sanitize(dev_id)}, TIMESTAMP WITHOUT TIME ZONE 'epoch' + (#{sanitize(t)} * INTERVAL '1 second' ), #{sanitize(k)}, #{sanitize(v)})"
                connection.insert(sql)
            end
        end
    end
end

