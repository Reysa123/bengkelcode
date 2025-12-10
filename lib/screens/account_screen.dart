import 'package:bengkel/screens/add_edit_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/account/account_event.dart';
import '../blocs/account/account_state.dart';
import '../model/account.dart'; // Make sure your Account model is correctly imported

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    // When the screen loads, dispatch an event to load accounts
    context.read<AccountBloc>().add(const LoadAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
        centerTitle: true,
      ),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // After success, re-load accounts to reflect changes
            context.read<AccountBloc>().add(const LoadAccounts());
          } else if (state is AccountError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AccountsLoaded) {
            if (state.accounts.isEmpty) {
              return const Center(
                child: Text('No accounts found. Add your first account!'),
              );
            }
            return ListView.builder(
              itemCount: state.accounts.length,
              itemBuilder: (context, index) {
                final account = state.accounts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Dismissible(
                    // Allows swipe-to-delete
                    key: ValueKey(account.id), // Unique key for Dismissible
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      // Show confirmation dialog before deleting
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Deletion"),
                            content: Text(
                              "Are you sure you want to delete '${account.namaAkun}'?",
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      // Dispatch delete event
                      if (account.id != null) {
                        context.read<AccountBloc>().add(
                          DeleteAccount(account.id!),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot delete account: ID is null.'),
                          ),
                        );
                      }
                    },
                    child: ListTile(
                      title: Text(account.namaAkun),
                      subtitle: Text(account.jenisAkun),
                      trailing: const Icon(
                        Icons.edit,
                      ), // Indicates it can be edited
                      onTap: () {
                        _showAddEditAccountDialog(context, account: account);
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is AccountError) {
            return Center(
              child: Text('Failed to load accounts: ${state.message}'),
            );
          }
          return const Center(child: Text('Something went wrong!')); // Fallback
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditAccountDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to show add/edit dialog (we'll create this dialog next)
  void _showAddEditAccountDialog(BuildContext context, {Akun? account}) {
    // For now, we'll just print, but this will eventually navigate to a new screen or show a dialog
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditAccountScreen(account: account)),
    );
  }
}
