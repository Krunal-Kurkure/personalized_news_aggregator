import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.grey.shade50,
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final cardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 8,
    offset: Offset(0, 4),
  )
];
