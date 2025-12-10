import 'package:equatable/equatable.dart';
import '../../model/mekanik.dart'; // Make sure this path is correct for your Mekanik model

// --- Base Event ---
abstract class MekanikEvent extends Equatable {
  const MekanikEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event to load the list of mechanics
class LoadMekanik extends MekanikEvent {
  const LoadMekanik();
}

class LoadMekaniks extends MekanikEvent {
  const LoadMekaniks();
}

// Event to add a new mechanic
class AddMekanik extends MekanikEvent {
  final Mekanik mekanik;

  const AddMekanik(this.mekanik);

  @override
  List<Object> get props => [mekanik];
}

// Event to update an existing mechanic
class UpdateMekanik extends MekanikEvent {
  final Mekanik mekanik;

  const UpdateMekanik(this.mekanik);

  @override
  List<Object> get props => [mekanik];
}

// Event to delete a mechanic
class DeleteMekanik extends MekanikEvent {
  final int id;

  const DeleteMekanik(this.id);

  @override
  List<Object> get props => [id];
}
