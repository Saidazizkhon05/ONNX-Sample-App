import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:csv/csv.dart';
import 'package:onnx_sample_app/constants.dart';
import 'package:onnx_sample_app/models/inference_result.dart';

class OnnxInferenceService {
  OrtSession? _session;
  List<List<dynamic>>? _csvData;
  int _featureCount = 0;

  Future<void> initialize() async {
    await _initializeOnnxRuntime();
    await _loadCsvData();
    await _loadModel();
  }

  Future<void> _initializeOnnxRuntime() async {
    OrtEnv.instance.init();
    final providers = OrtEnv.instance.availableProviders();
    debugPrint('Available ONNX providers: $providers');
  }

  Future<void> _loadCsvData() async {
    final csvContent = await rootBundle.loadString(AppConstants.csvAssetPath);
    _csvData = const CsvToListConverter().convert(csvContent, eol: '\n');

    if (_csvData == null || _csvData!.isEmpty) {
      throw Exception('CSV data is empty or invalid');
    }

    final headerRow = _csvData!.first;
    _featureCount = headerRow.length - 1; // Exclude label column

    debugPrint("CSV data loaded successfully, feature count: $_featureCount");
  }

  Future<void> _loadModel() async {
    final sessionOptions = OrtSessionOptions()
      ..setInterOpNumThreads(AppConstants.interOpNumThreads)
      ..setIntraOpNumThreads(AppConstants.intraOpNumThreads)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);

    final rawAssetFile = await rootBundle.load(AppConstants.modelAssetPath);
    final bytes = rawAssetFile.buffer.asUint8List();

    _session = OrtSession.fromBuffer(bytes, sessionOptions);

    debugPrint("Model input names: ${_session!.inputNames}");
    debugPrint("Model output names: ${_session!.outputNames}");
    debugPrint("ONNX model loaded successfully");
  }

  Future<List<InferenceResult>> runInferenceOnAllRows() async {
    if (_session == null || _csvData == null || _csvData!.isEmpty) {
      throw Exception('Model or data not loaded');
    }

    final results = <InferenceResult>[];
    final inputName = _session!.inputNames.first;

    debugPrint("Using input name: $inputName");

    // Skip header row
    for (int rowIndex = 1; rowIndex < _csvData!.length; rowIndex++) {
      final result = await _runInferenceForRow(_csvData![rowIndex], inputName);
      results.add(result);
    }

    debugPrint("Inference completed for all rows");
    return results;
  }

  Future<InferenceResult> _runInferenceForRow(List<dynamic> row, String inputName) async {
    final label = row[AppConstants.labelColumnIndex].toString();
    final features = _extractFeaturesFromRow(row);

    final inputTensor = OrtValueTensor.createTensorWithDataList(
      Float32List.fromList(features),
      [1, _featureCount],
    );

    final runOptions = OrtRunOptions();
    final inputs = {inputName: inputTensor};
    final outputs = _session!.run(runOptions, inputs);

    final outputValue = outputs[0]?.value as List<List>;
    final prediction = outputValue.first.first.toString();

    // Clean up resources
    inputTensor.release();
    runOptions.release();
    outputs.forEach((element) => element?.release());

    return InferenceResult(label: label, output: prediction);
  }

  List<double> _extractFeaturesFromRow(List<dynamic> row) {
    final features = <double>[];
    // Start from index 1 to skip the label column
    for (int i = 1; i < row.length; i++) {
      features.add(double.parse(row[i].toString()));
    }
    return features;
  }

  void dispose() {
    _session?.release();
    OrtEnv.instance.release();
  }
}

  Future<List<InferenceResult>> runInferenceOnAllRows() async {
    if (_session == null || _csvData == null || _csvData!.isEmpty) {
      throw Exception('Model or data not loaded');
    }

    final results = <InferenceResult>[];
    final inputName = _session!.inputNames.first;

    debugPrint("Using input name: $inputName");

    // Skip header row
    for (int rowIndex = 1; rowIndex < _csvData!.length; rowIndex++) {
      final result = await _runInferenceForRow(_csvData![rowIndex], inputName);
      results.add(result);
    }

    debugPrint("Inference completed for all rows");
    return results;
  }

  Future<InferenceResult> _runInferenceForRow(List<dynamic> row, String inputName) async {
    final label = row[_labelColumnIndex].toString();
    final features = _extractFeaturesFromRow(row);

    final inputTensor = OrtValueTensor.createTensorWithDataList(
      Float32List.fromList(features),
      [1, _featureCount],
    );

    final runOptions = OrtRunOptions();
    final inputs = {inputName: inputTensor};
    final outputs = _session!.run(runOptions, inputs);

    final outputValue = outputs[0]?.value as List<List>;
    final prediction = outputValue.first.first.toString();

    // Clean up resources
    inputTensor.release();
    runOptions.release();
    outputs.forEach((element) => element?.release());

    return InferenceResult(label: label, output: prediction);
  }

  List<double> _extractFeaturesFromRow(List<dynamic> row) {
    final features = <double>[];
    // Start from index 1 to skip the label column
    for (int i = 1; i < row.length; i++) {
      features.add(double.parse(row[i].toString()));
    }
    return features;
  }

  void dispose() {
    _session?.release();
    OrtEnv.instance.release();
  }
}