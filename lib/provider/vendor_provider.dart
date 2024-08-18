

import 'package:app_web_cms/models/vendor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//StateNotifier là 1 class được cung cấp bởi gói Riverpod, giúp quản lý trạng thái và thông báo các listeners về những thay đổi của trạng thái
class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider()
  : super(Vendor(
    id: '', 
    fullName: '', 
    email: '', 
    state: '', 
    city: '', 
    locality: '', 
    role: '', 
    password: ''));

  // Getter method để trích xuất giá trị từ các đối tượng
  Vendor ? get vendor => state;
  // Khai báo phương thức để cập nhật trạng thái ng dùng dựa trên chuỗi JSON đại diện cho đối tượng Vendor

  void setVendor(String vendorJson) {
    state = Vendor.fromJson(vendorJson);
  }

  // Phương thức xóa trạng thái người dùng
  void signOut() {
    state = null;
  }
}

// Làm cho dữ liệu truy cập được vào toàn bộ ứng dụng
final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref){
  return VendorProvider();
});