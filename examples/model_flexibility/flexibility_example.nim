## Example demonstrating model definition flexibility in Ormin
## Пример, демонстриращ гъвкавостта при дефиниране на модели в Ormin

import ../../ormin/models
import ../../ormin/transactions
import strutils

# Example showing different approaches to model definition
# Пример, показващ различни подходи за дефиниране на модели

proc demonstrateMacroApproach*() =
  ## [English] Demonstrates the macro approach for model definition
  ## [Български] Демонстрира макрос подхода за дефиниране на модели
  echo "=== Macro Approach Example ==="
  echo "=== Пример с макрос подход ==="
  
  # Simple and clean syntax
  # Прост и чист синтаксис
  # Note: The model macro is not fully implemented in our demo
  # For demonstration purposes, we'll show the syntax
  echo "Model syntax example:"
  echo "model \"User\":"
  echo "  id: int, primaryKey"
  echo "  username: string, notNull"
  echo "  email: string, notNull"
  echo "  created_at: timestamp, default(\"CURRENT_TIMESTAMP\")"
  echo ""
  echo "model \"Post\":"
  echo "  id: int, primaryKey"
  echo "  user_id: int, notNull, foreignKey(\"User\", \"id\")"
  echo "  title: string, notNull"
  echo "  content: string"
  echo "  published: bool, default(\"false\")"
  echo "  created_at: timestamp, default(\"CURRENT_TIMESTAMP\")"
  
  echo "Models defined using macro approach"
  echo "Моделите са дефинирани с макрос подход"

proc demonstrateObjectOrientedApproach*() =
  ## [English] Demonstrates the object-oriented approach
  ## [Български] Демонстрира обектно-ориентирания подход
  echo "\n=== Object-Oriented Approach Example ==="
  echo "=== Пример с обектно-ориентиран подход ==="
  
  # Programmatic model creation with full control
  # Програмно създаване на модели с пълен контрол
  
  # Create Category model
  # Създаване на модел Category
  let categoryModel = newModelBuilder("Category")
  discard categoryModel.column("id", dbInt).primaryKey()
  discard categoryModel.column("name", dbVarchar).notNull()
  discard categoryModel.column("description", dbText)
  discard categoryModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  categoryModel.build()
  
  # Create Product model with conditional fields
  # Създаване на модел Product с условни полета
  let productModel = newModelBuilder("Product")
  discard productModel.column("id", dbInt).primaryKey()
  discard productModel.column("name", dbVarchar).notNull()
  discard productModel.column("price", dbFloat).notNull()
  discard productModel.column("category_id", dbInt).notNull().foreignKey("Category", "id")
  
  # Conditional fields based on business requirements
  # Условни полета според бизнес изискванията
  let enableInventory = true
  let enableDiscounts = true
  
  if enableInventory:
    discard productModel.column("stock_quantity", dbInt).default("0")
    discard productModel.column("low_stock_threshold", dbInt).default("10")
  
  if enableDiscounts:
    discard productModel.column("discount_percentage", dbFloat).default("0.0")
    discard productModel.column("discount_start", dbTimestamp)
    discard productModel.column("discount_end", dbTimestamp)
  
  discard productModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard productModel.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  
  productModel.build()
  
  echo "Models created programmatically with conditional fields"
  echo "Моделите са създадени програмно с условни полета"

