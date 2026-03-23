import 'package:flutter/material.dart';

import '../core/models/models.dart';

class MockData {
  static const TierInfo tier = TierInfo(
    name: 'Silver',
    currentPoints: 2650,
    nextTierPoints: 4000,
    progress: 0.66,
  );

  static final UserProfile profile = UserProfile(
    name: 'Lina Al Masri',
    phone: '+962 79 222 1119',
    email: 'lina@josequal.com',
    gender: 'female',
    dob: DateTime(1995, 4, 12),
  );

  static List<WalletTransaction> recentTransactions = [
    WalletTransaction(
      id: 'txn-001',
      title: 'Euro Mall - Downtown',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      amount: 42.75,
      points: 43,
      earned: true,
    ),
    WalletTransaction(
      id: 'txn-002',
      title: 'Euro Mall - Abdoun',
      date: DateTime.now().subtract(const Duration(days: 1)),
      amount: 120.50,
      points: 120,
      earned: true,
    ),
    WalletTransaction(
      id: 'txn-003',
      title: 'Voucher redemption',
      date: DateTime.now().subtract(const Duration(days: 3)),
      amount: -20,
      points: -200,
      earned: false,
    ),
  ];

  static List<Voucher> vouchers = [
    Voucher(
      id: 'v-001',
      title: '10% off fashion',
      description: 'Valid on fashion & accessories.',
      percentage: true,
      value: 10,
      expiresAt: DateTime.now().add(const Duration(days: 12)),
      status: VoucherStatus.active,
      code: 'FASH10',
      minimumSpend: 25,
    ),
    Voucher(
      id: 'v-002',
      title: 'JD 15 dining voucher',
      description: 'Redeem at any Euro Mall food outlet.',
      percentage: false,
      value: 15,
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      status: VoucherStatus.soon,
      code: 'EAT15',
      minimumSpend: 50,
    ),
    Voucher(
      id: 'v-003',
      title: 'Free coffee upgrade',
      description: 'Upgrade to any large size.',
      percentage: false,
      value: 0,
      expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      status: VoucherStatus.expired,
      code: 'COFFEEUP',
    ),
  ];

  static List<Offer> offers = [
    Offer(
      id: 'o-001',
      title: 'Double points weekend',
      subtitle: 'Earn 2x points on all stores this Friday & Saturday.',
      badge: 'Limited',
      expiresAt: DateTime.now().add(const Duration(days: 2)),
      imageUrl: null,
    ),
    Offer(
      id: 'o-002',
      title: 'Beauty flash sale',
      subtitle: 'Up to 30% off selected brands.',
      badge: 'New',
      imageUrl: null,
    ),
    Offer(
      id: 'o-003',
      title: 'Cinema & snacks bundle',
      subtitle: 'Save JD 5 on every ticket + snack combo.',
      badge: 'Bundle',
      imageUrl: null,
    ),
  ];

  static List<Branch> branches = const [
    Branch(
      id: 'b-001',
      name: 'Abdoun',
      address: 'Abdoun Circle, Amman',
      phone: '+962 6 555 1111',
      hours: '10:00 - 22:00',
      latitude: 31.9497,
      longitude: 35.9327,
      openNow: true,
    ),
    Branch(
      id: 'b-002',
      name: 'Downtown',
      address: 'King Hussein Street, Amman',
      phone: '+962 6 444 2222',
      hours: '09:00 - 23:00',
      latitude: 31.9515,
      longitude: 35.9396,
      openNow: false,
    ),
    Branch(
      id: 'b-003',
      name: 'Airport Road',
      address: 'Queen Alia Airport Road',
      phone: '+962 6 222 3333',
      hours: '24/7',
      latitude: 31.9729,
      longitude: 35.9916,
      openNow: true,
    ),
  ];

  static List<Color> gradientPalette = const [
    Color(0xFFFFF3F0),
    Color(0xFFF8F9FB),
    Color(0xFFEFF4FF),
  ];
}
