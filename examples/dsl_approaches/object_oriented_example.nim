## Object-Oriented Approach Example for Model Definition
## Пример за обектно-ориентиран подход при дефиниране на модели
##
## [English] This example demonstrates the object-oriented approach to model definition.
## The OO approach provides maximum flexibility with programmatic control, method chaining,
## and the ability to create models dynamically based on configuration or conditions.
##
## [Български] Този пример демонстрира обектно-ориентирания подход за дефиниране на модели.
## OO подходът предоставя максимална гъвкавост с програмен контрол, верижно извикване на методи
## и възможност за динамично създаване на модели според конфигурация или условия.

import ../../ormin/models
import ../../ormin/dsl_models
import ../../ormin/transactions
import ../../ormin/migrations
import strutils, tables

echo "=== OBJECT-ORIENTED APPROACH EXAMPLE ==="
echo "=== ПРИМЕР ЗА ОБЕКТНО-ОРИЕНТИРАН ПОДХОД ==="
echo "=" .repeat(50)

# ============================================================================
# CONFIGURATION-DRIVEN MODEL CREATION / СЪЗДАВАНЕ НА МОДЕЛИ СПОРЕД КОНФИГУРАЦИЯ
# ============================================================================

echo "\n1. CONFIGURATION-DRIVEN MODEL CREATION"
echo "1. СЪЗДАВАНЕ НА МОДЕЛИ СПОРЕД КОНФИГУРАЦИЯ"
echo "-" .repeat(40)

# Configuration for different features
# Конфигурация за различни функции
type
  SystemConfig = object
    enableUserProfiles: bool
    enableSocialLogin: bool
    enableTwoFactor: bool
    enableAuditLogging: bool
    enableFileUploads: bool
    enableNotifications: bool
    enableComments: bool
    enableRatings: bool

let config = SystemConfig(
  enableUserProfiles: true,
  enableSocialLogin: true,
  enableTwoFactor: false,
  enableAuditLogging: true,
  enableFileUploads: true,
  enableNotifications: true,
  enableComments: true,
  enableRatings: true
)

echo "System configuration loaded:"
echo "Системна конфигурация заредена:"
echo "  - User Profiles: ", config.enableUserProfiles
echo "  - Social Login: ", config.enableSocialLogin
echo "  - Two Factor Auth: ", config.enableTwoFactor
echo "  - Audit Logging: ", config.enableAuditLogging
echo "  - File Uploads: ", config.enableFileUploads
echo "  - Notifications: ", config.enableNotifications
echo "  - Comments: ", config.enableComments
echo "  - Ratings: ", config.enableRatings

# ============================================================================
# DYNAMIC USER MODEL CREATION / ДИНАМИЧНО СЪЗДАВАНЕ НА МОДЕЛ USER
# ============================================================================

echo "\n2. DYNAMIC USER MODEL CREATION"
echo "2. ДИНАМИЧНО СЪЗДАВАНЕ НА МОДЕЛ USER"
echo "-" .repeat(40)

# Create User model with conditional fields based on configuration
# Създаване на модел User с условни полета според конфигурацията
let userModel = newModelBuilder("User")

# Core user fields (always present)
# Основни потребителски полета (винаги присъстват)
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull().unique()
discard userModel.column("email", dbVarchar).notNull().unique().indexed()
discard userModel.column("password_hash", dbVarchar).notNull()
discard userModel.column("active", dbBool).default("true")
discard userModel.column("email_verified", dbBool).default("false")

echo "✓ Core user fields added"
echo "✓ Основни потребителски полета добавени"

# Add profile fields if enabled
# Добавяне на профилни полета, ако са включени
if config.enableUserProfiles:
  discard userModel.column("first_name", dbVarchar)
  discard userModel.column("last_name", dbVarchar)
  discard userModel.column("display_name", dbVarchar)
  discard userModel.column("avatar_url", dbVarchar)
  discard userModel.column("bio", dbText)
  discard userModel.column("website", dbVarchar)
  discard userModel.column("location", dbVarchar)
  discard userModel.column("birth_date", dbTimestamp)
  discard userModel.column("phone", dbVarchar)
  
  echo "✓ User profile fields added"
  echo "✓ Полета за потребителски профил добавени"

# Add social login fields if enabled
# Добавяне на полета за социален вход, ако са включени
if config.enableSocialLogin:
  discard userModel.column("google_id", dbVarchar).unique()
  discard userModel.column("facebook_id", dbVarchar).unique()
  discard userModel.column("github_id", dbVarchar).unique()
  discard userModel.column("twitter_id", dbVarchar).unique()
  
  echo "✓ Social login fields added"
  echo "✓ Полета за социален вход добавени"

