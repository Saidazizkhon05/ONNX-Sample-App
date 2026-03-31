/// Application-wide constants
class AppConstants {
  // App Configuration
  static const String appTitle = 'XGBoost Model';
  static const String pageTitle = 'ONNX Runtime CSV Demo';

  // Asset Paths
  static const String modelAssetPath = 'assets/windowed_10_300_wr_ratio-0_03_15.onnx';
  static const String csvAssetPath = 'assets/windowed_10_300_wr_ratio-0.csv';

  // Data Processing
  static const int labelColumnIndex = 0;

  // UI Text
  static const String runInferenceButtonText = 'Run Inference';
  static const String inferenceResultsTitle = 'Inference Results:';
  static const String noResultsMessage = 'Run inference to see results';

  // Status Messages
  static const String initializingMessage = 'Initializing...';
  static const String initializingOnnxMessage = 'Initializing ONNX Runtime...';
  static const String readyMessage = 'Ready to run inference';
  static const String processingMessage = 'Running inference...';
  static const String initializationFailedMessage = 'Initialization failed: ';
  static const String inferenceFailedMessage = 'Inference failed: ';

  // Table Headers
  static const String labelColumnHeader = 'Label';
  static const String outputColumnHeader = 'Model Output';

  // ONNX Configuration
  static const int interOpNumThreads = 1;
  static const int intraOpNumThreads = 1;
}