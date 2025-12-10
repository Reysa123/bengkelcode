// lib/screens/add_edit_pembelian_suku_cadang_screen.dart
import 'package:bengkel/blocs/part/part_bloc.dart';
import 'package:bengkel/blocs/part/part_event.dart';
import 'package:bengkel/blocs/part/part_state.dart';
import 'package:bengkel/blocs/pembelian_suku_cadang/pembelian_suku_cadang_bloc.dart';
import 'package:bengkel/blocs/pembelian_suku_cadang/pembelian_suku_cadang_event.dart';
import 'package:bengkel/blocs/vendor/vendor_bloc.dart';
import 'package:bengkel/blocs/vendor/vendor_event.dart';
import 'package:bengkel/blocs/vendor/vendor_state.dart';
import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/detail_pembelian_suku_cadang.dart';
import 'package:bengkel/model/pembelian_suku_cadang.dart';
import 'package:bengkel/model/suplier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEditPembelianSukuCadangScreen extends StatefulWidget {
  final PembelianSukuCadang?
  pembelianSukuCadang; // Null jika menambah, berisi data jika mengedit

  const AddEditPembelianSukuCadangScreen({super.key, this.pembelianSukuCadang});

  @override
  State<AddEditPembelianSukuCadangScreen> createState() =>
      _AddEditPembelianSukuCadangScreenState();
}