# Add two-factor authentication fields if enabled
# Добавяне на полета за двуфакторна автентификация, ако са включени
if config.enableTwoFactor:
  discard userModel.column("two_factor_secret", dbVarchar)
  discard userModel.column("two_factor_enabled", dbBool).default("false")
  discard userModel.column("backup_codes", dbText)
  discard userModel.column("recovery_codes_used", dbInt).default("0")
  
  echo "✓ Two-factor authentication fields added"
  echo "✓ Полета за двуфакторна автентификация добавени"

# Add audit fields (always useful)
# Добавяне на одит полета (винаги полезни)
discard userModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
discard userModel.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
discard userModel.column("last_login_at", dbTimestamp)
discard userModel.column("login_count", dbInt).default("0")

echo "✓ Audit fields added"
echo "✓ Одит полета добавени"

# Build the user model
# Изграждане на модела за потребител
userModel.build()
echo "✓ User model built successfully"
echo "✓ Модел User изграден успешно"

# ============================================================================
# DYNAMIC CONTENT MODELS / ДИНАМИЧНИ МОДЕЛИ ЗА СЪДЪРЖАНИЕ
# ============================================================================

echo "\n3. DYNAMIC CONTENT MODELS"
echo "3. ДИНАМИЧНИ МОДЕЛИ ЗА СЪДЪРЖАНИЕ"
echo "-" .repeat(40)

# Create Article model with conditional features
# Създаване на модел Article с условни функции
let articleModel = newModelBuilder("Article")

# Core article fields
# Основни полета за статия
discard articleModel.column("id", dbInt).primaryKey()
discard articleModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard articleModel.column("title", dbVarchar).notNull().indexed()
discard articleModel.column("slug", dbVarchar).notNull().unique().indexed()
discard articleModel.column("excerpt", dbText)
discard articleModel.column("content", dbText).notNull()
discard articleModel.column("status", dbVarchar).default("draft").indexed()
discard articleModel.column("published_at", dbTimestamp).indexed()
discard articleModel.column("view_count", dbInt).default("0")
discard articleModel.column("featured", dbBool).default("false").indexed()

echo "✓ Core article fields added"
echo "✓ Основни полета за статия добавени"

# Add rating fields if enabled
# Добавяне на полета за рейтинг, ако са включени
if config.enableRatings:
  discard articleModel.column("rating_sum", dbInt).default("0")
  discard articleModel.column("rating_count", dbInt).default("0")
  discard articleModel.column("average_rating", dbFloat).default("0.0")
  
  echo "✓ Rating fields added to Article"
  echo "✓ Полета за рейтинг добавени към Article"

# Add comment count if comments are enabled
# Добавяне на брояч за коментари, ако коментарите са включени
if config.enableComments:
  discard articleModel.column("comment_count", dbInt).default("0")
  discard articleModel.column("allow_comments", dbBool).default("true")
  
  echo "✓ Comment fields added to Article"
  echo "✓ Полета за коментари добавени към Article"

# Add file upload fields if enabled
# Добавяне на полета за качване на файлове, ако са включени
if config.enableFileUploads:
  discard articleModel.column("featured_image_id", dbInt).foreignKey("Media", "id")
  discard articleModel.column("gallery_images", dbText)  # JSON array of media IDs
  discard articleModel.column("attachments", dbText)     # JSON array of media IDs
  
  echo "✓ File upload fields added to Article"
  echo "✓ Полета за качване на файлове добавени към Article"

# Standard audit fields
# Стандартни одит полета
discard articleModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP").indexed()
discard articleModel.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")

articleModel.build()
echo "✓ Article model built successfully"
echo "✓ Модел Article изграден успешно"

# ============================================================================
# CONDITIONAL COMMENT SYSTEM / УСЛОВНА СИСТЕМА ЗА КОМЕНТАРИ
# ============================================================================

