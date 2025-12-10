import 'dart:io';
import 'dart:math';

import 'package:bengkel/blocs/bengkel/bengkel_bloc.dart';
import 'package:bengkel/blocs/bengkel/bengkel_event.dart';
import 'package:bengkel/blocs/bengkel/bengkel_state.dart';
import 'package:bengkel/model/bengkel.dart';
import 'package:bengkel/model/kode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

class BengkelScreen extends StatefulWidget {
  const BengkelScreen({super.key});

  @override
  State<BengkelScreen> createState() => _BengkelScreenState();
}

class _BengkelScreenState extends State<BengkelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _pass = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _emailController = TextEditingController();
  bool simpan = false, dapat = false, ambilgambar = false;
  String kode = '';
  String pass = '';
  File? imagse;
  String gambar = "";
  @override
  void initState() {
    super.initState();
    // Dispatch event untuk memuat data bengkel saat layar dibuka
    context.read<BengkelBloc>().add(const LoadBengkels());
    // getImageFileFromAssets();
  }

  // getImageFileFromAssets() async {
  //   setState(() {
  //     dapat = true;
  //   });
  //   final byteData = await rootBundle.load('assets/images/example.png');

  //   final file = File(
  //     '${(await getTemporaryDirectory()).path}/images/example.png',
  //   );
  //   await file.create(recursive: true);
  //   await file.writeAsBytes(
  //     byteData.buffer.asUint8List(
  //       byteData.offsetInBytes,
  //       byteData.lengthInBytes,
  //     ),
  //   );

  //   setState(() {
  //     asets = file;
  //     dapat = false;
  //   });
  // }

  Future<void> pickImage() async {
    setState(() {
      ambilgambar = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Filter for image files
      allowMultiple: false, // Allow only single image selection
    );

    // Get the path to the selected image
    // print(filePath);
    if (result != null && result.files.single.path != null) {
      print(result.files.single.path!);
      setState(() {
        imagse = File(result.files.single.path!);
        gambar = result.files.single.path!;
      });
    } else {
      // User canceled the picker
    }
    setState(() {
      ambilgambar = false;
    });
  }

  getKodes() async {
    final news = Random();

    await getKode().then((v) {
      if (kode.isEmpty) {
        final nos = news.nextInt(v.length);
        setState(() {
          kode = v[nos].code;
          pass = v[nos].password;
        });
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _pass.dispose();
    super.dispose();
  }

  stat(BengkelState state) {
    if (state is BengkelsLoaded) {
      if (imagse == null) {
        _namaController.text = state.bengkels.nama ?? "";
        _alamatController.text = state.bengkels.alamat ?? "";
        _teleponController.text = state.bengkels.telepon ?? "";
        _emailController.text = state.bengkels.email ?? "";

        kode = state.bengkels.kode ?? "";
        gambar = state.bengkels.logo ?? "";
        if (state.bengkels.logo!.isNotEmpty) {
          imagse = File(state.bengkels.logo!);
        }
      }
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Jika form valid, buat objek Bengkel
      //print('gambar sebelum disimpan $gambar');
      final newBengkel = Bengkel(
        id: 1, // Asumsikan hanya ada satu entitas bengkel
        nama: _namaController.text,
        alamat: _alamatController.text,
        telepon: _teleponController.text,
        email: _emailController.text,
        logo: gambar,
        kode: kode,
      );
      if (pass == _pass.text) {
        // Dispatch event untuk menyimpan/memperbarui data
        simpan
            ? context.read<BengkelBloc>().add(AddBengkel(newBengkel))
            : context.read<BengkelBloc>().add(UpdateBengkel(newBengkel));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                simpan
                    ? Text('Data bengkel berhasil disimpan!')
                    : Text('Data bengkel berhasil diupdate!'),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password yang anda masukan salah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Bengkel'),
        centerTitle: true,
        automaticallyImplyLeading: simpan ? false : true,
      ),

      body: BlocBuilder<BengkelBloc, BengkelState>(
        builder: (context, state) {
          if (state is BengkelLoading) {
            return Center(child: CircularProgressIndicator());
          }
          // if (state is BengkelError) {
          //   return Center(child: Text('Error tidak bisa membuka database'));
          // }

          stat(state);
          // print(state.bengkels.logo);

          if (state is BengkelError) {
            getKodes();
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Bengkel',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama bengkel tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _teleponController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong.';
                        }
                        if (value.length < 10) {
                          return 'Nomor telepon terlalu pendek.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pemilik',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pemilik tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: TextEditingController(text: kode),
                      style: TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Kode Aplikasi',
                        hintStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(),
                        enabled: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pass,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          simpan = true;
                        });
                        _saveForm();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 240,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.blue[300],
                        foregroundColor: Colors.black,
                        shadowColor: Colors.yellow[200],
                        elevation: 5,
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return dapat
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: 700,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _namaController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Bengkel',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama bengkel tidak boleh kosong.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _alamatController,
                            decoration: const InputDecoration(
                              labelText: 'Alamat',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat tidak boleh kosong.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _teleponController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Nomor Telepon',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor telepon tidak boleh kosong.';
                              }
                              if (value.length < 10) {
                                return 'Nomor telepon terlalu pendek.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Pemilik',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama pemilik tidak boleh kosong.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          imagse != null
                              ? Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(imagse!),
                                  ),
                                ),
                                //child: Text(gambar),
                              )
                              : Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/example.png',
                                    ),
                                  ),
                                ),
                                //child: Text(gambar),
                              ),
                          const SizedBox(height: 8),
                          imagse != null ? Text(gambar) : Text(''),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed:
                                ambilgambar
                                    ? null
                                    : () async {
                                      await pickImage();
                                    },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.yellow[200],
                              elevation: 5,
                            ),
                            child:
                                imagse == null
                                    ? ambilgambar
                                        ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(),
                                        )
                                        : Text('Select Logo')
                                    : ambilgambar
                                    ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(),
                                    )
                                    : Text('Select Update Logo'),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: ambilgambar ? null : _saveForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 240,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.orange[300],
                              foregroundColor: Colors.black,
                              shadowColor: Colors.yellow[200],
                              elevation: 5,
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
        },
      ),
    );
  }
}