class _AddEditPembelianSukuCadangScreenState
    extends State<AddEditPembelianSukuCadangScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tanggalPembelianController;
  late TextEditingController _catatanController;
  DateFormat df = DateFormat('dd-MM-yyyy HH:mm:ss');
  DateTime tp = DateTime.now();
  int? _selectedSupplierId;
  final List<Map<String, dynamic>> _selectedSukuCadangDetails =
      []; // Untuk menyimpan detail suku cadang yang dibeli
  List<DetailPembelianSukuCadang> sukuCadangDetails = [];
  @override
  void initState() {
    super.initState();
    // Muat data supplier dan suku cadang untuk dropdown
    context.read<VendorBloc>().add(const LoadVendors());
    context.read<SukuCadangBloc>().add(const LoadParts());

    if (widget.pembelianSukuCadang != null) {
      _tanggalPembelianController = TextEditingController(
        text: df.format(widget.pembelianSukuCadang!.tanggalPembelian),
      );
      _catatanController = TextEditingController(
        text: widget.pembelianSukuCadang!.catatan ?? '',
      );
      _selectedSupplierId = widget.pembelianSukuCadang!.supplierId;
      isiDetail();
    } else {
      _tanggalPembelianController = TextEditingController(
        text: df.format(DateTime.now()),
      );
      _catatanController = TextEditingController();
    }
  }

  isiDetail() async {
    final db = await DatabaseHelper().database;
    final id = widget.pembelianSukuCadang?.id;
    final depem = await db.query('DetailPembelianSukuCadang');
    for (var e in depem.where((v) => v['pembelian_id'] == id).toList()) {
      setState(() {
        _selectedSukuCadangDetails.add({
          'pembelian_id': e['pembelian_id'],
          'suku_cadang_id': e['suku_cadang_id'],
          'jumlah': e['jumlah'],
          'harga_beli_saat_itu': e['harga_beli_saat_itu'],
          'sub_total': e['sub_total'],
        });
      });
    }
  }

  @override
  void dispose() {
    _tanggalPembelianController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          tp = finalDateTime;
          controller.text = df.format(finalDateTime);
        });
      }
    }
  }

  void _addSukuCadangDetailItem() {
    setState(() {
      _selectedSukuCadangDetails.add({
        'pembelian_id': 0,
        'suku_cadang_id': null,
        'jumlah': 1,
        'harga_beli_saat_itu': 0.0,
        'sub_total': 0.0,
      });
    });
  }

  void _removeSukuCadangDetailItem(int index) {
    setState(() {
      _selectedSukuCadangDetails.removeAt(index);
    });
  }

  void _savePembelianSukuCadang() {
    if (_formKey.currentState!.validate()) {
      double totalPembelian = 0.0;
      for (var detail in _selectedSukuCadangDetails) {
        totalPembelian += detail['sub_total'] as double;
        sukuCadangDetails.add(DetailPembelianSukuCadang.fromMap(detail));
      }

      final pembelianData = PembelianSukuCadang(
        id: widget.pembelianSukuCadang?.id,
        supplierId: _selectedSupplierId!,
        tanggalPembelian: tp,
        totalPembelian: totalPembelian,
        status: 'In Proses',
        catatan:
            _catatanController.text.isEmpty ? null : _catatanController.text,
      );

      // Ini mungkin memerlukan event khusus di BLoC PembelianSukuCadang
      // yang menerima PembelianSukuCadang dan List<DetailPembelianSukuCadang>
      if (widget.pembelianSukuCadang == null) {
        context.read<PembelianSukuCadangBloc>().add(
          AddPembelianSukuCadang(
            pembelianData,
            detailSukuCadang: sukuCadangDetails,
          ), // Saat ini hanya mengirim data utama
          // Anda perlu memodifikasi AddPembelianSukuCadangEvent untuk menerima detail
          // atau membuat event baru seperti AddPembelianSukuCadangWithDetails
        );
      } else {
        context.read<PembelianSukuCadangBloc>().add(
          UpdatePembelianSukuCadang(
            pembelianData,
            detailSukuCadang: sukuCadangDetails,
          ), // Saat ini hanya mengirim data utama
          // Anda perlu memodifikasi UpdatePembelianSukuCadangEvent untuk menerima detail
          // atau membuat event baru seperti UpdatePembelianSukuCadangWithDetails
        );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pembelianSukuCadang == null
              ? 'Tambah Pembelian Suku Cadang'
              : 'Edit Pembelian Suku Cadang',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Dropdown untuk memilih Supplier
              BlocBuilder<VendorBloc, VendorState>(
                builder: (context, state) {
                  if (state is VendorsLoaded) {
                    return DropdownButtonFormField<int>(
                      value: _selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: 'Supplier',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Pilih Supplier'),
                      items:
                          state.vendors.map((Supplier supplier) {
                            return DropdownMenuItem<int>(
                              value: supplier.id,
                              child: Text(supplier.namaSupplier),
                            );
                          }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedSupplierId = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih supplier';
                        }
                        return null;
                      },
                    );
                  } else if (state is VendorLoading) {
                    return const LinearProgressIndicator();
                  } else if (state is VendorError) {
                    return Text('Error memuat supplier: ${state.message}');
                  }
                  return const Text('Tidak ada supplier tersedia.');
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _tanggalPembelianController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pembelian',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(_tanggalPembelianController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal pembelian tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24.0),
              Text(
                'Detail Suku Cadang Dibeli',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0),
              BlocBuilder<SukuCadangBloc, PartState>(
                builder: (context, sukuCadangState) {
                  if (sukuCadangState is PartsLoaded) {
                    return Column(
                      children: [
                        ..._selectedSukuCadangDetails.asMap().entries.map((
                          entry,
                        ) {
                          int idx = entry.key;
                          Map<String, dynamic> item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DropdownButtonFormField<int>(
                                    value: item['suku_cadang_id'],
                                    decoration: const InputDecoration(
                                      labelText: 'Suku Cadang',
                                      border: OutlineInputBorder(),
                                    ),
                                    items:
                                        sukuCadangState.parts
                                            .map<DropdownMenuItem<int>>((part) {
                                              return DropdownMenuItem<int>(
                                                value: part.id,
                                                child: Text(part.namaPart),
                                              );
                                            })
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        item['suku_cadang_id'] = value;
                                        final selectedPart = sukuCadangState
                                            .parts
                                            .firstWhere(
                                              (element) => element.id == value,
                                            );
                                        item['harga_beli_saat_itu'] =
                                            selectedPart
                                                .hargaBeli; // Ambil harga beli
                                        item['sub_total'] =
                                            (item['jumlah'] as int) *
                                            (item['harga_beli_saat_itu']
                                                as double);
                                      });
                                    },
                                    validator:
                                        (value) =>
                                            value == null
                                                ? 'Pilih suku cadang'
                                                : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    initialValue: item['jumlah'].toString(),
                                    decoration: const InputDecoration(
                                      labelText: 'Jumlah',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        item['jumlah'] =
                                            int.tryParse(value) ?? 1;
                                        item['sub_total'] =
                                            (item['jumlah'] as int) *
                                            (item['harga_beli_saat_itu']
                                                as double);
                                      });
                                    },
                                    validator:
                                        (value) =>
                                            (int.tryParse(value ?? '') ?? 0) <=
                                                    0
                                                ? 'Min 1'
                                                : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 180,
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text: NumberFormat(
                                        '#,###',
                                      ).format(item['sub_total']),
                                    ),
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      prefixText: 'Rp.',
                                      suffixText: ',-',
                                      labelText: 'Harga',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed:
                                      () => _removeSukuCadangDetailItem(idx),
                                ),
                              ],
                            ),
                          );
                        }),
                        ElevatedButton.icon(
                          onPressed: _addSukuCadangDetailItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Item Suku Cadang'),
                        ),
                      ],
                    );
                  } else if (sukuCadangState is PartLoading) {
                    return const LinearProgressIndicator();
                  } else if (sukuCadangState is PartError) {
                    return Text(
                      'Error memuat suku cadang: ${sukuCadangState.message}',
                    );
                  }
                  return const Text('Tidak ada suku cadang tersedia.');
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _savePembelianSukuCadang,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.blue[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,
                ),
                child: Text(
                  widget.pembelianSukuCadang == null
                      ? 'Simpan Pembelian'
                      : 'Perbarui Pembelian',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
