require "./chatiq/*"
require "kemal"
require "crypto/md5"
require "./*"
require "json"

SOCKETS = [] of HTTP::WebSocket
Users = {} of String => ChatUser
Messages = [] of ChatMessage

# Авторизация
post "/auth" do |req|
  begin
    name = req.params.json["name"].as(String)
    password = req.params.json["password"].as(String)
    if name + "123" == password
      Users[name] = ChatUser.new name
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
      message = ChatMessage.new(text, checkUser(access_token))
      Messages << message
      SOCKETS.each { |socket| socket.send "new message sent"}
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
patch "/messages/:id" do
  SOCKETS.each { |socket| socket.send "message edited"}
end

# Удаление сообщения
delete "/messages/:id" do
  SOCKETS.each { |socket| socket.send "message deleted"}
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

Kemal.run
