// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../domaine/entities/Vehicule.dart';
// import '../../domaine/repositories/vehicule_repository.dart';
//
// import '../models/vehicule_model.dart';
//
// class VehiculeRepositoryImpl implements VehiculeRepository {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   @override
//   Future<void> addVehicule(Vehicule vehicule) async {
//     await firestore.collection('vehicules').add(
//       VehiculeModel(
//         marque: vehicule.marque,
//         model: vehicule.model,
//         year: vehicule.year,
//       ).toMap(),
//     );
//   }
//
//   @override
//   Future<List<Vehicule>> getVehicules() async {
//     final snapshot = await firestore.collection('vehicules').get();
//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//       data['Vid'] = doc.id; // treat Firestore doc ID as Vid
//       return VehiculeModel.fromMap(data);
//     }).toList();
//   }
//
//   @override
//   Future<void> updateVehicule(Vehicule vehicule) async {
//     if (vehicule.Vid == null) throw Exception('Vehicule ID is null');
//     await firestore.collection('vehicules').doc(vehicule.Vid.toString()).update(
//       VehiculeModel(
//         vid: vehicule.Vid,
//         marque: vehicule.marque,
//         model: vehicule.model,
//         year: vehicule.year,
//       ).toMap(),
//     );
//   }
//
//   @override
//   Future<void> deleteVehicule(int vid) async {
//     await firestore.collection('vehicules').doc(vid.toString()).delete();
//   }
// }
