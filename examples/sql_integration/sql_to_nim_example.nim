## Ormin SQL Integration Example
## Пример за SQL интеграция в Ormin
##
## [English]
## This example demonstrates how to use the SQL schema importer to convert
## SQL DDL statements directly into Nim model definitions.
##
## [Български] 
## Този пример демонстрира как да използвате SQL схема импортера за конвертиране
## на SQL DDL заявки директно в дефиниции на Nim модели.

import ../../ormin/sql_schema_importer
import ../../ormin/models
import os

proc demonstrateSqlImport*() =
  echo "=== SQL Schema Import Demonstration ==="
  echo "=== Демонстрация на SQL схема импорт ==="
  echo ""
  
  # Create a sample SQL schema
  let sampleSqlSchema = """
  -- User table for authentication
  -- Таблица за потребители за автентикация
  CREATE TABLE IF NOT EXISTS User (
    id INTEGER PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
  );
  
  -- Posts table for user content
  -- Таблица за публикации на потребителите
  CREATE TABLE IF NOT EXISTS Post (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    slug VARCHAR(250) NOT NULL,
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(id)
  );
  
  -- Comments table for post discussions
  -- Таблица за коментари към публикациите
  CREATE TABLE IF NOT EXISTS Comment (
    id INTEGER PRIMARY KEY,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Post(id),
    FOREIGN KEY (user_id) REFERENCES User(id)
  );
  
  -- Tags table for categorization
  -- Таблица за тагове за категоризация
  CREATE TABLE IF NOT EXISTS Tag (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  
  -- Many-to-many relationship between posts and tags
  -- Много-към-много връзка между публикации и тагове
  CREATE TABLE IF NOT EXISTS PostTag (
    post_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES Post(id),
    FOREIGN KEY (tag_id) REFERENCES Tag(id)
  );
  """
  
  # Create the SQL schema importer
  echo "Creating SQL schema importer..."
  echo "Създаване на SQL схема импортер..."
  let importer = newSqlSchemaImporter()
  
  # Import the schema from string
  echo "Importing schema from SQL..."
  echo "Импортиране на схема от SQL..."
  importer.importFromString(sampleSqlSchema)
  
  # Display imported tables
  echo "\nImported tables / Импортирани таблици:"
  for tableName, table in importer.tables:
    echo "- " & tableName & " (" & $table.columns.len & " columns / колони)"
  
  # Generate Nim model code
  echo "\n=== Generated Nim Models ==="
  echo "=== Генерирани Nim модели ==="
  let nimCode = importer.generateNimModels()
  echo nimCode
  
  # Generate SQL back from models (for verification)
  echo "\n=== Generated SQL (for verification) ==="
  echo "=== Генериран SQL (за проверка) ==="
  let sqlCode = importer.generateSqlFromModels()
  echo sqlCode

proc demonstrateFileImport*() =
  echo "\n=== File Import Demonstration ==="
  echo "=== Демонстрация на импорт от файл ==="
  
  # Create a sample SQL file
  let sqlFilePath = "sample_schema.sql"
  let sampleContent = """
  CREATE TABLE IF NOT EXISTS Product (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    category_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Category(id)
  );
  
  CREATE TABLE IF NOT EXISTS Category (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    parent_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES Category(id)
  );
  """
  
  # Write the sample SQL file
  writeFile(sqlFilePath, sampleContent)
  echo "Created sample SQL file: " & sqlFilePath
  echo "Създаден примерен SQL файл: " & sqlFilePath
  
  try:
    # Import from file
    let importer = importSqlSchema(sqlFilePath)
    
    echo "\nTables imported from file / Таблици импортирани от файл:"
    for tableName, table in importer.tables:
      echo "- " & tableName
      for column in table.columns:
        echo "  * " & column.name & ": " & column.sqlType
    
    # Generate Nim models and save to file
    let nimModelsPath = "generated_models.nim"
    sqlToNimModels(sqlFilePath, nimModelsPath)
    
  finally:
    # Clean up
    if fileExists(sqlFilePath):
      removeFile(sqlFilePath)
      echo "Cleaned up sample file / Почистен примерен файл: " & sqlFilePath
    
    let nimModelsPath = "generated_models.nim"
    if fileExists(nimModelsPath):
      removeFile(nimModelsPath)
      echo "Cleaned up generated file / Почистен генериран файл: " & nimModelsPath

proc demonstrateAdvancedFeatures*() =
  echo "\n=== Advanced Features Demonstration ==="
  echo "=== Демонстрация на разширени функции ==="
  
  let complexSql = """
  -- Complex table with various constraints
  -- Сложна таблица с различни ограничения
  CREATE TABLE IF NOT EXISTS Order (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_number VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    shipping_address TEXT,
    billing_address TEXT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customer(id)
  );
  
  CREATE TABLE IF NOT EXISTS Customer (
    id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_premium BOOLEAN DEFAULT FALSE,
    loyalty_points INTEGER DEFAULT 0
  );
  """
  
  let importer = newSqlSchemaImporter()
  importer.importFromString(complexSql)
  
  echo "Complex schema imported successfully!"
  echo "Сложна схема импортирана успешно!"
  
  echo "\nType mappings demonstration / Демонстрация на съпоставяне на типове:"
  for tableName, table in importer.tables:
    echo "\nTable: " & tableName
    for column in table.columns:
      let dbType = mapSqlTypeToDbType(column.sqlType)
      echo "  " & column.name & ": " & column.sqlType & " -> " & $dbType

when isMainModule:
  echo "Ormin SQL Integration Examples"
  echo "Примери за SQL интеграция в Ormin"
  echo "================================="
  
  demonstrateSqlImport()
  demonstrateFileImport()
  demonstrateAdvancedFeatures()
  
  echo "\n=== Summary / Резюме ==="
  echo "✓ SQL schema parsing / SQL схема парсиране"
  echo "✓ Automatic type mapping / Автоматично съпоставяне на типове"
  echo "✓ Nim model generation / Генериране на Nim модели"
  echo "✓ File import/export / Импорт/експорт от файлове"
  echo "✓ Foreign key relationships / Връзки с външни ключове"
  echo ""
  echo "The SQL integration is ready for use!"
  echo "SQL интеграцията е готова за използване!"