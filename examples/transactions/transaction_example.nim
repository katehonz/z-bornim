## Example demonstrating the Ormin transaction API
## Пример, демонстриращ API за транзакции на Ormin

import ../../ormin/transactions
import ../../ormin/models

# Example usage of the transaction API
# Пример за използване на API за транзакции

proc basicTransactionExample*(db: DbConn) =
  ## [English] Basic transaction usage example
  ## [Български] Основен пример за използване на транзакции
  echo "=== Basic Transaction Example ==="
  echo "=== Основен пример за транзакции ==="
  
  # Method 1: Manual transaction management
  # Метод 1: Ръчно управление на транзакции
  let tx = newTransaction(db)
  try:
    tx.begin()
    echo "Transaction started / Транзакцията започна"
    
    # Simulate database operations
    # Симулиране на операции с базата данни
    db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", "John Doe", "john@example.com")
    tx.incrementOperationCount()
    
    db.exec(sql"INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)", "1", "My First Post", "Hello World!")
    tx.incrementOperationCount()
    
    tx.commit()
    echo "Transaction committed successfully / Транзакцията е потвърдена успешно"
    
  except Exception as e:
    if tx.isActive():
      tx.rollback()
      echo "Transaction rolled back due to error: ", e.msg
      echo "Транзакцията е отменена поради грешка: ", e.msg
    raise

proc templateTransactionExample*(db: DbConn) =
  ## [English] Transaction template usage example
  ## [Български] Пример за използване на шаблон за транзакции
  echo "\n=== Template Transaction Example ==="
  echo "=== Пример с шаблон за транзакции ==="
  
  # Method 2: Using the withTransaction template
  # Метод 2: Използване на шаблона withTransaction
  withTransaction(db):
    echo "Inside transaction template / Вътре в шаблона за транзакции"
    
    # These operations will be automatically committed or rolled back
    # Тези операции ще бъдат автоматично потвърдени или отменени
    db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", "Jane Smith", "jane@example.com")
    db.exec(sql"INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)", "2", "Jane's Post", "Nice to meet you!")
    
    echo "Operations completed / Операциите са завършени"

proc isolationLevelExample*(db: DbConn) =
  ## [English] Transaction isolation level example
  ## [Български] Пример за ниво на изолация на транзакции
  echo "\n=== Isolation Level Example ==="
  echo "=== Пример за ниво на изолация ==="
  
  # Using different isolation levels
  # Използване на различни нива на изолация
  transactionWithIsolation(db, tilSerializable):
    echo "Running with SERIALIZABLE isolation / Изпълнява се с SERIALIZABLE изолация"
    db.exec(sql"SELECT COUNT(*) FROM users")
    
  transactionWithIsolation(db, tilReadCommitted):
    echo "Running with READ COMMITTED isolation / Изпълнява се с READ COMMITTED изолация"
    db.exec(sql"SELECT * FROM posts WHERE user_id = ?", "1")

proc savepointExample*(db: DbConn) =
  ## [English] Savepoint usage example
  ## [Български] Пример за използване на savepoints
  echo "\n=== Savepoint Example ==="
  echo "=== Пример за savepoints ==="
  
  let tx = newTransaction(db)
  try:
    tx.begin()
    echo "Main transaction started / Основната транзакция започна"
    
    # Insert a user
    # Вмъкване на потребител
    db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", "Alice Brown", "alice@example.com")
    tx.incrementOperationCount()
    
    # Create a savepoint
    # Създаване на savepoint
    tx.createSavepoint("user_created")
    echo "Savepoint 'user_created' created / Savepoint 'user_created' е създаден"
    
    try:
      # Try to insert a post (this might fail)
      # Опит за вмъкване на пост (това може да се провали)
      db.exec(sql"INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)", "999", "Invalid Post", "This should fail")
      tx.incrementOperationCount()
      
    except Exception as e:
      echo "Post insertion failed, rolling back to savepoint: ", e.msg
      echo "Вмъкването на поста се провали, връщане към savepoint: ", e.msg
      tx.rollbackToSavepoint("user_created")
    
    # Insert a valid post
    # Вмъкване на валиден пост
    db.exec(sql"INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)", "3", "Alice's Post", "Hello from Alice!")
    tx.incrementOperationCount()
    
    # Release the savepoint
    # Освобождаване на savepoint
    tx.releaseSavepoint("user_created")
    echo "Savepoint released / Savepoint е освободен"
    
    tx.commit()
    echo "Transaction committed with savepoint handling / Транзакцията е потвърдена със savepoint обработка"
    
  except Exception as e:
    if tx.isActive():
      tx.rollback()
      echo "Transaction rolled back: ", e.msg
      echo "Транзакцията е отменена: ", e.msg
    raise

