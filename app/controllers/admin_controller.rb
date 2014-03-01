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
        @breadcrumbs = [["Главная", 'main']]
    end

    def users
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
        end

        @list = Db.getAllUsers()
        @title = 'Администрирование'
        @subtitle = 'Список пользователей'

        @breadcrumbs = [["Главная", 'main'], ["Пользователи", 'users']]
    end

    def user_edit
        if !app_checkLogin
            redirect_to  :controller => 'application', :action => 'index'
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
end

