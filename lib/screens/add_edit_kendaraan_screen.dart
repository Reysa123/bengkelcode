// lib/screens/add_edit_kendaraan_screen.dart
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_bloc.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_event.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_state.dart';
import 'package:bengkel/blocs/type/type_kendaraan_bloc.dart';
import 'package:bengkel/blocs/type/type_kendaraan_event.dart';
import 'package:bengkel/blocs/type/type_kendaraan_state.dart';
import 'package:bengkel/blocs/vehicle/kendaraan_bloc.dart';
import 'package:bengkel/blocs/vehicle/kendaraan_event.dart';
import 'package:bengkel/blocs/vehicle/kendaraan_state.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/model/merk_kendaraan.dart';
import 'package:bengkel/model/type_kendaraan.dart';
import 'package:bengkel/screens/add_edit_pelanggan_screen.dart';
import 'package:bengkel/screens/merk_kendaraan_screen.dart';
import 'package:bengkel/screens/type_kendaraan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditKendaraanScreen extends StatefulWidget {
  final Kendaraan? kendaraan; // Null jika menambah, berisi data jika mengedit
  final String? namaCust;
  const AddEditKendaraanScreen({super.key, this.kendaraan, this.namaCust});

  @override
  State<AddEditKendaraanScreen> createState() => _AddEditKendaraanScreenState();
}

