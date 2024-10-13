class MessageResponse {
  String message;
  
  MessageResponse({
    required this.message,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(message: json['message']);
  }
}