## Pragma-based DSL Approach Example for Model Definition
## Пример за DSL подход базиран на прагми при дефиниране на модели
##
## [English] This example demonstrates the pragma-based DSL approach to model definition.
## Note: This is a conceptual example showing the intended syntax. The actual pragma
## processing would require more advanced macro implementation.
##
## [Български] Този пример демонстрира DSL подхода базиран на прагми за дефиниране на модели.
## Забележка: Това е концептуален пример, показващ предвидения синтаксис. Действителната
## обработка на прагми би изисквала по-напреднала имплементация на макроси.

import ../../ormin/models
import ../../ormin/transactions
import ../../ormin/migrations
import strutils

echo "=== PRAGMA-BASED DSL APPROACH EXAMPLE ==="
echo "=== ПРИМЕР ЗА DSL ПОДХОД БАЗИРАН НА ПРАГМИ ==="
echo "=" .repeat(50)

echo "\n[English] This example demonstrates the conceptual pragma-based DSL syntax."
echo "[Български] Този пример демонстрира концептуалния синтаксис на DSL базиран на прагми."
echo "\nFor this demonstration, we'll use the standard macro approach"
echo "За тази демонстрация ще използваме стандартния макрос подход"
echo "but show how the pragma syntax would look in comments."
echo "но ще покажем как би изглеждал прагма синтаксисът в коментари."

# ============================================================================
# CONCEPTUAL PRAGMA SYNTAX EXAMPLES / ПРИМЕРИ ЗА КОНЦЕПТУАЛЕН ПРАГМА СИНТАКСИС
# ============================================================================

echo "\n1. CONCEPTUAL PRAGMA SYNTAX"
echo "1. КОНЦЕПТУАЛЕН ПРАГМА СИНТАКСИС"
echo "-" .repeat(40)

echo "\nConceptual User model with rich pragma annotations:"
echo "Концептуален модел User с богати прагма анотации:"
echo """
model "User":
  id {.primaryKey, autoIncrement, comment: "Unique user identifier".}: int
  username {.notNull, unique, indexed, minLength: 3, maxLength: 50,
            comment: "Unique username for login".}: string
  email {.notNull, unique, indexed, maxLength: 255,
          comment: "User email address".}: string
  password_hash {.notNull, minLength: 60, maxLength: 255,
                  comment: "Bcrypt hashed password".}: string
  first_name {.maxLength: 100, comment: "User's first name".}: string
  last_name {.maxLength: 100, comment: "User's last name".}: string
  active {.default: "true", indexed, comment: "Account status".}: bool
  created_at {.default: "CURRENT_TIMESTAMP", indexed,
               comment: "Account creation time".}: timestamp
"""

echo "\nConceptual Article model with comprehensive metadata:"
echo "Концептуален модел Article с цялостни метаданни:"
echo """
model "Article":
  id {.primaryKey, autoIncrement, comment: "Unique article ID".}: int
  title {.notNull, maxLength: 500, indexed,
          comment: "Article title".}: string
  slug {.notNull, unique, indexed, maxLength: 500,
         comment: "URL-friendly identifier".}: string
  content {.notNull, comment: "Article content in HTML".}: text
  status {.default: "draft", indexed, maxLength: 20,
           check: "status IN ('draft', 'published', 'archived')",
           comment: "Publication status".}: string
  view_count {.default: "0", indexed, comment: "View counter".}: int
  featured {.default: "false", indexed, comment: "Featured flag".}: bool
  meta_title {.maxLength: 200, comment: "SEO meta title".}: string
  published_at {.indexed, comment: "Publication timestamp".}: timestamp
"""

# ============================================================================
# ACTUAL WORKING MODELS / ДЕЙСТВИТЕЛНО РАБОТЕЩИ МОДЕЛИ
# ============================================================================

echo "\n2. ACTUAL WORKING MODELS (using standard macro syntax)"
echo "2. ДЕЙСТВИТЕЛНО РАБОТЕЩИ МОДЕЛИ (с стандартен макрос синтаксис)"
echo "-" .repeat(40)

