# DSL Approaches for Model Definition in Ormin

## Overview

Ormin provides three different approaches for defining database models, each with unique advantages and use cases:

1. **Macro Approach** - Simple and clean syntax for quick definition
2. **Object-Oriented Approach** - Flexible programmatic definition with method chaining
3. **Pragma-based DSL Approach** - Declarative syntax for enhanced readability

## 1. Macro Approach

### Characteristics
- **Simplicity**: The simplest way to define models
- **Readability**: Clean and intuitive syntax
- **Speed**: Minimal code for basic models
- **Static**: Definitions are processed at compile time

### Syntax

```nim
model "ModelName":
  column_name: type, constraint1, constraint2
  another_column: type, constraint
```

### Example

```nim
import ormin/models

# Define User model
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

# Define Post model
model "Post":
  id: int, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  title: string, notNull
  content: string, notNull
  published: bool, default("false")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
```

### Supported Constraints
- `primaryKey` - Primary key constraint
- `notNull` - NOT NULL constraint
- `default("value")` - Default value
- `foreignKey("Table", "column")` - Foreign key reference

### Advantages
- ✅ Very easy to use
- ✅ Minimal code
- ✅ Good readability
- ✅ Fast compilation

### Disadvantages
- ❌ Limited flexibility
- ❌ Difficult for dynamic generation
- ❌ No support for conditional logic

### When to Use
- Simple models with fixed structure
- Rapid prototyping
- Static database schemas
- When simplicity is a priority

## 2. Object-Oriented Approach

### Characteristics
- **Flexibility**: Full programmatic control over definition
- **Dynamic**: Ability to conditionally define columns
- **Fluent**: Fluent API with method chaining
- **Powerful**: Supports complex model generation logic

### Syntax

```nim
let model = newModelBuilder("ModelName")
discard model.column("name", type).constraint1().constraint2()
model.build()
```

### Example

```nim
import ormin/models

# Create Comment model with conditional fields
let commentModel = newModelBuilder("Comment")
discard commentModel.column("id", dbInt).primaryKey()
discard commentModel.column("post_id", dbInt).notNull().foreignKey("Post", "id")
discard commentModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard commentModel.column("content", dbText).notNull()
discard commentModel.column("status", dbVarchar).default("pending")

# Conditional fields based on configuration
let enableModeration = true
let enableReplies = true

if enableModeration:
  discard commentModel.column("approved", dbBool).default("false")
  discard commentModel.column("approved_by", dbInt).foreignKey("User", "id")
  discard commentModel.column("approved_at", dbTimestamp)

if enableReplies:
  discard commentModel.column("parent_id", dbInt).foreignKey("Comment", "id")
  discard commentModel.column("reply_count", dbInt).default("0")

discard commentModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
commentModel.build()
```

### Supported Methods
- `column(name, type)` - Add a column
- `primaryKey()` - Set as primary key
- `notNull()` - NOT NULL constraint
- `default(value)` - Default value
- `foreignKey(table, column)` - Foreign key reference
- `unique()` - Unique constraint
- `indexed()` - Create index
- `comment(text)` - Column comment
- `check(expression)` - Check constraint

### Advantages
- ✅ Maximum flexibility
- ✅ Programmatic control
- ✅ Conditional logic
- ✅ Dynamic generation
- ✅ Code reusability

### Disadvantages
- ❌ More code required
- ❌ More complex syntax
- ❌ Can be overkill for simple cases

### When to Use
- Complex models with conditional logic
- Dynamic schema generation
- When you need programmatic control
- Configuration-based models
- Systems with modular architecture

## 3. Pragma-based DSL Approach

### Characteristics
- **Readability**: Most readable syntax
- **Declarative**: Declarative style of definition
- **Rich**: Supports rich metadata
- **Self-documenting**: Code serves as documentation

### Syntax

```nim
model "ModelName":
  column_name {.constraint1, constraint2: value.}: type
```

### Example

```nim
import ormin/dsl_models

# Define model with rich pragmas
model "User":
  id {.primaryKey, autoIncrement.}: int
  username {.notNull, unique, maxLength: 50, minLength: 3.}: string
  email {.notNull, unique, indexed.}: string
  password_hash {.notNull, minLength: 8.}: string
  first_name {.maxLength: 100.}: string
  last_name {.maxLength: 100.}: string
  avatar_url {.comment: "URL to user avatar image".}: string
  bio {.maxLength: 500.}: string
  active {.default: "true".}: bool
  email_verified {.default: "false".}: bool
  created_at {.default: "CURRENT_TIMESTAMP".}: timestamp
  updated_at {.default: "CURRENT_TIMESTAMP".}: timestamp

# Define model with constraints
model "Product":
  id {.primaryKey.}: int
  name {.notNull, maxLength: 200.}: string
  price {.notNull, check: "price > 0".}: float
  category_id {.notNull, foreignKey: ("Category", "id").}: int
  stock_quantity {.default: "0", check: "stock_quantity >= 0".}: int
  active {.default: "true".}: bool
  created_at {.default: "CURRENT_TIMESTAMP".}: timestamp
```

### Supported Pragmas
- `{.primaryKey.}` - Primary key constraint
- `{.notNull.}` - NOT NULL constraint
- `{.unique.}` - Unique constraint
- `{.indexed.}` - Create index
- `{.autoIncrement.}` - Auto increment
- `{.default: "value".}` - Default value
- `{.foreignKey: ("Table", "column").}` - Foreign key reference
- `{.maxLength: 100.}` - Maximum length
- `{.minLength: 3.}` - Minimum length
- `{.comment: "text".}` - Column comment
- `{.check: "expression".}` - Check constraint

