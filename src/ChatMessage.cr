require "json"
class ChatMessage


  JSON.mapping(
    text: String,
    senderName: String,
  )
  @text : String
  @senderName : String | Nil

  def initialize(text : String, senderName : String | Nil)
  	@text = text
  	@senderName = senderName
  end

  def initialize(text : String)
  	@text = "text"
  end
end