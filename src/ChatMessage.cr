require "json"
class ChatMessage


  JSON.mapping(
    id: Int32,
    text: String,
    senderName: String,
  )

  @id : Int32?
  @text : String | Nil
  @senderName : String | Nil

  def initialize(text : String, senderName : String | Nil, id : Int32 | Nil)
  	@text = text
  	@senderName = senderName
    @id = id
  end

  def initialize()
  end
end