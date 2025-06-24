# Ormin - ORM Library for Nim

## Introduction

Ormin is an ORM (Object-Relational Mapping) library for the Nim language that allows easy interaction with relational databases. The library offers a type-safe way to define models and execute queries to the database.

## Key Features

1. **Model Definition via SQL Files**: Models are defined in SQL files and imported into Nim code.
2. **Query DSL**: Provides a domain-specific language for queries that is close to SQL but integrated into Nim.
3. **Multiple Database Support**: Supports SQLite, PostgreSQL, and MySQL.
4. **Compile-Time Code Generation**: Uses Nim macros for code generation at compile time.
5. **Type Safety**: Ensures type checking at compile time.

## Installation

```
nimble install ormin
```

## How to Use Ormin

### Traditional Approach with SQL Files

#### Defining a Model

Create an SQL file with your table definitions:

```sql
-- model.sql
CREATE TABLE IF NOT EXISTS User(
    username text PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS Message(
    username text,
    time integer,
    msg text NOT NULL,
    FOREIGN KEY (username) REFERENCES User(username)
);
```

#### Importing the Model

```nim
import ormin
importModel(DbBackend.sqlite, "model")
```

#### Executing Queries

```nim
# Creating a user
proc create*(user: User) =
  query:
    insert user(username = ?user.username)

# Finding a user
proc findUser*(username: string, user: var User): bool =
  let res = query:
    select user(username)
    where username == ?username
  if res.len == 0: return false
  else: user.username = res[0]
  return true
```

### New Approach with Model Definition in Code

With the new improvements, you can define models directly in Nim code in several ways:

#### 1. Using the `model` Macro

```nim
import ormin/models

model "User":
  username: string, primaryKey
  email: string, notNull
  age: int

model "Message":
  id: int, primaryKey
  username: string, foreignKey("User", "username")
  content: string, notNull
  created_at: timestamp

# Generate types for the models
createModels()
```

#### 2. Object-Oriented Approach

This approach allows for more flexible and programmatic model definition:

```nim
import ormin/models

# Create a user model
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
discard userModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
userModel.build()

# Create a message model
let messageModel = newModelBuilder("Message")
discard messageModel.column("id", dbInt).primaryKey()
discard messageModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard messageModel.column("content", dbVarchar).notNull()
discard messageModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
messageModel.build()

# Generate types for the models
createModels()
```

#### 3. DSL Approach

This approach offers a more declarative and readable syntax:

```nim
import ormin/models

# Define models with DSL
defineModel:
  model User:
    id {.primaryKey.}: int
    username {.notNull.}: string
    email {.notNull.}: string
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp

  model Message:
    id {.primaryKey.}: int
    user_id {.notNull, foreignKey: ("User", "id").}: int
    content {.notNull.}: string
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp

# Generate types for the models
createModels()
```

### Using Transactions

With the new comprehensive transaction support, you can execute multiple queries in a single transaction with full control and monitoring:

#### Basic Transaction Usage

```nim
import ormin/transactions

# Method 1: Manual transaction management
let tx = newTransaction(db)
try:
  tx.begin()
  
  # Your database operations
  db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", "John", "john@example.com")
  tx.incrementOperationCount()
  
  db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "1", "My Post")
  tx.incrementOperationCount()
  
  tx.commit()
  echo "Transaction committed successfully"
except:
  if tx.isActive():
    tx.rollback()
  raise

# Method 2: Using the withTransaction template (recommended)
withTransaction(db):
  # Your database operations
  db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", "Jane", "jane@example.com")
  db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "2", "Jane's Post")
  # Automatically commits on success or rolls back on error

# Method 3: Short syntax
transaction(db):
  # Your queries here
```

#### Transaction Isolation Levels

```nim
# Using different isolation levels
transactionWithIsolation(db, tilSerializable):
  # Operations with highest isolation level
  db.exec(sql"SELECT COUNT(*) FROM users")

transactionWithIsolation(db, tilReadCommitted):
  # Operations with READ COMMITTED isolation
  db.exec(sql"SELECT * FROM posts")

# Creating a transaction with specific isolation level
let tx = newTransaction(db, isolationLevel = tilRepeatableRead)
```

#### Nested Transactions with Savepoints

```nim
let tx = newTransaction(db)
try:
  tx.begin()
  
  # Main operations
  db.exec(sql"INSERT INTO users (name) VALUES (?)", "Alice")
  
  # Create savepoint
  tx.createSavepoint("user_created")
  
  try:
    # Risky operations
    db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "999", "Invalid")
  except:
    # Rollback to savepoint on error
    tx.rollbackToSavepoint("user_created")
    echo "Rolled back to savepoint"
  
  # Continue with valid operations
  db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "1", "Valid Post")
  
  # Release savepoint
  tx.releaseSavepoint("user_created")
  
  tx.commit()
except:
  if tx.isActive():
    tx.rollback()
  raise
```

