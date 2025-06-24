# Ormin Transaction API

## Introduction

The Ormin Transaction API provides comprehensive support for database transaction management. This module includes basic transaction operations, nested transaction support with savepoints, automatic transaction management, and advanced monitoring features.

## Key Features

- **Basic transaction operations**: `begin`, `commit`, `rollback`
- **Isolation levels**: Support for all standard isolation levels
- **Savepoints**: Nested transactions with partial rollback capability
- **Automatic retry**: Handling deadlock situations
- **Statistics and monitoring**: Transaction performance tracking
- **Convenient templates**: Automatic transaction management

## Data Types

### TransactionIsolationLevel

Transaction isolation levels:

```nim
type
  TransactionIsolationLevel* = enum
    tilReadUncommitted = "READ UNCOMMITTED"  # Lowest level
    tilReadCommitted = "READ COMMITTED"      # Default
    tilRepeatableRead = "REPEATABLE READ"    # Medium level
    tilSerializable = "SERIALIZABLE"         # Highest level
```

### TransactionState

Transaction states:

```nim
type
  TransactionState* = enum
    tsInactive     # Transaction is not active
    tsActive       # Transaction is active
    tsCommitted    # Transaction has been committed
    tsRolledBack   # Transaction has been rolled back
```

### Transaction

The main transaction object:

```nim
type
  Transaction* = ref object
    db*: DbConn                           # Database connection
    state*: TransactionState              # Current state
    isolationLevel*: TransactionIsolationLevel  # Isolation level
    savepoints*: seq[string]              # Active savepoints
    stats*: TransactionStats              # Statistics
    autoRetry*: bool                      # Automatic retry
    maxRetries*: int                      # Maximum retry attempts
```

## Core Functions

### newTransaction

Creates a new transaction with options:

```nim
proc newTransaction*(db: DbConn, 
                    isolationLevel: TransactionIsolationLevel = tilReadCommitted,
                    autoRetry: bool = false, 
                    maxRetries: int = 3): Transaction
```

**Parameters:**
- `db`: Database connection
- `isolationLevel`: Isolation level (default: READ COMMITTED)
- `autoRetry`: Automatic retry on deadlock
- `maxRetries`: Maximum number of retry attempts

**Example:**
```nim
let tx = newTransaction(db, tilSerializable, autoRetry = true, maxRetries = 5)
```

### begin

Starts a transaction:

```nim
proc begin*(t: Transaction)
```

**Example:**
```nim
let tx = newTransaction(db)
tx.begin()
```

### commit

Commits a transaction:

```nim
proc commit*(t: Transaction)
```

**Example:**
```nim
tx.commit()
```

### rollback

Rolls back a transaction:

```nim
proc rollback*(t: Transaction)
```

**Example:**
```nim
tx.rollback()
```

## Savepoints

### createSavepoint

Creates a savepoint in an active transaction:

```nim
proc createSavepoint*(t: Transaction, name: string)
```

**Example:**
```nim
tx.createSavepoint("checkpoint1")
```

### rollbackToSavepoint

Rolls back to a specific savepoint:

```nim
proc rollbackToSavepoint*(t: Transaction, name: string)
```

**Example:**
```nim
tx.rollbackToSavepoint("checkpoint1")
```

### releaseSavepoint

Releases a savepoint:

```nim
proc releaseSavepoint*(t: Transaction, name: string)
```

**Example:**
```nim
tx.releaseSavepoint("checkpoint1")
```

## Utility Functions

### isActive

Checks if the transaction is currently active:

```nim
proc isActive*(t: Transaction): bool
```

### getDuration

Gets the duration of the transaction:

```nim
proc getDuration*(t: Transaction): Duration
```

### incrementOperationCount

Increments the operation counter:

```nim
proc incrementOperationCount*(t: Transaction)
```

## Management Templates

### withTransaction

Automatic transaction management:

```nim
template withTransaction*(db: DbConn, body: untyped)
```

**Example:**
```nim
withTransaction(db):
  db.exec(sql"INSERT INTO users (name) VALUES (?)", "John")
  db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "1", "My Post")
  # Automatically commits on success or rolls back on error
```

### withTransactionRetry

Transaction with automatic retry:

```nim
template withTransactionRetry*(db: DbConn, maxRetries: int, body: untyped)
```

**Example:**
```nim
withTransactionRetry(db, 3):
  # Operations that might cause deadlock
  db.exec(sql"UPDATE users SET email = ? WHERE id = ?", "new@example.com", "1")
  db.exec(sql"UPDATE posts SET title = ? WHERE user_id = ?", "New Title", "1")
```

### transactionWithIsolation

Transaction with specific isolation level:

```nim
template transactionWithIsolation*(db: DbConn, isolationLevel: TransactionIsolationLevel, body: untyped)
```

**Example:**
```nim
transactionWithIsolation(db, tilSerializable):
  db.exec(sql"SELECT COUNT(*) FROM users")
  db.exec(sql"UPDATE users SET last_login = NOW()")
```

## Monitoring and Statistics

### getActiveTransactions

Gets a list of active transactions:

```nim
proc getActiveTransactions*(): seq[Transaction]
```

**Example:**
```nim
let activeTx = getActiveTransactions()
echo "Active transactions: ", activeTx.len
```

