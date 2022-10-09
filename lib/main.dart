import "package:flutter/material.dart";
import 'package:relic/pages/loading.dart';

void main() => runApp(
  MaterialApp(
      home: const LoadingScreen(),
      title: "Relic",
      theme: ThemeData.dark(), // you will want to define this later
    )
  );
