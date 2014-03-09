# coding: utf-8

class UserController < ApplicationController
    def main
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
        end

        @title = "Устройства контроля топлива"
        @subtitle = "Карта"
    end
end
