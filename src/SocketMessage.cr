require "json"

class SocketMessage

  JSON.mapping(
    message_id: Int32?,
    action: String,
    message_text: String?,
    sender_name: String?
  )

  @message_id : Int32?
  @action : String
  @message_text : String?
  @sender_name : String?

  def initialize(message_id : Int32 | Nil, action : String, message_text : String | Nil, sender_name : String | Nil) 

  	@message_id = message_id
  	@action = action
  	@message_text = message_text
  	@sender_name = sender_name

  end
end