import 'package:equatable/equatable.dart';
import '../../model/part.dart'; // Adjust path

abstract class PartEvent extends Equatable {
  const PartEvent();

  @override
  List<Object> get props => [];
}

class LoadParts extends PartEvent {
  const LoadParts();
}

class AddPart extends PartEvent {
  final SukuCadang part;
  const AddPart(this.part);

  @override
  List<Object> get props => [part];
}

class UpdatePart extends PartEvent {
  final SukuCadang part;
  const UpdatePart(this.part);

  @override
  List<Object> get props => [part];
}

class DeletePart extends PartEvent {
  final int partId;
  const DeletePart(this.partId);

  @override
  List<Object> get props => [partId];
}

// Event for adjusting stock quantity (e.g., after purchase or use)
class AdjustPartStock extends PartEvent {
  final int partId;
  final int quantityChange; // Positive for increase, negative for decrease
  const AdjustPartStock(this.partId, this.quantityChange);

  @override
  List<Object> get props => [partId, quantityChange];
}
