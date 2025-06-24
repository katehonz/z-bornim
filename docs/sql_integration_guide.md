# Ormin SQL Integration Guide
# Ръководство за SQL интеграция в Ormin

## English

### Overview

The Ormin SQL Integration feature allows developers to define their database schemas using standard SQL DDL (Data Definition Language) statements and automatically generate corresponding Nim model definitions. This approach is particularly beneficial for developers who are already familiar with SQL and prefer to work with SQL files directly.

### Key Benefits

1. **Familiar Syntax**: Use standard SQL CREATE TABLE statements
2. **Direct Import**: Import existing SQL schema files
3. **Automatic Type Mapping**: SQL types are automatically mapped to Nim types
4. **Foreign Key Support**: Relationships between tables are preserved
5. **Bidirectional Conversion**: Generate SQL from models and models from SQL

### Getting Started

#### Basic Usage

```nim
import ormin/sql_schema_importer

# Create an importer
let importer = newSqlSchemaImporter()

# Import from SQL string
let sqlSchema = """
CREATE TABLE User (
  id INTEGER PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL
);
"""

importer.importFromString(sqlSchema)

# Generate Nim models
let nimCode = importer.generateNimModels()
echo nimCode
```

#### Import from File

```nim
# Import directly from SQL file
let importer = importSqlSchema("schema.sql")

# Convert SQL file to Nim models file
sqlToNimModels("schema.sql", "models.nim")
```

### Supported SQL Features

#### Column Types

| SQL Type | Nim Type | DbTypeKind |
|----------|----------|------------|
| INTEGER, INT | int | dbInt |
| FLOAT, REAL, DOUBLE | float | dbFloat |
| VARCHAR, TEXT | string | dbVarchar |
| CHAR | string | dbFixedChar |
| BOOLEAN, BOOL | bool | dbBool |
| TIMESTAMP, DATETIME | DateTime | dbTimestamp |

#### Constraints

- **PRIMARY KEY**: Automatically detected and mapped
- **NOT NULL**: Preserved in model definition
- **DEFAULT**: Default values are maintained
- **FOREIGN KEY**: Relationships are preserved and mapped

#### Example Schema

```sql
CREATE TABLE IF NOT EXISTS User (
  id INTEGER PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS Post (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES User(id)
);
```

#### Generated Nim Code

```nim
# Generated Nim models from SQL schema

import ormin/models

# Model for table: User
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
discard userModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
discard userModel.column("is_active", dbBool).default("TRUE")
userModel.build()

# Model for table: Post
let postModel = newModelBuilder("Post")
discard postModel.column("id", dbInt).primaryKey()
discard postModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard postModel.column("title", dbVarchar).notNull()
discard postModel.column("content", dbVarchar)
discard postModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
postModel.build()
```

### Advanced Features

#### Complex Relationships

```sql
-- Many-to-many relationship example
CREATE TABLE PostTag (
  post_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  PRIMARY KEY (post_id, tag_id),
  FOREIGN KEY (post_id) REFERENCES Post(id),
  FOREIGN KEY (tag_id) REFERENCES Tag(id)
);
```

#### Self-Referencing Tables

```sql
CREATE TABLE Category (
  id INTEGER PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  parent_id INTEGER,
  FOREIGN KEY (parent_id) REFERENCES Category(id)
);
```

### API Reference

#### SqlSchemaImporter

- `newSqlSchemaImporter()`: Creates a new importer instance
- `importFromFile(filepath: string)`: Imports schema from SQL file
- `importFromString(sql: string)`: Imports schema from SQL string
- `generateNimModels()`: Generates Nim model code
- `generateSqlFromModels()`: Generates SQL from imported models

#### Utility Functions

- `importSqlSchema(filepath: string)`: Convenience function for file import
- `sqlToNimModels(sqlFile, nimFile: string)`: Convert SQL file to Nim models
- `mapSqlTypeToDbType(sqlType: string)`: Map SQL type to DbTypeKind

