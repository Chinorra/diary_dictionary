import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'my_dictionary',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return DatabaseConnection(result.resolvedExecutor);
  }));
}
