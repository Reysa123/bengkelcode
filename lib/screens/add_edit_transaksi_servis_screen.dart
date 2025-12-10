// lib/screens/add_edit_transaksi_servis_screen.dart
import 'package:bengkel/blocs/jasa/jasa_bloc.dart';
import 'package:bengkel/blocs/jasa/jasa_event.dart';
import 'package:bengkel/blocs/jasa/jasa_state.dart';
import 'package:bengkel/blocs/mekanik/mekanik_bloc.dart';
import 'package:bengkel/blocs/mekanik/mekanik_event.dart';
import 'package:bengkel/blocs/mekanik/mekanik_state.dart';
import 'package:bengkel/blocs/nomor/nomor_bloc.dart';
import 'package:bengkel/blocs/nomor/nomor_event.dart';
import 'package:bengkel/blocs/nomor/nomor_state.dart';
import 'package:bengkel/blocs/part/part_bloc.dart';
import 'package:bengkel/blocs/part/part_event.dart';
import 'package:bengkel/blocs/part/part_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_detail_service_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_bloc.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_event.dart';
import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_bloc.dart';
import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_event.dart';
import 'package:bengkel/blocs/vehicle/kendaraan_bloc.dart';
import 'package:bengkel/blocs/vehicle/kendaraan_event.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:bengkel/model/detailsukucadangservice.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/model/transaksiservice.dart';
import 'package:bengkel/print/printpkb.dart';
import 'package:bengkel/screens/suku_cadang_list_screen.dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEditTransaksiServisScreen extends StatefulWidget {
  final TransaksiServis?
  transaksiServis; // Null jika menambah, berisi data jika mengedit
  final Kendaraan? kendaraan;
  final Pelanggan? pelanggan;

  const AddEditTransaksiServisScreen({
    super.key,
    this.transaksiServis,
    this.kendaraan,
    this.pelanggan,
  });

  @override
  State<AddEditTransaksiServisScreen> createState() =>
      _AddEditTransaksiServisScreenState();
}

