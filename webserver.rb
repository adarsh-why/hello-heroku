require 'libuv'

def response_header version, page
    if page == "404.html"
        puts "\n\nHTTP/#{version} 404 Not Found"
    else
        puts "\n\nHTTP/#{version} 200 OK"
    end
end

def response_date
    puts "Date: #{Time.now}"
end

def response_content_type request_hash
    content = request_hash["Accept"].split(',').first.chomp
    puts "Content type: #{content}"
end

def response_connection request_hash
    puts "Connection: #{request_hash["Connection"]}"
end

def response_url url
    if url == ""
        request_page = 'index.html'
    else
        request_page = url.gsub('HTTP','').strip
    end
    puts "Requested page: #{request_page}\n\n"
end

def send_to_browser url
    page = url.gsub('HTTP','').strip
    
    if page == ""
        page = "index.html"
    elsif page == "index.html"
        page = "index.html"
    else page = "404.html"
    end
    
    file = File.open(page, 'r')
    return file.read(), page       
end

def start_server
    server = TCPServer.new('localhost', 3000)
    while connection = server.accept
        request_hash = {}
        request = connection.gets.chomp
        p request
        method, url, version = request.split('/')
        next if url.gsub('HTTP','').strip == 'favicon.ico'
        while true
            request = connection.gets
            p request
            key,value = request.split(':')
            break if request == "\r\n"    
            request_hash[key] = value
        end
        # request_hash.each{|k,v| puts "#{k} : #{v}"}
        html, page = send_to_browser url

        #Calling functions to generate HTTP response
        response_header version, page
        response_date
        response_content_type request_hash
        response_connection request_hash
        response_url url

        connection.puts(html)
        connection.close
    end
end

start_server