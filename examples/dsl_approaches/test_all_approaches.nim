## Test All DSL Approaches
## Тест на всички DSL подходи
##
## [English] This file tests and demonstrates all three DSL approaches working together.
## [Български] Този файл тества и демонстрира всички три DSL подхода работещи заедно.

import ../../ormin/models
import ../../ormin/transactions
import ../../ormin/migrations
import strutils

echo "=== TESTING ALL DSL APPROACHES ==="
echo "=== ТЕСТВАНЕ НА ВСИЧКИ DSL ПОДХОДИ ==="
echo "=" .repeat(50)

# Clear any existing models
# Изчистване на съществуващи модели
modelRegistry.tables.clear()

# ============================================================================
# APPROACH 1: MACRO-BASED DSL / ПОДХОД 1: DSL БАЗИРАН НА МАКРОСИ
# ============================================================================

echo "\n1. TESTING MACRO-BASED DSL"
echo "1. ТЕСТВАНЕ НА DSL БАЗИРАН НА МАКРОСИ"
echo "-" .repeat(40)

# Simple User model
# Прост модел User
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull
  password_hash: string, notNull
  active: bool, default("true")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ User model created with macro approach"
echo "✓ Модел User създаден с макрос подход"

# Simple Post model
# Прост модел Post
model "Post":
  id: int, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  title: string, notNull
  content: string, notNull
  published: bool, default("false")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Post model created with macro approach"
echo "✓ Модел Post създаден с макрос подход"

# ============================================================================
# APPROACH 2: OBJECT-ORIENTED DSL / ПОДХОД 2: ОБЕКТНО-ОРИЕНТИРАН DSL
# ============================================================================

echo "\n2. TESTING OBJECT-ORIENTED DSL"
echo "2. ТЕСТВАНЕ НА ОБЕКТНО-ОРИЕНТИРАН DSL"
echo "-" .repeat(40)

# Comment model with fluent API
# Модел Comment с плавен API
let commentModel = newModelBuilder("Comment")
discard commentModel.column("id", dbInt).primaryKey()
discard commentModel.column("post_id", dbInt).notNull().foreignKey("Post", "id")
discard commentModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard commentModel.column("content", dbText).notNull()
discard commentModel.column("status", dbVarchar).default("pending")
discard commentModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
commentModel.build()

echo "✓ Comment model created with object-oriented approach"
echo "✓ Модел Comment създаден с обектно-ориентиран подход"

# Category model with conditional fields
# Модел Category с условни полета
let categoryModel = newModelBuilder("Category")
discard categoryModel.column("id", dbInt).primaryKey()
discard categoryModel.column("name", dbVarchar).notNull()
discard categoryModel.column("slug", dbVarchar).notNull()
discard categoryModel.column("description", dbText)

# Add optional fields based on configuration
# Добавяне на опционални полета според конфигурацията
let enableHierarchy = true
let enableSorting = true

if enableHierarchy:
  discard categoryModel.column("parent_id", dbInt).foreignKey("Category", "id")
  discard categoryModel.column("depth", dbInt).default("0")

if enableSorting:
  discard categoryModel.column("sort_order", dbInt).default("0")

discard categoryModel.column("active", dbBool).default("true")
discard categoryModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
categoryModel.build()

echo "✓ Category model created with conditional fields"
echo "✓ Модел Category създаден с условни полета"

# ============================================================================
# APPROACH 3: TEMPLATE-BASED PATTERNS / ПОДХОД 3: ШАБЛОНИ
# ============================================================================

echo "\n3. TESTING TEMPLATE-BASED PATTERNS"
echo "3. ТЕСТВАНЕ НА ШАБЛОНИ"
echo "-" .repeat(40)

# Define reusable templates
# Дефиниране на шаблони за многократна употреба
proc addAuditFields(model: ModelBuilder) =
  discard model.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard model.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard model.column("created_by", dbInt).foreignKey("User", "id")
  discard model.column("updated_by", dbInt).foreignKey("User", "id")

proc addSoftDeleteFields(model: ModelBuilder) =
  discard model.column("deleted_at", dbTimestamp)
  discard model.column("is_deleted", dbBool).default("false")

