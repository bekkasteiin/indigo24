class Student {
  int rollNo;
  String name;
  List grades;

  Student({
    this.rollNo,
    this.name,
    this.grades
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    rollNo: json["rollNo"],
    name: json["name"],
    grades: json["grades"]
  );

  Map<String, dynamic> toJson() => {
    "rollNo": rollNo,
    "name": name,
    "grades" :grades
  };


  @override
  String toString() {
    return """
    id: $rollNo,
    name: $name,
    grades: $grades
    ----------------------------------
    """;
  }
}