# User model - demonstrating what the pragma syntax would generate
# Модел User - демонстриращ какво би генерирал прагма синтаксисът
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull
  password_hash: string, notNull
  first_name: string
  last_name: string
  display_name: string
  avatar_url: string
  bio: string
  website: string
  location: string
  birth_date: timestamp
  phone: string
  active: bool, default("true")
  email_verified: bool, default("false")
  email_verified_at: timestamp
  two_factor_enabled: bool, default("false")
  two_factor_secret: string
  backup_codes: string
  google_id: string
  facebook_id: string
  github_id: string
  twitter_id: string
  language: string, default("en")
  timezone: string, default("UTC")
  theme: string, default("light")
  notifications_enabled: bool, default("true")
  login_count: int, default("0")
  post_count: int, default("0")
  comment_count: int, default("0")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")
  last_login_at: timestamp
  last_activity_at: timestamp

echo "✓ User model defined (equivalent to rich pragma syntax)"
echo "✓ Модел User дефиниран (еквивалентен на богат прагма синтаксис)"

# Role model with permission management
# Модел Role с управление на разрешения
model "Role":
  id: int, primaryKey
  name: string, notNull
  slug: string, notNull
  description: string
  permissions: string, notNull
  level: int, default("1")
  active: bool, default("true")
  system_role: bool, default("false")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")
  created_by: int, foreignKey("User", "id")

echo "✓ Role model defined with permission management"
echo "✓ Модел Role дефиниран с управление на разрешения"

# Article model with rich content features
# Модел Article с богати функции за съдържание
model "Article":
  id: int, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  category_id: int, foreignKey("Category", "id")
  title: string, notNull
  slug: string, notNull
  excerpt: string
  content: string, notNull
  featured_image_url: string
  status: string, default("draft")
  published_at: timestamp
  view_count: int, default("0")
  like_count: int, default("0")
  comment_count: int, default("0")
  featured: bool, default("false")
  allow_comments: bool, default("true")
  meta_title: string
  meta_description: string
  meta_keywords: string
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Article model defined with comprehensive features"
echo "✓ Модел Article дефиниран с цялостни функции"

# Category model with hierarchical structure
# Модел Category с йерархична структура
model "Category":
  id: int, primaryKey
  name: string, notNull
  slug: string, notNull
  description: string
  parent_id: int, foreignKey("Category", "id")
  color: string, default("#007bff")
  icon: string
  sort_order: int, default("0")
  post_count: int, default("0")
  active: bool, default("true")
  featured: bool, default("false")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Category model defined with hierarchical structure"
echo "✓ Модел Category дефиниран с йерархична структура"

# Comment model with moderation features
# Модел Comment с функции за модерация
model "Comment":
  id: int, primaryKey
  article_id: int, notNull, foreignKey("Article", "id")
  user_id: int, notNull, foreignKey("User", "id")
  parent_id: int, foreignKey("Comment", "id")
  content: string, notNull
  status: string, default("pending")
  approved_by: int, foreignKey("User", "id")
  approved_at: timestamp
  like_count: int, default("0")
  reply_count: int, default("0")
  ip_address: string
  user_agent: string
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Comment model defined with moderation features"
echo "✓ Модел Comment дефиниран с функции за модерация"

# Tag model for content organization
# Модел Tag за организация на съдържанието
model "Tag":
  id: int, primaryKey
  name: string, notNull
  slug: string, notNull
  description: string
  color: string, default("#6c757d")
  usage_count: int, default("0")
  active: bool, default("true")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Tag model defined for content organization"
echo "✓ Модел Tag дефиниран за организация на съдържанието"

# ArticleTag junction table
# Таблица ArticleTag за връзка
model "ArticleTag":
  id: int, primaryKey
  article_id: int, notNull, foreignKey("Article", "id")
  tag_id: int, notNull, foreignKey("Tag", "id")
  created_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ ArticleTag junction table defined"
echo "✓ Таблица ArticleTag за връзка дефинирана"

# Setting model for configuration
# Модел Setting за конфигурация
model "Setting":
  id: int, primaryKey
  key: string, notNull
  value: string
  setting_type: string, default("string")
  description: string
  category: string, default("general")
  is_public: bool, default("false")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
  updated_at: timestamp, default("CURRENT_TIMESTAMP")

echo "✓ Setting model defined for configuration"
echo "✓ Модел Setting дефиниран за конфигурация"

# ============================================================================
# PRAGMA SYNTAX BENEFITS EXPLANATION / ОБЯСНЕНИЕ НА ПРЕДИМСТВАТА НА ПРАГМА СИНТАКСИСА
# ============================================================================

