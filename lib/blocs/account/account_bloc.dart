import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/accountrepository.dart'; // Adjust path
// Adjust path
import 'account_event.dart';                        // Adjust path
import 'account_state.dart';                        // Adjust path

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AkunRepository _accountRepository;

  AccountBloc(this._accountRepository) : super(AccountInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
    on<LoadAccountsByType>(_onLoadAccountsByType);
  }

  // Event Handler for LoadAccounts
  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      final accounts = await _accountRepository.getAkun();
      emit(AccountsLoaded(accounts: accounts));
    } catch (e) {
      emit(AccountError('Failed to load accounts: ${e.toString()}'));
    }
  }

  // Event Handler for AddAccount
  Future<void> _onAddAccount(
    AddAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading()); // Or a more specific 'AccountAdding' state
    try {
      await _accountRepository.insertAkun(event.account);
      emit(const AccountOperationSuccess('Account added successfully!'));
      // After a successful operation, reload accounts to update the UI
      add(const LoadAccounts());
    } catch (e) {
      emit(AccountError('Failed to add account: ${e.toString()}'));
    }
  }

  // Event Handler for UpdateAccount
  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading()); // Or 'AccountUpdating'
    try {
      await _accountRepository.updateAkun(event.account);
      emit(const AccountOperationSuccess('Account updated successfully!'));
      add(const LoadAccounts());
    } catch (e) {
      emit(AccountError('Failed to update account: ${e.toString()}'));
    }
  }

  // Event Handler for DeleteAccount
  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading()); // Or 'AccountDeleting'
    try {
      await _accountRepository.deleteAkun(event.accountId);
      emit(const AccountOperationSuccess('Account deleted successfully!'));
      add(const LoadAccounts());
    } catch (e) {
      emit(AccountError('Failed to delete account: ${e.toString()}'));
    }
  }

  // Event Handler for LoadAccountsByType
  Future<void> _onLoadAccountsByType(
    LoadAccountsByType event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      final accounts = await _accountRepository.getAkunsByType(event.type);
      emit(AccountsLoaded(accounts: accounts));
    } catch (e) {
      emit(AccountError('Failed to load accounts by type: ${e.toString()}'));
    }
  }
}