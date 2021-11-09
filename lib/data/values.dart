import 'package:flutter/material.dart';

String appName = "Famguard";

Color colorGradientTop = Color(0xFF2596be);
Color colorGradientBottom = Color(0xFF4db1ce);

Gradient appGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      colorGradientTop,
      colorGradientBottom,
    ],
    stops: [
      0,
      0.7
    ]);
