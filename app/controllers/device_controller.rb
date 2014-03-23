# coding: utf-8

class DeviceController < ApplicationController
    
    def f0(l)
        ret = 0.0
        begin
            if l
                ret = Float(l)
            end
        rescue ArgumentError
            ret = 0.0
        end
        return ret
    end

    def addP(params)
        res = {'code' => 1}

        if params['id'].nil?
            res['code'] = 0
            res['error'] = 'No id'
            return res
        end
        id = params['id']
        
        dt = id0(params["t"])
        if dt == 0
            dt = Time.now.to_i
        end

        lat = f0(params["lat"])
        lon = f0(params["lon"])
        spd = f0(params["spd"])

        code = Db.addDeviceData(id, lat, lon, spd, dt)
        if not code
            res['code'] = 0
        end

        res['id'] = 2
        res['timeout'] = 42;
        return res
    end

    def p
        res = addP(params)
        render :json => res
    end
end
