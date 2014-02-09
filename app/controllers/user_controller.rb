# coding: utf-8

class AdminController < ApplicationController
    def main
        if !checkLogin
            redirect_to  :controller => 'application', :action => 'index'
        end
    end
end
