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
