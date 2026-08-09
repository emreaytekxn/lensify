// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_item_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBatchItemModelCollection on Isar {
  IsarCollection<BatchItemModel> get batchItemModels => this.collection();
}

const BatchItemModelSchema = CollectionSchema(
  name: r'BatchItemModel',
  id: -8372500829398805379,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'conversionType': PropertySchema(
      id: 1,
      name: r'conversionType',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'errorMessage': PropertySchema(
      id: 3,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'outputPath': PropertySchema(
      id: 4,
      name: r'outputPath',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 5,
      name: r'progress',
      type: IsarType.double,
    ),
    r'sourceFileName': PropertySchema(
      id: 6,
      name: r'sourceFileName',
      type: IsarType.string,
    ),
    r'sourcePath': PropertySchema(
      id: 7,
      name: r'sourcePath',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 8,
      name: r'status',
      type: IsarType.byte,
      enumMap: _BatchItemModelstatusEnumValueMap,
    ),
    r'targetFormat': PropertySchema(
      id: 9,
      name: r'targetFormat',
      type: IsarType.string,
    )
  },
  estimateSize: _batchItemModelEstimateSize,
  serialize: _batchItemModelSerialize,
  deserialize: _batchItemModelDeserialize,
  deserializeProp: _batchItemModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _batchItemModelGetId,
  getLinks: _batchItemModelGetLinks,
  attach: _batchItemModelAttach,
  version: '3.1.0+1',
);

int _batchItemModelEstimateSize(
  BatchItemModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.conversionType.length * 3;
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.outputPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceFileName.length * 3;
  bytesCount += 3 + object.sourcePath.length * 3;
  bytesCount += 3 + object.targetFormat.length * 3;
  return bytesCount;
}

void _batchItemModelSerialize(
  BatchItemModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeString(offsets[1], object.conversionType);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.errorMessage);
  writer.writeString(offsets[4], object.outputPath);
  writer.writeDouble(offsets[5], object.progress);
  writer.writeString(offsets[6], object.sourceFileName);
  writer.writeString(offsets[7], object.sourcePath);
  writer.writeByte(offsets[8], object.status.index);
  writer.writeString(offsets[9], object.targetFormat);
}

BatchItemModel _batchItemModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BatchItemModel();
  object.completedAt = reader.readDateTimeOrNull(offsets[0]);
  object.conversionType = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.errorMessage = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.outputPath = reader.readStringOrNull(offsets[4]);
  object.progress = reader.readDouble(offsets[5]);
  object.sourceFileName = reader.readString(offsets[6]);
  object.sourcePath = reader.readString(offsets[7]);
  object.status =
      _BatchItemModelstatusValueEnumMap[reader.readByteOrNull(offsets[8])] ??
          BatchItemStatus.pending;
  object.targetFormat = reader.readString(offsets[9]);
  return object;
}

P _batchItemModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_BatchItemModelstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BatchItemStatus.pending) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BatchItemModelstatusEnumValueMap = {
  'pending': 0,
  'converting': 1,
  'completed': 2,
  'failed': 3,
  'paused': 4,
};
const _BatchItemModelstatusValueEnumMap = {
  0: BatchItemStatus.pending,
  1: BatchItemStatus.converting,
  2: BatchItemStatus.completed,
  3: BatchItemStatus.failed,
  4: BatchItemStatus.paused,
};

Id _batchItemModelGetId(BatchItemModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _batchItemModelGetLinks(BatchItemModel object) {
  return [];
}

void _batchItemModelAttach(
    IsarCollection<dynamic> col, Id id, BatchItemModel object) {
  object.id = id;
}

extension BatchItemModelQueryWhereSort
    on QueryBuilder<BatchItemModel, BatchItemModel, QWhere> {
  QueryBuilder<BatchItemModel, BatchItemModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BatchItemModelQueryWhere
    on QueryBuilder<BatchItemModel, BatchItemModel, QWhereClause> {
  QueryBuilder<BatchItemModel, BatchItemModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BatchItemModelQueryFilter
    on QueryBuilder<BatchItemModel, BatchItemModel, QFilterCondition> {
  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conversionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conversionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conversionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conversionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conversionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversionType',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      conversionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversionType',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'outputPath',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'outputPath',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outputPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'outputPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      outputPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'outputPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      progressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      progressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      progressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      progressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceFileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceFileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceFileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceFileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceFileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceFileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceFileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceFileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceFileName',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourceFileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceFileName',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourcePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourcePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourcePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourcePath',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      sourcePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourcePath',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      statusEqualTo(BatchItemStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      statusGreaterThan(
    BatchItemStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      statusLessThan(
    BatchItemStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      statusBetween(
    BatchItemStatus lower,
    BatchItemStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetFormat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetFormat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetFormat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetFormat',
        value: '',
      ));
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterFilterCondition>
      targetFormatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetFormat',
        value: '',
      ));
    });
  }
}

extension BatchItemModelQueryObject
    on QueryBuilder<BatchItemModel, BatchItemModel, QFilterCondition> {}

extension BatchItemModelQueryLinks
    on QueryBuilder<BatchItemModel, BatchItemModel, QFilterCondition> {}

extension BatchItemModelQuerySortBy
    on QueryBuilder<BatchItemModel, BatchItemModel, QSortBy> {
  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByConversionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversionType', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByConversionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversionType', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByOutputPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPath', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByOutputPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPath', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortBySourceFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFileName', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortBySourceFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFileName', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortBySourcePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePath', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortBySourcePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePath', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByTargetFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetFormat', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      sortByTargetFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetFormat', Sort.desc);
    });
  }
}

extension BatchItemModelQuerySortThenBy
    on QueryBuilder<BatchItemModel, BatchItemModel, QSortThenBy> {
  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByConversionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversionType', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByConversionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversionType', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByOutputPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPath', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByOutputPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPath', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenBySourceFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFileName', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenBySourceFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFileName', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenBySourcePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePath', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenBySourcePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePath', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByTargetFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetFormat', Sort.asc);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QAfterSortBy>
      thenByTargetFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetFormat', Sort.desc);
    });
  }
}

extension BatchItemModelQueryWhereDistinct
    on QueryBuilder<BatchItemModel, BatchItemModel, QDistinct> {
  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct>
      distinctByConversionType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversionType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct>
      distinctByErrorMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct> distinctByOutputPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct>
      distinctBySourceFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceFileName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct> distinctBySourcePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourcePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<BatchItemModel, BatchItemModel, QDistinct>
      distinctByTargetFormat({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetFormat', caseSensitive: caseSensitive);
    });
  }
}

extension BatchItemModelQueryProperty
    on QueryBuilder<BatchItemModel, BatchItemModel, QQueryProperty> {
  QueryBuilder<BatchItemModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BatchItemModel, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<BatchItemModel, String, QQueryOperations>
      conversionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversionType');
    });
  }

  QueryBuilder<BatchItemModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BatchItemModel, String?, QQueryOperations>
      errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<BatchItemModel, String?, QQueryOperations> outputPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputPath');
    });
  }

  QueryBuilder<BatchItemModel, double, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<BatchItemModel, String, QQueryOperations>
      sourceFileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceFileName');
    });
  }

  QueryBuilder<BatchItemModel, String, QQueryOperations> sourcePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourcePath');
    });
  }

  QueryBuilder<BatchItemModel, BatchItemStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<BatchItemModel, String, QQueryOperations>
      targetFormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetFormat');
    });
  }
}
