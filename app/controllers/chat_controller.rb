# coding: utf-8

class ChatController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [:log, :msg]

    def log
        id = id0(params['id'])
        rows = Db.getChatLogSince(id)
        ret = rows.to_ary()

        render :json => ret
    end

    def msg
        msg = params['msg']
        id = Db.addChatMessage(msg)
        render :json => {:id => id}
    end

end

