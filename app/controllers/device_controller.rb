# coding: utf-8

class DeviceController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [:p, :reg]

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
        
        dt = id0(params["time"]) / 1000.0
        if dt == 0
            dt = Time.now.to_i
        end

        lat = f0(params["lat"])
        lon = f0(params["lon"])
        spd = f0(params["spd"])
        distance = f0(params["distance"])
        acc = f0(params["acc"])

        code = Db.addDeviceData(id, lat, lon, acc, spd, distance, dt)
        Db.setDeviceInfo(id, [{'key' => 'last_point', 'value' => (lat.to_s + ',' + lon.to_s), 'dt' => dt}])
        if not code
            res['code'] = 0
        end

        return res
    end

    def paramsForDevice(dev_id, param_id)
#        puts 'paramsForDevice: ' + param_id.to_s
        params = Db.getParametersForDevice(dev_id, param_id)

        ret = {}
        for p in params.keys
            if p == "last_command_id"
                ret[p] = params[p]
            else
                unless params[p]["value"].nil?
                    ret[p] = params[p]["value"]
                end
            end
        end

#        puts ret

        return ret
    end

    def p
        res = { "code" => 0 }

        if params.has_key?("id")
            dev_id = params["id"]
            if params.has_key?("type")
                type = params["type"]
                if type == "marker"
                    res["code"] = 1
                    t = params["time"].to_i / 1000.0
                    marker = params["tag"]
                    unless marker.nil?
                        Db.addDeviceStat(dev_id, t, {('mark_' + marker) => ''})
                        Db.setDeviceInfo(dev_id, [{'key' => 'last_ping', 'value' => '', 'dt' => t}])
                    end
                elsif type == "ping"
                    t = params["time"].to_i / 1000.0
                    
                    desc = nil
                    if params.has_key?("desc")
                        desc = params["has_key"]
                    end

                    Db.addDeviceMsg(dev_id, desc, 'P', nil, t)
                    Db.setDeviceInfo(dev_id, [{'key' => 'last_ping', 'value' => '', 'dt' => t}])

                    p = params["device"].clone
                    p.delete("type")
                    p.delete("c")
                    p.delete("t")
                    p.delete("id")

                    unless p.empty?
                        p["ip"] = request.remote_ip
                        Db.addDeviceStat(dev_id, t, p)
                    end

                    res["code"] = 1
                elsif type == "location"
                    res = addP(params)
                elsif type == "code"
                    amount = Db.useFuelCode(params['code'], dev_id)
                    res["code"] = 1
                    res["id"] = -1
                    res["fuel_code"] = {"amount" => amount, "code" => params['code']}
                elsif type == "damage"
                    t = params["time"].to_i / 1000.0
                    raw = params["raw"]
                    damage = params["damage"]

                    text = "Damage: " + damage.to_s + " (" + raw + ")"

                    Db.addDump(dev_id, t, text)
                    res["code"] = 1
                    
                elsif type == "dump"
                    t = params["time"].to_i / 1000.0
                    text = params["text"]

                    Db.addDump(dev_id, t, text)
                    res["code"] = 1

                elsif type == "info"
                    res["code"] = 1
                end
            end

            if params.has_key?("c")
#                puts '----------------------------'
#                puts params
#                puts '----------------------------'
                cmds = paramsForDevice(dev_id, params["c"].to_i)
                res["params"] = cmds
            end
        end

        #puts "Returning: " + res.to_s
        render :json => res
    end

    def fuel
        #entering fuel code
        res_code = false
        amount = 0
        if params.has_key?('dev_id') and params.has_key?('code')
            amount = Db.useFuelCode(params['code'])
            if amount >= 0
                res_code = true
            end
        end
        res = {'code' => res_code, 'amount' => amount}
        render :json => res
    end

    def reg
        dev_hw_id = params["hw_id"]
        dev_desc = params["desc"]
        dev_name = params["name"]

        code = false

        foundDevice = Db.getDeviceByHwId(dev_hw_id)
        if foundDevice.nil?
            id = ApplicationHelper.encodeHardwareId(dev_hw_id)
            unless id.empty?
                Db.addDevice(id, dev_hw_id, dev_name, dev_desc)
                code = true
            end
        else
            id = foundDevice["id"]
            Db.editDevice(id, dev_name)
            code = true
        end

        ret = {}
        ret["code"] = code
        ret["id"] = id

        params = paramsForDevice(id, 0)
        ret["params"] = params

        render :json => ret
    end
end

