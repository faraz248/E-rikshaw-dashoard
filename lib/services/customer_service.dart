import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Add Customer (Shop ID mandatory rahega)
  Future<void> addCustomer(CustomerModel customer) async {
    await _db.collection('customers').add(customer.toMap());
  }

  // 2. Multi-tenant Fetch: Sirf is shop ke customers layega
  Stream<List<CustomerModel>> getCustomersByShop(String currentShopId) {
    return _db
        .collection('customers')
        .where('shopId', isEqualTo: currentShopId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CustomerModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
