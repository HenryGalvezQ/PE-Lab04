class StartChatRequest {
  final String productId;
  final String
  counterpartId; // vendedor (si tú eres comprador) o comprador (si tú eres vendedor)

  StartChatRequest({required this.productId, required this.counterpartId});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'counterpartId': counterpartId,
  };
}
