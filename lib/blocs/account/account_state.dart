import 'package:equatable/equatable.dart';
import '../../model/account.dart'; // Adjust path

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountsLoaded extends AccountState {
  final List<Akun> accounts;
  const AccountsLoaded({this.accounts = const []});

  @override
  List<Object> get props => [accounts];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);

  @override
  List<Object> get props => [message];
}

class AccountOperationSuccess extends AccountState {
  final String message;
  const AccountOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