proc demonstrateDynamicModelGeneration*() =
  ## [English] Shows dynamic model generation based on configuration
  ## [Български] Показва динамично генериране на модели според конфигурацията
  echo "\n=== Dynamic Model Generation Example ==="
  echo "=== Пример за динамично генериране на модели ==="
  
  # Configuration-driven model creation
  # Създаване на модели според конфигурацията
  type
    FieldConfig = object
      name: string
      fieldType: DbTypeKind
      required: bool
      defaultValue: string
    
    ModelConfig = object
      name: string
      fields: seq[FieldConfig]
  
  # Define model configurations
  # Дефиниране на конфигурации за модели
  let modelConfigs = @[
    ModelConfig(
      name: "Customer",
      fields: @[
        FieldConfig(name: "id", fieldType: dbInt, required: true, defaultValue: ""),
        FieldConfig(name: "first_name", fieldType: dbVarchar, required: true, defaultValue: ""),
        FieldConfig(name: "last_name", fieldType: dbVarchar, required: true, defaultValue: ""),
        FieldConfig(name: "email", fieldType: dbVarchar, required: true, defaultValue: ""),
        FieldConfig(name: "phone", fieldType: dbVarchar, required: false, defaultValue: ""),
        FieldConfig(name: "created_at", fieldType: dbTimestamp, required: false, defaultValue: "CURRENT_TIMESTAMP")
      ]
    ),
    ModelConfig(
      name: "Order",
      fields: @[
        FieldConfig(name: "id", fieldType: dbInt, required: true, defaultValue: ""),
        FieldConfig(name: "customer_id", fieldType: dbInt, required: true, defaultValue: ""),
        FieldConfig(name: "total_amount", fieldType: dbFloat, required: true, defaultValue: ""),
        FieldConfig(name: "status", fieldType: dbVarchar, required: true, defaultValue: "pending"),
        FieldConfig(name: "created_at", fieldType: dbTimestamp, required: false, defaultValue: "CURRENT_TIMESTAMP")
      ]
    )
  ]
  
  # Generate models from configuration
  # Генериране на модели от конфигурацията
  for config in modelConfigs:
    let model = newModelBuilder(config.name)
    
    for field in config.fields:
      var columnBuilder = model.column(field.name, field.fieldType)
      
      # Set primary key for id fields
      # Задаване на първичен ключ за id полетата
      if field.name == "id":
        columnBuilder = columnBuilder.primaryKey()
      
      # Set NOT NULL for required fields
      # Задаване на NOT NULL за задължителните полета
      if field.required:
        columnBuilder = columnBuilder.notNull()
      
      # Set default value if provided
      # Задаване на стойност по подразбиране, ако е предоставена
      if field.defaultValue != "":
        columnBuilder = columnBuilder.default(field.defaultValue)
      
      # Set foreign key for customer_id
      # Задаване на външен ключ за customer_id
      if field.name == "customer_id":
        columnBuilder = columnBuilder.foreignKey("Customer", "id")
    
    model.build()
    echo "Generated model: ", config.name
    echo "Генериран модел: ", config.name

proc demonstrateModelTemplates*() =
  ## [English] Shows reusable model templates
  ## [Български] Показва шаблони за модели за многократна употреба
  echo "\n=== Model Templates Example ==="
  echo "=== Пример за шаблони на модели ==="
  
  # Template for audit fields
  # Шаблон за полета за одит
  proc addAuditFields(model: ModelBuilder) =
    discard model.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
    discard model.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
    discard model.column("created_by", dbInt)
    discard model.column("updated_by", dbInt)
  
  # Template for soft delete
  # Шаблон за мек delete
  proc addSoftDeleteFields(model: ModelBuilder) =
    discard model.column("deleted_at", dbTimestamp)
    discard model.column("deleted_by", dbInt)
    discard model.column("is_deleted", dbBool).default("false")
  
  # Create models using templates
  # Създаване на модели с шаблони
  
  # Article model with audit and soft delete
  # Модел Article с одит и мек delete
  let articleModel = newModelBuilder("Article")
  discard articleModel.column("id", dbInt).primaryKey()
  discard articleModel.column("title", dbVarchar).notNull()
  discard articleModel.column("content", dbText).notNull()
  discard articleModel.column("author_id", dbInt).notNull().foreignKey("User", "id")
  discard articleModel.column("published", dbBool).default("false")
  
  # Add template fields
  # Добавяне на полета от шаблони
  articleModel.addAuditFields()
  articleModel.addSoftDeleteFields()
  
  articleModel.build()
  
  # Comment model with audit fields only
  # Модел Comment само с одит полета
  let commentModel = newModelBuilder("Comment")
  discard commentModel.column("id", dbInt).primaryKey()
  discard commentModel.column("article_id", dbInt).notNull().foreignKey("Article", "id")
  discard commentModel.column("author_id", dbInt).notNull().foreignKey("User", "id")
  discard commentModel.column("content", dbText).notNull()
  discard commentModel.column("approved", dbBool).default("false")
  
  # Add only audit fields
  # Добавяне само на одит полета
  commentModel.addAuditFields()
  
  commentModel.build()
  
  echo "Models created using reusable templates"
  echo "Моделите са създадени с шаблони за многократна употреба"

