import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:csv/csv.dart';

class OnnxRuntimePage extends StatefulWidget {
  const OnnxRuntimePage({super.key});

  @override
  State<OnnxRuntimePage> createState() => _OnnxRuntimePageState();
}

class _OnnxRuntimePageState extends State<OnnxRuntimePage> {
  // String _version = '';
  String statusOfOnnxModel = 'Ready';
  String _result = '';
  String? _csvContent;
  List<List<dynamic>>? _csvData;
  int _featureCount = 0;
  OrtSession? _session;
  List<double> _inputValues = []; // Store results for all rows
  List<Map<String, dynamic>> _allResults = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _allResults = [];
  }

  Future<void> _initializeApp() async {
    // Initialize OnnxRuntime
    await _initOnnxRuntime();

    // Load CSV data
    await _loadCsvData();

    // Load ONNX model
    await _loadModel();
  }

  Future<void> _initOnnxRuntime() async {
    try {
      // Initialize OnnxRuntime environment
      OrtEnv.instance.init();

      // Log available providers
      final providers = OrtEnv.instance.availableProviders();
      print('Available ONNX providers: $providers');
    } catch (e) {
      setState(() {
        statusOfOnnxModel = 'Error initializing ONNX Runtime: $e';
      });
      print('Error initializing ONNX Runtime: $e');
    }
  }

  Future<void> _loadCsvData() async {
    try {
      // Load CSV file from assets
      _csvContent = await rootBundle
          .loadString('assets/windowed_10_300_wr_ratio-0.csv');

      // Parse CSV content
      _csvData = const CsvToListConverter().convert(_csvContent!, eol: '\n');

      // Get header row
      final headerRow = _csvData![0];

      // First column is label, rest are features
      // Determine feature count (excluding the first column which is the label)
      _featureCount = headerRow.length - 1;

      // Initialize input values array with the right size
      _inputValues = List<double>.filled(_featureCount, 0.0);

      setState(() {
        statusOfOnnxModel = "CSV data loaded with ${_csvData!.length - 1} rows";
      });

      print("CSV data loaded successfully, feature count: $_featureCount");
    } catch (e) {
      print("Error loading CSV data: $e");
      setState(() {
        statusOfOnnxModel = "Error loading CSV data: $e";
      });
    }
  }

  Future<void> _loadModel() async {
    try {
      // Create session options
      final sessionOptions = OrtSessionOptions()
        ..setInterOpNumThreads(1)
        ..setIntraOpNumThreads(1)
        ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);

      // Load model from assets
      const assetFileName = 'assets/windowed_10_300_wr_ratio-0_03_15.onnx';
      final rawAssetFile = await rootBundle.load(assetFileName);
      final bytes = rawAssetFile.buffer.asUint8List();

      // Create session from model bytes
      _session = OrtSession.fromBuffer(bytes, sessionOptions);

      // Print out the input and output names for debugging
      print("Model input names: ${_session!.inputNames}");
      print("Model output names: ${_session!.outputNames}");

      setState(() {
        statusOfOnnxModel =
            "Model loaded successfully. Input names: ${_session!.inputNames}";
      });

      print("ONNX model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
      setState(() {
        statusOfOnnxModel = "Error loading model: $e";
      });
    }
  }

  Future<void> _runInferenceForAllRows() async {
    if (_session == null || _csvData == null || _csvData!.isEmpty) {
      setState(() {
        statusOfOnnxModel = "Cannot run inference: Model or data not loaded";
      });
      return;
    }

    try {
      setState(() {
        statusOfOnnxModel = "Running inference for all rows...";
        _allResults = [];
      });

      // Get the correct input name from the model
      final inputName = _session!.inputNames.first;
      print("Using input name: $inputName");

      // Process all rows (skip header)
      for (int rowIndex = 1; rowIndex < _csvData!.length; rowIndex++) {
        // Extract feature values from the current row
        List<dynamic> row = _csvData![rowIndex];

        // Get the label (first column)
        String label = row[0].toString();

        // Get the features (all columns except first if it's a label)
        for (int i = 0; i < _featureCount; i++) {
          _inputValues[i] = double.parse(row[i + 1].toString());
        }

        // Create input tensor
        final inputTensor = OrtValueTensor.createTensorWithDataList(
            Float32List.fromList(_inputValues), [1, _featureCount]);

        // Run inference using the correct input name
        final runOptions = OrtRunOptions();
        final inputs = {inputName: inputTensor};
        final outputs = _session!.run(runOptions, inputs);

        // Process output
        List<List> outputValue = outputs[0]?.value as List<List>;

        // Store result with its label
        _allResults.add(
            {'label': label, 'output': outputValue.first.first.toString()});

        // Release resources
        inputTensor.release();
        runOptions.release();
        outputs.forEach((element) {
          element?.release();
        });
      }

      // Update UI with result
      setState(() {
        _result = "Processed ${_allResults.length} rows";
        statusOfOnnxModel = "Inference completed for all rows";
      });

      print("Inference completed for all rows");
    } catch (e) {
      print("Error running inference: $e");
      setState(() {
        statusOfOnnxModel = "Error running inference: $e";
        _result = e.toString();
      });
    }
  }

// DONE
  Widget _buildResultsTable() {
    if (_allResults.isEmpty) {
      return const Center(
        child: Text("Run inference to see results"),
      );
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Label")),
            DataColumn(label: Text("Model Output")),
          ],
          rows: _allResults
              .map<DataRow>(
                (result) => DataRow(
                  cells: [
                    DataCell(Text(result['label'])),
                    DataCell(Text(result['output'])),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ONNX Runtime CSV Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _runInferenceForAllRows,
              child: const Text('Predict'),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _result.isEmpty ? 'No prediction yet' : _result,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Prediction Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildResultsTable(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Release ONNX resources
    _session?.release();
    OrtEnv.instance.release();
    super.dispose();
  }
}
