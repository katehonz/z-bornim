## Comprehensive DSL Model Definition Example
## Цялостен пример за дефиниране на DSL модели
##
## [English] This example demonstrates three different approaches to model definition:
## 1. Macro-based approach with simple syntax
## 2. Object-oriented approach with method chaining  
## 3. Pragma-based DSL approach for better readability
##
## [Български] Този пример демонстрира три различни подхода за дефиниране на модели:
## 1. Подход базиран на макроси с прост синтаксис
## 2. Обектно-ориентиран подход с верижно извикване на методи
## 3. DSL подход базиран на прагми за по-добра четимост

import ../../ormin/models
import ../../ormin/dsl_models
import ../../ormin/transactions
import ../../ormin/migrations
import strutils, times

echo "=== Comprehensive DSL Model Definition Examples ==="
echo "=== Цялостни примери за дефиниране на DSL модели ==="
echo "=" .repeat(60)

# ============================================================================
# APPROACH 1: MACRO-BASED DSL / ПОДХОД 1: DSL БАЗИРАН НА МАКРОСИ
# ============================================================================

proc demonstrateMacroBasedDSL*() =
  ## [English] Demonstrates the macro-based DSL approach
  ## [Български] Демонстрира подхода с DSL базиран на макроси
  
  echo "\n1. MACRO-BASED DSL APPROACH"
  echo "1. ПОДХОД С DSL БАЗИРАН НА МАКРОСИ"
  echo "-" .repeat(40)
  
  # Simple and clean syntax using the model macro
  # Прост и чист синтаксис с използване на макроса model
  
  # User model with basic fields
  # Модел User с основни полета
  model "User":
    id: int, primaryKey
    username: string, notNull
    email: string, notNull
    password_hash: string, notNull
    first_name: string
    last_name: string
    avatar_url: string
    bio: string
    active: bool, default("true")
    email_verified: bool, default("false")
    created_at: timestamp, default("CURRENT_TIMESTAMP")
    updated_at: timestamp, default("CURRENT_TIMESTAMP")
  
  # Category model for blog posts
  # Модел Category за блог постове
  model "Category":
    id: int, primaryKey
    name: string, notNull
    slug: string, notNull
    description: string
    color: string, default("#007bff")
    icon: string
    parent_id: int, foreignKey("Category", "id")
    sort_order: int, default("0")
    active: bool, default("true")
    created_at: timestamp, default("CURRENT_TIMESTAMP")
  
  # Post model with rich content support
  # Модел Post с поддръжка на богато съдържание
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
  
  echo "✓ Macro-based models defined successfully"
  echo "✓ Моделите базирани на макроси са дефинирани успешно"

# ============================================================================
# APPROACH 2: OBJECT-ORIENTED DSL / ПОДХОД 2: ОБЕКТНО-ОРИЕНТИРАН DSL
# ============================================================================

proc demonstrateObjectOrientedDSL*() =
  ## [English] Demonstrates the object-oriented DSL approach
  ## [Български] Демонстрира обектно-ориентирания DSL подход
  
  echo "\n2. OBJECT-ORIENTED DSL APPROACH"
  echo "2. ОБЕКТНО-ОРИЕНТИРАН DSL ПОДХОД"
  echo "-" .repeat(40)
  
  # Comment model with fluent API
  # Модел Comment с плавен API
  let commentModel = newModelBuilder("Comment")
  discard commentModel.column("id", dbInt).primaryKey()
  discard commentModel.column("post_id", dbInt).notNull().foreignKey("Post", "id")
  discard commentModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
  discard commentModel.column("parent_id", dbInt).foreignKey("Comment", "id")
  discard commentModel.column("content", dbText).notNull()
  discard commentModel.column("status", dbVarchar).default("pending")
  discard commentModel.column("ip_address", dbVarchar)
  discard commentModel.column("user_agent", dbText)
  discard commentModel.column("like_count", dbInt).default("0")
  discard commentModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard commentModel.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  commentModel.build()
  
  # Tag model for content organization
  # Модел Tag за организация на съдържанието
  let tagModel = newModelBuilder("Tag")
  discard tagModel.column("id", dbInt).primaryKey()
  discard tagModel.column("name", dbVarchar).notNull().unique()
  discard tagModel.column("slug", dbVarchar).notNull().unique()
  discard tagModel.column("description", dbText)
  discard tagModel.column("color", dbVarchar).default("#6c757d")
  discard tagModel.column("usage_count", dbInt).default("0")
  discard tagModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  tagModel.build()
  
  # PostTag junction table for many-to-many relationship
  # Таблица PostTag за many-to-many връзка
  let postTagModel = newModelBuilder("PostTag")
  discard postTagModel.column("id", dbInt).primaryKey()
  discard postTagModel.column("post_id", dbInt).notNull().foreignKey("Post", "id")
  discard postTagModel.column("tag_id", dbInt).notNull().foreignKey("Tag", "id")
  discard postTagModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  postTagModel.build()
  
  # Media model for file management
  # Модел Media за управление на файлове
  let mediaModel = newModelBuilder("Media")
  discard mediaModel.column("id", dbInt).primaryKey()
  discard mediaModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
  discard mediaModel.column("filename", dbVarchar).notNull()
  discard mediaModel.column("original_name", dbVarchar).notNull()
  discard mediaModel.column("mime_type", dbVarchar).notNull()
  discard mediaModel.column("file_size", dbInt).notNull()
  discard mediaModel.column("width", dbInt)
  discard mediaModel.column("height", dbInt)
  discard mediaModel.column("alt_text", dbVarchar)
  discard mediaModel.column("caption", dbText)
  discard mediaModel.column("storage_path", dbVarchar).notNull()
  discard mediaModel.column("public_url", dbVarchar)
  discard mediaModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  mediaModel.build()
  
  echo "✓ Object-oriented models defined successfully"
  echo "✓ Обектно-ориентираните модели са дефинирани успешно"

