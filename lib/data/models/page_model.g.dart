// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPageModelCollection on Isar {
  IsarCollection<PageModel> get pageModels => this.collection();
}

const PageModelSchema = CollectionSchema(
  name: r'PageModel',
  id: -5125267323554502652,
  properties: {
    r'appliedFilter': PropertySchema(
      id: 0,
      name: r'appliedFilter',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'documentId': PropertySchema(
      id: 2,
      name: r'documentId',
      type: IsarType.long,
    ),
    r'originalImagePath': PropertySchema(
      id: 3,
      name: r'originalImagePath',
      type: IsarType.string,
    ),
    r'pageIndex': PropertySchema(
      id: 4,
      name: r'pageIndex',
      type: IsarType.long,
    ),
    r'processedImagePath': PropertySchema(
      id: 5,
      name: r'processedImagePath',
      type: IsarType.string,
    )
  },
  estimateSize: _pageModelEstimateSize,
  serialize: _pageModelSerialize,
  deserialize: _pageModelDeserialize,
  deserializeProp: _pageModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pageModelGetId,
  getLinks: _pageModelGetLinks,
  attach: _pageModelAttach,
  version: '3.1.0+1',
);

int _pageModelEstimateSize(
  PageModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appliedFilter.length * 3;
  bytesCount += 3 + object.originalImagePath.length * 3;
  {
    final value = object.processedImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _pageModelSerialize(
  PageModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appliedFilter);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.documentId);
  writer.writeString(offsets[3], object.originalImagePath);
  writer.writeLong(offsets[4], object.pageIndex);
  writer.writeString(offsets[5], object.processedImagePath);
}

PageModel _pageModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PageModel();
  object.appliedFilter = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.documentId = reader.readLong(offsets[2]);
  object.id = id;
  object.originalImagePath = reader.readString(offsets[3]);
  object.pageIndex = reader.readLong(offsets[4]);
  object.processedImagePath = reader.readStringOrNull(offsets[5]);
  return object;
}

P _pageModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pageModelGetId(PageModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pageModelGetLinks(PageModel object) {
  return [];
}

void _pageModelAttach(IsarCollection<dynamic> col, Id id, PageModel object) {
  object.id = id;
}

extension PageModelQueryWhereSort
    on QueryBuilder<PageModel, PageModel, QWhere> {
  QueryBuilder<PageModel, PageModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterWhere> anyDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'documentId'),
      );
    });
  }
}

extension PageModelQueryWhere
    on QueryBuilder<PageModel, PageModel, QWhereClause> {
  QueryBuilder<PageModel, PageModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> documentIdEqualTo(
      int documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> documentIdNotEqualTo(
      int documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> documentIdGreaterThan(
    int documentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'documentId',
        lower: [documentId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> documentIdLessThan(
    int documentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'documentId',
        lower: [],
        upper: [documentId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterWhereClause> documentIdBetween(
    int lowerDocumentId,
    int upperDocumentId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'documentId',
        lower: [lowerDocumentId],
        includeLower: includeLower,
        upper: [upperDocumentId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PageModelQueryFilter
    on QueryBuilder<PageModel, PageModel, QFilterCondition> {
  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appliedFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appliedFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appliedFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appliedFilter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appliedFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appliedFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appliedFilter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appliedFilter',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appliedFilter',
        value: '',
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      appliedFilterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appliedFilter',
        value: '',
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
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

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> documentIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      documentIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> documentIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> documentIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      originalImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> pageIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      pageIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> pageIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition> pageIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'processedImagePath',
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'processedImagePath',
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processedImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'processedImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterFilterCondition>
      processedImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'processedImagePath',
        value: '',
      ));
    });
  }
}

extension PageModelQueryObject
    on QueryBuilder<PageModel, PageModel, QFilterCondition> {}

extension PageModelQueryLinks
    on QueryBuilder<PageModel, PageModel, QFilterCondition> {}

extension PageModelQuerySortBy on QueryBuilder<PageModel, PageModel, QSortBy> {
  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByAppliedFilter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedFilter', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByAppliedFilterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedFilter', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByOriginalImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy>
      sortByOriginalImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImagePath', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByPageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageIndex', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByPageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageIndex', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> sortByProcessedImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy>
      sortByProcessedImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedImagePath', Sort.desc);
    });
  }
}

extension PageModelQuerySortThenBy
    on QueryBuilder<PageModel, PageModel, QSortThenBy> {
  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByAppliedFilter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedFilter', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByAppliedFilterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appliedFilter', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByOriginalImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy>
      thenByOriginalImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImagePath', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByPageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageIndex', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByPageIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageIndex', Sort.desc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy> thenByProcessedImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageModel, PageModel, QAfterSortBy>
      thenByProcessedImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedImagePath', Sort.desc);
    });
  }
}

extension PageModelQueryWhereDistinct
    on QueryBuilder<PageModel, PageModel, QDistinct> {
  QueryBuilder<PageModel, PageModel, QDistinct> distinctByAppliedFilter(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appliedFilter',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageModel, PageModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PageModel, PageModel, QDistinct> distinctByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId');
    });
  }

  QueryBuilder<PageModel, PageModel, QDistinct> distinctByOriginalImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageModel, PageModel, QDistinct> distinctByPageIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageIndex');
    });
  }

  QueryBuilder<PageModel, PageModel, QDistinct> distinctByProcessedImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processedImagePath',
          caseSensitive: caseSensitive);
    });
  }
}

extension PageModelQueryProperty
    on QueryBuilder<PageModel, PageModel, QQueryProperty> {
  QueryBuilder<PageModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PageModel, String, QQueryOperations> appliedFilterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appliedFilter');
    });
  }

  QueryBuilder<PageModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PageModel, int, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<PageModel, String, QQueryOperations>
      originalImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalImagePath');
    });
  }

  QueryBuilder<PageModel, int, QQueryOperations> pageIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageIndex');
    });
  }

  QueryBuilder<PageModel, String?, QQueryOperations>
      processedImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processedImagePath');
    });
  }
}
