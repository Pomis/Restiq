require "./chatiq/*"
require "kemal"
require "crypto/md5"

# Авторизация
post "/auth" do |req|
  name = req.params.json["name"].as(String)
  Crypto::MD5.hex_digest(name)
end

# Получение последних n сообщений
get "/messages/:count" do

end

# Отправка сообщения
post "/messages" do |req|

end

# Редактирование сообщения
patch "/messages/:id" do

end

# Удаление сообщения
delete "/messages/:id" do

end

# Оповещение об обновлении
ws "/messages" do

end



Kemal.run