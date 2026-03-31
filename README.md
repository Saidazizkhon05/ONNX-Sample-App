# ONNX Sample App

A Flutter application demonstrating how to use ONNX Runtime to run machine learning models on mobile devices. This sample app loads an XGBoost model (converted to ONNX format) and performs inference on CSV data.

## Features

- **ONNX Runtime Integration**: Uses the `onnxruntime` Flutter package to run ONNX models
- **XGBoost Model Support**: Demonstrates running an XGBoost model converted to ONNX format
- **CSV Data Processing**: Loads and processes CSV data for batch inference
- **Cross-Platform**: Works on Android, iOS, and other platforms supported by Flutter
- **Real-time Results**: Displays inference results in a clean, tabular format

## Prerequisites

- Flutter SDK (^3.6.2)
- Dart SDK (compatible with Flutter)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Saidazizkhon05/ONNX-Sample-App.git
   cd ONNX-Sample-App
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Usage

1. Launch the app on your device/emulator
2. The app will automatically:
   - Initialize ONNX Runtime
   - Load the CSV data from assets
   - Load the ONNX model
3. Tap the "Predict" button to run inference on all rows in the CSV
4. View the results in the table below, showing labels and model outputs

## Project Structure

```
lib/
├── main.dart              # App entry point and theme configuration
└── onnxruntime_page.dart  # Main page with ONNX inference logic

assets/
├── windowed_10_300_wr_ratio-0_03_15.onnx  # XGBoost model in ONNX format
└── windowed_10_300_wr_ratio-0.csv         # Sample CSV data for inference

android/                   # Android platform code
ios/                       # iOS platform code
```

## Dependencies

- **flutter**: UI framework
- **onnxruntime**: ^1.4.1 - ONNX Runtime for Flutter
- **csv**: ^6.0.0 - CSV parsing library

## How It Works

1. **Model Loading**: The app loads a pre-trained XGBoost model that has been converted to ONNX format
2. **Data Preparation**: CSV data is loaded and parsed, with features extracted for inference
3. **Inference**: ONNX Runtime processes each row of data through the model
4. **Results Display**: Model outputs are displayed alongside their corresponding labels

The model expects input data with multiple features and produces a single output value for each input row.

## Model Details

- **Model File**: `windowed_10_300_wr_ratio-0_03_15.onnx`
- **Original Model**: XGBoost classifier/regressor
- **Input**: Feature vectors (numerical values)
- **Output**: Prediction results