# ============================================================================
# APPROACH 3: PRAGMA-BASED DSL / ПОДХОД 3: DSL БАЗИРАН НА ПРАГМИ
# ============================================================================

proc demonstratePragmaBasedDSL*() =
  ## [English] Demonstrates the pragma-based DSL approach
  ## [Български] Демонстрира подхода с DSL базиран на прагми
  
  echo "\n3. PRAGMA-BASED DSL APPROACH"
  echo "3. DSL ПОДХОД БАЗИРАН НА ПРАГМИ"
  echo "-" .repeat(40)
  
  # Using pragma-based syntax for enhanced readability
  # Използване на синтаксис базиран на прагми за подобрена четимост
  
  # Role model for user permissions
  # Модел Role за потребителски разрешения
  model "Role":
    id {.primaryKey.}: int
    name {.notNull, unique.}: string
    slug {.notNull, unique.}: string
    description: string
    permissions {.notNull.}: string  # JSON array of permissions
    level {.default: "1".}: int
    active {.default: "true".}: bool
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp
    updated_at {.default: "CURRENT_TIMESTAMP".}: timestamp
  
  # UserRole junction table
  # Таблица UserRole за връзка
  model "UserRole":
    id {.primaryKey.}: int
    user_id {.notNull, foreignKey: ("User", "id").}: int
    role_id {.notNull, foreignKey: ("Role", "id").}: int
    assigned_by {.foreignKey: ("User", "id").}: int
    assigned_at {.default: "CURRENT_TIMESTAMP".}: timestamp
    expires_at: timestamp
    active {.default: "true".}: bool
  
  # Settings model for application configuration
  # Модел Settings за конфигурация на приложението
  model "Setting":
    id {.primaryKey.}: int
    key {.notNull, unique.}: string
    value: string
    type {.default: "string".}: string  # string, int, bool, json
    description: string
    category {.default: "general".}: string
    is_public {.default: "false".}: bool
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp
    updated_at {.default: "CURRENT_TIMESTAMP".}: timestamp
  
  # AuditLog model for tracking changes
  # Модел AuditLog за проследяване на промени
  model "AuditLog":
    id {.primaryKey.}: int
    user_id {.foreignKey: ("User", "id").}: int
    table_name {.notNull.}: string
    record_id {.notNull.}: int
    action {.notNull.}: string  # CREATE, UPDATE, DELETE
    old_values: string  # JSON
    new_values: string  # JSON
    ip_address: string
    user_agent: string
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp
  
  echo "✓ Pragma-based models defined successfully"
  echo "✓ Моделите базирани на прагми са дефинирани успешно"

# ============================================================================
# ADVANCED DSL FEATURES / РАЗШИРЕНИ DSL ФУНКЦИИ
# ============================================================================

