
import 'package:flutter/material.dart';

class HotelSearchScreen extends StatelessWidget {
  const HotelSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('호텔 검색'),
      ),
      body: const Center(
        child: Text('호텔 검색 화면'),
      ),
    );
  }
}
