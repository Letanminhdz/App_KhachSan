import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cau_hinh/cau_hinh_api.dart';
import 'cau_hinh/mau_sac_app.dart';
import 'man_hinh/dieu_huong_chinh.dart';
import 'quan_ly_trang_thai/dat_phong_provider.dart';
import 'quan_ly_trang_thai/xac_thuc_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CauHinhApi.khoiTao();
  runApp(const UngDungDatPhongKhachSan());
}

class UngDungDatPhongKhachSan extends StatelessWidget {
  const UngDungDatPhongKhachSan({super.key});

  @override
  Widget build(BuildContext nguoiCanh) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => XacThucProvider()..khoiTao(),
        ),
        ChangeNotifierProvider(
          create: (_) => DatPhongProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Khách Sạn Grand Luxury',
        debugShowCheckedModeBanner: false,
        theme: MauSacApp.giaoDienSang,
        home: const DieuHuongChinh(),
      ),
    );
  }
}