if config.enableComments:
  echo "\n4. CONDITIONAL COMMENT SYSTEM"
  echo "4. УСЛОВНА СИСТЕМА ЗА КОМЕНТАРИ"
  echo "-" .repeat(40)
  
  # Create Comment model with advanced features
  # Създаване на модел Comment с разширени функции
  let commentModel = newModelBuilder("Comment")
  
  # Core comment fields
  # Основни полета за коментар
  discard commentModel.column("id", dbInt).primaryKey()
  discard commentModel.column("article_id", dbInt).notNull().foreignKey("Article", "id").indexed()
  discard commentModel.column("user_id", dbInt).notNull().foreignKey("User", "id").indexed()
  discard commentModel.column("parent_id", dbInt).foreignKey("Comment", "id").indexed()
  discard commentModel.column("content", dbText).notNull()
  discard commentModel.column("status", dbVarchar).default("pending").indexed()
  
  # Add rating fields for comments if enabled
  # Добавяне на полета за рейтинг на коментари, ако са включени
  if config.enableRatings:
    discard commentModel.column("like_count", dbInt).default("0")
    discard commentModel.column("dislike_count", dbInt).default("0")
    discard commentModel.column("score", dbInt).default("0")
    
    echo "✓ Rating fields added to Comment"
    echo "✓ Полета за рейтинг добавени към Comment"
  
  # Moderation fields
  # Полета за модерация
  discard commentModel.column("ip_address", dbVarchar)
  discard commentModel.column("user_agent", dbText)
  discard commentModel.column("approved_by", dbInt).foreignKey("User", "id")
  discard commentModel.column("approved_at", dbTimestamp)
  
  # Nested comments support
  # Поддръжка на вложени коментари
  discard commentModel.column("depth", dbInt).default("0")
  discard commentModel.column("path", dbVarchar).indexed()  # Materialized path for nested comments
  discard commentModel.column("reply_count", dbInt).default("0")
  
  # Audit fields
  # Одит полета
  discard commentModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP").indexed()
  discard commentModel.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard commentModel.column("edited_at", dbTimestamp)
  
  commentModel.build()
  echo "✓ Comment model built successfully"
  echo "✓ Модел Comment изграден успешно"

# ============================================================================
# CONDITIONAL MEDIA SYSTEM / УСЛОВНА МЕДИЙНА СИСТЕМА
# ============================================================================

if config.enableFileUploads:
  echo "\n5. CONDITIONAL MEDIA SYSTEM"
  echo "5. УСЛОВНА МЕДИЙНА СИСТЕМА"
  echo "-" .repeat(40)
  
  # Create Media model with advanced file management
  # Създаване на модел Media с разширено управление на файлове
  let mediaModel = newModelBuilder("Media")
  
  # Core media fields
  # Основни медийни полета
  discard mediaModel.column("id", dbInt).primaryKey()
  discard mediaModel.column("user_id", dbInt).notNull().foreignKey("User", "id").indexed()
  discard mediaModel.column("filename", dbVarchar).notNull()
  discard mediaModel.column("original_name", dbVarchar).notNull()
  discard mediaModel.column("mime_type", dbVarchar).notNull().indexed()
  discard mediaModel.column("file_size", dbInt).notNull()
  discard mediaModel.column("file_hash", dbVarchar).unique()  # For deduplication
  
  # Image-specific fields
  # Полета специфични за изображения
  discard mediaModel.column("width", dbInt)
  discard mediaModel.column("height", dbInt)
  discard mediaModel.column("alt_text", dbVarchar)
  discard mediaModel.column("caption", dbText)
  
  # Storage information
  # Информация за съхранение
  discard mediaModel.column("storage_driver", dbVarchar).default("local")
  discard mediaModel.column("storage_path", dbVarchar).notNull()
  discard mediaModel.column("public_url", dbVarchar)
  discard mediaModel.column("cdn_url", dbVarchar)
  
  # Metadata
  # Метаданни
  discard mediaModel.column("metadata", dbText)  # JSON metadata
  discard mediaModel.column("exif_data", dbText)  # EXIF data for images
  
  # Usage tracking
  # Проследяване на използването
  discard mediaModel.column("usage_count", dbInt).default("0")
  discard mediaModel.column("download_count", dbInt).default("0")
  discard mediaModel.column("last_accessed", dbTimestamp)
  
  # Audit fields
  # Одит полета
  discard mediaModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP").indexed()
  discard mediaModel.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  
  mediaModel.build()
  echo "✓ Media model built successfully"
  echo "✓ Модел Media изграден успешно"
  
  # Create MediaUsage tracking model
  # Създаване на модел MediaUsage за проследяване
  let mediaUsageModel = newModelBuilder("MediaUsage")
  discard mediaUsageModel.column("id", dbInt).primaryKey()
  discard mediaUsageModel.column("media_id", dbInt).notNull().foreignKey("Media", "id").indexed()
  discard mediaUsageModel.column("entity_type", dbVarchar).notNull().indexed()
  discard mediaUsageModel.column("entity_id", dbInt).notNull().indexed()
  discard mediaUsageModel.column("usage_type", dbVarchar).notNull()  # featured, gallery, attachment, etc.
  discard mediaUsageModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  
  mediaUsageModel.build()
  echo "✓ MediaUsage model built successfully"
  echo "✓ Модел MediaUsage изграден успешно"