echo "\n3. PRAGMA SYNTAX BENEFITS"
echo "3. ПРЕДИМСТВА НА ПРАГМА СИНТАКСИСА"
echo "-" .repeat(40)

echo "\nThe pragma-based DSL approach would provide:"
echo "DSL подходът базиран на прагми би предоставил:"
echo ""
echo "✓ Self-documenting code with inline comments"
echo "✓ Самодокументиращ код с вградени коментари"
echo ""
echo "✓ Rich metadata support:"
echo "✓ Богата поддръжка на метаданни:"
echo "  - Field length constraints (minLength, maxLength)"
echo "  - Ограничения за дължина на полета (minLength, maxLength)"
echo "  - Validation rules (check constraints)"
echo "  - Правила за валидация (check ограничения)"
echo "  - Index hints (indexed, unique)"
echo "  - Подсказки за индекси (indexed, unique)"
echo "  - Documentation (comment annotations)"
echo "  - Документация (comment анотации)"
echo ""
echo "✓ Declarative constraint definition:"
echo "✓ Декларативно дефиниране на ограничения:"
echo "  - {.check: \"price > 0\".} for business rules"
echo "  - {.check: \"price > 0\".} за бизнес правила"
echo "  - {.foreignKey: (\"Table\", \"column\").} for relationships"
echo "  - {.foreignKey: (\"Table\", \"column\").} за връзки"
echo ""
echo "✓ Enhanced readability:"
echo "✓ Подобрена четимост:"
echo "  - Clear separation of field properties"
echo "  - Ясно разделение на свойствата на полетата"
echo "  - Intuitive syntax for constraints"
echo "  - Интуитивен синтаксис за ограничения"
echo "  - Self-explanatory field definitions"
echo "  - Самообясняващи дефиниции на полета"

# ============================================================================
# COMPARISON WITH OTHER APPROACHES / СРАВНЕНИЕ С ДРУГИ ПОДХОДИ
# ============================================================================

echo "\n4. COMPARISON WITH OTHER APPROACHES"
echo "4. СРАВНЕНИЕ С ДРУГИ ПОДХОДИ"
echo "-" .repeat(40)

echo "\nMacro Approach (current):"
echo "Макрос подход (текущ):"
echo "  username: string, notNull"
echo ""
echo "Pragma Approach (conceptual):"
echo "Прагма подход (концептуален):"
echo "  username {.notNull, unique, maxLength: 50, comment: \"Login name\".}: string"
echo ""
echo "Object-Oriented Approach:"
echo "Обектно-ориентиран подход:"
echo "  discard model.column(\"username\", dbVarchar).notNull().unique().maxLength(50)"
echo ""

echo "Benefits comparison:"
echo "Сравнение на предимствата:"
echo ""
echo "| Feature          | Macro | Pragma | OO    |"
echo "| Функция          | Макрос| Прагма | ОО    |"
echo "|------------------|-------|--------|-------|"
echo "| Simplicity       | ⭐⭐⭐⭐⭐ | ⭐⭐⭐   | ⭐⭐    |"
echo "| Простота         |       |        |       |"
echo "| Readability      | ⭐⭐⭐⭐  | ⭐⭐⭐⭐⭐ | ⭐⭐    |"
echo "| Четимост         |       |        |       |"
echo "| Metadata         | ⭐⭐    | ⭐⭐⭐⭐⭐ | ⭐⭐⭐   |"
echo "| Метаданни        |       |        |       |"
echo "| Flexibility      | ⭐⭐    | ⭐⭐⭐   | ⭐⭐⭐⭐⭐ |"
echo "| Гъвкавост        |       |        |       |"
echo "| Documentation    | ⭐     | ⭐⭐⭐⭐⭐ | ⭐⭐    |"
echo "| Документация     |       |        |       |"

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
var db = open("pragma_dsl_example.db", "", "", "")

# Setup migrations
# Настройка на миграции
let mm = newMigrationManager(db, migrationsDir = "migrations")

# Create migration
# Създаване на миграция
let migrationFile = mm.createMigration("pragma_dsl_schema")
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

# Sample data operations
# Примерни операции с данни
echo "\nSAMPLE DATA OPERATIONS"
echo "ПРИМЕРНИ ОПЕРАЦИИ С ДАННИ"
echo "-" .repeat(30)

