# Model Definition Flexibility in Ormin

## Introduction

One of the most important characteristics of Ormin is the flexibility in defining models. Developers can choose between different approaches according to their needs, experience, and preferences. This flexibility makes Ormin suitable for both beginners and experienced developers.

## Available Approaches

### 1. Traditional Approach with SQL Files

This approach is ideal for developers who:
- Have experience with SQL
- Prefer direct control over the database schema
- Work with existing databases
- Want to use specific database features

#### Advantages:
- **Full Control**: Direct definition of SQL schema
- **Compatibility**: Easy integration with existing databases
- **Specific Features**: Use of unique capabilities of different DBMS
- **Familiar Syntax**: Standard SQL syntax

#### Example:
```sql
-- model.sql
CREATE TABLE IF NOT EXISTS User(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Post(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(id)
);
```

```nim
import ormin
importModel(DbBackend.sqlite, "model")
```

### 2. Macro Approach

This approach offers a balance between simplicity and flexibility:

#### Advantages:
- **Simple Syntax**: Easy to learn and use
- **Nim Integration**: Define models in the same file
- **Type Safety**: Automatic type checking
- **Rapid Development**: Minimal code for model definition

#### Example:
```nim
import ormin/models

model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull
  created_at: timestamp, default("CURRENT_TIMESTAMP")

model "Post":
  id: int, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  title: string, notNull
  content: string
  created_at: timestamp, default("CURRENT_TIMESTAMP")

createModels()
```

### 3. Object-Oriented Approach

This approach is most suitable for:
- Programmatic model generation
- Dynamic schema creation
- Complex business logic in model definition
- Conditional field addition

#### Advantages:
- **Programmatic Control**: Full flexibility in model creation
- **Dynamism**: Ability to conditionally add columns
- **Method Chaining**: Readable and intuitive code
- **Reusability**: Ability to create templates

#### Example:
```nim
import ormin/models

# Create user model
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
discard userModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")

# Conditionally add columns
if needsProfilePicture:
  discard userModel.column("profile_picture", dbVarchar)

userModel.build()

# Create post model
let postModel = newModelBuilder("Post")
discard postModel.column("id", dbInt).primaryKey()
discard postModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard postModel.column("title", dbVarchar).notNull()
discard postModel.column("content", dbText)
discard postModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
postModel.build()

createModels()
```

### 4. DSL Approach

This approach offers the most declarative syntax:

#### Advantages:
- **Declarative**: Very readable and clear syntax
- **Grouping**: Ability to define multiple models together
- **Pragmas**: Use of Nim pragmas for attributes
- **Aesthetics**: Most beautiful syntax

#### Example:
```nim
import ormin/models

defineModel:
  model User:
    id {.primaryKey.}: int
    username {.notNull.}: string
    email {.notNull.}: string
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp

  model Post:
    id {.primaryKey.}: int
    user_id {.notNull, foreignKey: ("User", "id").}: int
    title {.notNull.}: string
    content: string
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp

createModels()
```

## Approach Comparison

| Characteristic | SQL Files | Macro | Object-Oriented | DSL |
|----------------|-----------|-------|----------------|-----|
| **Ease of Learning** | Medium | High | Medium | High |
| **Flexibility** | High | Medium | Very High | Medium |
| **Programmatic Control** | Low | Low | High | Low |
| **Readability** | Medium | High | Medium | Very High |
| **Nim Integration** | Low | High | High | High |
| **Dynamism** | Low | Low | High | Low |

## When to Use Which Approach

### SQL Files - use when:
- Working with an existing database
- You have complex SQL schemas with specific features
- Your team has strong SQL experience
- You want maximum control over generated SQL

### Macro Approach - use when:
- Starting a new project
- You want rapid development
- You prefer simple syntax
- Your models are relatively simple

### Object-Oriented Approach - use when:
- You need programmatic model generation
- You have complex business logic for models
- You want conditional field addition
- You're creating schema generation tools

### DSL Approach - use when:
- You want the most readable code
- You're defining multiple models together
- You prefer declarative style
- Code aesthetics is important

## Combining Approaches

Ormin allows combining different approaches in one project:

```nim
# Import core models from SQL
importModel(DbBackend.sqlite, "core_models")

# Add additional models with macro
model "UserSession":
  id: int, primaryKey
  user_id: int, foreignKey("User", "id")
  token: string, notNull
  expires_at: timestamp

# Programmatically create models for logs
let logModel = newModelBuilder("ActivityLog")
discard logModel.column("id", dbInt).primaryKey()
discard logModel.column("user_id", dbInt).foreignKey("User", "id")
discard logModel.column("action", dbVarchar).notNull()
discard logModel.column("timestamp", dbTimestamp).default("CURRENT_TIMESTAMP")

# Conditionally add fields based on configuration
if config.enableDetailedLogging:
  discard logModel.column("details", dbText)
  discard logModel.column("ip_address", dbVarchar)

logModel.build()

createModels()
```

## Migration Between Approaches

### From SQL Files to Code

```nim
# Old version - SQL file
# CREATE TABLE User(id INTEGER PRIMARY KEY, name TEXT);

# New version - macro
model "User":
  id: int, primaryKey
  name: string
```

### From Macro to Object-Oriented

```nim
# Old version - macro
# model "User":
#   id: int, primaryKey
#   name: string

# New version - object-oriented
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("name", dbVarchar)
userModel.build()
```

## Best Practices

### 1. Choose Approach Based on Project
- **Small projects**: Macro or DSL approach
- **Medium projects**: Combination of macro and object-oriented
- **Large projects**: SQL files or object-oriented approach

### 2. Team Consistency
- Choose one primary approach for the team
- Document the reasons for the choice
- Use other approaches only when necessary

### 3. Project Evolution
- Start with a simpler approach
- Migrate to more complex approaches when needed
- Maintain backward compatibility

### 4. Testing
- Test all approaches in the project
- Ensure generated SQL is correct
- Check performance

## Conclusion

Ormin's flexibility in model definition is one of its strongest features. It allows developers to choose the approach that best fits their needs, experience, and project requirements. Whether you prefer the traditional SQL approach or modern programmatic methods, Ormin provides the tools you need.

This flexibility makes Ormin suitable for a wide range of projects - from simple web applications to complex enterprise systems. The ability to combine different approaches in one project provides additional freedom and allows gradual evolution of the codebase.