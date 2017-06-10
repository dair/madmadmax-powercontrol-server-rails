# coding: utf-8
#
# MIT License
#
# Copyright (c) 2016-2017 Vladimir Lebedev-Schmidthof
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class DeviceController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [:p, :reg, :fuel, :repair, :track]

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

    def subP(params)
        res = { "code" => 0 }

        if params.has_key?("id")
            dev_id = params["id"]
            if params.has_key?("type")
                type = params["type"]
                if type == "bundle"
                    puts '------------------BUNDLE------------------------'
                    data = params["data"] # should be array
                    for item in data
                        subP(item)
                    end
                    res["code"] = 1
                    puts '------------------BUNDLE------------------------'
                elsif type == "marker"
                    res["code"] = 1
                    t = params["time"].to_i / 1000.0
                    marker = params["tag"]
                    unless marker.nil?
                        Db.addDeviceStat(dev_id, t, {('mark_' + marker) => ''})
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
                    t = params["time"].to_i / 1000.0
                    Db.addDeviceStat(dev_id, t, params["info"])
                    res["code"] = 1
                end
            end

            if params.has_key?("c")
#                puts '----------------------------'
#                puts params
#                puts '----------------------------'
                cmds = paramsForDevice(dev_id, params["c"].to_i)
                res["params"] = cmds

                u = 0
                if params.has_key?("u")
                    u = params["u"]
                    upgrades = Db.getDeviceUpgradesRaw(dev_id, u)
                    unless upgrades.nil?
                        res["upgrades"] = upgrades
                    end
                end
            end
        end

        return res
    end

    def p
        res = subP(params)
        #puts "Returning: " + res.to_s
        render :json => res
    end

    def fuel
        #entering fuel code
        res_code = false
        amount = 0
        if params.has_key?('dev_id') and params.has_key?('code')
            amount, upgrades = Db.useFuelCode(params['code'], params['dev_id'])
            if amount > 0
                res_code = true
            end
        end
        res = {'code' => res_code, 'amount' => amount}
        unless upgrades.nil?
            res["upgrades"] = upgrades
        end
        puts res
        render :json => res
    end
    
    def repair
        #entering repair code
        res_code = false
        amount = 0
        if params.has_key?('dev_id') and params.has_key?('code')
            amount = Db.useRepairCode(params['code'], params['dev_id'])
            if amount > 0
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

    def track
        dev_id = params["dev_id"]
        tracks = Db.getDeviceTracksSeparated(dev_id)

        render :json => tracks
    end
end