### Advantages
- ✅ Excellent readability
- ✅ Self-documenting code
- ✅ Rich metadata
- ✅ Declarative style
- ✅ Easy to understand

### Disadvantages
- ❌ Longer syntax
- ❌ Limited flexibility
- ❌ No support for conditional logic

### When to Use
- When readability is a priority
- Complex models with many constraints
- Documented schemas
- When you want self-documenting code
- Models with rich metadata

## Hybrid Approach

### Combining Approaches

You can combine different approaches in one project:

```nim
# Core models with macro approach
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull

# Complex models with object-oriented approach
let auditModel = newModelBuilder("AuditLog")
discard auditModel.column("id", dbInt).primaryKey()
discard auditModel.column("table_name", dbVarchar).notNull()
discard auditModel.column("action", dbVarchar).notNull()

# Conditional fields
let enableDetailedLogging = true
if enableDetailedLogging:
  discard auditModel.column("old_values", dbText)
  discard auditModel.column("new_values", dbText)

auditModel.build()

# Configuration models with pragmas
model "Setting":
  id {.primaryKey.}: int
  key {.notNull, unique, maxLength: 100.}: string
  value {.maxLength: 1000.}: string
  type {.default: "string".}: string
  description {.comment: "Setting description".}: string
```

## Advanced Features

### Schemas

```nim
defineSchema "BlogCMS":
  # Define multiple models
  model User:
    # ...
  
  model Post:
    # ...
```

### Migrations

```nim
migration "AddUserProfiles":
  up:
    createTable "UserProfile":
      id: int, primaryKey
      user_id: int, foreignKey("User", "id")
      bio: text
  
  down:
    dropTable "UserProfile"
```

### Validation

```nim
validator "User":
  username:
    required: true
    minLength: 3
    maxLength: 50
    pattern: r"^[a-zA-Z0-9_]+$"
  
  email:
    required: true
    format: email
```

### Relationships

```nim
relationships "User":
  hasMany Post, foreignKey: "user_id"
  hasOne UserProfile, foreignKey: "user_id"
  belongsToMany Role, through: "UserRole"
```

## Approach Comparison

| Feature | Macro | Object-Oriented | Pragma |
|---------|-------|----------------|--------|
| Simplicity | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Readability | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Flexibility | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Power | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Dynamic | ⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| Metadata | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## Recommendations

### For Beginners
Start with the **macro approach** for simplicity and easy learning.

### For Complex Projects
Use the **object-oriented approach** for maximum flexibility.

### For Documented Schemas
Choose the **pragma-based DSL approach** for best readability.

### For Large Projects
Combine all approaches based on the needs of different parts of the system.

## Best Practices

### Model Organization
```nim
# Group related models together
defineSchema "UserManagement":
  model User:
    # User fields
  
  model Role:
    # Role fields
  
  model UserRole:
    # Junction table

defineSchema "ContentManagement":
  model Post:
    # Post fields
  
  model Category:
    # Category fields
```

### Naming Conventions
- Use PascalCase for model names: `User`, `BlogPost`, `UserRole`
- Use snake_case for column names: `user_id`, `created_at`, `first_name`
- Use descriptive names: `email_verified_at` instead of `verified`

### Field Patterns
```nim
# Standard audit fields
created_at: timestamp, default("CURRENT_TIMESTAMP")
updated_at: timestamp, default("CURRENT_TIMESTAMP")

# Soft delete pattern
deleted_at: timestamp
is_deleted: bool, default("false")

# Status fields
status: string, default("active")
active: bool, default("true")
```

### Performance Considerations
- Add indexes on frequently queried columns
- Use appropriate data types for storage efficiency
- Consider partitioning for large tables

```nim
model "User":
  id: int, primaryKey
  email: string, notNull, unique, indexed  # Indexed for fast lookups
  username: string, notNull, unique, indexed
  created_at: timestamp, default("CURRENT_TIMESTAMP"), indexed  # For date range queries
```

## Migration Strategies

### Version Control
```nim
# Version 1.0
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull

# Version 1.1 - Add profile fields
migration "AddUserProfile":
  up:
    alterTable "User":
      addColumn "first_name", string
      addColumn "last_name", string
      addColumn "avatar_url", string
  
  down:
    alterTable "User":
      dropColumn "first_name"
      dropColumn "last_name"
      dropColumn "avatar_url"
```

### Backward Compatibility
- Always provide migration scripts
- Use default values for new columns
- Consider deprecation periods for removed fields

## Testing Models

### Unit Tests
```nim
import unittest
import ormin/models

suite "User Model Tests":
  test "User model creation":
    let user = User(
      username: "testuser",
      email: "test@example.com",
      password_hash: "hashed_password"
    )
    check user.username == "testuser"
    check user.email == "test@example.com"
  
  test "User validation":
    # Test validation rules
    check validateUser(username: "ab") == false  # Too short
    check validateUser(username: "validuser") == true
```

### Integration Tests
```nim
suite "Database Integration Tests":
  setup:
    # Create test database
    let db = open(":memory:", "", "", "")
    createModels()
  
  teardown:
    db.close()
  
  test "User CRUD operations":
    # Test create, read, update, delete operations
    discard
```

## Conclusion

Ormin provides flexible and powerful ways to define database models. The choice of approach depends on:

- The complexity of your models
- The need for dynamic generation
- Readability priorities
- Project size and complexity
- Team experience

Each approach has its place and can be used effectively in the appropriate context. The key is to choose the right tool for the job and maintain consistency within your project.