// lib/screens/add_edit_jasa_screen.dart
import 'package:bengkel/blocs/jasa/jasa_bloc.dart';
import 'package:bengkel/blocs/jasa/jasa_event.dart';
import 'package:bengkel/model/jasa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Pastikan path ini benar

class AddEditJasaScreen extends StatefulWidget {
  final Jasa? jasa; // Null jika menambah, berisi data jika mengedit

  const AddEditJasaScreen({super.key, this.jasa});

  @override
  State<AddEditJasaScreen> createState() => _AddEditJasaScreenState();
}

class _AddEditJasaScreenState extends State<AddEditJasaScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  late TextEditingController _namaJasaController;
  late TextEditingController _hargaBeliController;
  late TextEditingController _hargaJualController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data awal jika dalam mode edit
    _namaJasaController = TextEditingController(
      text: widget.jasa?.namaJasa ?? '',
    );
    _hargaBeliController = TextEditingController(
      text: widget.jasa?.hargaBeli.toString() ?? '0.0',
    );
    _hargaJualController = TextEditingController(
      text: widget.jasa?.hargaJual.toString() ?? '0.0',
    );
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget tidak lagi digunakan
    _namaJasaController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan data jasa
  void _saveJasa() {
    if (_formKey.currentState!.validate()) {
      // Buat objek Jasa dari input form
      final newJasa = Jasa(
        id:
            widget
                .jasa
                ?.id, // ID akan null jika menambah baru, ada jika mengedit
        namaJasa: _namaJasaController.text,
        hargaBeli: double.parse(_hargaBeliController.text),
        hargaJual: double.parse(_hargaJualController.text),
      );

      // Dispatch event ke BLoC berdasarkan mode (tambah atau edit)
      if (widget.jasa == null) {
        // Mode Tambah
        context.read<JasaBloc>().add(AddJasa(newJasa));
      } else {
        // Mode Edit
        context.read<JasaBloc>().add(UpdateJasa(newJasa));
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
        title: Text(widget.jasa == null ? 'Tambah Jasa Baru' : 'Edit Jasa'),
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
                controller: _namaJasaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Jasa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama jasa tidak boleh kosong';
                  }
                  return null;
                },
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
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveJasa,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.blue[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,
                ),
                child: Text(
                  widget.jasa == null ? 'Simpan Jasa' : 'Perbarui Jasa',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
