require 'hashids'


module ApplicationHelper
    @@hashids = Hashids.new("MadMadMax_2016")
    
    def self.encodeHardwareId(id)
        if id.nil?
            return nil
        end
        hw_id_nodash = id.gsub('-', '')
        id = @@hashids.encode_hex(hw_id_nodash)

        return id
    end
end
