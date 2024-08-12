

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gainz/data/datasources/datasource.dart';
import 'package:gainz/domain/entities/workout_session/workout_session.dart';
import 'package:logger/logger.dart';

class FirebaseDatasource implements Datasource {

  @override
  Future<void> saveWorkout(WorkoutSessionEntity workoutSession) async {

    final fbAuth = FirebaseAuth.instance;

    if(fbAuth.currentUser == null) return ;

    final db = FirebaseFirestore.instance;


    final payload = {
      ...workoutSession.toJson(),
      'userId': fbAuth.currentUser!.uid
    };

    Logger().d([
      'saving workout',
      payload
    ]);

    await db.collection("workouts").add(payload).then((DocumentReference doc) =>
        print('DocumentSnapshot added with ID: ${doc.id}'));


  }

  @override
  Future<List<WorkoutSessionEntity>> loadWorkouts() async {
    final fbAuth = FirebaseAuth.instance;

    if(fbAuth.currentUser == null) return [];

    final db = FirebaseFirestore.instance;
    
    return (await db.collection('workouts')
        .where("userId", isEqualTo: fbAuth.currentUser!.uid)
        .orderBy('startedAt', descending: true)
        .get()).docs.map<WorkoutSessionEntity>((doc) => WorkoutSessionEntity.fromJson({
      ...doc.data(),
      'id': doc.id
    })).toList();
  }

  @override
  Future<void> deleteWorkout(String id) async {
    final fbAuth = FirebaseAuth.instance;

    if(fbAuth.currentUser == null) return ;

    final db = FirebaseFirestore.instance;

    db.collection('workouts').doc(id).delete();
  }

}