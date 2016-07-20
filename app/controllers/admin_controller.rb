# coding: utf-8
require 'digest/md5'

class AdminController < ApplicationController
    protect_from_forgery with: :exception
    
    alias :app_checkLogin :checkLogin

    def calcDigit(num, digit)
        n = num
        count = 0
        while n > 0
            d = n % 10
            if d == digit
                count += 1
            end
            n = n / 10
        end
        return count
    end

    def dummy(r)
        return r
    end

    def checkLogin
        #return super and session[:userstatus] == 'A'
        ret = super
        st = session[:userstatus]
        bs = (st == 'A')
        return (ret and bs)
    end

    def main
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        @title = "Администрирование"
        @subtitle = "Главное меню"
        @breadcrumbs = [["Главная", 'main']]
    end

    def users
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        @list = Db.getAllUsers()
        @title = 'Администрирование'
        @subtitle = 'Список пользователей'

        @breadcrumbs = [["Главная", 'main'], ["Пользователи", 'users']]
    end

    def user_edit
        if !app_checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        param_name = params[:username]

        if param_name.nil?
            @last_error = 'weeee';
            @user = {}
            @user["id"] = ""
            @user["status"] = ""

            title = "Добавление"
        else
            dbUser = Db.getUser(param_name)

            if dbUser.nil?
                addError("Такого пользователя нет")
                redirect_to :action => 'users'
                return
            end
            @user = {}
            @user["id"] = dbUser["name"]
            @user["status"] = dbUser["status"]
        end

        @breadcrumbs = [["Главная", 'main'], ["Пользователи", 'users'], ["Редактирование", '']]
    end

    def user_write
        if !app_checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        oldlogin = params[:oldlogin]
        if oldlogin == session[:userid]
            if !checkLogin
                addError("Недостаточно прав для редактирования не себя");
                redirect_to  :controller => 'user', :action => 'main'
                return
            end
        end

        newlogin = params[:login]
        hash = params[:hash]
        if oldlogin.empty?
            oldlogin = newlogin
        end

        stored_hash = Digest::SHA3::hexdigest(hash + ':' + newlogin)
        Db.addUser(oldlogin, newlogin, stored_hash)

        if oldlogin == session[:userid]
            redirect_to :controller => 'application', :action => 'logout'
        else
            redirect_to :action => 'users'
        end
    end

    def devices
        if !app_checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        @params = Db.getCommonParameters()
        @known_list = Db.getAllKnownDevices()
        @unknown_list = Db.getAllUnknownDevices()

        @title = "Администрирование"
        @subtitle = "Устройства"
        @breadcrumbs = [["Главная", 'main'], ["Устройства", 'devices']]
    end
    
    def device_edit
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        dev_id = params[:dev_id]
        
        if dev_id.nil? or dev_id.empty?
            redirect_to :action => 'devices'
            addError('Добавить устройство можно только из списка')
            return
        end

        @device = {}
        @params = {}
        @stat = []
        if not dev_id.nil? and not dev_id.empty?
            @params = Db.getParametersForDevice(dev_id, 0)
            @params.delete("last_command_id")
            @device = Db.getDevice(dev_id)
