// lib/screens/add_edit_penjualan_suku_cadang_screen.dart
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:bengkel/blocs/nomor/nomor_bloc.dart';
import 'package:bengkel/blocs/nomor/nomor_event.dart';
import 'package:bengkel/blocs/nomor/nomor_state.dart';
import 'package:bengkel/blocs/part/part_bloc.dart';
import 'package:bengkel/blocs/part/part_event.dart';
import 'package:bengkel/blocs/part/part_state.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_bloc.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_event.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_state.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_bloc.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_event.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_state.dart';
import 'package:bengkel/model/detailpenjualansukucadang.dart';
import 'package:bengkel/model/part.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/model/penjualansukucadang.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEditPenjualanSukuCadangScreen extends StatefulWidget {
  final PenjualanSukuCadang?
  penjualanSukuCadang; // Null jika menambah, berisi data jika mengedit

  const AddEditPenjualanSukuCadangScreen({super.key, this.penjualanSukuCadang});

  @override
  State<AddEditPenjualanSukuCadangScreen> createState() =>
      _AddEditPenjualanSukuCadangScreenState();
}

class _AddEditPenjualanSukuCadangScreenState
    extends State<AddEditPenjualanSukuCadangScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tanggalPenjualanController;
  late TextEditingController _catatanController;
  DateFormat df = DateFormat('dd-MM-yyyy HH:mm:ss');
  bool dapat = false;
  String? _selectedPelangganId;
  DateTime tp = DateTime.now();
  int? pelangganId;
  List<Map<String, dynamic>> _selectedSukuCadangDetails =
      []; // Untuk menyimpan detail suku cadang yang dijual
  int? nomorTrx;
  double _totalPenjualan = 0.0;

  @override
  void initState() {
    super.initState();
    // Muat data untuk dropdown
    context.read<PelangganBloc>().add(const LoadPelanggan());
    context.read<SukuCadangBloc>().add(const LoadParts());
    context.read<NomorBloc>().add(const LoadNomor());
    if (widget.penjualanSukuCadang != null) {
      start();
      // Mode Edit: Muat data penjualan utama
      _tanggalPenjualanController = TextEditingController(
        text: df.format(widget.penjualanSukuCadang!.tanggalPenjualan),
      );
      tp = widget.penjualanSukuCadang!.tanggalPenjualan;
      nomorTrx = widget.penjualanSukuCadang!.transaksiId!;
      _catatanController = TextEditingController(
        text: widget.penjualanSukuCadang!.catatan ?? '',
      );
      pelangganId = widget.penjualanSukuCadang!.pelangganId;

      // Dispatch event untuk memuat detail suku cadang
      context.read<PenjualanSukuCadangBloc>().add(
        LoadPenjualanSukuCadangDetail(widget.penjualanSukuCadang!.transaksiId!),
      );
      stop();
    } else {
      start();
      // Mode Tambah: Inisialisasi default
      _tanggalPenjualanController = TextEditingController(
        text: df.format(DateTime.now()),
      );
      _catatanController = TextEditingController();
      stop();
    }
  }

  start() {
    setState(() {
      dapat = true;
    });
    final a = BlocProvider.of<NomorBloc>(context).state;
    if (a is NomorLoaded) {
      setState(() {
        widget.penjualanSukuCadang == null
            ? nomorTrx = a.notrx!
            : widget.penjualanSukuCadang!.transaksiId!;
      });
    }
  }

  stop() {
    setState(() {
      dapat = false;
    });
  }

  @override
  void dispose() {
    _tanggalPenjualanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih tanggal dan waktu
  Future<void> _selectDateTime(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(controller.text.isEmpty ? '' : controller.text) ??
          DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          DateTime.tryParse(controller.text.isEmpty ? '' : controller.text) ??
              DateTime.now(),
        ),
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
          controller.text = finalDateTime.toIso8601String().substring(0, 19);
          tp = finalDateTime;
        });
      }
    }
  }

  // Fungsi untuk menambah item suku cadang
  void _addSukuCadangDetailItem() {
    setState(() {
      _selectedSukuCadangDetails.add({
        'catatan': "",
        'suku_cadang_id': null,
        'jumlah': 1,
        'harga_jual_saat_itu': 0.0,
        'sub_total': 0.0,
      });
      _calculateTotals();
    });
  }

  // Fungsi untuk menghapus item suku cadang
  void _removeSukuCadangDetailItem(int index) {
    setState(() {
      _selectedSukuCadangDetails.removeAt(index);
      _calculateTotals();
    });
  }

  // Fungsi untuk menghitung ulang total biaya
  void _calculateTotals() {
    double currentTotalPenjualan = 0.0;
    for (var detail in _selectedSukuCadangDetails) {
      currentTotalPenjualan += detail['sub_total'] as double;
    }

    setState(() {
      _totalPenjualan = currentTotalPenjualan;
    });
  }

  // Fungsi untuk menyimpan penjualan suku cadang
  void _savePenjualanSukuCadang() {
    if (_formKey.currentState!.validate()) {
      final penjualanData = PenjualanSukuCadang(
        id: widget.penjualanSukuCadang?.id,
        transaksiId: nomorTrx,
        pelangganId: pelangganId, // Bisa null untuk penjualan tunai
        tanggalPenjualan: tp,
        totalPenjualan: _totalPenjualan,
        status: 'In Proses',
        catatan:
            _catatanController.text.isEmpty ? null : _catatanController.text,
      );

      final List<DetailPenjualanSukuCadang> sukuCadangDetailsToSave =
          _selectedSukuCadangDetails.map((item) {
            return DetailPenjualanSukuCadang(
              penjualanId: 0, // Akan diisi oleh BLoC
              sukuCadangId: item['suku_cadang_id'],
              jumlah: item['jumlah'],
              hargaJualSaatItu: item['harga_jual_saat_itu'],

              subTotal: item['sub_total'],
            );
          }).toList();

      if (widget.penjualanSukuCadang == null) {
        context.read<PenjualanSukuCadangBloc>().add(
          AddPenjualanSukuCadang(
            penjualanData,
            detailSukuCadang: sukuCadangDetailsToSave,
          ),
        );
        context.read<NomorBloc>().add(UpdateNomorTrk());
      } else {
        context.read<PenjualanSukuCadangBloc>().add(
          UpdatePenjualanSukuCadang(
            penjualanData,
            detailSukuCadang: sukuCadangDetailsToSave,
          ),
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
          widget.penjualanSukuCadang == null
              ? 'Tambah Penjualan Suku Cadang'
              : 'Edit Penjualan Suku Cadang',
        ),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PenjualanSukuCadangBloc, PenjualanSukuCadangState>(
            listener: (context, state) {
              if (state is PenjualanSukuCadangDetailLoaded) {
                setState(() {
                  // Isi detail suku cadang
                  _selectedSukuCadangDetails =
                      state.detailSukuCadang.map((detail) {
                        return {
                          'suku_cadang_id': detail.sukuCadangId,
                          'jumlah': detail.jumlah,
                          'harga_jual_saat_itu': detail.hargaJualSaatItu,
                          'sub_total': detail.subTotal,
                        };
                      }).toList();
                  _calculateTotals(); // Hitung ulang total setelah memuat detail
                });
              }
            },
          ),
          BlocListener<NomorBloc, NomorState>(
            listener: (context, state) {
              if (state is NomorLoaded) {
                setState(() {
                  widget.penjualanSukuCadang == null
                      ? nomorTrx = state.notrx!
                      : widget.penjualanSukuCadang!.transaksiId!;
                });
              }
            },
          ),
        ],
        child:
            dapat
                ? Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        // Pelanggan Dropdown (Opsional)
                        BlocBuilder<PelangganBloc, PelangganState>(
                          builder: (context, state) {
                            if (state is PelangganLoaded) {
                              _selectedPelangganId =
                                  pelangganId == null
                                      ? null
                                      : state.pelangganList
                                          .where((v) => v.id == pelangganId)
                                          .first
                                          .nama;
                              return CustomDropdown<String>.search(
                                initialItem: _selectedPelangganId,
                                decoration: CustomDropdownDecoration(
                                  closedFillColor: Colors.white,
                                  expandedFillColor: Colors.white,
                                  prefixIcon: InkWell(
                                    child: Icon(Icons.search),
                                    onTap: () async {},
                                  ),
                                  closedBorderRadius: BorderRadius.circular(5),
                                  expandedBorderRadius: BorderRadius.circular(
                                    5,
                                  ),
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
                                  headerStyle: TextStyle(fontSize: 12),
                                  listItemStyle: TextStyle(fontSize: 12),
                                  hintStyle: TextStyle(fontSize: 12),
                                ),
                                hintText:
                                    'Pilih Pelanggan (untuk penjualan langsung)',

                                items:
                                    state.pelangganList
                                        .map((Pelanggan v) => v.nama)
                                        .toList(),

                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedPelangganId = newValue;
                                    pelangganId =
                                        state.pelangganList
                                            .where((v) => v.nama == newValue)
                                            .first
                                            .id;
                                  });
                                },
                              );
                            } else if (state is PelangganLoading) {
                              return const LinearProgressIndicator();
                            } else if (state is PelangganError) {
                              return Text(
                                'Error memuat pelanggan: //${state.message}',
                              );
                            }
                            return const Text('Tidak ada pelanggan tersedia.');
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Tanggal Penjualan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 25,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: nomorTrx.toString(),
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Nomor Transaksi',
                                  border: OutlineInputBorder(),
                                ),
                                readOnly: true,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: TextFormField(
                                controller: _tanggalPenjualanController,
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal Penjualan',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap:
                                    () => _selectDateTime(
                                      _tanggalPenjualanController,
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Tanggal penjualan tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
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

                        // --- Detail Suku Cadang ---
                        Text(
                          'Detail Suku Cadang Dijual',
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
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
                                                  sukuCadangState.parts.map<
                                                    DropdownMenuItem<int>
                                                  >((part) {
                                                    return DropdownMenuItem<
                                                      int
                                                    >(
                                                      value: part.id,
                                                      child: Text(
                                                        '${part.namaPart} (Stok: ${part.stok})',
                                                      ), // Tampilkan stok
                                                    );
                                                  }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  item['suku_cadang_id'] =
                                                      value;
                                                  final selectedPart =
                                                      sukuCadangState.parts
                                                          .firstWhere(
                                                            (element) =>
                                                                element.id ==
                                                                value,
                                                          );
                                                  item['harga_jual_saat_itu'] =
                                                      selectedPart
                                                          .hargaJual; // Ambil harga jual suku cadang
                                                  item['sub_total'] =
                                                      (item['jumlah'] as int) *
                                                      (item['harga_jual_saat_itu']
                                                          as double);
                                                  _calculateTotals();
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
                                            flex: 2,
                                            child: TextFormField(
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              initialValue:
                                                  item['jumlah'].toString(),
                                              decoration: const InputDecoration(
                                                labelText: 'Jumlah',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  item['jumlah'] =
                                                      int.tryParse(value) ?? 1;
                                                  item['sub_total'] =
                                                      (double.parse(
                                                        item['jumlah']
                                                            .toString(),
                                                      )) *
                                                      (double.parse(
                                                        item['harga_jual_saat_itu']
                                                            .toString(),
                                                      ));
                                                  _calculateTotals();
                                                });
                                              },
                                              validator: (value) {
                                                final int? jumlah =
                                                    int.tryParse(value ?? '');
                                                if (jumlah == null ||
                                                    jumlah <= 0) {
                                                  return 'Min 1';
                                                }
                                                final selectedPartId =
                                                    item['suku_cadang_id'];
                                                if (selectedPartId != null) {
                                                  final SukuCadang
                                                  selectedPart = sukuCadangState
                                                      .parts
                                                      .firstWhere(
                                                        (element) =>
                                                            element.id ==
                                                            selectedPartId,
                                                      );
                                                  if (jumlah >
                                                      selectedPart.stok) {
                                                    return 'Stok tidak cukup (${selectedPart.stok} tersedia)';
                                                  }
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 1,
                                            child: TextFormField(
                                              controller: TextEditingController(
                                                text:
                                                    'Rp ${NumberFormat('#,###').format(double.parse(item['sub_total']?.toStringAsFixed(0)))}',
                                              ),
                                              decoration: const InputDecoration(
                                                labelText: 'Total',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed:
                                                () =>
                                                    _removeSukuCadangDetailItem(
                                                      idx,
                                                    ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  ElevatedButton.icon(
                                    onPressed: _addSukuCadangDetailItem,
                                    icon: const Icon(Icons.add),
                                    label: const Text(
                                      'Tambah Item Suku Cadang',
                                    ),
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
                            return const Text(
                              'Tidak ada suku cadang tersedia.',
                            );
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // --- Total Biaya ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL PENJUALAN:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${NumberFormat('#,###').format(double.parse(_totalPenjualan.toStringAsFixed(0)))}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),

                        ElevatedButton(
                          onPressed: _savePenjualanSukuCadang,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            backgroundColor: Colors.blue[200],
                            foregroundColor: Colors.black,
                            shadowColor: Colors.yellow,
                            elevation: 5,
                          ),
                          child: Text(
                            widget.penjualanSukuCadang == null
                                ? 'Simpan Penjualan'
                                : 'Perbarui Penjualan',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