# ============================================================================
# CONDITIONAL NOTIFICATION SYSTEM / УСЛОВНА СИСТЕМА ЗА ИЗВЕСТИЯ
# ============================================================================

if config.enableNotifications:
  echo "\n6. CONDITIONAL NOTIFICATION SYSTEM"
  echo "6. УСЛОВНА СИСТЕМА ЗА ИЗВЕСТИЯ"
  echo "-" .repeat(40)
  
  # Create Notification model
  # Създаване на модел Notification
  let notificationModel = newModelBuilder("Notification")
  
  # Core notification fields
  # Основни полета за известие
  discard notificationModel.column("id", dbInt).primaryKey()
  discard notificationModel.column("user_id", dbInt).notNull().foreignKey("User", "id").indexed()
  discard notificationModel.column("type", dbVarchar).notNull().indexed()
  discard notificationModel.column("title", dbVarchar).notNull()
  discard notificationModel.column("message", dbText).notNull()
  discard notificationModel.column("data", dbText)  # JSON data
  
  # Notification state
  # Състояние на известието
  discard notificationModel.column("read_at", dbTimestamp).indexed()
  discard notificationModel.column("action_url", dbVarchar)
  discard notificationModel.column("priority", dbVarchar).default("normal").indexed()
  
  # Delivery tracking
  # Проследяване на доставката
  discard notificationModel.column("sent_at", dbTimestamp)
  discard notificationModel.column("delivery_method", dbVarchar)  # email, push, sms, etc.
  discard notificationModel.column("delivery_status", dbVarchar).default("pending")
  
  # Audit fields
  # Одит полета
  discard notificationModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP").indexed()
  discard notificationModel.column("expires_at", dbTimestamp).indexed()
  
  notificationModel.build()
  echo "✓ Notification model built successfully"
  echo "✓ Модел Notification изграден успешно"

# ============================================================================
# CONDITIONAL AUDIT LOGGING / УСЛОВНО ОДИТ ЛОГВАНЕ
# ============================================================================

if config.enableAuditLogging:
  echo "\n7. CONDITIONAL AUDIT LOGGING"
  echo "7. УСЛОВНО ОДИТ ЛОГВАНЕ"
  echo "-" .repeat(40)
  
  # Create comprehensive AuditLog model
  # Създаване на цялостен модел AuditLog
  let auditLogModel = newModelBuilder("AuditLog")
  
  # Core audit fields
  # Основни одит полета
  discard auditLogModel.column("id", dbInt).primaryKey()
  discard auditLogModel.column("user_id", dbInt).foreignKey("User", "id").indexed()
  discard auditLogModel.column("session_id", dbVarchar).indexed()
  
  # Entity information
  # Информация за обекта
  discard auditLogModel.column("table_name", dbVarchar).notNull().indexed()
  discard auditLogModel.column("record_id", dbInt).notNull().indexed()
  discard auditLogModel.column("action", dbVarchar).notNull().indexed()  # CREATE, UPDATE, DELETE
  
  # Change tracking
  # Проследяване на промените
  discard auditLogModel.column("old_values", dbText)  # JSON of old values
  discard auditLogModel.column("new_values", dbText)  # JSON of new values
  discard auditLogModel.column("changed_fields", dbText)  # JSON array of changed field names
  
  # Request context
  # Контекст на заявката
  discard auditLogModel.column("ip_address", dbVarchar).indexed()
  discard auditLogModel.column("user_agent", dbText)
  discard auditLogModel.column("request_url", dbVarchar)
  discard auditLogModel.column("request_method", dbVarchar)
  
  # Additional metadata
  # Допълнителни метаданни
  discard auditLogModel.column("tags", dbText)  # JSON array of tags
  discard auditLogModel.column("metadata", dbText)  # Additional JSON metadata
  
  # Timestamp
  # Времева отметка
  discard auditLogModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP").indexed()
  
  auditLogModel.build()
  echo "✓ AuditLog model built successfully"
  echo "✓ Модел AuditLog изграден успешно"

# ============================================================================
# TEMPLATE-BASED MODEL CREATION / СЪЗДАВАНЕ НА МОДЕЛИ БАЗИРАНО НА ШАБЛОНИ
# ============================================================================

