import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:csv/csv.dart';
import 'package:onnx_sample_app/constants.dart';
import 'package:onnx_sample_app/models/app_status.dart';
import 'package:onnx_sample_app/models/inference_result.dart';
import 'package:onnx_sample_app/service/onnx_inference_service.dart';
import 'package:onnx_sample_app/widgets/results_table.dart';
import 'package:onnx_sample_app/widgets/status_card.dart';

class OnnxRuntimePage extends StatefulWidget {
  const OnnxRuntimePage({super.key});

  @override
  State<OnnxRuntimePage> createState() => _OnnxRuntimePageState();
}

class _OnnxRuntimePageState extends State<OnnxRuntimePage> {
  late final OnnxInferenceService _inferenceService;
  AppStatus _appStatus = AppStatus.initializing;
  String _statusMessage = AppConstants.initializingMessage;
  List<InferenceResult> _inferenceResults = [];

  @override
  void initState() {
    super.initState();
    _inferenceService = OnnxInferenceService();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _appStatus = AppStatus.initializing;
        _statusMessage = AppConstants.initializingOnnxMessage;
      });

      await _inferenceService.initialize();

      setState(() {
        _appStatus = AppStatus.ready;
        _statusMessage = AppConstants.readyMessage;
      });
    } catch (e) {
      setState(() {
        _appStatus = AppStatus.error;
        _statusMessage = '${AppConstants.initializationFailedMessage}$e';
      });
    }
  }

  Future<void> _runInference() async {
    if (_appStatus != AppStatus.ready) return;

    try {
      setState(() {
        _appStatus = AppStatus.processing;
        _statusMessage = AppConstants.processingMessage;
        _inferenceResults = [];
      });

      final results = await _inferenceService.runInferenceOnAllRows();

      setState(() {
        _inferenceResults = results;
        _appStatus = AppStatus.completed;
        _statusMessage = 'Processed ${results.length} rows successfully';
      });
    } catch (e) {
      setState(() {
        _appStatus = AppStatus.error;
        _statusMessage = '${AppConstants.inferenceFailedMessage}$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.pageTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _appStatus == AppStatus.ready ? _runInference : null,
              child: const Text(AppConstants.runInferenceButtonText),
            ),
            const SizedBox(height: 20),
            StatusCard(
              status: _appStatus,
              message: _statusMessage,
            ),
            const SizedBox(height: 20),
            const Text(
              AppConstants.inferenceResultsTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ResultsTable(results: _inferenceResults),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inferenceService.dispose();
    super.dispose();
  }
}
