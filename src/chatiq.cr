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
      SOCKETS.each do |socket| 
        socket.send (SocketMessage.new nil, "user_joined", nil, name).to_json
      end
      req.response.status_code = 200
      Crypto::MD5.hex_digest(name)
    else
      req.response.status_code = 401
    end
  rescue KeyError
    req.response.status_code = 400
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
      SOCKETS.each do |socket| 
        socket.send (SocketMessage.new message.@id, "message_sent", message.@text, checkUser(access_token)).to_json
      end
      req.response.status_code = 200
    else 
      req.response.status_code = 401
    end
  rescue e  
    puts e.message  
    req.response.status_code = 400
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
      SOCKETS.each do |socket| 
        socket.send (SocketMessage.new reqId, "message_edited", text, checkUser(access_token)).to_json
      end
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
      SOCKETS.each do |socket| 
        socket.send (SocketMessage.new reqId, "message_deleted", nil, nil).to_json
      end
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

Kemal.run
