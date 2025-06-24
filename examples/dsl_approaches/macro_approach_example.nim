## Macro Approach Example for Model Definition
## Пример за макрос подход при дефиниране на модели
##
## [English] This example demonstrates the macro-based approach to model definition.
## The macro approach is the simplest and most straightforward way to define models
## with clean, readable syntax that's perfect for static model definitions.
##
## [Български] Този пример демонстрира подхода базиран на макроси за дефиниране на модели.
## Макрос подходът е най-простият и най-директният начин за дефиниране на модели
## с чист, четим синтаксис, който е перфектен за статични дефиниции на модели.

import ../../ormin/models
import ../../ormin/transactions
import ../../ormin/migrations
import strutils

echo "=== MACRO APPROACH EXAMPLE ==="
echo "=== ПРИМЕР ЗА МАКРОС ПОДХОД ==="
echo "=" .repeat(50)

# ============================================================================
# BASIC MODELS / ОСНОВНИ МОДЕЛИ
# ============================================================================

echo "\n1. BASIC MODELS DEFINITION"
echo "1. ДЕФИНИРАНЕ НА ОСНОВНИ МОДЕЛИ"
echo "-" .repeat(30)

# User model - Core entity for authentication and user management
# Модел User - Основна единица за автентификация и управление на потребители
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull
  password_hash: string, notNull
  first_name: string
  last_name: string
  active: bool, default("true")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ User model defined with macro approach"
echo "✓ Модел User дефиниран с макрос подход"

# Role model - For user permissions and access control
# Модел Role - За потребителски разрешения и контрол на достъпа
model "Role":
  id: int, primaryKey
  name: string, notNull
  description: string
  permissions: string  # JSON array of permissions
  active: bool, default("true")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Role model defined"
echo "✓ Модел Role дефиниран"

# UserRole junction table - Many-to-many relationship
# Таблица UserRole - Many-to-many връзка
model "UserRole":
  id: int, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  role_id: int, notNull, foreignKey("Role", "id")
  assigned_at: timestamp, default("CURRENT_TIMESTAMP")
  expires_at: timestamp

echo "✓ UserRole junction table defined"
echo "✓ Таблица за връзка UserRole дефинирана"

# ============================================================================
# CONTENT MANAGEMENT MODELS / МОДЕЛИ ЗА УПРАВЛЕНИЕ НА СЪДЪРЖАНИЕ
# ============================================================================

echo "\n2. CONTENT MANAGEMENT MODELS"
echo "2. МОДЕЛИ ЗА УПРАВЛЕНИЕ НА СЪДЪРЖАНИЕ"
echo "-" .repeat(30)

# Category model - For organizing content
# Модел Category - За организиране на съдържание
model "Category":
  id: int, primaryKey
  name: string, notNull
  slug: string, notNull
  description: string
  parent_id: int, foreignKey("Category", "id")
  sort_order: int, default("0")
  active: bool, default("true")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Category model with hierarchical structure"
echo "✓ Модел Category с йерархична структура"

# Post model - Main content entity
# Модел Post - Основна единица за съдържание
model "Post":
  id: int, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  category_id: int, foreignKey("Category", "id")
  title: string, notNull
  slug: string, notNull
  excerpt: string
  content: string, notNull
  featured_image: string
  status: string, default("draft")
  published_at: timestamp
  view_count: int, default("0")
  like_count: int, default("0")
  comment_count: int, default("0")
  featured: bool, default("false")
  allow_comments: bool, default("true")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Post model with rich content features"
echo "✓ Модел Post с богати функции за съдържание"

# Comment model - For user interactions
# Модел Comment - За потребителски взаимодействия
model "Comment":
  id: int, primaryKey
  post_id: int, notNull, foreignKey("Post", "id")
  user_id: int, notNull, foreignKey("User", "id")
  parent_id: int, foreignKey("Comment", "id")
  content: string, notNull
  status: string, default("pending")
  like_count: int, default("0")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Comment model with nested comments support"
echo "✓ Модел Comment с поддръжка на вложени коментари"

# ============================================================================
# TAGGING SYSTEM / СИСТЕМА ЗА ТАГОВЕ
# ============================================================================

echo "\n3. TAGGING SYSTEM MODELS"
echo "3. МОДЕЛИ ЗА СИСТЕМА ОТ ТАГОВЕ"
echo "-" .repeat(30)

# Tag model - For content labeling
# Модел Tag - За етикетиране на съдържание
model "Tag":
  id: int, primaryKey
  name: string, notNull
  slug: string, notNull
  description: string
  color: string, default("#6c757d")
  usage_count: int, default("0")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Tag model for content labeling"
echo "✓ Модел Tag за етикетиране на съдържание"

# PostTag junction table - Many-to-many relationship between posts and tags
# Таблица PostTag - Many-to-many връзка между постове и тагове
model "PostTag":
  id: int, primaryKey
  post_id: int, notNull, foreignKey("Post", "id")
  tag_id: int, notNull, foreignKey("Tag", "id")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ PostTag junction table for many-to-many relationship"
