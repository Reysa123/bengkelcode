// lib/screens/type_kendaraan_screen.dart
import 'package:bengkel/model/merk_kendaraan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/type_kendaraan.dart';
import '../blocs/type/type_kendaraan_bloc.dart';
import '../blocs/type/type_kendaraan_event.dart';
import '../blocs/type/type_kendaraan_state.dart';

class TypeKendaraanScreen extends StatefulWidget {
  const TypeKendaraanScreen({super.key});

  @override
  State<TypeKendaraanScreen> createState() => _TypeKendaraanScreenState();
}

class _TypeKendaraanScreenState extends State<TypeKendaraanScreen> {
  final TextEditingController _nameController = TextEditingController();

  String? merks;
  int merek = 0;
  List<MerkKendaraan> _merks = [];
  @override
  void initState() {
    super.initState();
    context.read<TypeKendaraanBloc>().add(const LoadTypeKendaraan());
  }

  showMerk(String? value) {
    setState(() {
      merks = value;
      merek = _merks.where((v) => v.namaMerk == value).first.id!;
    });
  }

  void _showFormDialog({TypeKendaraan? type}) {
    if (type != null) {
      _nameController.text = type.namaTipe;
      merks = _merks.where((v) => v.id == type.merkId).first.namaMerk;
    } else {
      _nameController.text = '';
      merks = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            type == null ? 'Tambah Tipe Kendaraan' : 'Edit Tipe Kendaraan',
          ),
          content: Column(
            children: [
              DropdownButtonFormField<String>(
                value: merks,
                decoration: const InputDecoration(
                  labelText: 'Merk Kendaraan',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select Merk'),
                items:
                    _merks.map((e) => e.namaMerk).map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) {
                  showMerk(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an merk';
                  }
                  return null;
                },
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Tipe'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final newType = TypeKendaraan(
                    id: type?.id,
                    namaTipe: _nameController.text,
                    merkId: merek,
                  );
                  if (type == null) {
                    context.read<TypeKendaraanBloc>().add(
                      AddTypeKendaraan(newType),
                    );
                  } else {
                    context.read<TypeKendaraanBloc>().add(
                      UpdateTypeKendaraan(newType),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(type == null ? 'Simpan' : 'Perbarui'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Tipe Kendaraan'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus tipe kendaraan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<TypeKendaraanBloc>().add(DeleteTypeKendaraan(id));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipe Kendaraan'), centerTitle: true),
      body: BlocBuilder<TypeKendaraanBloc, TypeKendaraanState>(
        builder: (context, state) {
          if (state is TypeKendaraanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TypeKendaraanLoaded) {
            if (state.types.isEmpty) {
              _merks = state.merks;
              //merks = _merks.firstOrNull?.namaMerk;
              return const Center(child: Text('Tidak ada tipe kendaraan.'));
            }
            _merks = state.merks;
            // merks = _merks.firstOrNull?.namaMerk;
            return ListView.builder(
              itemCount: state.types.length,
              itemBuilder: (context, index) {
                final type = state.types[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(type.namaTipe),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showFormDialog(type: type),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(type.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is TypeKendaraanError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(
            child: Text('Muat data untuk melihat tipe kendaraan.'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
