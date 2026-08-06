import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/isar_local_datasource.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../domain/repositories/scanner_repository.dart';

// Provides the single instance of IsarLocalDataSource
final localDataSourceProvider = Provider<IsarLocalDataSource>((ref) {
  return IsarLocalDataSource();
});

// Provides the ScannerRepository implementation
final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return ScannerRepositoryImpl(dataSource);
});
