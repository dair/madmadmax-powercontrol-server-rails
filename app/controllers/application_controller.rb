class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def setDefaultVars
    if (flash[:last_error])
      @last_error = flash[:last_error].join(", ")
    end
    @username = session[:userid]
    @title = "Power"
    @subtitle = "Power"
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

  def index
    if (session[:fail])
      @password_fail = true
      session[:fail] = nil
    end
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
        if status == 'A'
            redirect_to :controller => 'admin', :action => :main
        else
            redirect_to :controller => 'user', :action => :main
        end
    end
  end
end
