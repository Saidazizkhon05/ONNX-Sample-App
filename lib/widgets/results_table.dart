import 'package:flutter/material.dart';
import 'package:onnx_sample_app/constants.dart';
import 'package:onnx_sample_app/models/inference_result.dart';

class ResultsTable extends StatelessWidget {
  final List<InferenceResult> results;

  const ResultsTable({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Text(AppConstants.noResultsMessage),
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
            DataColumn(label: Text(AppConstants.labelColumnHeader)),
            DataColumn(label: Text(AppConstants.outputColumnHeader)),
          ],
          rows: results
              .map<DataRow>(
                (result) => DataRow(
                  cells: [
                    DataCell(Text(result.label)),
                    DataCell(Text(result.output)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}