#### Automatic Retry on Deadlock

```nim
# Automatic retry on deadlock (up to 3 times)
withTransactionRetry(db, 3):
  # Operations that might cause deadlock
  db.exec(sql"UPDATE users SET email = ? WHERE id = ?", "new@example.com", "1")
  db.exec(sql"UPDATE posts SET title = ? WHERE user_id = ?", "New Title", "1")
```

#### Transaction Statistics and Monitoring

```nim
let tx = newTransaction(db)
try:
  tx.begin()
  
  # Perform operations
  for i in 1..10:
    db.exec(sql"INSERT INTO test (value) VALUES (?)", $i)
    tx.incrementOperationCount()
  
  tx.commit()
  
  # Get statistics
  let stats = tx.getTransactionStats()
  echo "Operation count: ", stats.operationCount
  echo "Duration: ", tx.getDuration()
  echo "Rollback count: ", stats.rollbackCount
  
except:
  if tx.isActive():
    tx.rollback()
  raise

# Monitor active transactions
let activeTx = getActiveTransactions()
echo "Active transactions: ", activeTx.len

# Cleanup inactive transactions
cleanupInactiveTransactions()
```

#### Transaction Creation Options

```nim
# Create transaction with all options
let tx = newTransaction(
  db = db,
  isolationLevel = tilSerializable,    # Isolation level
  autoRetry = true,                    # Automatic retry
  maxRetries = 5                       # Maximum retry attempts
)
```

#### Transaction Error Handling

```nim
# Specific error types for transactions
try:
  withTransaction(db):
    # Your operations
    pass
except TransactionError as e:
  echo "Transaction error: ", e.msg
except DeadlockError as e:
  echo "Deadlock error: ", e.msg
except SavepointError as e:
  echo "Savepoint error: ", e.msg
```

### Database Migrations

With the new migration support, you can manage changes to your database schema:

```nim
import ormin/migrations

# Create a migration manager
let mm = newMigrationManager(db)

# Create a new migration
let migrationFile = mm.createMigration("add_user_table")
echo "Created migration: ", migrationFile

# Apply all pending migrations
mm.migrateUp()

# Roll back the last migration
mm.migrateDown(1)
```

## Advantages of Ormin

1. **Performance**: Code generation at compile time can provide better performance.
2. **Type Safety**: Nim's strong typing combined with compile-time checks.
3. **Ease of Use**: The query DSL is very close to SQL, making it easy to learn.
4. **SQL Integration**: Direct use of SQL files for schema definition can be convenient for developers already familiar with SQL.
5. **Flexibility**: With the new improvements, you can choose between defining models in SQL or in code.

## Improvement Suggestions

The following improvements have been implemented in the latest version:

1. **Migration Support**: Tools for managing changes to the database schema.
2. **Transaction Support**: API for working with transactions.
3. **Alternative Model Definition Approaches**: Ability to define models in Nim code in several ways:
   - **`model` Macro**: Basic way to define models with a simple syntax.
   - **Object-Oriented Approach**: Programmatic model definition with method chaining.
   - **DSL Approach**: Declarative syntax using pragmas for better readability.

## Detailed Description of New Model Definition Approaches

### `model` Macro

The simplest way to define models in Nim code:

```nim
model "User":
  username: string, primaryKey
  email: string, notNull
  age: int
```

This approach is easy to use and understand but has limited flexibility.

### Object-Oriented Approach

This approach allows programmatic model definition and is particularly useful when models need to be created dynamically:

```nim
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
userModel.build()
```

Advantages:
- Programmatic model creation
- Ability to conditionally add columns
- Method chaining syntax for more readable code

### DSL Approach

This approach offers the most declarative and readable syntax, using Nim pragmas:

```nim
defineModel:
  model User:
    id {.primaryKey.}: int
    username {.notNull.}: string
    email {.notNull.}: string
```

Advantages:
- Very readable syntax
- Ability to define multiple models in one block
- Use of pragmas for column attributes

## Planned Improvements for Future Versions

1. **Improved Relationship Support**: More explicit API for working with relationships between tables in Nim code.
2. **Improved Documentation**: Creation of more detailed documentation with usage examples.
3. **Asynchronous Operation Support**: Adding support for asynchronous database queries.
4. **Query Caching**: Implementation of a caching mechanism to improve performance.
5. **Lazy Loading**: Adding support for lazy loading of related objects.
6. **Data Validation**: Adding a mechanism for validating data before saving to the database.
7. **Complex Query Support**: Extending the DSL to support more complex queries, such as subqueries, window functions, etc.