echo "\n8. TEMPLATE-BASED MODEL CREATION"
echo "8. СЪЗДАВАНЕ НА МОДЕЛИ БАЗИРАНО НА ШАБЛОНИ"
echo "-" .repeat(40)

# Define reusable templates
# Дефиниране на шаблони за многократна употреба
proc addTimestampFields(model: ModelBuilder) =
  ## Add standard timestamp fields to a model
  ## Добавяне на стандартни полета за време към модел
  discard model.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP").indexed()
  discard model.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")

proc addSoftDeleteFields(model: ModelBuilder) =
  ## Add soft delete fields to a model
  ## Добавяне на полета за мек delete към модел
  discard model.column("deleted_at", dbTimestamp).indexed()
  discard model.column("deleted_by", dbInt).foreignKey("User", "id")
  discard model.column("is_deleted", dbBool).default("false").indexed()

proc addSortableFields(model: ModelBuilder) =
  ## Add sortable fields to a model
  ## Добавяне на полета за сортиране към модел
  discard model.column("sort_order", dbInt).default("0").indexed()
  discard model.column("weight", dbInt).default("0")

proc addStatusFields(model: ModelBuilder) =
  ## Add status fields to a model
  ## Добавяне на полета за статус към модел
  discard model.column("status", dbVarchar).default("active").indexed()
  discard model.column("active", dbBool).default("true").indexed()

# Create Category model using templates
# Създаване на модел Category с шаблони
let categoryModel = newModelBuilder("Category")
discard categoryModel.column("id", dbInt).primaryKey()
discard categoryModel.column("name", dbVarchar).notNull().indexed()
discard categoryModel.column("slug", dbVarchar).notNull().unique().indexed()
discard categoryModel.column("description", dbText)
discard categoryModel.column("parent_id", dbInt).foreignKey("Category", "id").indexed()
discard categoryModel.column("color", dbVarchar).default("#007bff")
discard categoryModel.column("icon", dbVarchar)

# Apply templates
# Прилагане на шаблони
categoryModel.addTimestampFields()
categoryModel.addSoftDeleteFields()
categoryModel.addSortableFields()
categoryModel.addStatusFields()

categoryModel.build()
echo "✓ Category model built with templates"
echo "✓ Модел Category изграден с шаблони"

# Create Tag model using templates
# Създаване на модел Tag с шаблони
let tagModel = newModelBuilder("Tag")
discard tagModel.column("id", dbInt).primaryKey()
discard tagModel.column("name", dbVarchar).notNull().unique().indexed()
discard tagModel.column("slug", dbVarchar).notNull().unique().indexed()
discard tagModel.column("description", dbText)
discard tagModel.column("color", dbVarchar).default("#6c757d")
discard tagModel.column("usage_count", dbInt).default("0").indexed()

# Apply templates
# Прилагане на шаблони
tagModel.addTimestampFields()
tagModel.addStatusFields()

tagModel.build()
echo "✓ Tag model built with templates"
echo "✓ Модел Tag изграден с шаблони"

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
var db = open("object_oriented_example.db", "", "", "")

# Setup migrations
# Настройка на миграции
let mm = newMigrationManager(db, migrationsDir = "migrations")

# Create migration
# Създаване на миграция
let migrationFile = mm.createMigration("object_oriented_schema")
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

# Cleanup
# Почистване
db.close()

echo "\n" & "=" .repeat(50)
echo "OBJECT-ORIENTED APPROACH EXAMPLE COMPLETED!"
echo "ПРИМЕРЪТ ЗА ОБЕКТНО-ОРИЕНТИРАН ПОДХОД Е ЗАВЪРШЕН!"
echo "=" .repeat(50)

echo "\nObject-Oriented Approach Benefits Demonstrated:"
echo "Демонстрирани предимства на обектно-ориентирания подход:"
echo "✓ Maximum flexibility and programmatic control"
echo "✓ Максимална гъвкавост и програмен контрол"
echo "✓ Configuration-driven model generation"
echo "✓ Генериране на модели според конфигурация"
echo "✓ Conditional field addition based on features"
echo "✓ Условно добавяне на полета според функции"
echo "✓ Reusable templates and patterns"
echo "✓ Шаблони и шаблони за многократна употреба"
echo "✓ Dynamic schema adaptation"
echo "✓ Динамична адаптация на схемата"
echo "✓ Method chaining for fluent API"
echo "✓ Верижно извикване на методи за плавен API"

# Run the example when this file is executed directly
# Изпълнение на примера, когато този файл се изпълнява директно
when isMainModule:
  echo "\nObject-oriented approach example completed!"
  echo "Примерът за обектно-ориентиран подход е завършен!"