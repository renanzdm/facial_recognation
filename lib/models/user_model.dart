
class User {
  List<int> dataImage;
  User({
    required this.dataImage,
  });

  factory User.fromMap(Map<String, dynamic> json) {
    return User(dataImage: json['image']);
  }
}
