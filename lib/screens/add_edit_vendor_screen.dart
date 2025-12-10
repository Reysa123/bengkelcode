// lib/screens/add_edit_vendor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/vendor/vendor_bloc.dart';
import '../blocs/vendor/vendor_event.dart';
import '../model/suplier.dart';

class AddEditVendorScreen extends StatefulWidget {
  final Supplier? vendor; // Null if adding, non-null if editing

  const AddEditVendorScreen({super.key, this.vendor});

  @override
  State<AddEditVendorScreen> createState() => _AddEditVendorScreenState();
}

class _AddEditVendorScreenState extends State<AddEditVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.vendor?.namaSupplier ?? '',
    );
    _contactPersonController = TextEditingController(
      text: widget.vendor?.email ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: widget.vendor?.telepon ?? '',
    );
    _addressController = TextEditingController(
      text: widget.vendor?.alamat ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final contactPerson =
          _contactPersonController.text.isNotEmpty
              ? _contactPersonController.text
              : null;
      final phoneNumber =
          _phoneNumberController.text.isNotEmpty
              ? _phoneNumberController.text
              : null;
      final address =
          _addressController.text.isNotEmpty ? _addressController.text : null;

      if (widget.vendor == null) {
        // Adding new vendor
        final newVendor = Supplier(
          namaSupplier: name,
          email: contactPerson,
          telepon: phoneNumber!,
          alamat: address,
        );
        context.read<VendorBloc>().add(AddVendor(newVendor));
      } else {
        // Updating existing vendor
        final updatedVendor = widget.vendor!.copyWith(
          namaSupplier: name,
          email: contactPerson,
          telepon: phoneNumber,
          alamat: address,
        );
        context.read<VendorBloc>().add(UpdateVendor(updatedVendor));
      }
      Navigator.of(context).pop(); // Go back to VendorScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vendor == null ? 'Add New Vendor' : 'Edit Vendor'),
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
                  labelText: 'Vendor Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a vendor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.blue[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,

                  textStyle: const TextStyle(fontSize: 18),
                ),
                icon: Icon(Icons.save),
                label: Text(
                  widget.vendor == null ? 'Add Vendor' : 'Update Vendor',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
