
class HeaderDelete
    def initialize(app, options = {})
        @app, @options = app, options
    end
     
    def call(env)
        r = @app.call(env)
#X-Frame-Options: SAMEORIGIN
#X-Xss-Protection: 1; mode=block
#X-Content-Type-Options: nosniff
#X-Ua-Compatible: chrome=1
#Content-Type: application/json; charset=utf-8
#Etag: "9444bcccea0ff703bb688ff3e8ab590b"
#Cache-Control: max-age=0, private, must-revalidate
#X-Request-Id: 043ce4ea-6028-4f35-a4b2-a86a48fcb90f
#Server: WEBrick/1.3.1 (Ruby/2.0.0/2013-11-22)
#Date: Fri, 02 May 2014 14:52:18 GMT
#Content-Length: 10
#Connection: Keep-Alive
#Set-Cookie: request_method=POST; path=/

        puts '=========================================================================='
        puts env['REQUEST_PATH']
        puts '=========================================================================='
        if env['REQUEST_PATH'] == '/device/p'
            r[1].delete "X-Runtime"
            r[1].delete "X-Frame-Options"
            r[1].delete "X-XSS-Protection"
            r[1].delete "X-UA-Compatible"
            r[1].delete "X-Request-Id"
            r[1].delete "X-Content-Type-Options"
            r[1].delete "ETag"
            r[1].delete "Set-Cookie"
            r
        else
            r
        end
    end
end
