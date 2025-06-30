import 'package:flutter/material.dart';
import 'package:yanolja_clone/data/datasource/hanok_local_data_source.dart';
import 'package:yanolja_clone/data/model/hanok_model.dart';

class HanokViewModel with ChangeNotifier {
  final HanokLocalDataSource _dataSource = HanokLocalDataSource();

  List<Hanok> _hanoks = [];
  List<Hanok> get hanoks => _hanoks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HanokViewModel() {
    fetchHanoks();
  }

  Future<void> fetchHanoks() async {
    _isLoading = true;
    notifyListeners();

    _hanoks = await _dataSource.getHanoks();

    _isLoading = false;
    notifyListeners();
  }
}
