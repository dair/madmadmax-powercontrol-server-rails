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

    def self.addUser(id, hash)
        transaction do
            rows = connection.select_all(%Q{select hash from "user" where name = #{sanitize(id)}})
            
            calc_hash = Digest::SHA2.hexdigest(hash + id)
            
            if rows.size > 0
                connection.update(%Q{update "user" set hash = #{sanitize(hash)} where name = #{sanitize(id)}})
            else
                connection.insert(%Q{insert into "user" (name, hash) values (#{sanitize(id)}, #{sanitize(hash)})})
            end
        end
    end
end

