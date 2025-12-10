import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:bengkel/blocs/account/account_bloc.dart';
import 'package:bengkel/blocs/account/account_event.dart';
import 'package:bengkel/blocs/account/account_state.dart';
import 'package:bengkel/blocs/jurnal/jurnal_bloc.dart';
import 'package:bengkel/blocs/jurnal/jurnal_event.dart';
import 'package:bengkel/model/account.dart';
import 'package:bengkel/model/jurnal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InputPemasukan extends StatefulWidget {
  const InputPemasukan({super.key});

  @override
  State<InputPemasukan> createState() => _InputPemasukanState();
}

class _InputPemasukanState extends State<InputPemasukan> {
  final TextEditingController _jumlah = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  String? _akun;
  List<Akun> listAkun = [];
  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(LoadAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Input Pemasukan')),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountsLoaded) {
            final kas =
                state.accounts.where((v) => v.namaAkun == 'Kas').first.id;
            final akun = state.accounts.where(
              (v) => v.jenisAkun == 'Equity' || v.jenisAkun == 'Revenue',
            );
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 18,
                children: [
                  CustomDropdown<String>.search(
                    initialItem: _akun,
                    items: akun.map((e) => e.namaAkun).toList(),
                    hintText: 'Select Akun',
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
                      // headerStyle: TextStyle(fontSize: 12),
                      // listItemStyle: TextStyle(fontSize: 12),
                      // hintStyle: TextStyle(fontSize: 12),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _akun = v;
                        listAkun =
                            state.accounts
                                .where((v) => v.namaAkun == _akun)
                                .toList();
                      });
                      // print(listAkun.first.id);
                    },
                  ),
                  TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _jumlah,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Jumlah',
                    ),
                  ),
                  TextField(
                    controller: _desc,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Deskripsi',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (_akun!.isNotEmpty) {
                        if (_jumlah.text.isNotEmpty) {
                          if (_desc.text.isNotEmpty) {
                            // print(listAkun.first.id);
                            final jurnal = Jurnal(
                              tanggal: DateTime.now(),
                              deskripsi: _desc.text,
                              kredit: double.parse(_jumlah.text),
                              debit: 0.0,
                              akunId: listAkun.first.id!,
                              referensiTransaksiId: listAkun.first.id!,
                              tipeReferensi: 'Pemasukan',
                            );
                            final jurnalkas = Jurnal(
                              tanggal: DateTime.now(),
                              deskripsi: _desc.text,
                              debit: double.parse(_jumlah.text),
                              kredit: 0.0,
                              akunId: kas!,
                              referensiTransaksiId: listAkun.first.id!,
                              tipeReferensi: 'Pemasukan',
                            );
                            context.read<JurnalBloc>().add(
                              AddJurnal(jurnal: jurnal),
                            );
                            context.read<JurnalBloc>().add(
                              AddJurnal(jurnal: jurnalkas),
                            );
                            simpanDialog();
                            setState(() {
                              _jumlah.text = "";
                              _desc.text = "";
                              _akun = null;
                            });
                          } else {
                            peringatan();
                          }
                        } else {
                          peringatan();
                        }
                      } else {
                        peringatan();
                      }
                    },
                    label: Text('Simpan'),
                    icon: Icon(Icons.save_outlined),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  void peringatan() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Isi data dengan lengkap')));
  }

  void simpanDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue[100],

        content: Text(
          'Simpan data berhasil',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