transaction(db):
  # Create sample user
  # Създаване на примерен потребител
  db.exec(sql"INSERT INTO User (username, email, password_hash, first_name, last_name) VALUES (?, ?, ?, ?, ?)",
          "pragma_user", "pragma@example.com", "hashed_password", "Pragma", "User")
  
  # Create sample role
  # Създаване на примерна роля
  db.exec(sql"INSERT INTO Role (name, slug, description, permissions) VALUES (?, ?, ?, ?)",
          "Content Editor", "content-editor", "Can create and edit content", "[\"articles.create\", \"articles.edit\"]")
  
  # Create sample category
  # Създаване на примерна категория
  db.exec(sql"INSERT INTO Category (name, slug, description) VALUES (?, ?, ?)",
          "Pragma Examples", "pragma-examples", "Examples demonstrating pragma-based DSL")
  
  # Create sample tag
  # Създаване на примерен таг
  db.exec(sql"INSERT INTO Tag (name, slug, description, color) VALUES (?, ?, ?, ?)",
          "DSL", "dsl", "Domain Specific Language examples", "#FF6B6B")
  
  echo "✓ Sample data created successfully"
  echo "✓ Примерни данни създадени успешно"

# Query sample data
# Заявка за примерни данни
echo "\nQUERYING SAMPLE DATA"
echo "ЗАЯВКА ЗА ПРИМЕРНИ ДАННИ"
echo "-" .repeat(30)

# Get users
# Получаване на потребители
echo "\nUsers:"
echo "Потребители:"
for row in db.fastRows(sql"SELECT id, username, email, first_name, last_name FROM User"):
  echo "  ID: ", row[0], ", Username: ", row[1], ", Email: ", row[2], ", Name: ", row[3], " ", row[4]

# Get roles
# Получаване на роли
echo "\nRoles:"
echo "Роли:"
for row in db.fastRows(sql"SELECT id, name, slug, description FROM Role"):
  echo "  ID: ", row[0], ", Name: ", row[1], ", Slug: ", row[2], ", Description: ", row[3]

# Get categories
# Получаване на категории
echo "\nCategories:"
echo "Категории:"
for row in db.fastRows(sql"SELECT id, name, slug, description FROM Category"):
  echo "  ID: ", row[0], ", Name: ", row[1], ", Slug: ", row[2], ", Description: ", row[3]

# Get tags
# Получаване на тагове
echo "\nTags:"
echo "Тагове:"
for row in db.fastRows(sql"SELECT id, name, slug, description, color FROM Tag"):
  echo "  ID: ", row[0], ", Name: ", row[1], ", Slug: ", row[2], ", Description: ", row[3], ", Color: ", row[4]

# Cleanup
# Почистване
db.close()

echo "\n" & "=" .repeat(50)
echo "PRAGMA-BASED DSL APPROACH EXAMPLE COMPLETED!"
echo "ПРИМЕРЪТ ЗА DSL ПОДХОД БАЗИРАН НА ПРАГМИ Е ЗАВЪРШЕН!"
echo "=" .repeat(50)

echo "\nPragma-based DSL Approach Benefits (Conceptual):"
echo "Предимства на DSL подхода базиран на прагми (концептуални):"
echo "✓ Excellent readability and self-documenting code"
echo "✓ Отлична четимост и самодокументиращ код"
echo "✓ Rich metadata support with comprehensive annotations"
echo "✓ Богата поддръжка на метаданни с цялостни анотации"
echo "✓ Declarative constraint and validation syntax"
echo "✓ Декларативен синтаксис за ограничения и валидация"
echo "✓ Inline documentation with comment pragmas"
echo "✓ Вградена документация с comment прагми"
echo "✓ Clear separation of field properties and constraints"
echo "✓ Ясно разделение на свойства и ограничения на полетата"
echo "✓ Intuitive and expressive model definitions"
echo "✓ Интуитивни и изразителни дефиниции на модели"

echo "\nNote: This example shows the conceptual syntax."
echo "Забележка: Този пример показва концептуалния синтаксис."
echo "Full pragma support would require advanced macro implementation."
echo "Пълната поддръжка на прагми би изисквала напреднала имплементация на макроси."

# Run the example when this file is executed directly
# Изпълнение на примера, когато този файл се изпълнява директно
when isMainModule:
  echo "\nPragma-based DSL approach example completed!"
  echo "Примерът за DSL подход базиран на прагми е завършен!"