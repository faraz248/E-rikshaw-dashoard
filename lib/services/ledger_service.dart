import 'package:cloud_firestore/cloud_firestore.dart';

class LedgerService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Nayi payment add karega aur main customer ke pendingAmount ko instantly ghata dega
  static Future<void> addPayment({
    required String customerId,
    required double amountPaid,
    required String paymentMode, // 'Cash', 'UPI', 'Bank Transfer'
    required String notes,
    required double currentPending,
  }) async {
    final double updatedPending =
        (currentPending - amountPaid).clamp(0.0, double.infinity);

    // 1. Transaction history entry
    await _db
        .collection('Customers')
        .doc(customerId)
        .collection('EmiTransactions')
        .add({
      'amount': amountPaid,
      'paymentMode': paymentMode,
      'notes': notes,
      'date': FieldValue.serverTimestamp(),
      'remainingBalance': updatedPending,
    });

    // 2. Main customer record update
    await _db.collection('Customers').doc(customerId).set({
      'pendingAmount': updatedPending,
      'lastPaymentDate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// EMI structure set ya edit karne ke liye (Total Vehicle Cost, Down Payment, Monthly EMI)
  static Future<void> updateEmiPlan({
    required String customerId,
    required double totalAmount,
    required double downPayment,
    required double monthlyEmi,
    required String financerName,
  }) async {
    final double pending =
        (totalAmount - downPayment).clamp(0.0, double.infinity);

    await _db.collection('Customers').doc(customerId).set({
      'totalAmount': totalAmount,
      'downPayment': downPayment,
      'pendingAmount': pending,
      'monthlyEmi': monthlyEmi,
      'financerName': financerName,
    }, SetOptions(merge: true));
  }
}