echo "✓ Таблица PostTag за many-to-many връзка"

# ============================================================================
# SYSTEM MODELS / СИСТЕМНИ МОДЕЛИ
# ============================================================================

echo "\n4. SYSTEM MODELS"
echo "4. СИСТЕМНИ МОДЕЛИ"
echo "-" .repeat(30)

# Setting model - For application configuration
# Модел Setting - За конфигурация на приложението
model "Setting":
  id: int, primaryKey
  key: string, notNull
  value: string
  type: string, default("string")
  description: string
  category: string, default("general")
  is_public: bool, default("false")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Setting model for application configuration"
echo "✓ Модел Setting за конфигурация на приложението"

# Session model - For user session management
# Модел Session - За управление на потребителски сесии
model "Session":
  id: string, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  ip_address: string, notNull
  user_agent: string
  payload: string, notNull
  last_activity: timestamp, notNull
  expires_at: timestamp, notNull

echo "✓ Session model for user session management"
echo "✓ Модел Session за управление на потребителски сесии"

# AuditLog model - For tracking system changes
# Модел AuditLog - За проследяване на системни промени
model "AuditLog":
  id: int, primaryKey
  user_id: int, foreignKey("User", "id")
  table_name: string, notNull
  record_id: int, notNull
  action: string, notNull
  old_values: string
  new_values: string
  ip_address: string
  user_agent: string
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ AuditLog model for system change tracking"
echo "✓ Модел AuditLog за проследяване на системни промени"

# ============================================================================
# MEDIA MANAGEMENT / УПРАВЛЕНИЕ НА МЕДИЯ
# ============================================================================

echo "\n5. MEDIA MANAGEMENT MODELS"
echo "5. МОДЕЛИ ЗА УПРАВЛЕНИЕ НА МЕДИЯ"
echo "-" .repeat(30)

# Media model - For file management
# Модел Media - За управление на файлове
model "Media":
  id: int, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  filename: string, notNull
  original_name: string, notNull
  mime_type: string, notNull
  file_size: int, notNull
  width: int
  height: int
  alt_text: string
  caption: string
  storage_path: string, notNull
  public_url: string
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Media model for file management"
echo "✓ Модел Media за управление на файлове"

# MediaUsage model - Track where media files are used
# Модел MediaUsage - Проследяване къде се използват медийни файлове
model "MediaUsage":
  id: int, primaryKey
  media_id: int, notNull, foreignKey("Media", "id")
  entity_type: string, notNull
  entity_id: int, notNull
  usage_type: string, notNull
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ MediaUsage model for tracking media file usage"
echo "✓ Модел MediaUsage за проследяване на използването на медийни файлове"

# ============================================================================
# GENERATE MODELS AND DATABASE OPERATIONS / ГЕНЕРИРАНЕ НА МОДЕЛИ И ОПЕРАЦИИ С БД
# ============================================================================

echo "\n" & "=" .repeat(50)
echo "GENERATING MODELS AND DATABASE OPERATIONS"
echo "ГЕНЕРИРАНЕ НА МОДЕЛИ И ОПЕРАЦИИ С БАЗА ДАННИ"
echo "=" .repeat(50)

# Generate all models
# Генериране на всички модели
createModels()

# Generate SQL schema
# Генериране на SQL схема
let sqlSchema = generateSql(modelRegistry)
echo "\nGenerated SQL Schema:"
echo "Генерирана SQL схема:"
echo "-" .repeat(30)
echo sqlSchema

# Database operations
# Операции с база данни
echo "\nDATABASE OPERATIONS"
echo "ОПЕРАЦИИ С БАЗА ДАННИ"
echo "-" .repeat(30)

# Connect to database
# Свързване към база данни
var db = open("macro_approach_example.db", "", "", "")

# Setup migrations
# Настройка на миграции
let mm = newMigrationManager(db, migrationsDir = "migrations")

# Create migration
# Създаване на миграция
let migrationFile = mm.createMigration("macro_approach_schema")
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

# ============================================================================
# SAMPLE DATA OPERATIONS / ПРИМЕРНИ ОПЕРАЦИИ С ДАННИ
# ============================================================================

echo "\nSAMPLE DATA OPERATIONS"
echo "ПРИМЕРНИ ОПЕРАЦИИ С ДАННИ"
echo "-" .repeat(30)