#            dbdata = Db.getDevice(dev_id)
#            if not dbdata.nil?
#                @device["id"] = dbdata["id"]
#                @device["hw_id"] = dbdata["hw_id"]
#                @device["name"] = dbdata["name"]
#                @device["description"] = dbdata["description"]
#            end
            @upgrades = Db.getDeviceUpgrades(dev_id)

            @stat = Db.getLatestDeviceStat(dev_id)
        end

        @title = "Администрирование"
        if dev_id != 0
            @subtitle = "Редактирование устройства"
        else
            @subtitle = "Добавление устройства"
        end
        @breadcrumbs = [["Главная", '/admin/main'], ["Устройства", '/admin/devices'], [@subtitle, ""]]
    end

    def device_write
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        id = params["id"]
        name = params["name"]

        Db.editDevice(id, name)
    
        redirect_to :action => 'devices'
    end

    def map
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end
        
        mapData = Db.mapCoords()
        if mapData.nil?
            @map = {}
        else
            @map = mapData
        end
        @title = "Администрирование"
        @subtitle = "Карта местности"
        @breadcrumbs = [["Главная", 'main'], [@subtitle, 'map']]
    end

    def map_write
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end
        
        rred = nil
        content_type = nil
        if not params[:map_image].nil?
            fin = params[:map_image]

            while not fin.eof?
                #puts "READ"
                chunk = params[:map_image].read
                if not chunk.nil?
                    if rred.nil?
                        rred = chunk
                    else
                        rred = rred + chunk
                    end
                end
            end
            
            content_type = fin.content_type
        end

        latitude = 0
        if not params[:latitude].nil?
            latitude = params[:latitude].to_f
        end
        longitude = 0
        if not params[:longitude].nil?
            longitude = params[:longitude].to_f
        end
        
        Db.setMap(rred, content_type, longitude, latitude)

        redirect_to :action => 'map'
    end

    def param_edit
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end
        
        dev_id = params["dev_id"]
        device = nil
        if dev_id.nil?
            @params = Db.getCommonParameters()
        else
            device = Db.getDevice(dev_id)
            @device_id = dev_id
            @params = Db.getParametersForDevice(dev_id, 0)
            @params.delete("last_command_id")
        end

        @title = "Администрирование"
        @subtitle = "Редактирование параметров устройства"
        @breadcrumbs = [["Главная", 'main'], ["Устройства", 'devices']]
        unless device.nil?
            @breadcrumbs << [device['name'], 'device_edit/' + device['id']]
        end
        @breadcrumbs << [@subtitle, '']
    end

    def param_write
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end
        
        dev_id = nil
        if params.has_key?('dev_id')
            dev_id = params['dev_id']
        end
        
        all_params = Db.getAllParameters()
        to_store = {}
        for id in all_params.keys
            new_data_key = 'field_' + id
            old_data_key = 'orig_' + id
            if params.has_key?(new_data_key) and params.has_key?(old_data_key)
                new_data = params[new_data_key].strip
                old_data = params[old_data_key].strip
                if new_data != old_data
                    to_store[id] = new_data
                end
            end
        end

        puts 'to-store: ' + to_store.to_s
        unless to_store.empty?
            Db.writeParams(dev_id, session[:userid], to_store)
        end

        if dev_id.nil?
            redirect_to :action => 'devices'
        else
            redirect_to ('/admin/device_edit/'+dev_id)
        end
    end

    def fuelcodes
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end
        
        @codes = Db.getAllFuelCodes()
        
        @title = "Администрирование"
        @subtitle = "Коды канистр топлива"
        @breadcrumbs = [["Главная", 'main'] ]
        @breadcrumbs << [@subtitle, '']
    end

    def fuelcodes_add
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end
        
        count = id0(params['count'])
        amount = id0(params['amount'])

        if count == 0
            addError('И зачем добавлять ничего?')
        else
            start_num = 10000000
            end_num =   99999999

            codes = []
            i = 0
            while i < count
                code = start_num + rand(end_num - start_num)
                if calcDigit(code, 6) < 3
                    ex = Db.checkCodeExists(code)
                    unless ex
                        line = { 'code' => code.to_s, 'amount' => amount }
                        codes << line
                        i += 1
                    end
                end
            end

            Db.addFuelCodes(codes)
        end
        
        redirect_to :action => 'fuelcodes'
    end

    def gpx
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        if params.has_key?("dev_id")
            dev_id = params["dev_id"]
            pts = Db.points([dev_id], 0)
            points = pts[dev_id]
            max_time = 0
            min_lat = 1000
            min_lon = 1000
            max_lat = -1000
            max_lon = -1000

            points.each do |k,v|
                if max_time < k
                    max_time = k
                end
                if min_lat > v["lat"]
                    min_lat = v["lat"]
                end
                if min_lon > v["lon"]
                    min_lon = v["lon"]
                end
                if max_lat < v["lat"]
                    max_lat = v["lat"]
                end
                if max_lon < v["lon"]
                    max_lon = v["lon"]
                end
            end

            @map = {}
            @map["time"] = max_time
            @map["minlat"] = min_lat
            @map["minlon"] = min_lon
            @map["maxlat"] = max_lat
            @map["maxlon"] = max_lon
            @map["points"] = points
            puts @map
        
            @title = "Администрирование"
            device = Db.getDevice(dev_id)
            @subtitle = "Карта приключений: \"" + device['name'] + "\""
            @breadcrumbs = [["Главная", 'main'], ["Устройства", 'devices']]
            #@breadcrumbs << [device['name'], 'device_edit/' + device['id']]
            @breadcrumbs << [@subtitle, '']
        else
            redirect_to :action => 'devices'
            return
        end
    end

    def upgrade_edit
        @dev_id = params["dev_id"]
        @upg_id = params["upg_id"]
        
        
        @params = Db.getAllParameters()
        unless @upg_id.nil?
            @upgrade = Db.getUpgrade(@upg_id)
        else
            @upgrade = {}
        end

        @title = "Администрирование"
        if @upg_id.nil?
            @subtitle = "Добавление улучшения автомобиля"
        else
            @subtitle = "Изменение улучшения автомобиля"
        end
        @breadcrumbs = [["Главная", 'main'] ]
        @breadcrumbs << [@subtitle, '']
    end

    def upgrade_write
        dev_id = params["dev_id"]
        upg_id = params["upg_id"]
        if dev_id.nil?
            upgrade_params = Db.getUpgrade(upg_id)
            dev_id = upgrade_params["dev_id"]
        end
        description = params["description"]
        existingParams = Db.getAllParameters()

        storeHash = {}

        for k in params.keys
            if existingParams.has_key?(k) and not params[k].strip.empty?
                storeHash[k] = params[k].strip
            end
        end
        
        Db.editUpgrade(dev_id, upg_id, description, storeHash)

        redirect_to :action => 'device_edit', :dev_id => dev_id
    end
end