class _AddEditKendaraanScreenState extends State<AddEditKendaraanScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  late TextEditingController _merkController;
  late TextEditingController _modelController;
  late TextEditingController _tahunController;
  late TextEditingController _platNomorController;
  late TextEditingController _nomorRangkaController;
  late TextEditingController _nomorMesinController;
  late TextEditingController _km;
  String? merks, types;

  List<TypeKendaraan> _types = [];
  int? _selectedPelangganId;
  String? _selectedPelanggan; // Untuk menyimpan ID pelanggan yang dipilih

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data awal jika dalam mode edit
    _merkController = TextEditingController(text: widget.kendaraan?.merk ?? '');
    _modelController = TextEditingController(
      text: widget.kendaraan?.model ?? '',
    );
    _tahunController = TextEditingController(
      text: widget.kendaraan?.tahun?.toString() ?? '',
    );
    _platNomorController = TextEditingController(
      text: widget.kendaraan?.platNomor ?? '',
    );
    _nomorRangkaController = TextEditingController(
      text: widget.kendaraan?.nomorRangka ?? '',
    );
    _nomorMesinController = TextEditingController(
      text: widget.kendaraan?.nomorMesin ?? '',
    );
    _km = TextEditingController(text: widget.kendaraan?.km.toString() ?? '0');
    _selectedPelangganId = widget.kendaraan?.pelangganId;
    _selectedPelanggan = widget.namaCust;
    widget.kendaraan?.merk == "" ? null : merks = widget.kendaraan?.merk;
    widget.kendaraan?.model == "" ? null : types = widget.kendaraan?.model;

    context.read<TypeKendaraanBloc>().add(LoadTypeKendaraan());
    // Muat data pelanggan saat inisialisasi untuk dropdown
    context.read<PelangganBloc>().add(const LoadPelanggan());
    context.read<KendaraanBloc>().add(const LoadKendaraan());
  }

  @override
  void dispose() {
    // Pastikan untuk membuang controller saat widget tidak lagi digunakan
    _merkController.dispose();
    _modelController.dispose();
    _tahunController.dispose();
    _platNomorController.dispose();
    _nomorRangkaController.dispose();
    _nomorMesinController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan data kendaraan
  void _saveKendaraan() {
    if (_formKey.currentState!.validate()) {
      // Buat objek Kendaraan dari input form
      final newKendaraan = Kendaraan(
        id:
            widget
                .kendaraan
                ?.id, // ID akan null jika menambah baru, ada jika mengedit
        pelangganId: _selectedPelangganId!, // Wajib diisi dari dropdown
        merk: merks!,
        model: types!,
        tahun: int.tryParse(_tahunController.text),
        platNomor: _platNomorController.text,
        nomorRangka:
            _nomorRangkaController.text.isEmpty
                ? null
                : _nomorRangkaController.text,
        nomorMesin:
            _nomorMesinController.text.isEmpty
                ? null
                : _nomorMesinController.text,
        km: _km.text.isEmpty ? 0 : int.parse(_km.text),
      );

      // Dispatch event ke BLoC berdasarkan mode (tambah atau edit)
      if (widget.kendaraan == null) {
        // Mode Tambah
        context.read<KendaraanBloc>().add(AddKendaraan(newKendaraan));
      } else {
        // Mode Edit
        context.read<KendaraanBloc>().add(UpdateKendaraan(newKendaraan));
      }

      Navigator.pop(
        context,
        _nomorRangkaController.text,
      ); // Kembali ke layar sebelumnya setelah menyimpan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.kendaraan == null ? 'Tambah Kendaraan Baru' : 'Edit Kendaraan',
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
              // Dropdown untuk memilih Pelanggan
              BlocBuilder<PelangganBloc, PelangganState>(
                builder: (context, state) {
                  if (state is PelangganLoaded) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: CustomDropdown<String>.search(
                              initialItem: _selectedPelanggan,

                              items:
                                  state.pelangganList
                                      .map((e) => e.nama)
                                      .toList(),
                              hintText: 'Select Pelanggan',
                              decoration: CustomDropdownDecoration(
                                closedFillColor: Colors.white,
                                expandedFillColor: Colors.white,
                                closedBorderRadius: BorderRadius.circular(5),
                                expandedBorderRadius: BorderRadius.circular(5),
                                closedBorder: BoxBorder.lerp(
                                  Border.all(),
                                  Border.all(),
                                  1,
                                ),
                                expandedBorder: BoxBorder.lerp(
                                  Border.all(),
                                  Border.all(),
                                  1,
                                ),
                                headerStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                listItemStyle: TextStyle(fontSize: 14),
                                hintStyle: TextStyle(fontSize: 12),
                                searchFieldDecoration: SearchFieldDecoration(),
                              ),
                              onChanged: (String? vv) {
                                setState(() {
                                  _selectedPelangganId =
                                      state.pelangganList
                                          .firstWhere((v) => v.nama == vv)
                                          .id;
                                });
                              },

                              validator: (value) {
                                if (value == null) {
                                  return 'Pilih pelanggan pemilik kendaraan';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const AddEditPelangganScreen(),
                              ),
                            );
                          },
                          child: const Text('...'),
                        ),
                      ],
                    );
                  } else if (state is PelangganLoading) {
                    return const LinearProgressIndicator();
                  } else if (state is PelangganError) {
                    return Text('Error memuat pelanggan: ${state.message}');
                  }
                  return const Text('Tidak ada pelanggan tersedia.');
                },
              ),
              const SizedBox(height: 16.0),

              BlocBuilder<KendaraanBloc, KendaraanState>(
                builder: (context, state) {
                  if (state is KendaraanLoaded) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      spacing: 10,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: merks,
                            decoration: const InputDecoration(
                              labelText: 'Merk Kendaraan',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select Merk'),
                            items:
                                state.merkList.map((MerkKendaraan e) {
                                  return DropdownMenuItem(
                                    value: e.namaMerk,
                                    child: Text(e.namaMerk),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                types = null;
                                merks = value;
                                int? id =
                                    state.merkList
                                        .where((t) => t.namaMerk == value)
                                        .first
                                        .id;
                                setState(() {
                                  _types =
                                      state.typeList
                                          .where((v) => v.merkId == id)
                                          .toList();
                                });
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an merk';
                              }
                              return null;
                            },
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const MerkKendaraanScreen(),
                              ),
                            ).then(
                              (onValue) => context.read<KendaraanBloc>().add(
                                const LoadKendaraan(),
                              ),
                            );
                          },
                          child: const Text('...'),
                        ),
                      ],
                    );
                  } else if (state is KendaraanLoading) {
                    return const LinearProgressIndicator();
                  } else if (state is KendaraanError) {
                    return Text(
                      'Error memuat merk kendaraan: ${state.message}',
                    );
                  }
                  return const Text('Tidak ada merk tersedia.');
                },
              ),

              const SizedBox(height: 16.0),
              BlocBuilder<TypeKendaraanBloc, TypeKendaraanState>(
                builder: (context, stateTypes) {
                  if (stateTypes is TypeKendaraanLoaded) {
                    final type =
                        widget.kendaraan == null
                            ? _types
                            : _types.isNotEmpty || widget.kendaraan != null
                            ? _types
                            : stateTypes.types;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      spacing: 10,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: types,
                            decoration: const InputDecoration(
                              labelText: 'Tipe Kendaraan',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select tipe'),
                            items:
                                type.map((TypeKendaraan e) {
                                  return DropdownMenuItem(
                                    value: e.namaTipe,
                                    child: Text(e.namaTipe),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                types = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an tipe';
                              }
                              return null;
                            },
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const TypeKendaraanScreen(),
                              ),
                            ).then(
                              (onValue) => context.read<KendaraanBloc>().add(
                                const LoadKendaraan(),
                              ),
                            );
                          },
                          child: const Text('...'),
                        ),
                      ],
                    );
                  } else if (stateTypes is TypeKendaraanLoading) {
                    return const LinearProgressIndicator();
                  } else if (stateTypes is TypeKendaraanError) {
                    return Text(
                      'Error memuat tipe kendaraan: ${stateTypes.message}',
                    );
                  }
                  return const Text('Tidak ada tipe tersedia.');
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _tahunController,
                decoration: const InputDecoration(
                  labelText: 'Tahun (Opsional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      int.tryParse(value) == null) {
                    return 'Masukkan tahun yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _platNomorController,
                decoration: const InputDecoration(
                  labelText: 'Plat Nomor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Plat nomor tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nomorRangkaController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Rangka (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nomorMesinController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Mesin (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                readOnly: widget.kendaraan == null,
                controller: _km,
                decoration: const InputDecoration(
                  labelText: 'Kilometer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: _saveKendaraan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.blue[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,
                ),
                icon: Icon(Icons.save),
                label: Text(
                  widget.kendaraan == null
                      ? 'Simpan Kendaraan'
                      : 'Perbarui Kendaraan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