proc demonstrateAdvancedDSLFeatures*() =
  ## [English] Demonstrates advanced DSL features
  ## [Български] Демонстрира разширени DSL функции
  
  echo "\n4. ADVANCED DSL FEATURES"
  echo "4. РАЗШИРЕНИ DSL ФУНКЦИИ"
  echo "-" .repeat(40)
  
  # Schema definition with multiple models
  # Дефиниция на схема с множество модели
  defineSchema "BlogCMS":
    echo "  - Defining comprehensive blog CMS schema"
    echo "  - Дефиниране на цялостна схема за блог CMS"
    
    # All models are already defined above
    # Всички модели вече са дефинирани по-горе
  
  # Migration example
  # Пример за миграция
  migration "AddUserProfiles":
    echo "  - Creating migration for user profiles"
    echo "  - Създаване на миграция за потребителски профили"
    
    # In a real implementation, this would generate migration SQL
    # В реална имплементация това би генерирало SQL за миграция
  
  # Validation rules
  # Правила за валидация
  validator "User":
    echo "  - Defining validation rules for User model"
    echo "  - Дефиниране на правила за валидация за модел User"
    
    # username validation rules
    # правила за валидация на username
    # required: true, minLength: 3, maxLength: 50, pattern: alphanumeric
  
  # Named queries
  # Именувани заявки
  query "FindActiveUsers":
    echo "  - Defining named query for active users"
    echo "  - Дефиниране на именувана заявка за активни потребители"
    
    # SELECT * FROM User WHERE active = true ORDER BY created_at DESC
  
  # Model relationships
  # Връзки между модели
  relationships "User":
    echo "  - Defining relationships for User model"
    echo "  - Дефиниране на връзки за модел User"
    
    # hasMany Post, hasMany Comment, belongsToMany Role
  
  echo "✓ Advanced DSL features demonstrated successfully"
  echo "✓ Разширените DSL функции са демонстрирани успешно"

# ============================================================================
# HYBRID APPROACH / ХИБРИДЕН ПОДХОД
# ============================================================================

proc demonstrateHybridApproach*() =
  ## [English] Demonstrates combining different DSL approaches
  ## [Български] Демонстрира комбиниране на различни DSL подходи
  
  echo "\n5. HYBRID APPROACH - COMBINING ALL METHODS"
  echo "5. ХИБРИДЕН ПОДХОД - КОМБИНИРАНЕ НА ВСИЧКИ МЕТОДИ"
  echo "-" .repeat(40)
  
  # Core models using macro approach (simple and fast)
  # Основни модели с макрос подход (прости и бързи)
  echo "  Using macro approach for core models:"
  echo "  Използване на макрос подход за основни модели:"
  
  model "Session":
    id: string, primaryKey
    user_id: int, notNull, foreignKey("User", "id")
    ip_address: string, notNull
    user_agent: string
    payload: string, notNull
    last_activity: timestamp, notNull
    expires_at: timestamp, notNull
  
  # Complex models using object-oriented approach
  # Сложни модели с обектно-ориентиран подход
  echo "  Using object-oriented approach for complex models:"
  echo "  Използване на обектно-ориентиран подход за сложни модели:"
  
  let notificationModel = newModelBuilder("Notification")
  discard notificationModel.column("id", dbInt).primaryKey()
  discard notificationModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
  discard notificationModel.column("type", dbVarchar).notNull()
  discard notificationModel.column("title", dbVarchar).notNull()
  discard notificationModel.column("message", dbText).notNull()
  discard notificationModel.column("data", dbText)  # JSON data
  discard notificationModel.column("read_at", dbTimestamp)
  discard notificationModel.column("action_url", dbVarchar)
  discard notificationModel.column("priority", dbVarchar).default("normal")
  discard notificationModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  notificationModel.build()
  
  # Configuration models using pragma approach (readable)
  # Конфигурационни модели с прагма подход (четими)
  echo "  Using pragma approach for configuration models:"
  echo "  Използване на прагма подход за конфигурационни модели:"
  
  model "EmailTemplate":
    id {.primaryKey.}: int
    name {.notNull, unique.}: string
    subject {.notNull.}: string
    body_html {.notNull.}: string
    body_text: string
    variables: string  # JSON array of available variables
    category {.default: "system".}: string
    active {.default: "true".}: bool
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp
    updated_at {.default: "CURRENT_TIMESTAMP".}: timestamp
  
  echo "✓ Hybrid approach demonstrated successfully"
  echo "✓ Хибридният подход е демонстриран успешно"

# ============================================================================
# MAIN EXECUTION / ОСНОВНО ИЗПЪЛНЕНИЕ
# ============================================================================

