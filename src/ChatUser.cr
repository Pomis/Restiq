class ChatUser
  @password : String

  def initialize(name : String)
    @name = name
    @password = name + "123"
  end

  def name
  	@name
  end
end