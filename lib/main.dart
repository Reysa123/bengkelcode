import 'package:bengkel/blocs/account/account_bloc.dart';
import 'package:bengkel/blocs/bengkel/bengkel_bloc.dart';
import 'package:bengkel/blocs/jasa/jasa_bloc.dart';
import 'package:bengkel/blocs/jurnal/jurnal_bloc.dart';
import 'package:bengkel/blocs/mekanik/mekanik_bloc.dart';
import 'package:bengkel/blocs/merk/merk_kendaraan_bloc.dart';
import 'package:bengkel/blocs/neraca/neraca_bloc.dart';
import 'package:bengkel/blocs/nomor/nomor_bloc.dart';
import 'package:bengkel/blocs/part/part_bloc.dart';
import 'package:bengkel/blocs/payment/payment_bloc.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_bloc.dart';
import 'package:bengkel/blocs/pembelian_suku_cadang/pembelian_suku_cadang_bloc.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_bloc.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_bloc.dart';
import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_bloc.dart';
import 'package:bengkel/blocs/type/type_kendaraan_bloc.dart';
import 'package:bengkel/blocs/vehicle/kendaraan_bloc.dart';
import 'package:bengkel/blocs/vendor/vendor_bloc.dart';
import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/repository/accountrepository.dart';
import 'package:bengkel/repository/bengkel_repsitory.dart';
import 'package:bengkel/repository/detail_pembelian_suku_cadang_repository.dart';
import 'package:bengkel/repository/detail_penjualan_suku_cadang_repository.dart';
import 'package:bengkel/repository/detail_transaksi_service_repository.dart';
import 'package:bengkel/repository/detail_transaksi_suku_cadang_servis_repository.dart';
import 'package:bengkel/repository/jasa_repository.dart';
import 'package:bengkel/repository/jurnal_repository.dart';
import 'package:bengkel/repository/kendaraan_repository.dart';
import 'package:bengkel/repository/mekanik_repository.dart';
import 'package:bengkel/repository/merk_kendaraan_repository.dart';
import 'package:bengkel/repository/neraca_repository.dart';
import 'package:bengkel/repository/nomor_repository.dart';
import 'package:bengkel/repository/part_repository.dart';
import 'package:bengkel/repository/payment_repository.dart';
import 'package:bengkel/repository/pelanggan_repository.dart';
import 'package:bengkel/repository/pembelian_suku_cadang_repository.dart';
import 'package:bengkel/repository/penjualan_suku_cadang_repository.dart';
import 'package:bengkel/repository/transaksi_service_repository.dart';
import 'package:bengkel/repository/transaksi_servis_repository.dart';
import 'package:bengkel/repository/type_kendaraan_repository.dart';
import 'package:bengkel/repository/vendor_repository.dart';
import 'package:bengkel/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final DatabaseHelper helper = DatabaseHelper();
  await helper.initDatabase();
  // Initialize the database

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountBloc>(
          create:
              (context) =>
                  AccountBloc(AkunRepository()), // Dispatch initial event
        ),
        BlocProvider<VendorBloc>(
          create:
              (context) =>
                  VendorBloc(SupplierRepository()), // Dispatch initial event
        ),
        BlocProvider<MekanikBloc>(
          create: (context) => MekanikBloc(MekanikRepository()),
        ),
        BlocProvider<JasaBloc>(create: (context) => JasaBloc(JasaRepository())),
        BlocProvider<SukuCadangBloc>(
          create:
              (context) =>
                  SukuCadangBloc(PartRepository()), // Dispatch initial event
        ),
        BlocProvider<PelangganBloc>(
          create:
              (context) => PelangganBloc(
                PelangganRepository(),
              ), // Dispatch initial event
        ),
        BlocProvider<KendaraanBloc>(
          create:
              (context) => KendaraanBloc(
                KendaraanRepository(),
                PelangganRepository(),
                MerkKendaraanRepository(),
                TypeKendaraanRepository(),
              ), // Dispatch initial event
        ),
        BlocProvider<PembelianSukuCadangBloc>(
          create:
              (context) => PembelianSukuCadangBloc(
                PembelianSukuCadangRepository(),
                DetailPembelianSukuCadangRepository(),
              ), // Dispatch initial event
        ),
        BlocProvider<TransaksiServisBloc>(
          create:
              (context) => TransaksiServisBloc(
                TransaksiServisRepository(),
                DetailTransaksiServiceRepository(),
                DetailTransaksiSukuCadangServisRepository(),

                PartRepository(),
                KendaraanRepository(),
                PelangganRepository(),
                JasaRepository(), // Diperlukan untuk harga beli suku cadang di BLoC
              ),
        ),
        BlocProvider<PenjualanSukuCadangBloc>(
          create:
              (context) => PenjualanSukuCadangBloc(
                PenjualanSukuCadangRepository(),
                DetailPenjualanSukuCadangRepository(),
                PartRepository(), // SukuCadangRepository juga diperlukan di sini
              ),
        ),
        BlocProvider<JurnalBloc>(
          create:
              (context) => JurnalBloc(
                JurnalRepository(),
                AkunRepository(), // AccountRepository diperlukan di sini
              ),
        ),
        BlocProvider<NeracaBloc>(
          create: (context) => NeracaBloc(NeracaRepository()),
        ),
        BlocProvider<TypeKendaraanBloc>(
          create: (context) => TypeKendaraanBloc(TypeKendaraanRepository()),
        ),
        BlocProvider<MerkKendaraanBloc>(
          create: (context) => MerkKendaraanBloc(MerkKendaraanRepository()),
        ),

        BlocProvider<TransaksiServiceDetailBloc>(
          create:
              (context) =>
                  TransaksiServiceDetailBloc(TransaksiServiceRepository()),
        ),
        BlocProvider<PaymentBloc>(
          create: (context) => PaymentBloc(PaymentRepository()),
        ),
        BlocProvider<NomorBloc>(
          create: (context) => NomorBloc(NomorRepository()),
        ),
        BlocProvider<BengkelBloc>(
          create: (context) => BengkelBloc(BengkelRepository()),
        ),
        // Add other BLoCs hereTransaksiServiceDetailState
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bengkel App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const DashboardScreen(), // Your initial screen
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
