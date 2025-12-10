// lib/screens/Merk_kendaraan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/merk_kendaraan.dart';
import '../blocs/merk/merk_kendaraan_bloc.dart';
import '../blocs/merk/merk_kendaraan_event.dart';
import '../blocs/merk/merk_kendaraan_state.dart';

class MerkKendaraanScreen extends StatefulWidget {
  const MerkKendaraanScreen({super.key});

  @override
  State<MerkKendaraanScreen> createState() => _MerkKendaraanScreenState();
}

class _MerkKendaraanScreenState extends State<MerkKendaraanScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MerkKendaraanBloc>().add(const LoadMerkKendaraan([]));
  }

  void _showFormDialog({MerkKendaraan? merk}) {
    if (merk != null) {
      _nameController.text = merk.namaMerk;
    } else {
      _nameController.text = '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            merk == null ? 'Tambah Merk Kendaraan' : 'Edit Merk Kendaraan',
          ),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Merk'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final newMerk = MerkKendaraan(
                    id: merk?.id,
                    namaMerk: _nameController.text,
                  );
                  if (merk == null) {
                    context.read<MerkKendaraanBloc>().add(
                      AddMerkKendaraan(newMerk),
                    );
                  } else {
                    context.read<MerkKendaraanBloc>().add(
                      UpdateMerkKendaraan(newMerk),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(merk == null ? 'Simpan' : 'Perbarui'),
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
          title: const Text('Hapus Merk Kendaraan'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus Merk kendaraan ini?',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                backgroundColor: Colors.orangeAccent[200],
                foregroundColor: Colors.black,
                shadowColor: Colors.yellow,
                elevation: 5,
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                backgroundColor: Colors.red[200],
                foregroundColor: Colors.black,
                shadowColor: Colors.yellow,
                elevation: 5,
              ),
              onPressed: () {
                context.read<MerkKendaraanBloc>().add(DeleteMerkKendaraan(id));
                Navigator.pop(context);
              },
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
      appBar: AppBar(title: const Text('Merk Kendaraan'), centerTitle: true),
      body: BlocBuilder<MerkKendaraanBloc, MerkKendaraanState>(
        builder: (context, state) {
          if (state is MerkKendaraanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MerkKendaraanLoaded) {
            if (state.listmerks.isEmpty) {
              return const Center(child: Text('Tidak ada Merk kendaraan.'));
            }
            return ListView.builder(
              itemCount: state.listmerks.length,
              itemBuilder: (context, index) {
                final merk = state.listmerks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(merk.namaMerk),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormDialog(merk: merk),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(merk.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is MerkKendaraanError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(
            child: Text('Muat data untuk melihat Merk kendaraan.'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
