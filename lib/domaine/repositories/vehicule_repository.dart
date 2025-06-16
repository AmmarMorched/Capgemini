import '../entities/vehicule.dart';

abstract class VehiculeRepository {
  Future<void> addVehicule(Vehicule vehicule);
  Future<List<Vehicule>> getVehicules();
  Future<void> updateVehicule(Vehicule vehicule);
  Future<void> deleteVehicule(int vid);
}