class _AddEditTransaksiServisScreenState
    extends State<AddEditTransaksiServisScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tanggalMasukController;
  late TextEditingController _tanggalSelesaiController;
  late TextEditingController _catatanController;
  late TextEditingController _kmController;
  int? _selectedKendaraanId;
  int? _selectedMekanikId;
  String? _selectedStatus;
  int noPKB = 0;
  String? _namaMekanik;
  SingleSelectController? con;
  List<Map<String, dynamic>> _selectedJasaDetails = []; // Untuk detail jasa
  List<Map<String, dynamic>> _selectedSukuCadangDetails =
      []; // Untuk detail suku cadang

  double _totalBiayaJasa = 0.0;
  double _totalBiayaSukuCadang = 0.0;
  double _totalFinal = 0.0;

  final List<String> _statusOptions = [
    'Finish',
    'In Proses',
    'Komplit',
    'Cancelled',
    'Lunas',
  ];

  @override
  void initState() {
    super.initState();
    // Muat data untuk dropdown
    context.read<KendaraanBloc>().add(const LoadKendaraan());
    context.read<MekanikBloc>().add(const LoadMekanik());
    context.read<JasaBloc>().add(const LoadJasa());
    context.read<SukuCadangBloc>().add(const LoadParts());
    context.read<NomorBloc>().add(const LoadNomor());

    if (widget.transaksiServis != null) {
      // Mode Edit: Muat data transaksi utama
      _tanggalMasukController = TextEditingController(
        text: widget.transaksiServis!.tanggalMasuk.toIso8601String().substring(
          0,
          19,
        ),
      );
      _tanggalSelesaiController = TextEditingController(
        text:
            widget.transaksiServis!.tanggalSelesai?.toIso8601String().substring(
              0,
              19,
            ) ??
            '',
      );
      _catatanController = TextEditingController(
        text: widget.transaksiServis!.catatan ?? '',
      );
      noPKB = widget.transaksiServis!.idpkb;
      _selectedKendaraanId =
          widget.transaksiServis == null
              ? widget.kendaraan!.id
              : widget.transaksiServis!.kendaraanId;
      _kmController = TextEditingController(
        text: widget.transaksiServis?.km.toString() ?? "0",
      );
      _selectedMekanikId = widget.transaksiServis!.mekanikId;
      _selectedStatus = widget.transaksiServis!.status;

      context.read<TransaksiServiceDetailBloc>().add(
        LoadTransaksiService(transaksiId: widget.transaksiServis!.idpkb),
      );
    } else {
      start();
      // Mode Tambah: Inisialisasi default
      _tanggalMasukController = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 19),
      );
      _tanggalSelesaiController = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 19),
      );
      _catatanController = TextEditingController();
      _kmController = TextEditingController();
      _selectedStatus = _statusOptions[1]; // Default status is In Progress
      _selectedKendaraanId =
          widget.transaksiServis == null
              ? widget.kendaraan!.id
              : widget.transaksiServis!.kendaraanId;
    }
  }

  @override
  void dispose() {
    _tanggalMasukController.dispose();
    _tanggalSelesaiController.dispose();
    _catatanController.dispose();
    _kmController.dispose();
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
        });
      }
    }
  }

  // Fungsi untuk menambah item jasa
  void _addJasaDetailItem() {
    setState(() {
      _selectedJasaDetails.add({
        'jasa_id': null,
        'nama_jasa': null,
        'jumlah': 1,
        'harga_jasa_saat_itu': 0.0,
        'sub_total': 0.0,
        'status': 'In Proses',
        'catatan_layanan': null,
      });
      _calculateTotals();
    });
  }

  // Fungsi untuk menghapus item jasa
  void _removeJasaDetailItem(int index) {
    setState(() {
      _selectedJasaDetails.removeAt(index);
      _calculateTotals();
    });
  }

  // Fungsi untuk menambah item suku cadang
  void _addSukuCadangDetailItem() {
    setState(() {
      _selectedSukuCadangDetails.add({
        'suku_cadang_id': null,
        'suku_cadang_ids': null,
        'kode_suku_cadang': null,
        'nama_suku_cadang': null,
        'jumlah': 1,
        'status': 'In Proses',
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
    double currentTotalJasa = 0.0;
    for (var detail in _selectedJasaDetails) {
      currentTotalJasa += detail['sub_total'] as double;
    }

    double currentTotalSukuCadang = 0.0;
    for (var detail in _selectedSukuCadangDetails) {
      currentTotalSukuCadang += detail['sub_total'] as double;
    }

    setState(() {
      _totalBiayaJasa = currentTotalJasa;
      _totalBiayaSukuCadang = currentTotalSukuCadang;
      _totalFinal = _totalBiayaJasa + _totalBiayaSukuCadang;
    });
  }

  // Fungsi untuk menyimpan transaksi servis
  void _saveTransaksiServis() async {
    if (_formKey.currentState!.validate()) {
      final transaksiData = TransaksiServis(
        id: widget.transaksiServis?.id,
        idpkb: noPKB,
        kendaraanId: _selectedKendaraanId!,
        km: int.parse(_kmController.text),
        mekanikId: _selectedMekanikId,
        tanggalMasuk: DateTime.parse(_tanggalMasukController.text),
        tanggalSelesai:
            _tanggalSelesaiController.text.isNotEmpty
                ? DateTime.parse(_tanggalSelesaiController.text)
                : null,
        status: _selectedStatus!,
        totalBiayaJasa: _totalBiayaJasa,
        totalBiayaSukuCadang: _totalBiayaSukuCadang,
        totalFinal: _totalFinal,
        catatan:
            _catatanController.text.isEmpty ? null : _catatanController.text,
      );

      final List<DetailTransaksiService> jasaDetailsToSave =
          _selectedJasaDetails.map((item) {
            return DetailTransaksiService(
              transaksiServisId: noPKB, // Akan diisi oleh BLoC
              jasaId: item['jasa_id'],
              jumlah: item['jumlah'],
              hargaJasaSaatItu: item['harga_jasa_saat_itu'],
              subTotal: item['sub_total'],
              catatanLayanan: item['catatan_layanan'],
            );
          }).toList();

      final List<DetailTransaksiSukuCadangServis> sukuCadangDetailsToSave =
          _selectedSukuCadangDetails.map((item) {
            return DetailTransaksiSukuCadangServis(
              transaksiServisId: noPKB, // Akan diisi oleh BLoC
              sukuCadangId: item['suku_cadang_id'],
              jumlah: item['jumlah'],
              hargaJualSaatItu: item['harga_jual_saat_itu'],
              subTotal: item['sub_total'],
            );
          }).toList();

      if (widget.transaksiServis == null) {
        print('object');
        context.read<TransaksiServisBloc>().add(
          AddTransaksiServis(
            transaksiData,
            detailJasa: jasaDetailsToSave,
            detailSukuCadang: sukuCadangDetailsToSave,
          ),
        );
        context.read<KendaraanBloc>().add(
          UpdateKmKendaraan(
            int.parse(_kmController.text),
            _selectedKendaraanId!,
          ),
        );
        context.read<NomorBloc>().add(UpdateNomor());
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrintPKBPdf(transaksiId: noPKB),
          ),
        ).then((v) => Navigator.pop(context));
      } else {
        print('no object');
        context.read<TransaksiServisBloc>().add(
          UpdateTransaksiServis(
            transaksiData,
            detailJasa: jasaDetailsToSave,
            detailSukuCadang: sukuCadangDetailsToSave,
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }

  bool dapat = false;
  start() async {
    setState(() {
      dapat = true;
    });
    final a = context.read<NomorBloc>().state;
    if (a is NomorLoaded) {
      setState(() {
        noPKB = a.noPkb;
        dapat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.transaksiServis == null
              ? 'Tambah Perintah Kerja'
              : 'Edit Perintah Kerja',
        ),
        centerTitle: true,
      ),
      body:
          dapat
              ? Center(child: CircularProgressIndicator())
              : BlocListener<
                TransaksiServiceDetailBloc,
                TransaksiServiceDetailState
              >(
                listener: (context, state) {
                  if (state is TransaksiServiceLoaded) {
                    List<Map<String, dynamic>> jasa = state.jasa;
                    List<Map<String, dynamic>> part = state.part;
                    // print(state.jasa);
                    setState(() {
                      // Isi detail jasa
                      _selectedJasaDetails =
                          jasa.map((detail) {
                            return {
                              'jasa_id': detail['id'],
                              'nama_jasa': detail['nama_jasa'],
                              'status': detail['status'],
                              'harga_beli': detail['harga_beli'],
                              'harga_jual': detail['harga_jual'],
                              'jumlah': detail['jumlah'],
                              'harga_jasa_saat_itu':
                                  detail['harga_jasa_saat_itu'],
                              'sub_total': detail['sub_total'],
                              'catatan_layanan': detail['catatan_layanan'],
                            };
                          }).toList();

                      // Isi detail suku cadang
                      _selectedSukuCadangDetails =
                          part.map((detail) {
                            return {
                              'suku_cadang_id': detail['id'],
                              'suku_cadang_ids': detail['kode_part'],
                              'status': detail['status'],
                              //'kode_suku_cadang': detail['kode_part'],
                              'stok': detail['stok'],
                              'harga_beli': detail['harga_beli'],
                              'harga_jual': detail['harga_jual'],
                              'nama_suku_cadang': detail['nama_part'],
                              'jumlah': detail['jumlah'],
                              'harga_jual_saat_itu':
                                  detail['harga_jual_saat_itu'],
                              'sub_total': detail['sub_total'],
                            };
                          }).toList();

                      _calculateTotals(); // Hitung ulang total setelah memuat detail
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        _buildHeader(
                          'No. Polisi',
                          widget.kendaraan!.platNomor,
                          "Nama Pelanggan",
                          widget.pelanggan!.nama,
                        ),
                        _buildHeader(
                          "No. Mesin",
                          widget.kendaraan!.nomorMesin ?? "-",

                          "Alamat Pelanggan",
                          widget.pelanggan!.alamat ?? "-",
                        ),
                        _buildHeader(
                          'No. Plat',
                          widget.kendaraan!.platNomor,

                          "Telepon",
                          widget.pelanggan!.telepon,
                        ),
                        _buildHeader(
                          'Merk',
                          widget.kendaraan!.merk,
                          'Tahun',
                          widget.kendaraan!.tahun.toString(),
                        ),
                        _buildHeader(
                          'Tipe',
                          widget.kendaraan!.model,
                          'No. PKB',
                          '$noPKB',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Divider(
                            color: Colors.black,
                            height: 1,
                            thickness: 1,
                          ),
                        ),

                        // Kendaraan Dropdown
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 500,
                              child: TextFormField(
                                enabled:
                                    widget.transaksiServis != null &&
                                            widget.transaksiServis!.status !=
                                                'In Progress'
                                        ? false
                                        : true,
                                controller: _tanggalMasukController,
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal Masuk',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap:
                                    () => _selectDateTime(
                                      _tanggalMasukController,
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Tanggal masuk tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            BlocBuilder<MekanikBloc, MekanikState>(
                              builder: (context, state) {
                                if (state is MekanikLoaded) {
                                  final list = state.mekanikList;
                                  return SizedBox(
                                    width: 500,
                                    child: CustomDropdown<String>.search(
                                      initialItem:
                                          _selectedMekanikId != null
                                              ? list
                                                  .where(
                                                    (v) =>
                                                        v.id ==
                                                        _selectedMekanikId,
                                                  )
                                                  .first
                                                  .namaMekanik
                                              : _namaMekanik,
                                      enabled:
                                          widget.transaksiServis != null &&
                                                  widget
                                                          .transaksiServis!
                                                          .status !=
                                                      'In Progress'
                                              ? false
                                              : true,
                                      items:
                                          list
                                              .map((e) => e.namaMekanik)
                                              .toList(),
                                      hintText: 'Select Mekanik',
                                      decoration: CustomDropdownDecoration(
                                        closedFillColor: Colors.white,
                                        expandedFillColor: Colors.white,
                                        closedBorderRadius:
                                            BorderRadius.circular(5),
                                        expandedBorderRadius:
                                            BorderRadius.circular(5),
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
                                      onChanged: (String? v) {
                                        setState(() {
                                          _selectedMekanikId =
                                              list
                                                  .where(
                                                    (e) => e.namaMekanik == v,
                                                  )
                                                  .firstOrNull
                                                  ?.id;
                                          _namaMekanik = v;
                                        });
                                      },
                                    ),
                                  );
                                } else if (state is MekanikLoading) {
                                  return SizedBox(
                                    width: 200,
                                    child: const LinearProgressIndicator(),
                                  );
                                } else if (state is MekanikError) {
                                  return Text(
                                    'Error memuat mekanik: ${state.message}',
                                  );
                                }
                                return const Text(
                                  'Tidak ada mekanik tersedia.',
                                );
                              },
                            ),
                          ],
                        ),

                        // Mekanik Dropdown
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 500,
                              child: TextFormField(
                                enabled:
                                    widget.transaksiServis != null &&
                                            widget.transaksiServis!.status !=
                                                'In Progress'
                                        ? false
                                        : true,
                                controller: _tanggalSelesaiController,
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal Selesai (Opsional)',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap:
                                    () => _selectDateTime(
                                      _tanggalSelesaiController,
                                    ),
                              ),
                            ),
                            SizedBox(
                              width: 500,
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: const InputDecoration(
                                  enabled: false,
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    _statusOptions.map((String status) {
                                      return DropdownMenuItem<String>(
                                        enabled:
                                            widget.transaksiServis == null ||
                                                    widget
                                                            .transaksiServis!
                                                            .status !=
                                                        'In Progress'
                                                ? false
                                                : true,
                                        value: status,
                                        child: Text(status),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedStatus = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Pilih status';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        // Status
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            enabled:
                                widget.transaksiServis != null &&
                                        widget.transaksiServis!.status !=
                                            'In Proses'
                                    ? false
                                    : true,
                            controller: _kmController,
                            decoration: const InputDecoration(
                              labelText: 'Kilometer (Opsional)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a number in kilometer.';
                              }
                              final n = num.tryParse(value);
                              if (n == null) {
                                return '"$value" is not a valid number.';
                              }
                              if (num.tryParse(value)! < widget.kendaraan!.km) {
                                return "Kilometer yang diinput lebih kecil dari sebelumnya ($value-${widget.kendaraan!.km})";
                              }
                              return null;
                            },
                            //maxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          enabled:
                              widget.transaksiServis != null &&
                                      widget.transaksiServis!.status !=
                                          'In Progress'
                                  ? false
                                  : true,
                          controller: _catatanController,
                          decoration: const InputDecoration(
                            labelText: 'Keluhan (Opsional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24.0),

                        // --- Detail Jasa ---
                        Text(
                          'Detail Jasa',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8.0),
                        BlocBuilder<JasaBloc, JasaState>(
                          builder: (context, jasaState) {
                            if (jasaState is JasaLoaded) {
                              final list = jasaState.jasaList;
                              return Column(
                                children: [
                                  ..._selectedJasaDetails.asMap().entries.map((
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
                                            child: CustomDropdown<
                                              String
                                            >.search(
                                              initialItem:
                                                  _selectedJasaDetails.isEmpty
                                                      ? list
                                                          .where(
                                                            (v) =>
                                                                v.id ==
                                                                item['jasa_id'],
                                                          )
                                                          .first
                                                          .namaJasa
                                                      : item['nama_jasa'],
                                              enabled:
                                                  widget.transaksiServis !=
                                                              null &&
                                                          widget
                                                                  .transaksiServis!
                                                                  .status !=
                                                              'In Progress'
                                                      ? false
                                                      : true,
                                              items:
                                                  list
                                                      .map((e) => e.namaJasa)
                                                      .toList(),
                                              hintText: 'Select Jasa',
                                              decoration:
                                                  CustomDropdownDecoration(
                                                    closedFillColor:
                                                        Colors.white,
                                                    expandedFillColor:
                                                        Colors.white,
                                                    closedBorderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    expandedBorderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    closedBorder:
                                                        BoxBorder.lerp(
                                                          Border.all(),
                                                          Border.all(),
                                                          1,
                                                        ),
                                                    expandedBorder:
                                                        BoxBorder.lerp(
                                                          Border.all(),
                                                          Border.all(),
                                                          1,
                                                        ),
                                                    headerStyle: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    listItemStyle: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    hintStyle: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              onChanged: (String? value) {
                                                if (_selectedJasaDetails
                                                    .map((a) => a['nama_jasa'])
                                                    .contains(value)) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                        "Detail jasa $value sudah ada!",
                                                      ),
                                                    ),
                                                  );
                                                  _removeJasaDetailItem(idx);
                                                  return null;
                                                }
                                                setState(() {
                                                  item['nama_jasa'] = value;
                                                  final selectedJasa = jasaState
                                                      .jasaList
                                                      .firstWhere(
                                                        (element) =>
                                                            element.namaJasa ==
                                                            value,
                                                      );
                                                  item['jasa_id'] =
                                                      selectedJasa.id;
                                                  item['harga_jasa_saat_itu'] =
                                                      selectedJasa
                                                          .hargaJual; // Ambil harga jual jasa
                                                  item['sub_total'] =
                                                      (item['jumlah'] as int) *
                                                      (item['harga_jasa_saat_itu']
                                                          as double);
                                                  _calculateTotals();
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Pilih Jasa';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 1,
                                            child: TextFormField(
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
                                                      (item['jumlah'] as int) *
                                                      (item['harga_jasa_saat_itu']
                                                          as double);
                                                  _calculateTotals();
                                                });
                                              },
                                              validator:
                                                  (value) =>
                                                      (int.tryParse(
                                                                    value ?? '',
                                                                  ) ??
                                                                  0) <=
                                                              0
                                                          ? 'Min 1'
                                                          : null,
                                            ),
                                          ),

                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 120,
                                            child: TextField(
                                              readOnly: true,
                                              controller: TextEditingController(
                                                text:
                                                    'Rp ${NumberFormat('#,###').format(item['sub_total'])}',
                                              ),
                                              decoration: const InputDecoration(
                                                labelText: 'Total',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              color:
                                                  item['status'] == 'In Proses'
                                                      ? Colors.black
                                                      : Colors.red,
                                            ),
                                            onPressed:
                                                item['status'] == 'In Proses'
                                                    ? () =>
                                                        _removeJasaDetailItem(
                                                          idx,
                                                        )
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  ElevatedButton.icon(
                                    onPressed: _addJasaDetailItem,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Tambah Item Jasa'),
                                  ),
                                ],
                              );
                            } else if (jasaState is JasaLoading) {
                              return const LinearProgressIndicator();
                            } else if (jasaState is JasaError) {
                              return Text(
                                'Error memuat jasa: ${jasaState.message}',
                              );
                            }
                            return const Text('Tidak ada jasa tersedia.');
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // --- Detail Suku Cadang ---
                        Text(
                          'Detail Suku Cadang',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8.0),
                        BlocBuilder<SukuCadangBloc, PartState>(
                          builder: (context, sukuCadangState) {
                            if (sukuCadangState is PartsLoaded) {
                              final lists = sukuCadangState.parts;
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
                                            flex: 2,
                                            child: CustomDropdown<
                                              String
                                            >.search(
                                              initialItem:
                                                  item['suku_cadang_ids'] ??
                                                  item['kode_suku_cadang'],

                                              enabled:
                                                  widget.transaksiServis !=
                                                              null &&
                                                          widget
                                                                  .transaksiServis!
                                                                  .status !=
                                                              'In Proses'
                                                      ? false
                                                      : true,
                                              items:
                                                  lists
                                                      .map((e) => e.kodePart!)
                                                      .toList(),
                                              hintText: 'Select Part',
                                              decoration: CustomDropdownDecoration(
                                                closedFillColor: Colors.white,
                                                expandedFillColor: Colors.white,
                                                prefixIcon: InkWell(
                                                  child: Icon(Icons.search),
                                                  onTap: () async {
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                SukuCadangListScreen(
                                                                  select: true,
                                                                ),
                                                      ),
                                                    ).then((value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          item['suku_cadang_ids'] =
                                                              value;
                                                        });
                                                      }
                                                      return;
                                                    });
                                                  },
                                                ),
                                                closedBorderRadius:
                                                    BorderRadius.circular(5),
                                                expandedBorderRadius:
                                                    BorderRadius.circular(5),
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
                                                  fontSize: 12,
                                                ),
                                                listItemStyle: TextStyle(
                                                  fontSize: 12,
                                                ),
                                                hintStyle: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              onChanged: (String? value) {
                                                if (_selectedSukuCadangDetails
                                                    .map(
                                                      (v) =>
                                                          v['kode_suku_cadang'],
                                                    )
                                                    .contains(value)) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                        "Detail kode part $value sudah ada!",
                                                      ),
                                                    ),
                                                  );
                                                  _removeSukuCadangDetailItem(
                                                    idx,
                                                  );
                                                  return null;
                                                }
                                                setState(() {
                                                  item['kode_suku_cadang'] =
                                                      value!;
                                                  final selectedPart = lists
                                                      .firstWhere(
                                                        (element) =>
                                                            element.kodePart ==
                                                            value,
                                                      );
                                                  item['nama_suku_cadang'] =
                                                      selectedPart.namaPart;
                                                  item['suku_cadang_id'] =
                                                      selectedPart.id;
                                                  item['harga_jual_saat_itu'] =
                                                      selectedPart
                                                          .hargaJual; // Ambil harga jual suku cadang
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
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Pilih Part';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 3,
                                            child: TextField(
                                              readOnly: true,
                                              controller: TextEditingController(
                                                text: item['nama_suku_cadang'],
                                              ),
                                              decoration: const InputDecoration(
                                                labelText: 'Nama Part',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 1,
                                            child: TextFormField(
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
                                              validator:
                                                  (value) =>
                                                      (int.tryParse(
                                                                    value ?? '',
                                                                  ) ??
                                                                  0) <=
                                                              0
                                                          ? 'Min 1'
                                                          : null,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 120,
                                            child: TextField(
                                              readOnly: true,
                                              controller: TextEditingController(
                                                text:
                                                    'Rp ${NumberFormat('#,###').format(item['sub_total'])}',
                                              ),
                                              decoration: const InputDecoration(
                                                labelText: 'Total',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),

                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              color:
                                                  item['status'] == 'In Proses'
                                                      ? Colors.black
                                                      : Colors.red,
                                            ),
                                            onPressed:
                                                item['status'] == 'In Proses'
                                                    ? () =>
                                                        _removeSukuCadangDetailItem(
                                                          idx,
                                                        )
                                                    : null,
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
                            const Text('Total Biaya Jasa:'),
                            Text(
                              'Rp ${NumberFormat('#,###').format(_totalBiayaJasa)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Biaya Suku Cadang:'),
                            Text(
                              'Rp ${NumberFormat('#,###').format(_totalBiayaSukuCadang)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL AKHIR:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${NumberFormat('#,###').format(_totalFinal)}',
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
                          onPressed:
                              widget.transaksiServis != null &&
                                      widget.transaksiServis!.status !=
                                          'In Proses'
                                  ? () {
                                    keluar();
                                  }
                                  : _saveTransaksiServis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.black,
                            elevation: 5,
                            shadowColor: Colors.yellow,
                            side: BorderSide(),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          child: Text(
                            widget.transaksiServis == null
                                ? 'Simpan Perintah Kerja'
                                : widget.transaksiServis == null ||
                                    widget.transaksiServis!.status !=
                                        'In Proses'
                                ? 'Keluar'
                                : 'Perbarui Perintah Kerja',
                          ),
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  keluar() {
    Navigator.pop(context);
  }

  Widget _buildHeader(String text, String value, String text1, String value2) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 130, child: Text(text)),
              SizedBox(width: 10, child: Text(':')),
              SizedBox(width: 330, child: Text(value)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 130, child: Text(text1)),
              SizedBox(width: 10, child: Text(':')),
              SizedBox(width: 330, child: Text(value2)),
            ],
          ),
        ],
      ),
    );
  }
}
