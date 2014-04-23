# coding: utf-8

class DeviceController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [:p]

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
        puts "========================================================================"
        puts "params: " + params.to_s
        puts "========================================================================"
        #puts "headers: " + request.headers.to_s
        #puts "request: " + request.raw_post.to_s
        res = addP(params)
        render :json => res
    end

    def auth
        dev_id = params["id"]
        dev_desc = params["desc"]
        ret = {}
        ret["code"] = false
        unless dev_id.nil?
            dev = Db.getDevice(dev_id)
            if dev.nil?
                Db.addDevice(dev_id, dev_desc)
                ret["code"] = false
            else
                if dev["type"].nil?
                    ret["code"] = false
                else
                    ret["code"] = true
                    ret["a"] = form_authenticity_token
                end
            end
        end

        puts ret

        render :json => ret
    end
end