# Insert sample data using transactions
# Вмъкване на примерни данни с транзакции
transaction(db):
  # Create sample users
  # Създаване на примерни потребители
  db.exec(sql"INSERT INTO User (username, email, password_hash, first_name, last_name) VALUES (?, ?, ?, ?, ?)",
          "admin", "admin@example.com", "hashed_admin_password", "Admin", "User")
  
  db.exec(sql"INSERT INTO User (username, email, password_hash, first_name, last_name) VALUES (?, ?, ?, ?, ?)",
          "john_doe", "john@example.com", "hashed_password", "John", "Doe")
  
  db.exec(sql"INSERT INTO User (username, email, password_hash, first_name, last_name) VALUES (?, ?, ?, ?, ?)",
          "jane_smith", "jane@example.com", "hashed_password", "Jane", "Smith")
  
  echo "✓ Sample users created"
  echo "✓ Примерни потребители създадени"
  
  # Create sample roles
  # Създаване на примерни роли
  db.exec(sql"INSERT INTO Role (name, description, permissions) VALUES (?, ?, ?)",
          "Administrator", "Full system access", "[\"*\"]")
  
  db.exec(sql"INSERT INTO Role (name, description, permissions) VALUES (?, ?, ?)",
          "Editor", "Content management access", "[\"posts.create\", \"posts.edit\", \"posts.delete\"]")
  
  db.exec(sql"INSERT INTO Role (name, description, permissions) VALUES (?, ?, ?)",
          "Author", "Content creation access", "[\"posts.create\", \"posts.edit_own\"]")
  
  echo "✓ Sample roles created"
  echo "✓ Примерни роли създадени"
  
  # Create sample categories
  # Създаване на примерни категории
  db.exec(sql"INSERT INTO Category (name, slug, description) VALUES (?, ?, ?)",
          "Technology", "technology", "Posts about technology and programming")
  
  db.exec(sql"INSERT INTO Category (name, slug, description) VALUES (?, ?, ?)",
          "Lifestyle", "lifestyle", "Posts about lifestyle and personal development")
  
  db.exec(sql"INSERT INTO Category (name, slug, description) VALUES (?, ?, ?)",
          "Business", "business", "Posts about business and entrepreneurship")
  
  echo "✓ Sample categories created"
  echo "✓ Примерни категории създадени"
  
  # Create sample tags
  # Създаване на примерни тагове
  db.exec(sql"INSERT INTO Tag (name, slug, description, color) VALUES (?, ?, ?, ?)",
          "Nim", "nim", "Posts about Nim programming language", "#FFD700")
  
  db.exec(sql"INSERT INTO Tag (name, slug, description, color) VALUES (?, ?, ?, ?)",
          "Database", "database", "Posts about database design and management", "#4169E1")
  
  db.exec(sql"INSERT INTO Tag (name, slug, description, color) VALUES (?, ?, ?, ?)",
          "Tutorial", "tutorial", "Educational posts and tutorials", "#32CD32")
  
  echo "✓ Sample tags created"
  echo "✓ Примерни тагове създадени"

# Query sample data
# Заявка за примерни данни
echo "\nQUERYING SAMPLE DATA"
echo "ЗАЯВКА ЗА ПРИМЕРНИ ДАННИ"
echo "-" .repeat(30)

# Get all users
# Получаване на всички потребители
echo "\nAll users:"
echo "Всички потребители:"
for row in db.fastRows(sql"SELECT id, username, email, first_name, last_name FROM User"):
  echo "  ID: ", row[0], ", Username: ", row[1], ", Email: ", row[2], ", Name: ", row[3], " ", row[4]

# Get all roles
# Получаване на всички роли
echo "\nAll roles:"
echo "Всички роли:"
for row in db.fastRows(sql"SELECT id, name, description FROM Role"):
  echo "  ID: ", row[0], ", Name: ", row[1], ", Description: ", row[2]

# Get all categories
# Получаване на всички категории
echo "\nAll categories:"
echo "Всички категории:"
for row in db.fastRows(sql"SELECT id, name, slug, description FROM Category"):
  echo "  ID: ", row[0], ", Name: ", row[1], ", Slug: ", row[2], ", Description: ", row[3]

# Get all tags
# Получаване на всички тагове
echo "\nAll tags:"
echo "Всички тагове:"
for row in db.fastRows(sql"SELECT id, name, slug, color FROM Tag"):
  echo "  ID: ", row[0], ", Name: ", row[1], ", Slug: ", row[2], ", Color: ", row[3]

# Cleanup
# Почистване
db.close()

echo "\n" & "=" .repeat(50)
echo "MACRO APPROACH EXAMPLE COMPLETED SUCCESSFULLY!"
echo "ПРИМЕРЪТ ЗА МАКРОС ПОДХОД Е ЗАВЪРШЕН УСПЕШНО!"
echo "=" .repeat(50)

echo "\nMacro Approach Benefits Demonstrated:"
echo "Демонстрирани предимства на макрос подхода:"
echo "✓ Simple and clean syntax"
echo "✓ Прост и чист синтаксис"
echo "✓ Minimal code for model definition"
echo "✓ Минимален код за дефиниране на модели"
echo "✓ Easy to read and understand"
echo "✓ Лесен за четене и разбиране"
echo "✓ Perfect for static model definitions"
echo "✓ Перфектен за статични дефиниции на модели"
echo "✓ Fast compilation and execution"
echo "✓ Бърза компилация и изпълнение"

# Run the example when this file is executed directly
# Изпълнение на примера, когато този файл се изпълнява директно
when isMainModule:
  echo "\nMacro approach example completed!"
  echo "Примерът за макрос подход е завършен!"