proc retryTransactionExample*(db: DbConn) =
  ## [English] Transaction retry example
  ## [Български] Пример за повторен опит на транзакции
  echo "\n=== Retry Transaction Example ==="
  echo "=== Пример за повторен опит на транзакции ==="
  
  # Using automatic retry on deadlock
  # Използване на автоматичен повторен опит при deadlock
  let maxRetries = 3
  withTransactionRetry(db, maxRetries):
    echo "Attempting transaction with retry / Опит за транзакция с повторение"
    
    # Simulate operations that might cause deadlock
    # Симулиране на операции, които могат да причинят deadlock
    db.exec(sql"UPDATE users SET email = ? WHERE id = ?", "updated@example.com", "1")
    db.exec(sql"UPDATE posts SET title = ? WHERE user_id = ?", "Updated Title", "1")
    
    echo "Retry transaction completed / Транзакцията с повторение е завършена"

proc transactionStatsExample*(db: DbConn) =
  ## [English] Transaction statistics example
  ## [Български] Пример за статистики на транзакции
  echo "\n=== Transaction Statistics Example ==="
  echo "=== Пример за статистики на транзакции ==="
  
  let tx = newTransaction(db)
  try:
    tx.begin()
    
    # Perform several operations
    # Изпълнение на няколко операции
    for i in 1..5:
      db.exec(sql"INSERT INTO test_table (value) VALUES (?)", $i)
      tx.incrementOperationCount()
    
    tx.commit()
    
    # Get transaction statistics
    # Получаване на статистики за транзакцията
    let stats = tx.getTransactionStats()
    echo "Transaction Statistics / Статистики на транзакцията:"
    echo "  Operations: ", stats.operationCount, " / Операции: ", stats.operationCount
    echo "  Duration: ", tx.getDuration(), " / Продължителност: ", tx.getDuration()
    echo "  Rollbacks: ", stats.rollbackCount, " / Отмени: ", stats.rollbackCount
    
  except Exception as e:
    if tx.isActive():
      tx.rollback()
    raise

proc monitoringExample*() =
  ## [English] Transaction monitoring example
  ## [Български] Пример за мониторинг на транзакции
  echo "\n=== Transaction Monitoring Example ==="
  echo "=== Пример за мониторинг на транзакции ==="
  
  # Get active transactions
  # Получаване на активни транзакции
  let activeTx = getActiveTransactions()
  echo "Active transactions: ", activeTx.len, " / Активни транзакции: ", activeTx.len
  
  # Cleanup inactive transactions
  # Почистване на неактивни транзакции
  cleanupInactiveTransactions()
  echo "Inactive transactions cleaned up / Неактивните транзакции са почистени"

# Main example function
# Основна функция за пример
proc runTransactionExamples*() =
  ## [English] Runs all transaction examples
  ## [Български] Изпълнява всички примери за транзакции
  echo "Ormin Transaction API Examples"
  echo "Примери за API за транзакции на Ormin"
  echo "================================"
  
  # Create a mock database connection
  # Създаване на фиктивна връзка с базата данни
  let db = DbConn()
  
  try:
    basicTransactionExample(db)
    templateTransactionExample(db)
    isolationLevelExample(db)
    savepointExample(db)
    retryTransactionExample(db)
    transactionStatsExample(db)
    monitoringExample()
    
    echo "\n=== All Examples Completed Successfully ==="
    echo "=== Всички примери са завършени успешно ==="
    
  except Exception as e:
    echo "Error running examples: ", e.msg
    echo "Грешка при изпълнение на примерите: ", e.msg
  finally:
    db.close()

# Run examples when this file is executed directly
# Изпълнение на примерите, когато този файл се изпълнява директно
when isMainModule:
  runTransactionExamples()