class ApiMetaData {
  //Instance Variables/Properties
  var current_page; // can do final int
  //var from;
  //var path;
  //var per_page;
  //var to;

  //Constructor
  ApiMetaData({
    required this.current_page, //parameters must be provided when creating the instance.
    //required this.from,
    //required this.path,
    //required this.per_page,
    //required this.to,
  });

  //factory method that accepts json map (associative array in PHP) and returns an ApiProduct object. (Uses the constructor above to create and return an instance of the ApiProduct class)
  factory ApiMetaData.fromJson(Map<String, dynamic> json) {
    return ApiMetaData(
      current_page: json['meta']['current_page'], //can say as int,
      //from: json['from'],
      //path: json['path'],
      //per_page: json['per_page'],
      //to: json['to'],
    );
  }
}
