class GameStatus {
  int id;
  String gameName;
  int statusCode;
  String statusName;

  GameStatus(
    this.id,
    this.gameName,
    this.statusCode,
    this.statusName,
  );

  GameStatus.fromJson(Map<String, dynamic> json) : 
    id = json['id'] as int,
    gameName = json['gameName'] as String,
    statusCode = json['statusCode'] as int,
    statusName = json['statusName'] as String;

  Map<String, dynamic> toJson() => {
    'id': id, 
    'gameName': gameName,
    'statusCode': statusCode,
    'statusName': statusName,
  };
}