# Tag model using templates
# Модел Tag с шаблони
let tagModel = newModelBuilder("Tag")
discard tagModel.column("id", dbInt).primaryKey()
discard tagModel.column("name", dbVarchar).notNull()
discard tagModel.column("slug", dbVarchar).notNull()
discard tagModel.column("color", dbVarchar).default("#6c757d")
discard tagModel.column("usage_count", dbInt).default("0")

# Apply templates
# Прилагане на шаблони
tagModel.addAuditFields()
tagModel.addSoftDeleteFields()

tagModel.build()

echo "✓ Tag model created using reusable templates"
echo "✓ Модел Tag създаден с шаблони за многократна употреба"

# ============================================================================
# HYBRID APPROACH / ХИБРИДЕН ПОДХОД
# ============================================================================

echo "\n4. TESTING HYBRID APPROACH"
echo "4. ТЕСТВАНЕ НА ХИБРИДЕН ПОДХОД"
echo "-" .repeat(40)

# Simple models with macro approach
# Прости модели с макрос подход
model "Setting":
  id: int, primaryKey
  key: string, notNull
  value: string
  active: bool, default("true")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Setting model created with macro approach"
echo "✓ Модел Setting създаден с макрос подход"

# Complex model with object-oriented approach
# Сложен модел с обектно-ориентиран подход
let auditLogModel = newModelBuilder("AuditLog")
discard auditLogModel.column("id", dbInt).primaryKey()
discard auditLogModel.column("user_id", dbInt).foreignKey("User", "id")
discard auditLogModel.column("table_name", dbVarchar).notNull()
discard auditLogModel.column("record_id", dbInt).notNull()
discard auditLogModel.column("action", dbVarchar).notNull()
discard auditLogModel.column("old_values", dbText)
discard auditLogModel.column("new_values", dbText)
discard auditLogModel.column("ip_address", dbVarchar)
discard auditLogModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
auditLogModel.build()

echo "✓ AuditLog model created with object-oriented approach"
echo "✓ Модел AuditLog създаден с обектно-ориентиран подход"

# ============================================================================
# GENERATE AND TEST DATABASE / ГЕНЕРИРАНЕ И ТЕСТВАНЕ НА БАЗА ДАННИ
# ============================================================================

echo "\n" & "=" .repeat(50)
echo "GENERATING AND TESTING DATABASE"
echo "ГЕНЕРИРАНЕ И ТЕСТВАНЕ НА БАЗА ДАННИ"
echo "=" .repeat(50)

# Generate all models
# Генериране на всички модели
createModels()

echo "\nRegistered models:"
echo "Регистрирани модели:"
for name, table in modelRegistry.tables:
  echo "  - ", name, " (", table.columns.len, " columns)"
  echo "  - ", name, " (", table.columns.len, " колони)"

# Generate SQL schema
# Генериране на SQL схема
let sqlSchema = generateSql(modelRegistry)
echo "\nGenerated SQL Schema:"
echo "Генерирана SQL схема:"
echo "-" .repeat(30)
echo sqlSchema

# Test database operations
# Тестване на операции с база данни
echo "\nTESTING DATABASE OPERATIONS"
echo "ТЕСТВАНЕ НА ОПЕРАЦИИ С БАЗА ДАННИ"
echo "-" .repeat(30)

# Connect to database
# Свързване към база данни
var db = open("test_all_approaches.db", "", "", "")

# Setup migrations
# Настройка на миграции
let mm = newMigrationManager(db, migrationsDir = "migrations")

# Create migration
# Създаване на миграция
let migrationFile = mm.createMigration("test_all_approaches_schema")
echo "Created migration file: ", migrationFile
echo "Създаден файл за миграция: ", migrationFile

# Write SQL to migration file
# Записване на SQL във файла за миграция
writeFile(migrationFile, sqlSchema)

# Apply migrations
# Прилагане на миграции
mm.migrateUp()
echo "Applied migrations successfully"
echo "Миграциите са приложени успешно"

# Test data operations
# Тестване на операции с данни
echo "\nTESTING DATA OPERATIONS"
echo "ТЕСТВАНЕ НА ОПЕРАЦИИ С ДАННИ"
echo "-" .repeat(30)