### getTransactionStats

Gets statistics for a transaction:

```nim
proc getTransactionStats*(t: Transaction): TransactionStats
```

**Example:**
```nim
let stats = tx.getTransactionStats()
echo "Operation count: ", stats.operationCount
echo "Rollback count: ", stats.rollbackCount
```

### cleanupInactiveTransactions

Cleans up inactive transactions from the registry:

```nim
proc cleanupInactiveTransactions*()
```

**Example:**
```nim
cleanupInactiveTransactions()
```

## Error Handling

### TransactionError

Base error type for transactions:

```nim
type
  TransactionError* = object of DbError
```

### DeadlockError

Error for deadlock situations:

```nim
type
  DeadlockError* = object of TransactionError
```

### SavepointError

Error for savepoint operations:

```nim
type
  SavepointError* = object of TransactionError
```

**Error handling example:**
```nim
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

## Practical Examples

### Example 1: Basic Transaction

```nim
import ormin/transactions

let db = open("database.db", "", "", "")
let tx = newTransaction(db)

try:
  tx.begin()
  
  # Create user
  db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", 
          "John Doe", "john@example.com")
  tx.incrementOperationCount()
  
  # Create profile
  db.exec(sql"INSERT INTO profiles (user_id, bio) VALUES (?, ?)", 
          "1", "Software Developer")
  tx.incrementOperationCount()
  
  tx.commit()
  echo "User created successfully"
  
except Exception as e:
  if tx.isActive():
    tx.rollback()
  echo "Error: ", e.msg
  raise
finally:
  db.close()
```

### Example 2: Using Savepoints

```nim
import ormin/transactions

let db = open("database.db", "", "", "")

withTransaction(db):
  # Create main record
  db.exec(sql"INSERT INTO orders (customer_id, total) VALUES (?, ?)", 
          "1", "100.00")
  
  # Create savepoint before adding items
  let tx = newTransaction(db)  # In real implementation, we'd get current transaction
  tx.createSavepoint("before_items")
  
  try:
    # Add items to order
    db.exec(sql"INSERT INTO order_items (order_id, product_id, quantity) VALUES (?, ?, ?)", 
            "1", "101", "2")
    db.exec(sql"INSERT INTO order_items (order_id, product_id, quantity) VALUES (?, ?, ?)", 
            "1", "102", "1")
    
    # Release savepoint on success
    tx.releaseSavepoint("before_items")
    
  except Exception as e:
    # Rollback to savepoint on error
    tx.rollbackToSavepoint("before_items")
    echo "Error adding items: ", e.msg
    
    # Create empty order
    echo "Creating empty order"
```

### Example 3: Transaction Monitoring

```nim
import ormin/transactions

proc monitorTransactions() =
  # Get active transactions
  let activeTx = getActiveTransactions()
  
  echo "=== Transaction Monitoring ==="
  echo "Active transactions: ", activeTx.len
  
  for i, tx in activeTx:
    let stats = tx.getTransactionStats()
    echo "Transaction ", i + 1, ":"
    echo "  State: ", tx.state
    echo "  Isolation level: ", tx.isolationLevel
    echo "  Operation count: ", stats.operationCount
    echo "  Duration: ", tx.getDuration()
    echo "  Active savepoints: ", tx.savepoints.len
  
  # Cleanup inactive transactions
  cleanupInactiveTransactions()
  echo "Inactive transactions cleaned up"

# Call monitoring
monitorTransactions()
```

## Best Practices

### 1. Use Templates for Automatic Management

```nim
# Recommended
withTransaction(db):
  # Your operations

# Instead of manual management
let tx = newTransaction(db)
tx.begin()
try:
  # Your operations
  tx.commit()
except:
  tx.rollback()
  raise
```

### 2. Use Appropriate Isolation Levels

```nim
# For read operations
transactionWithIsolation(db, tilReadCommitted):
  # Read operations

# For critical operations
transactionWithIsolation(db, tilSerializable):
  # Critical operations
```

### 3. Use Savepoints for Complex Operations

```nim
withTransaction(db):
  # Main operations
  db.exec(sql"INSERT INTO main_table (...) VALUES (...)")
  
  # Create savepoint before risky operations
  let tx = getCurrentTransaction()  # Hypothetical function
  tx.createSavepoint("safe_point")
  
  try:
    # Risky operations
    performRiskyOperations()
    tx.releaseSavepoint("safe_point")
  except:
    tx.rollbackToSavepoint("safe_point")
    # Alternative operations
```

### 4. Monitor Performance

```nim
let tx = newTransaction(db)
try:
  tx.begin()
  
  # Your operations with counter increment
  for i in 1..1000:
    db.exec(sql"INSERT INTO test (value) VALUES (?)", $i)
    tx.incrementOperationCount()
  
  tx.commit()
  
  # Performance analysis
  let stats = tx.getTransactionStats()
  let duration = tx.getDuration()
  let opsPerSecond = stats.operationCount.float / duration.inSeconds.float
  
  echo "Operations per second: ", opsPerSecond
  
except:
  if tx.isActive():
    tx.rollback()
  raise
```

## Conclusion

The Ormin Transaction API provides powerful tools for database transaction management. Use the appropriate methods according to your application's needs and follow best practices for optimal performance and reliability.