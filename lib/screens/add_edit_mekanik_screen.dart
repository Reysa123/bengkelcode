// lib/screens/add_edit_mekanik_screen.dart
import 'package:bengkel/blocs/mekanik/mekanik_bloc.dart';
import 'package:bengkel/blocs/mekanik/mekanik_event.dart';
import 'package:bengkel/model/mekanik.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Pastikan path ini benar

class AddEditMekanikScreen extends StatefulWidget {
  final Mekanik? mekanik; // Null jika menambah, berisi data jika mengedit

  const AddEditMekanikScreen({super.key, this.mekanik});

  @override
  State<AddEditMekanikScreen> createState() => _AddEditMekanikScreenState();
}

class _AddEditMekanikScreenState extends State<AddEditMekanikScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  late TextEditingController _namaMekanikController;
  late TextEditingController _alamatController;
  late TextEditingController _teleponController;
  String? _ruleController = "-Select-"; // Untuk spesialisasi/rule
  String rules = "";

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data awal jika dalam mode edit
    _namaMekanikController = TextEditingController(
      text: widget.mekanik?.namaMekanik ?? '',
    );
    _alamatController = TextEditingController(
      text: widget.mekanik?.alamat ?? '',
    );
    _teleponController = TextEditingController(
      text: widget.mekanik?.telepon ?? '',
    );
    _ruleController = widget.mekanik?.rule;
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget tidak lagi digunakan
    _namaMekanikController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan data mekanik
  void _saveMekanik() {
    if (_formKey.currentState!.validate()) {
      // Buat objek Mekanik dari input form
      final newMekanik = Mekanik(
        id:
            widget
                .mekanik
                ?.id, // ID akan null jika menambah baru, ada jika mengedit
        namaMekanik: _namaMekanikController.text,
        alamat: _alamatController.text.isEmpty ? null : _alamatController.text,
        telepon:
            _teleponController.text.isEmpty ? null : _teleponController.text,
        rule: _ruleController,
      );

      // Dispatch event ke BLoC berdasarkan mode (tambah atau edit)
      if (widget.mekanik == null) {
        // Mode Tambah
        context.read<MekanikBloc>().add(AddMekanik(newMekanik));
      } else {
        // Mode Edit
        context.read<MekanikBloc>().add(UpdateMekanik(newMekanik));
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
          widget.mekanik == null ? 'Tambah Mekanik Baru' : 'Edit Mekanik',
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
                controller: _namaMekanikController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mekanik',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama mekanik tidak boleh kosong';
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
                  labelText: 'Telepon (Opsional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _ruleController,
                decoration: const InputDecoration(
                  labelText: 'Spesialisasi/Rule (Opsional)',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Pilih Spesialisasi/Rule'),
                items:
                    ["-Select-", "MEKANIK", "SERVICE ADVISOR", "FOREMAN"].map((
                      e,
                    ) {
                      return DropdownMenuItem<String>(value: e, child: Text(e));
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _ruleController = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value == "-Select-") {
                    return 'Pilih Spesialisasi/Rule';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveMekanik,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.blue[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,
                ),
                child: Text(
                  widget.mekanik == null
                      ? 'Simpan Mekanik'
                      : 'Perbarui Mekanik',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
