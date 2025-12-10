// lib/screens/vendor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/vendor/vendor_bloc.dart';
import '../blocs/vendor/vendor_event.dart';
import '../blocs/vendor/vendor_state.dart';
import '../model/suplier.dart'; // Make sure your Vendor model is correctly imported
import 'add_edit_vendor_screen.dart'; // We'll create this next

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  TextEditingController con = TextEditingController();
  List<Supplier> sup = [];
  @override
  void initState() {
    super.initState();
    // When the screen loads, dispatch an event to load vendors
    context.read<VendorBloc>().add(const LoadVendors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Management'), centerTitle: true),
      body: BlocConsumer<VendorBloc, VendorState>(
        listener: (context, state) {
          if (state is VendorOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // After success, re-load vendors to reflect changes
            context.read<VendorBloc>().add(const LoadVendors());
          } else if (state is VendorError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is VendorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VendorsLoaded) {
            if (state.vendors.isEmpty) {
              return const Center(
                child: Text('No vendors found. Add your first vendor!'),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SizedBox(
                  width: 1350,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextField(
                            controller: con,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Search by Name',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setState(() {
                                sup =
                                    state.vendors
                                        .where(
                                          (v) => v.namaSupplier
                                              .toLowerCase()
                                              .contains(value.toLowerCase()),
                                        )
                                        .toList();
                              });
                            },
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.blueGrey[100],

                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text('No.', textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                width: 180,
                                child: Text('Kode Supplier'),
                              ),
                              SizedBox(
                                width: 380,
                                child: Text('Nama Supplier'),
                              ),
                              SizedBox(
                                width: 300,
                                child: Text('Alamat Supplier'),
                              ),
                              SizedBox(
                                width: 160,
                                child: Text('Telepon Supplier'),
                              ),
                              SizedBox(width: 80),
                              Text(
                                'Edit',
                                style: TextStyle(color: Colors.blue),
                              ),
                              SizedBox(width: 40),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              con.text.isEmpty
                                  ? state.vendors.length
                                  : sup.length,
                          itemBuilder: (context, index) {
                            final vendor =
                                con.text.isEmpty
                                    ? state.vendors[index]
                                    : sup[index];
                            return Card(
                              color: Colors.amber[100],

                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        '${index + 1}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(vendor.id.toString()),
                                    ),
                                    SizedBox(
                                      width: 380,
                                      child: Text(vendor.namaSupplier),
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Text(vendor.alamat ?? ""),
                                    ),
                                    SizedBox(
                                      width: 160,
                                      child: Text(vendor.telepon),
                                    ),
                                    SizedBox(width: 80),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _showAddEditVendorScreen(
                                            context,
                                            vendor: vendor,
                                          ), // Panggil fungsi navigasi edit
                                    ),
                                    SizedBox(width: 40),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        return await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                "Confirm Deletion",
                                              ),
                                              content: Text(
                                                "Are you sure you want to delete '${vendor.namaSupplier}'?",
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (vendor.id != null) {
                                                      context
                                                          .read<VendorBloc>()
                                                          .add(
                                                            DeleteVendor(
                                                              vendor.id!,
                                                            ),
                                                          );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Cannot delete vendor: ID is null.',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    Navigator.of(
                                                      context,
                                                    ).pop(true);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is VendorError) {
            return Center(
              child: Text('Failed to load vendors: ${state.message}'),
            );
          }
          return const Center(child: Text('Something went wrong!')); // Fallback
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          // Navigate to Add Vendor screen
          _showAddEditVendorScreen(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to show add/edit dialog
  void _showAddEditVendorScreen(BuildContext context, {Supplier? vendor}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditVendorScreen(vendor: vendor)),
    );
  }
}
