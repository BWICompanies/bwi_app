class ApiLinks {
  //Instance Variables/Properties
  var first;
  var last;
  var prev;
  var next;

  //Constructor
  ApiLinks({
    required this.first, //parameters must be provided when creating the instance.
    required this.last,
    required this.prev,
    required this.next,
  });

  //factory method that accepts json map (associative array in PHP) and returns an ApiProduct object. (Uses the constructor above to create and return an instance of the ApiProduct class)
  factory ApiLinks.fromJson(Map<dynamic, dynamic> json) {
    return ApiLinks(
      first: json['links']['first'],
      last: json['links']['last'],
      prev: json['links']['prev'],
      next: json['links']['next'],
    );
  }
}
