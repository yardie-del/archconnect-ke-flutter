import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const mpesaGreen = Color(0xFF16A34A);
const mpesaGreenContainer = Color(0xFFDCFCE7);
const kenyaGreenPrimary = Color(0xFF15803D);
const kenyaRed = Color(0xFFB91C1C);
const safariGold = Color(0xFFCA8A04);
const slateDark = Color(0xFF1E293B);
const slateMedium = Color(0xFF334155);
const slateMuted = Color(0xFF64748B);
const slateSurfaceLight = Color(0xFFF1F5F9);
const cardBorder = Color(0xFFE2E8F0);

String formatKsh(int amount) {
  final f = NumberFormat.decimalPattern('en_US');
  return 'Ksh ${f.format(amount)}';
}