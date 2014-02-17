# coding: utf-8

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
        end

        @title = "Admin"
        @subtitle = "Menu"
        @breadcrumbs = ["Главная"]
    end

    def users
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
        end

        @list = Db.getAllUsers()
        @title = 'Администрирование'
        @subtitle = 'Список пользователей'

        @breadcrumbs = ["", 1, 2, 3]
    end

    def user_edit
        param_name = params[:username]
        if !app_checkLogin
            redirect_to  :controller => 'application', :action => 'index'
        end

        dbUser = Db.getUser(param_name)

        if dbUser.nil?
            addError("Такого пользователя нет")
            redirect_to :action => 'users'
            return
        end
        @user = {}
        @user["id"] = dbUser["name"]
        @user["status"] = dbUser["status"]

        puts '================================================='
        puts @user["status"]
        puts '================================================='

    end
end
