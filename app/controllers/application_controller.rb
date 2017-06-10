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

class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
  
    def id0(id)
        key = 0
        begin
            if (id)
                key = Integer(id)
            end
        rescue ArgumentError
            key = 0
        end
        return key
    end

    def setDefaultVars
        if (flash[:last_error])
            @last_error = flash[:last_error].join(", ")
        else
            @last_error = nil
        end
        @username = session[:userid]
#        @title = "Power"
#        @subtitle = "Power"
    end
  
    def addError(error)
        if !flash[:last_error]
            flash[:last_error] = Array.new
        end
        flash[:last_error].append(error)
    end

    def render(options = nil, extra_options = {}, &block)
        setDefaultVars()
        super(options, extra_options, &block)
    end

    def checkLogin
        if !session[:fail].nil? and session[:fail] == true
            return false
        end

        if session[:userid].nil?
            return false
        end

        return true
    end

    def default_redirect
        if session[:userstatus] == 'A'
            redirect_to :controller => 'admin', :action => :main
        else
            redirect_to :controller => 'user', :action => :main
        end
    end

    def index
        puts '------------index------------------'
        puts session.keys
#    puts 'id = \'' + session[:userid] + '\''
        puts '!------------index------------------'
        if (!session[:userid].nil?)
            default_redirect
            return
        end
        if (session[:fail])
            @password_fail = true
            session[:fail] = nil
        end

        @title = "Log in"
        @subtitle = ""
    end

    def login
#    puts "===================================="
        hash = params["hash"]
        login = params["login"]

        stored_hash = Digest::SHA3::hexdigest(hash + ':' + login)

#    puts 'Login: ' + login
#    puts 'hash: ' + hash
#    puts 'stored_hash: ' + stored_hash

        status = Db.checkCredentials(login, stored_hash)
    
        if status.nil?
            session[:fail] = true
            session[:userid] = nil
            session[:userstatus] = nil
            redirect_to :action => "index"
        else
            session[:fail] = false
            session[:userid] = login
            session[:userstatus] = status
            default_redirect
        end
    end

    def logout
        session[:userid] = nil
        session[:userstatus] = nil
        session[:fail] = false
        redirect_to :action => "index"
        return
    end
    
    def parseTime(t)
        Time.parse(t.to_s + ' GMT')
    end

end
