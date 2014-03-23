# coding: utf-8
require 'digest/md5'

class AdminController < ApplicationController
    protect_from_forgery with: :exception
    
    alias :app_checkLogin :checkLogin

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
        if not dev_id.nil? and not dev_id.empty?
            dbdata = Db.getDevice(dev_id)
            if not dbdata.nil?
                @device["id"] = dbdata["id"]
                @device["name"] = dbdata["name"]
                @device["type"] = dbdata["type"]
            end
        end
        @title = "Администрирование"
        if dev_id != 0
            @subtitle = "Редактирование устройства"
        else
            @subtitle = "Добавление устройства"
        end
        @breadcrumbs = [["Главная", 'main'], ["Устройства", 'devices'], [@subtitle, ""]]
    end

    def device_write
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
            return
        end

        old_id = params["old_id"]
        id = id0(params["id"])
        name = params["name"]
        type = params["type"]

        Db.addDevice(old_id, id, name, type)
    
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
                puts "READ"
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
end

