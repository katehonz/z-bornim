# SQL Integration Improvements for Ormin
# Подобрения за SQL интеграция в Ormin

## English

### Overview

This document describes the SQL integration improvements made to the Ormin ORM library. These enhancements allow developers to work directly with SQL DDL files for schema definition, making it easier for SQL-familiar developers to adopt Ormin.

### What Was Implemented

#### 1. SQL Schema Importer Module (`ormin/sql_schema_importer.nim`)

A comprehensive module that provides:

- **SQL Parsing**: Parse CREATE TABLE statements from SQL files or strings
- **Type Mapping**: Automatic conversion from SQL types to Nim/Ormin types
- **Model Generation**: Generate Nim model code from SQL schemas
- **Bidirectional Conversion**: Convert between SQL and Nim model definitions
- **Foreign Key Support**: Preserve relationships between tables

#### 2. Key Features

**Supported SQL Types:**
- INTEGER, INT → dbInt
- FLOAT, REAL, DOUBLE → dbFloat  
- VARCHAR, TEXT → dbVarchar
- CHAR → dbFixedChar
- BOOLEAN, BOOL → dbBool
- TIMESTAMP, DATETIME → dbTimestamp

**Supported Constraints:**
- PRIMARY KEY
- NOT NULL
- DEFAULT values
- FOREIGN KEY relationships

**API Functions:**
- `newSqlSchemaImporter()` - Create importer instance
- `importFromFile(filepath)` - Import from SQL file
- `importFromString(sql)` - Import from SQL string
- `generateNimModels()` - Generate Nim model code
- `generateSqlFromModels()` - Generate SQL from models
- `sqlToNimModels(sqlFile, nimFile)` - Convenience conversion function

#### 3. Example Usage

```nim
import ormin/sql_schema_importer

# Import from SQL file
let importer = importSqlSchema("schema.sql")

# Generate Nim models
let nimCode = importer.generateNimModels()
echo nimCode

# Or convert directly
sqlToNimModels("schema.sql", "models.nim")
```

#### 4. Integration with Existing Ormin Features

The SQL importer integrates seamlessly with:
- Existing model registry system
- Migration system
- Object-oriented model builder API
- DSL-style model definitions

### Files Created/Modified

#### New Files:
1. `z-bornim/ormin/sql_schema_importer.nim` - Main SQL import module
2. `examples/sql_integration/sql_to_nim_example.nim` - Usage examples
3. `docs/sql_integration_guide.md` - Comprehensive documentation
4. `test_sql_integration.nim` - Basic functionality test

#### Enhanced Files:
- `z-bornim/ormin/models.nim` - Already had good foundation for integration

### Testing Results

The implementation was successfully tested with:
- ✅ Basic SQL table parsing
- ✅ Column type mapping
- ✅ Constraint detection (PRIMARY KEY, NOT NULL, DEFAULT)
- ✅ Nim model code generation
- ✅ Integration with existing model system

**Test Output:**
```
=== Testing SQL Integration ===
Tables imported / Импортирани таблици:
- User (4 columns)
- Post (4 columns)

Generated Nim code:
# Generated Nim models from SQL schema
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
discard userModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
userModel.build()
```

### Benefits for Developers

1. **Familiar Workflow**: Use standard SQL DDL statements
2. **Easy Migration**: Import existing SQL schemas
3. **Reduced Learning Curve**: No need to learn new DSL syntax
4. **Database Agnostic**: Works with standard SQL syntax
5. **Bidirectional**: Convert between SQL and Nim representations

---

## Български

### Преглед

Този документ описва подобренията за SQL интеграция, направени в ORM библиотеката Ormin. Тези подобрения позволяват на разработчиците да работят директно с SQL DDL файлове за дефиниране на схеми, което улеснява разработчиците, запознати с SQL, да използват Ormin.

### Какво беше имплементирано

#### 1. Модул за SQL схема импорт (`ormin/sql_schema_importer.nim`)

Цялостен модул, който предоставя:

- **SQL парсиране**: Парсиране на CREATE TABLE заявки от SQL файлове или низове
- **Съпоставяне на типове**: Автоматично конвертиране от SQL типове към Nim/Ormin типове
- **Генериране на модели**: Генериране на Nim модел код от SQL схеми
- **Двупосочна конверсия**: Конвертиране между SQL и Nim модел дефиниции
- **Поддръжка на външни ключове**: Запазване на връзките между таблиците

#### 2. Основни характеристики

**Поддържани SQL типове:**
- INTEGER, INT → dbInt
- FLOAT, REAL, DOUBLE → dbFloat  
- VARCHAR, TEXT → dbVarchar
- CHAR → dbFixedChar
- BOOLEAN, BOOL → dbBool
- TIMESTAMP, DATETIME → dbTimestamp

**Поддържани ограничения:**
- PRIMARY KEY
- NOT NULL
- DEFAULT стойности
- FOREIGN KEY връзки

#### 3. Пример за използване

```nim
import ormin/sql_schema_importer

# Импорт от SQL файл
let importer = importSqlSchema("schema.sql")

# Генериране на Nim модели
let nimCode = importer.generateNimModels()
echo nimCode

# Или директна конверсия
sqlToNimModels("schema.sql", "models.nim")
```

### Резултати от тестването

Имплементацията беше успешно тествана с:
- ✅ Основно SQL таблица парсиране
- ✅ Съпоставяне на типове колони
- ✅ Откриване на ограничения (PRIMARY KEY, NOT NULL, DEFAULT)
- ✅ Генериране на Nim модел код
- ✅ Интеграция със съществуващата модел система

### Предимства за разработчиците

1. **Познат работен процес**: Използване на стандартни SQL DDL заявки
2. **Лесна миграция**: Импортиране на съществуващи SQL схеми
3. **Намалена крива на обучение**: Няма нужда от учене на нов DSL синтаксис
4. **Независим от база данни**: Работи със стандартен SQL синтаксис
5. **Двупосочен**: Конвертиране между SQL и Nim представяния

### Заключение

SQL интеграцията в Ormin е готова за използване и предоставя мощен начин за работа с бази данни, използвайки познатия SQL синтаксис, като същевременно се възползва от предимствата на Nim типовата система и ORM функционалността.