proc runComprehensiveDSLExample*() =
  ## [English] Runs all DSL approach examples
  ## [Български] Изпълнява всички примери за DSL подходи
  
  try:
    # Demonstrate all approaches
    # Демонстриране на всички подходи
    demonstrateMacroBasedDSL()
    demonstrateObjectOrientedDSL()
    demonstratePragmaBasedDSL()
    demonstrateAdvancedDSLFeatures()
    demonstrateHybridApproach()
    
    # Generate all models
    # Генериране на всички модели
    echo "\n" & "=" .repeat(60)
    echo "GENERATING MODELS AND SQL SCHEMA"
    echo "ГЕНЕРИРАНЕ НА МОДЕЛИ И SQL СХЕМА"
    echo "=" .repeat(60)
    
    createModels()
    
    # Show generated SQL schema
    # Показване на генерираната SQL схема
    echo "\nGenerated SQL Schema:"
    echo "Генерирана SQL схема:"
    echo "-" .repeat(40)
    let sqlSchema = generateSql(modelRegistry)
    echo sqlSchema
    
    # Database operations example
    # Пример за операции с база данни
    echo "\nDATABASE OPERATIONS EXAMPLE"
    echo "ПРИМЕР ЗА ОПЕРАЦИИ С БАЗА ДАННИ"
    echo "-" .repeat(40)
    
    # Connect to database
    # Свързване към база данни
    var db = open("comprehensive_dsl_example.db", "", "", "")
    
    # Setup migrations
    # Настройка на миграции
    let mm = newMigrationManager(db, migrationsDir = "migrations")
    
    # Create migration
    # Създаване на миграция
    let migrationFile = mm.createMigration("comprehensive_dsl_schema")
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
    echo "\nSample data operations:"
    echo "Примерни операции с данни:"
    
    transaction(db):
      # Insert sample user
      # Вмъкване на примерен потребител
      db.exec(sql"INSERT INTO User (username, email, password_hash, first_name, last_name) VALUES (?, ?, ?, ?, ?)",
              "john_doe", "john@example.com", "hashed_password", "John", "Doe")
      echo "  ✓ Sample user created"
      echo "  ✓ Примерен потребител е създаден"
      
      # Insert sample category
      # Вмъкване на примерна категория
      db.exec(sql"INSERT INTO Category (name, slug, description) VALUES (?, ?, ?)",
              "Technology", "technology", "Posts about technology and programming")
      echo "  ✓ Sample category created"
      echo "  ✓ Примерна категория е създадена"
    
    # Query data
    # Заявка за данни
    echo "\nQuerying sample data:"
    echo "Заявка за примерни данни:"
    
    for row in db.fastRows(sql"SELECT id, username, email FROM User LIMIT 5"):
      echo "  User: ID=", row[0], ", Username=", row[1], ", Email=", row[2]
      echo "  Потребител: ID=", row[0], ", Потребителско име=", row[1], ", Имейл=", row[2]
    
    # Cleanup
    # Почистване
    db.close()
    
    echo "\n" & "=" .repeat(60)
    echo "COMPREHENSIVE DSL EXAMPLE COMPLETED SUCCESSFULLY!"
    echo "ЦЯЛОСТНИЯТ DSL ПРИМЕР Е ЗАВЪРШЕН УСПЕШНО!"
    echo "=" .repeat(60)
    
    echo "\nSummary of demonstrated approaches:"
    echo "Резюме на демонстрираните подходи:"
    echo "1. ✓ Macro-based DSL - Simple and clean syntax"
    echo "1. ✓ DSL базиран на макроси - Прост и чист синтаксис"
    echo "2. ✓ Object-oriented DSL - Flexible method chaining"
    echo "2. ✓ Обектно-ориентиран DSL - Гъвкаво верижно извикване"
    echo "3. ✓ Pragma-based DSL - Enhanced readability"
    echo "3. ✓ DSL базиран на прагми - Подобрена четимост"
    echo "4. ✓ Advanced features - Schema, migrations, validation"
    echo "4. ✓ Разширени функции - Схема, миграции, валидация"
    echo "5. ✓ Hybrid approach - Combining all methods"
    echo "5. ✓ Хибриден подход - Комбиниране на всички методи"
    
  except Exception as e:
    echo "Error running comprehensive DSL example: ", e.msg
    echo "Грешка при изпълнение на цялостния DSL пример: ", e.msg

# Run the example when this file is executed directly
# Изпълнение на примера, когато този файл се изпълнява директно
when isMainModule:
  runComprehensiveDSLExample()