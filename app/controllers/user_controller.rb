# coding: utf-8

class UserController < ApplicationController
    def main
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
        end

        @title = "Устройства контроля топлива"
        @subtitle = "Карта"
    end

    def data
        if !checkLogin
            render :nothing => true
            return
        end
        ids = []
        unless params[:ids].nil?
            ids = params[:ids].split(',').map {|i| id0(i)}.uniq
        end
        time = id0(params[:time])

        points = Db.points(ids, time)

        render :json => points
    end
end
