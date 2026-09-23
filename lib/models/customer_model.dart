class CustomerModel {
  final String? id;
  final String shopId;
  final String name;
  final String fatherName;
  final String phone;
  final String address;
  final String? photoUrl;

  final String chassisNo;
  final String motorNo;
  final String batteryNo;
  final String vehicleNo;
  final String model;
  final String color;

  final String financerName;
  final double totalAmount;
  final double monthlyEmi;
  final DateTime registrationDate;

  CustomerModel({
    this.id,
    required this.shopId,
    required this.name,
    required this.fatherName,
    required this.phone,
    required this.address,
    this.photoUrl,
    required this.chassisNo,
    required this.motorNo,
    required this.batteryNo,
    required this.vehicleNo,
    required this.model,
    required this.color,
    required this.financerName,
    required this.totalAmount,
    required this.monthlyEmi,
    required this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'name': name,
      'fatherName': fatherName,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
      'chassisNo': chassisNo,
      'motorNo': motorNo,
      'batteryNo': batteryNo,
      'vehicleNo': vehicleNo,
      'model': model,
      'color': color,
      'financerName': financerName,
      'totalAmount': totalAmount,
      'monthlyEmi': monthlyEmi,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(String docId, Map<String, dynamic> map) {
    return CustomerModel(
      id: docId,
      shopId: map['shopId'] ?? '',
      name: map['name'] ?? '',
      fatherName: map['fatherName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      photoUrl: map['photoUrl'],
      chassisNo: map['chassisNo'] ?? '',
      motorNo: map['motorNo'] ?? '',
      batteryNo: map['batteryNo'] ?? '',
      vehicleNo: map['vehicleNo'] ?? '',
      model: map['model'] ?? '',
      color: map['color'] ?? '',
      financerName: map['financerName'] ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyEmi: (map['monthlyEmi'] as num?)?.toDouble() ?? 0.0,
      registrationDate:
          DateTime.tryParse(map['registrationDate'] ?? '') ?? DateTime.now(),
    );
  }
}
