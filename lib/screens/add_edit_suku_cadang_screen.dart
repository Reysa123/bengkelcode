// lib/screens/add_edit_suku_cadang_screen.dart
import 'package:bengkel/blocs/part/part_bloc.dart';
import 'package:bengkel/blocs/part/part_event.dart';
import 'package:bengkel/model/part.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Pastikan path ini benar

class AddEditSukuCadangScreen extends StatefulWidget {
  final SukuCadang? sukuCadang; // Null jika menambah, berisi data jika mengedit

  const AddEditSukuCadangScreen({super.key, this.sukuCadang});

  @override
  State<AddEditSukuCadangScreen> createState() =>
      _AddEditSukuCadangScreenState();
}

class _AddEditSukuCadangScreenState extends State<AddEditSukuCadangScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  late TextEditingController _namaPartController;
  late TextEditingController _kodePartController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaBeliController;
  late TextEditingController _hargaJualController;
  late TextEditingController _stokController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data awal jika dalam mode edit
    _namaPartController = TextEditingController(
      text: widget.sukuCadang?.namaPart ?? '',
    );
    _kodePartController = TextEditingController(
      text: widget.sukuCadang?.kodePart ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.sukuCadang?.deskripsi ?? '',
    );
    _hargaBeliController = TextEditingController(
      text: widget.sukuCadang?.hargaBeli.toString() ?? '0.0',
    );
    _hargaJualController = TextEditingController(
      text: widget.sukuCadang?.hargaJual.toString() ?? '0.0',
    );
    _stokController = TextEditingController(
      text: widget.sukuCadang?.stok.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget tidak lagi digunakan
    _namaPartController.dispose();
    _kodePartController.dispose();
    _deskripsiController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan data suku cadang
  void _saveSukuCadang() {
    if (_formKey.currentState!.validate()) {
      // Buat objek SukuCadang dari input form
      final newSukuCadang = SukuCadang(
        id:
            widget
                .sukuCadang
                ?.id, // ID akan null jika menambah baru, ada jika mengedit
        namaPart: _namaPartController.text,
        kodePart:
            _kodePartController.text.isEmpty ? null : _kodePartController.text,
        deskripsi:
            _deskripsiController.text.isEmpty
                ? null
                : _deskripsiController.text,
        hargaBeli: double.parse(_hargaBeliController.text),
        hargaJual: double.parse(_hargaJualController.text),
        stok: int.parse(_stokController.text),
      );

      // Dispatch event ke BLoC berdasarkan mode (tambah atau edit)
      if (widget.sukuCadang == null) {
        // Mode Tambah
        context.read<SukuCadangBloc>().add(AddPart(newSukuCadang));
      } else {
        // Mode Edit
        context.read<SukuCadangBloc>().add(UpdatePart(newSukuCadang));
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
          widget.sukuCadang == null
              ? 'Tambah Suku Cadang Baru'
              : 'Edit Suku Cadang',
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
                controller: _namaPartController,
                decoration: const InputDecoration(
                  labelText: 'Nama Suku Cadang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama suku cadang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _kodePartController,
                decoration: const InputDecoration(
                  labelText: 'Kode Part (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _hargaBeliController,
                decoration: const InputDecoration(
                  labelText: 'Harga Beli',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Masukkan harga beli yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _hargaJualController,
                decoration: const InputDecoration(
                  labelText: 'Harga Jual',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Masukkan harga jual yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _stokController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Masukkan jumlah stok yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveSukuCadang,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.blue[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,
                ),
                child: Text(
                  widget.sukuCadang == null
                      ? 'Simpan Suku Cadang'
                      : 'Perbarui Suku Cadang',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
