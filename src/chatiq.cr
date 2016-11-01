require "./chatiq/*"
require "kemal"
require "crypto/md5"
require "./*"
require "json"

SOCKETS = [] of HTTP::WebSocket
Users = {} of String => ChatUser
Messages = [] of ChatMessage
counter = 0

# Авторизация
post "/auth" do |req|
  begin
    name = req.params.json["name"].as(String)
    password = req.params.json["password"].as(String)
    if name + "123" == password
      Users[name] = ChatUser.new name
      send_message((SocketMessage.new nil, "user_joined", nil, name).to_json)
      req.response.status_code = 200
      Crypto::MD5.hex_digest(name)
    else
      req.response.status_code = 401
      puts "kek"
    end
  rescue KeyError
    req.response.status_code = 400
    puts "kek"
  end

end

# Получение последних n сообщений
get "/messages/:count" do |req|
  count = 0
  reqCount = req.params.url["count"].as(String).to_i
  if reqCount > Messages.size
    count = Messages.size
  else 
    count = reqCount
  end
  Messages.last(count).to_json
end

# Отправка сообщения
post "/messages" do |req|
  begin
    text = req.params.json["text"].as(String)
    access_token = req.params.json["access_token"].as(String)
    if checkUser(access_token) != nil
      message = ChatMessage.new(text, checkUser(access_token), counter += 1)
      Messages << message
      send_message((SocketMessage.new message.@id, "message_sent", message.@text, checkUser(access_token)).to_json)
      req.response.status_code = 200
    else 
      req.response.status_code = 401
      puts "kek"
    end
  rescue e  
    puts e.message  
    req.response.status_code = 400
    puts "kek"
  end
end

# Редактирование сообщения
patch "/messages/:id" do |req|
  begin
    text = req.params.json["text"].as(String)
    access_token = req.params.json["access_token"].as(String)
    reqId = req.params.url["id"].as(String).to_i

    if (checkUser(access_token) == get_message(reqId).@senderName)
      get_message(reqId).text = text
      send_message((SocketMessage.new reqId, "message_edited", text, checkUser(access_token)).to_json)
      req.response.status_code = 200
    else
      req.response.status_code = 401
    end
  rescue
    req.response.status_code = 400
  end
end

# Удаление сообщения
delete "/messages/:id" do |req|
  begin
    access_token = req.params.json["access_token"].as(String)
    reqId = req.params.url["id"].as(String).to_i
    if (checkUser(access_token) == get_message(reqId).@senderName)
      Messages.delete(get_message(reqId))
      send_message((SocketMessage.new reqId, "message_deleted", nil, nil).to_json)
      req.response.status_code = 200
    else
      req.response.status_code = 401
    end
  rescue
    req.response.status_code = 400
  end
end

# Оповещение об обновлении
ws "/messages" do |socket|
  SOCKETS << socket

  socket.on_close do
    SOCKETS.delete socket
  end
end

def checkUser(access_token : String) : String | Nil
  result = nil
  Users.each do |key, value|
    if access_token == Crypto::MD5.hex_digest(Users[key].name)
      result = Users[key].name
    end
  end
  result
end

def get_message(id : Int32) : ChatMessage
  result = ChatMessage.new
  Messages.each do |value|
    if value.@id == id
      result = value
    end
  end
  result
end

def send_message(message : String)
  begin
    SOCKETS.each do |socket| 
      socket.send message
    end
  rescue e
    puts e.message
  end
end


error 404 do
  "404"
end

error 401 do
  "401"
end

error 500 do
  "500"
end

error 501 do
  "501"
end

error 502 do
  "502"
end

Kemal.run
