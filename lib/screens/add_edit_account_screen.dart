import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/account/account_event.dart';
import '../model/account.dart';

class AddEditAccountScreen extends StatefulWidget {
  final Akun? account; // Null if adding, non-null if editing

  const AddEditAccountScreen({super.key, this.account});

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;// For dropdown
  String? _selectedType;
  // Pre-defined account types
  final List<String> _accountTypes = [
    'Asset',
    'Liability',
    'Equity',
    'Revenue',
    'Expense',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.namaAkun ?? '');
    
    _selectedType = widget.account?.jenisAkun ?? 'Asset';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final type = _selectedType;
      

      if (type == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account type.')),
        );
        return;
      }

      if (widget.account == null) {
        // Adding new account
        final newAccount = Akun(
          namaAkun: name,
          jenisAkun: type, // ADDED: Include notes
        );
        context.read<AccountBloc>().add(AddAccount(newAccount));
      } else {
        // Updating existing account
        final updatedAccount = widget.account!.copyWith(
          namaAkun: name,
          jenisAkun: type, // ADDED: Include notes
        );
        context.read<AccountBloc>().add(UpdateAccount(updatedAccount));
      }
      Navigator.of(context).pop(); // Go back to AccountScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.account == null ? 'Add New Account' : 'Edit Account',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select Type'),
                items:
                    _accountTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an account type';
                  }
                  return null;
                },
              ),
              

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  widget.account == null ? 'Add Account' : 'Update Account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
