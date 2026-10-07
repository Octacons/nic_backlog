class Game {
  int id;
  String code;
  String description;
  String developer;
  String gendre;
  String name;
  String publisher;
  double rate;
  DateTime releaseDate;

  Game(
    this.id,
    this.code,
    this.description,
    this.developer,
    this.gendre,
    this.name,
    this.publisher,
    this.rate,
    this.releaseDate,
  );

  Game.fromJson(Map<String, dynamic> json) : 
    id = json['id'] as int,
    code = json['code'] as String,
    description = json['description'] as String,
    developer = json['developer'] as String,
    gendre = json['gendre'] as String,
    name = json['name'] as String,
    publisher = json['publisher'] as String,
    rate = json['rate'] as double,
    releaseDate = json['releaseDate'] as DateTime;


  Map<String, dynamic> toJson() => {
    'id': id, 
    'code': code,
    'description': description,
    'developer': developer,
    'gendre': gendre,
    'name': name,
    'publisher': publisher,
    'rate': rate,
    'releaseDate': releaseDate,
  };

}