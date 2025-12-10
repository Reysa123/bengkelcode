// lib/screens/transaksi_service_list_screen.dart
import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_bloc.dart';
import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_event.dart';
import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_state.dart';
import 'package:bengkel/model/transaksiservice.dart';
import 'package:bengkel/screens/add_edit_transaksi_servis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransaksiServiceListScreen extends StatefulWidget {
  final String? sts;
  const TransaksiServiceListScreen({this.sts, super.key});

  @override
  State<TransaksiServiceListScreen> createState() =>
      _TransaksiServiceListScreenState();
}

class _TransaksiServiceListScreenState
    extends State<TransaksiServiceListScreen> {
  late TextEditingController _tanggalMasukController;
  late TextEditingController _tanggalSelesaiController;
  DateTime awal = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        1,
        0,
        0,
        0,
      ),
      akhir = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        23,
        59,
        59,
      );
  List<TransaksiServis> list = [], list1 = [];
  @override
  void initState() {
    super.initState();
    _tanggalMasukController = TextEditingController(
      text: DateFormat("dd-MM-yyyy").format(awal),
    );
    _tanggalSelesaiController = TextEditingController(
      text: DateFormat("dd-MM-yyyy").format(akhir),
    );
    // Muat daftar transaksi saat layar pertama kali dibuka
    cari();
    context.read<TransaksiServisBloc>().add(const LoadTransaksiServis());
  }

  // Fungsi untuk memilih tanggal dan waktu
  Future<void> _selectDateTime(
    TextEditingController controller,
    DateTime date,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty ? date : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      if (controller == _tanggalMasukController) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          0,
          0,
          0,
          0,
          0,
        );

        setState(() {
          controller.text = DateFormat("dd-MM-yyyy").format(finalDateTime);
          awal = finalDateTime;
        });
      } else {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          23,
          59,
          59,
          0,
          0,
        );

        setState(() {
          controller.text = DateFormat("dd-MM-yyyy").format(finalDateTime);
          akhir = finalDateTime;
        });
      }
    }
  }

  cari() {
    setState(() {
      final lists =
          list1
              .where(
                (v) =>
                    v.tanggalMasuk.isAfter(awal) &&
                    v.tanggalMasuk.isBefore(akhir),
              )
              .toList();
      widget.sts == null
          ? list = lists
          : list =
              lists
                  .where(
                    (v) => v.status.toLowerCase() == widget.sts!.toLowerCase(),
                  )
                  .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            widget.sts == null
                ? const Text('Daftar Transaksi Service')
                : const Text('Daftar Transaksi Service In Proses'),
        centerTitle: true,
      ),
      body: BlocBuilder<TransaksiServisBloc, TransaksiServisState>(
        builder: (context, state) {
          if (state is TransaksiServisLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransaksiServisLoaded) {
            if (state.transaksiServisList.isEmpty) {
              return const Center(child: Text('Tidak ada transaksi service.'));
            }

            list1 = state.transaksiServisList;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 500,
                        child: TextFormField(
                          controller: _tanggalMasukController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Awal',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap:
                              () => _selectDateTime(
                                _tanggalMasukController,
                                awal,
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal awal tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 500,
                        child: TextFormField(
                          controller: _tanggalSelesaiController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Akhir',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap:
                              () => _selectDateTime(
                                _tanggalSelesaiController,
                                akhir,
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal akhir tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.black,
                          shadowColor: Colors.amber,
                          elevation: 5,
                        ),
                        onPressed: () {
                          cari();
                        },
                        child: Text("Cari"),
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.all(8.0), child: Divider()),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 4,
                          top: 0,
                        ),
                        child: SizedBox(
                          width: 1620,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              list.isEmpty
                                  ? SizedBox()
                                  : Card(
                                    color: Colors.amber[100],
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8,
                                        top: 16,
                                        bottom: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            child: Text('No.'),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('No.Transaksi'),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('Tgl.Transaksi'),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('Status'),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('No. Plat'),
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child: Text('No. Rangka'),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            child: Text('Km'),
                                          ),
                                          SizedBox(
                                            width: 260,
                                            child: Text('Nama Pelanggan'),
                                          ),
                                          SizedBox(
                                            width: 360,
                                            child: Text('Alamat Pelanggan'),
                                          ),
                                          SizedBox(
                                            width: 160,
                                            child: Text('Telepon Pelanggan'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    final transaksi = list[index];
                                    final f = state.kendServiceList.firstWhere(
                                      (v) => v.id == transaksi.kendaraanId,
                                    );
                                    final cust = state.pelangganList.firstWhere(
                                      (v) => v.id == f.pelangganId,
                                    );
                                    return InkWell(
                                      onDoubleTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      AddEditTransaksiServisScreen(
                                                        transaksiServis:
                                                            transaksi,
                                                        kendaraan: f,
                                                        pelanggan: cust,
                                                      ),
                                            ),
                                          ),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 60,
                                                child: Text('${index + 1}'),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(
                                                  '${transaksi.idpkb}',
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(
                                                  DateFormat(
                                                    "dd-MM-yyyy",
                                                  ).format(
                                                    transaksi.tanggalMasuk,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(transaksi.status),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(f.platNomor),
                                              ),
                                              SizedBox(
                                                width: 180,
                                                child: Text(f.nomorRangka!),
                                              ),
                                              SizedBox(
                                                width: 60,
                                                child: Text(
                                                  transaksi.km.toString(),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 260,
                                                child: Text(cust.nama),
                                              ),
                                              SizedBox(
                                                width: 360,
                                                child: Text(cust.alamat!),
                                              ),
                                              SizedBox(
                                                width: 160,
                                                child: Text(cust.telepon),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  list.isNotEmpty ? Text('Total : ${list.length}') : SizedBox(),
                ],
              ),
            );
          } else if (state is TransaksiServisError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(child: Text('Silakan muat ulang halaman.'));
        },
      ),
    );
  }
}
