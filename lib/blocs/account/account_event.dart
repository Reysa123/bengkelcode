import 'package:equatable/equatable.dart';
import '../../model/account.dart'; // Adjust path

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class LoadAccounts extends AccountEvent {
  const LoadAccounts();
}

class AddAccount extends AccountEvent {
  final Akun account;
  const AddAccount(this.account);

  @override
  List<Object> get props => [account];
}

class UpdateAccount extends AccountEvent {
  final Akun account;
  const UpdateAccount(this.account);

  @override
  List<Object> get props => [account];
}

class DeleteAccount extends AccountEvent {
  final int accountId;
  const DeleteAccount(this.accountId);

  @override
  List<Object> get props => [accountId];
}

// Optional: If you need to filter accounts by type, etc.
class LoadAccountsByType extends AccountEvent {
  final String type;
  const LoadAccountsByType(this.type);

  @override
  List<Object> get props => [type];
}
