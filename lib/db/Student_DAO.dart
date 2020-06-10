import 'package:sembast/sembast.dart';
import 'student.dart';
import 'DatabaseSetup.dart';

class StudentDao{
  static const String folderName = "Students";
  final _studentFolder = intMapStoreFactory.store(folderName);


  Future<Database> get  _db  async => await AppDatabase.instance.database;

  Future insertStudent(Student student) async{

    await  _studentFolder.add(await _db, student.toJson() );
    print('Student Inserted successfully !!');
  }



  Future deleteAll() async{
    await _studentFolder.delete(await _db);
  }


  Future<List<Student>> getAllStudents()async{
    final recordSnapshot = await _studentFolder.find(await _db);
    return recordSnapshot.map((snapshot){
      final student = Student.fromJson(snapshot.value);
      return student;
    }).toList();
  }


}