// lib/screens/add_edit_pelanggan_screen.dart
import 'package:bengkel/blocs/pelanggan/pelanggan_bloc.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_event.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Pastikan path ini benar

class AddEditPelangganScreen extends StatefulWidget {
  final Pelanggan? pelanggan; // Null jika menambah, berisi data jika mengedit

  const AddEditPelangganScreen({super.key, this.pelanggan});

  @override
  State<AddEditPelangganScreen> createState() => _AddEditPelangganScreenState();
}

class _AddEditPelangganScreenState extends State<AddEditPelangganScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _teleponController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data awal jika dalam mode edit
    _namaController = TextEditingController(text: widget.pelanggan?.nama ?? '');
    _alamatController = TextEditingController(
      text: widget.pelanggan?.alamat ?? '',
    );
    _teleponController = TextEditingController(
      text: widget.pelanggan?.telepon ?? '',
    );
    _emailController = TextEditingController(
      text: widget.pelanggan?.email ?? '',
    );
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget tidak lagi digunakan
    _namaController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan data pelanggan
  void _savePelanggan() {
    if (_formKey.currentState!.validate()) {
      // Buat objek Pelanggan dari input form
      final newPelanggan = Pelanggan(
        id:
            widget
                .pelanggan
                ?.id, // ID akan null jika menambah baru, ada jika mengedit
        nama: _namaController.text,
        alamat: _alamatController.text.isEmpty ? null : _alamatController.text,
        telepon: _teleponController.text, // Telepon wajib diisi
        email: _emailController.text.isEmpty ? null : _emailController.text,
      );

      // Dispatch event ke BLoC berdasarkan mode (tambah atau edit)
      if (widget.pelanggan == null) {
        // Mode Tambah
        context.read<PelangganBloc>().add(AddPelanggan(newPelanggan));
      } else {
        // Mode Edit
        context.read<PelangganBloc>().add(UpdatePelanggan(newPelanggan));
      }

      Navigator.of(
        context,
      ).pop(); // Kembali ke layar sebelumnya setelah menyimpan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pelanggan == null ? 'Tambah Pelanggan Baru' : 'Edit Pelanggan',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Kaitkan form dengan GlobalKey
          child: ListView(
            // Gunakan ListView agar bisa discroll jika banyak field
            children: <Widget>[
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pelanggan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(
                  labelText: 'Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Opsional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan alamat email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: _savePelanggan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.blue[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,
                ),
                icon: Icon(Icons.save),
                label: Text(
                  widget.pelanggan == null
                      ? 'Simpan Pelanggan'
                      : 'Perbarui Pelanggan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