---

## Български

### Преглед

Функцията за SQL интеграция в Ormin позволява на разработчиците да дефинират схемите на своите бази данни, използвайки стандартни SQL DDL (Data Definition Language) заявки и автоматично да генерират съответните дефиниции на модели в Nim. Този подход е особено полезен за разработчици, които вече са запознати с SQL и предпочитат да работят директно с SQL файлове.

### Основни предимства

1. **Познат синтаксис**: Използване на стандартни SQL CREATE TABLE заявки
2. **Директен импорт**: Импортиране на съществуващи SQL схема файлове
3. **Автоматично съпоставяне на типове**: SQL типовете се съпоставят автоматично с Nim типове
4. **Поддръжка на външни ключове**: Връзките между таблиците се запазват
5. **Двупосочна конверсия**: Генериране на SQL от модели и модели от SQL

### Започване на работа

#### Основно използване

```nim
import ormin/sql_schema_importer

# Създаване на импортер
let importer = newSqlSchemaImporter()

# Импорт от SQL низ
let sqlSchema = """
CREATE TABLE User (
  id INTEGER PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL
);
"""

importer.importFromString(sqlSchema)

# Генериране на Nim модели
let nimCode = importer.generateNimModels()
echo nimCode
```

#### Импорт от файл

```nim
# Директен импорт от SQL файл
let importer = importSqlSchema("schema.sql")

# Конвертиране на SQL файл в Nim модели файл
sqlToNimModels("schema.sql", "models.nim")
```

### Поддържани SQL функции

#### Типове колони

| SQL Тип | Nim Тип | DbTypeKind |
|---------|---------|------------|
| INTEGER, INT | int | dbInt |
| FLOAT, REAL, DOUBLE | float | dbFloat |
| VARCHAR, TEXT | string | dbVarchar |
| CHAR | string | dbFixedChar |
| BOOLEAN, BOOL | bool | dbBool |
| TIMESTAMP, DATETIME | DateTime | dbTimestamp |

#### Ограничения

- **PRIMARY KEY**: Автоматично откриване и съпоставяне
- **NOT NULL**: Запазване в дефиницията на модела
- **DEFAULT**: Стойностите по подразбиране се поддържат
- **FOREIGN KEY**: Връзките се запазват и съпоставят

### Примери за използване

Вижте файла `examples/sql_integration/sql_to_nim_example.nim` за подробни примери за използване.

### Интеграция с миграции

SQL интеграцията работи отлично с системата за миграции на Ormin:

```nim
# Създаване на миграция от SQL схема
let importer = importSqlSchema("new_schema.sql")
let migrationSql = importer.generateSqlFromModels()

# Записване в миграционен файл
let migrationManager = newMigrationManager(db)
let migrationFile = migrationManager.createMigration("add_new_tables")
writeFile(migrationFile, migrationSql)
```

### Съвети за най-добри практики

1. **Използвайте описателни имена**: Използвайте ясни и описателни имена за таблици и колони
2. **Документирайте схемата**: Добавяйте коментари в SQL файловете
3. **Версионирайте схемите**: Използвайте система за контрол на версиите за SQL файловете
4. **Тествайте конверсиите**: Винаги тествайте генерираните модели
5. **Използвайте миграции**: Комбинирайте с системата за миграции за управление на промените

### Ограничения

- Сложни SQL конструкции като VIEWS, TRIGGERS и PROCEDURES не се поддържат
- Някои специфични за база данни типове може да не се съпоставят правилно
- Индексите се разпознават, но не се генерират в Nim кода

### Бъдещи подобрения

- Поддръжка за повече SQL типове данни
- Генериране на индекси в Nim кода
- Поддръжка за SQL VIEWS
- Подобрено парсиране на сложни ограничения
- Интеграция с различни бази данни (PostgreSQL, MySQL, etc.)