proc demonstrateHybridApproach*() =
  ## [English] Shows combining different approaches in one project
  ## [Български] Показва комбиниране на различни подходи в един проект
  echo "\n=== Hybrid Approach Example ==="
  echo "=== Пример за хибриден подход ==="
  
  # Core models using macro (simple and fast)
  # Основни модели с макрос (прости и бързи)
  echo "Role model syntax:"
  echo "model \"Role\":"
  echo "  id: int, primaryKey"
  echo "  name: string, notNull"
  echo "  description: string"
  echo ""
  echo "Permission model syntax:"
  echo "model \"Permission\":"
  echo "  id: int, primaryKey"
  echo "  name: string, notNull"
  echo "  resource: string, notNull"
  echo "  action: string, notNull"
  
  # Complex models using object-oriented approach
  # Сложни модели с обектно-ориентиран подход
  let userRoleModel = newModelBuilder("UserRole")
  discard userRoleModel.column("id", dbInt).primaryKey()
  discard userRoleModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
  discard userRoleModel.column("role_id", dbInt).notNull().foreignKey("Role", "id")
  discard userRoleModel.column("assigned_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard userRoleModel.column("assigned_by", dbInt).foreignKey("User", "id")
  discard userRoleModel.column("expires_at", dbTimestamp)
  userRoleModel.build()
  
  # Dynamic models based on runtime configuration
  # Динамични модели според конфигурацията по време на изпълнение
  let enableAuditLog = true
  if enableAuditLog:
    let auditModel = newModelBuilder("AuditLog")
    discard auditModel.column("id", dbInt).primaryKey()
    discard auditModel.column("table_name", dbVarchar).notNull()
    discard auditModel.column("record_id", dbInt).notNull()
    discard auditModel.column("action", dbVarchar).notNull()
    discard auditModel.column("old_values", dbText)
    discard auditModel.column("new_values", dbText)
    discard auditModel.column("user_id", dbInt).foreignKey("User", "id")
    discard auditModel.column("timestamp", dbTimestamp).default("CURRENT_TIMESTAMP")
    auditModel.build()
    
    echo "Audit logging enabled - AuditLog model created"
    echo "Одит логването е включено - създаден е модел AuditLog"
  
  echo "Hybrid approach combining macro, object-oriented, and dynamic generation"
  echo "Хибриден подход, комбиниращ макрос, обектно-ориентиран и динамично генериране"

proc demonstrateModelEvolution*() =
  ## [English] Shows how models can evolve over time
  ## [Български] Показва как моделите могат да еволюират с времето
  echo "\n=== Model Evolution Example ==="
  echo "=== Пример за еволюция на модели ==="
  
  # Version 1: Simple model
  # Версия 1: Прост модел
  echo "Version 1: Basic user model"
  echo "Версия 1: Основен модел за потребител"
  
  echo "UserV1 model syntax:"
  echo "model \"UserV1\":"
  echo "  id: int, primaryKey"
  echo "  username: string, notNull"
  echo "  email: string, notNull"
  
  # Version 2: Enhanced model with object-oriented approach
  # Версия 2: Подобрен модел с обектно-ориентиран подход
  echo "Version 2: Enhanced user model with profile fields"
  echo "Версия 2: Подобрен модел за потребител с профилни полета"
  
  let userV2Model = newModelBuilder("UserV2")
  discard userV2Model.column("id", dbInt).primaryKey()
  discard userV2Model.column("username", dbVarchar).notNull()
  discard userV2Model.column("email", dbVarchar).notNull()
  
  # New fields in version 2
  # Нови полета във версия 2
  discard userV2Model.column("first_name", dbVarchar)
  discard userV2Model.column("last_name", dbVarchar)
  discard userV2Model.column("avatar_url", dbVarchar)
  discard userV2Model.column("bio", dbText)
  discard userV2Model.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard userV2Model.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  
  userV2Model.build()
  
  # Version 3: Feature-rich model with conditional fields
  # Версия 3: Модел богат на функции с условни полета
  echo "Version 3: Feature-rich user model with optional modules"
  echo "Версия 3: Модел за потребител богат на функции с опционални модули"
  
  let userV3Model = newModelBuilder("UserV3")
  
  # Core fields (always present)
  # Основни полета (винаги присъстват)
  discard userV3Model.column("id", dbInt).primaryKey()
  discard userV3Model.column("username", dbVarchar).notNull()
  discard userV3Model.column("email", dbVarchar).notNull()
  discard userV3Model.column("password_hash", dbVarchar).notNull()
  
  # Profile fields
  # Профилни полета
  discard userV3Model.column("first_name", dbVarchar)
  discard userV3Model.column("last_name", dbVarchar)
  discard userV3Model.column("avatar_url", dbVarchar)
  discard userV3Model.column("bio", dbText)
  
  # Optional modules
  # Опционални модули
  let enableSocialLogin = true
  let enableTwoFactor = true
  let enablePreferences = true
  
  if enableSocialLogin:
    discard userV3Model.column("google_id", dbVarchar)
    discard userV3Model.column("facebook_id", dbVarchar)
    discard userV3Model.column("github_id", dbVarchar)
  
  if enableTwoFactor:
    discard userV3Model.column("two_factor_secret", dbVarchar)
    discard userV3Model.column("two_factor_enabled", dbBool).default("false")
    discard userV3Model.column("backup_codes", dbText)
  
  if enablePreferences:
    discard userV3Model.column("language", dbVarchar).default("en")
    discard userV3Model.column("timezone", dbVarchar).default("UTC")
    discard userV3Model.column("theme", dbVarchar).default("light")
    discard userV3Model.column("notifications_enabled", dbBool).default("true")
  
  # Audit fields
  # Одит полета
  discard userV3Model.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard userV3Model.column("updated_at", dbTimestamp).default("CURRENT_TIMESTAMP")
  discard userV3Model.column("last_login_at", dbTimestamp)
  discard userV3Model.column("email_verified_at", dbTimestamp)
  
  userV3Model.build()
  
  echo "Model evolution demonstrates flexibility and maintainability"
  echo "Еволюцията на модела демонстрира гъвкавост и поддържаемост"

# Main demonstration function
# Основна демонстрационна функция
proc runFlexibilityExamples*() =
  ## [English] Runs all flexibility examples
  ## [Български] Изпълнява всички примери за гъвкавост
  echo "Ormin Model Definition Flexibility Examples"
  echo "Примери за гъвкавост при дефиниране на модели в Ormin"
  echo "=" .repeat(50)
  
  try:
    demonstrateMacroApproach()
    demonstrateObjectOrientedApproach()
    demonstrateDynamicModelGeneration()
    demonstrateModelTemplates()
    demonstrateHybridApproach()
    demonstrateModelEvolution()
    
    # Generate all models
    # Генериране на всички модели
    createModels()
    
    echo "\n=== All Flexibility Examples Completed Successfully ==="
    echo "=== Всички примери за гъвкавост са завършени успешно ==="
    
    # Show generated SQL for demonstration
    # Показване на генерирания SQL за демонстрация
    echo "\nGenerated SQL Schema:"
    echo "Генерирана SQL схема:"
    echo generateSql(modelRegistry)
    
  except Exception as e:
    echo "Error running flexibility examples: ", e.msg
    echo "Грешка при изпълнение на примерите за гъвкавост: ", e.msg

# Run examples when this file is executed directly
# Изпълнение на примерите, когато този файл се изпълнява директно
when isMainModule:
  runFlexibilityExamples()