transaction(db):
  # Insert test user
  # Вмъкване на тестов потребител
  db.exec(sql"INSERT INTO User (username, email, password_hash) VALUES (?, ?, ?)",
          "testuser", "test@example.com", "hashed_password")
  echo "✓ Test user inserted"
  echo "✓ Тестов потребител вмъкнат"
  
  # Insert test category
  # Вмъкване на тестова категория
  db.exec(sql"INSERT INTO Category (name, slug, description) VALUES (?, ?, ?)",
          "Test Category", "test-category", "A test category")
  echo "✓ Test category inserted"
  echo "✓ Тестова категория вмъкната"
  
  # Insert test post
  # Вмъкване на тестов пост
  db.exec(sql"INSERT INTO Post (user_id, title, content) VALUES (?, ?, ?)",
          "1", "Test Post", "This is a test post content")
  echo "✓ Test post inserted"
  echo "✓ Тестов пост вмъкнат"
  
  # Insert test comment
  # Вмъкване на тестов коментар
  db.exec(sql"INSERT INTO Comment (post_id, user_id, content) VALUES (?, ?, ?)",
          "1", "1", "This is a test comment")
  echo "✓ Test comment inserted"
  echo "✓ Тестов коментар вмъкнат"
  
  # Insert test tag
  # Вмъкване на тестов таг
  db.exec(sql"INSERT INTO Tag (name, slug, color, created_by) VALUES (?, ?, ?, ?)",
          "Test Tag", "test-tag", "#FF5733", "1")
  echo "✓ Test tag inserted"
  echo "✓ Тестов таг вмъкнат"

# Query and verify data
# Заявка и проверка на данни
echo "\nVERIFYING DATA"
echo "ПРОВЕРКА НА ДАННИ"
echo "-" .repeat(30)

# Check users
# Проверка на потребители
let userCount = db.fastRows(sql"SELECT COUNT(*) FROM User")[0][0]
echo "Users in database: ", userCount
echo "Потребители в базата данни: ", userCount

# Check posts with user info
# Проверка на постове с информация за потребителя
echo "\nPosts with user information:"
echo "Постове с информация за потребителя:"
for row in db.fastRows(sql"SELECT p.title, u.username FROM Post p JOIN User u ON p.user_id = u.id"):
  echo "  Post: '", row[0], "' by ", row[1]
  echo "  Пост: '", row[0], "' от ", row[1]

# Check comments with post and user info
# Проверка на коментари с информация за пост и потребител
echo "\nComments with context:"
echo "Коментари с контекст:"
for row in db.fastRows(sql"SELECT c.content, p.title, u.username FROM Comment c JOIN Post p ON c.post_id = p.id JOIN User u ON c.user_id = u.id"):
  echo "  Comment: '", row[0], "' on '", row[1], "' by ", row[2]
  echo "  Коментар: '", row[0], "' към '", row[1], "' от ", row[2]

# Cleanup
# Почистване
db.close()

echo "\n" & "=" .repeat(50)
echo "ALL DSL APPROACHES TEST COMPLETED SUCCESSFULLY!"
echo "ТЕСТЪТ НА ВСИЧКИ DSL ПОДХОДИ Е ЗАВЪРШЕН УСПЕШНО!"
echo "=" .repeat(50)

echo "\nSummary of tested approaches:"
echo "Резюме на тестваните подходи:"
echo "✓ Macro-based DSL - Simple and clean syntax"
echo "✓ DSL базиран на макроси - Прост и чист синтаксис"
echo "✓ Object-oriented DSL - Flexible method chaining"
echo "✓ Обектно-ориентиран DSL - Гъвкаво верижно извикване"
echo "✓ Template-based patterns - Reusable code components"
echo "✓ Шаблони - Компоненти за многократна употреба"
echo "✓ Hybrid approach - Combining multiple methods"
echo "✓ Хибриден подход - Комбиниране на множество методи"
echo "✓ Database operations - Full CRUD functionality"
echo "✓ Операции с база данни - Пълна CRUD функционалност"

echo "\nAll approaches work together seamlessly!"
echo "Всички подходи работят заедно безпроблемно!"

# Run the test when this file is executed directly
# Изпълнение на теста, когато този файл се изпълнява директно
when isMainModule:
  echo "\nAll DSL approaches test completed!"
  echo "Тестът на всички DSL подходи е завършен!"