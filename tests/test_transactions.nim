## Test suite for Ormin Transaction API
## Тестов пакет за API за транзакции на Ormin

import unittest, times, os
import ../ormin/transactions
import ../ormin/models

# Test suite for transaction functionality
# Тестов пакет за функционалност на транзакции

suite "Transaction API Tests":
  
  var db: DbConn
  
  setup:
    # Initialize database connection for tests
    # Инициализиране на връзка с базата данни за тестове
    db = DbConn()
  
  teardown:
    # Clean up after tests
    # Почистване след тестовете
    if db != nil:
      db.close()
  
  test "Create new transaction with default options":
    ## Test creating a transaction with default parameters
    ## Тест за създаване на транзакция с параметри по подразбиране
    let tx = newTransaction(db)
    
    check tx.db == db
    check tx.state == tsInactive
    check tx.isolationLevel == tilReadCommitted
    check tx.savepoints.len == 0
    check tx.autoRetry == false
    check tx.maxRetries == 3
  
  test "Create new transaction with custom options":
    ## Test creating a transaction with custom parameters
    ## Тест за създаване на транзакция с персонализирани параметри
    let tx = newTransaction(db, tilSerializable, autoRetry = true, maxRetries = 5)
    
    check tx.isolationLevel == tilSerializable
    check tx.autoRetry == true
    check tx.maxRetries == 5
  
  test "Transaction state management":
    ## Test transaction state transitions
    ## Тест за преходи на състоянията на транзакцията
    let tx = newTransaction(db)
    
    # Initial state
    # Начално състояние
    check tx.state == tsInactive
    check not tx.isActive()
    
    # Begin transaction
    # Започване на транзакция
    tx.begin()
    check tx.state == tsActive
    check tx.isActive()
    
    # Commit transaction
    # Потвърждаване на транзакция
    tx.commit()
    check tx.state == tsCommitted
    check not tx.isActive()
  
  test "Transaction rollback":
    ## Test transaction rollback functionality
    ## Тест за функционалност на отмяна на транзакция
    let tx = newTransaction(db)
    
    tx.begin()
    check tx.isActive()
    
    tx.rollback()
    check tx.state == tsRolledBack
    check not tx.isActive()
  
  test "Transaction error handling - double begin":
    ## Test error when trying to begin an already active transaction
    ## Тест за грешка при опит за започване на вече активна транзакция
    let tx = newTransaction(db)
    tx.begin()
    
    expect(TransactionError):
      tx.begin()  # Should raise TransactionError
  
  test "Transaction error handling - commit without begin":
    ## Test error when trying to commit without active transaction
    ## Тест за грешка при опит за потвърждаване без активна транзакция
    let tx = newTransaction(db)
    
    expect(TransactionError):
      tx.commit()  # Should raise TransactionError
  
  test "Transaction error handling - rollback without begin":
    ## Test error when trying to rollback without active transaction
    ## Тест за грешка при опит за отмяна без активна транзакция
    let tx = newTransaction(db)
    
    expect(TransactionError):
      tx.rollback()  # Should raise TransactionError
  
  test "Savepoint creation and management":
    ## Test savepoint functionality
    ## Тест за функционалност на savepoints
    let tx = newTransaction(db)
    tx.begin()
    
    # Create savepoint
    # Създаване на savepoint
    tx.createSavepoint("test_savepoint")
    check "test_savepoint" in tx.savepoints
    
    # Release savepoint
    # Освобождаване на savepoint
    tx.releaseSavepoint("test_savepoint")
    check "test_savepoint" notin tx.savepoints
    
    tx.commit()
  
  test "Savepoint rollback":
    ## Test savepoint rollback functionality
    ## Тест за функционалност на отмяна до savepoint
    let tx = newTransaction(db)
    tx.begin()
    
    tx.createSavepoint("test_savepoint")
    check tx.stats.rollbackCount == 0
    
    tx.rollbackToSavepoint("test_savepoint")
    check tx.stats.rollbackCount == 1
    
    tx.commit()
  
  test "Savepoint error handling - create without active transaction":
    ## Test error when creating savepoint without active transaction
    ## Тест за грешка при създаване на savepoint без активна транзакция
    let tx = newTransaction(db)
    
    expect(SavepointError):
      tx.createSavepoint("test_savepoint")
  
  test "Savepoint error handling - duplicate savepoint":
    ## Test error when creating duplicate savepoint
    ## Тест за грешка при създаване на дублиран savepoint
    let tx = newTransaction(db)
    tx.begin()
    
    tx.createSavepoint("test_savepoint")
    
    expect(SavepointError):
      tx.createSavepoint("test_savepoint")  # Should raise SavepointError
    
    tx.commit()
  
  test "Transaction statistics":
    ## Test transaction statistics functionality
    ## Тест за функционалност на статистики на транзакции
    let tx = newTransaction(db)
    tx.begin()
    
    # Initial stats
    # Начални статистики
    check tx.stats.operationCount == 0
    check tx.stats.rollbackCount == 0
    
    # Increment operation count
    # Увеличаване на броя операции
    tx.incrementOperationCount()
    tx.incrementOperationCount()
    check tx.stats.operationCount == 2
    
    tx.commit()
    
    # Check final stats
    # Проверка на финалните статистики
    let stats = tx.getTransactionStats()
    check stats.operationCount == 2
    check stats.rollbackCount == 0
  
  test "Transaction duration calculation":
    ## Test transaction duration calculation
    ## Тест за изчисляване на продължителността на транзакция
    let tx = newTransaction(db)
    tx.begin()
    
    # Small delay to ensure measurable duration
    # Малко забавяне за осигуряване на измерима продължителност
    sleep(10)  # 10ms
    
    tx.commit()
    
    let duration = tx.getDuration()
    check duration.inMilliseconds >= 10
  
  test "withTransaction template success":
    ## Test successful execution with withTransaction template
    ## Тест за успешно изпълнение с шаблона withTransaction
    var executed = false
    
    withTransaction(db):
      executed = true
      # Simulate database operation
      # Симулиране на операция с базата данни
      db.exec(sql"SELECT 1")
    
    check executed == true
  
  test "withTransaction template with exception":
    ## Test exception handling with withTransaction template
    ## Тест за обработка на изключения с шаблона withTransaction
    var executed = false
    
    expect(ValueError):
      withTransaction(db):
        executed = true
        raise newException(ValueError, "Test exception")
    
    check executed == true
  
  test "Transaction registry management":
    ## Test transaction registry functionality
    ## Тест за функционалност на регистъра на транзакции
    # Clear registry first
    # Първо почистване на регистъра
    cleanupInactiveTransactions()
    
    let initialCount = getActiveTransactions().len
    
    let tx1 = newTransaction(db)
    let tx2 = newTransaction(db)
    
    tx1.begin()
    tx2.begin()
    
    let activeTx = getActiveTransactions()
    check activeTx.len >= 2  # At least our 2 transactions
    
    tx1.commit()
    tx2.rollback()
    
    # Cleanup inactive transactions
    # Почистване на неактивни транзакции
    cleanupInactiveTransactions()
  
  test "Transaction isolation levels":
    ## Test different transaction isolation levels
    ## Тест за различни нива на изолация на транзакции
    let levels = [tilReadUncommitted, tilReadCommitted, tilRepeatableRead, tilSerializable]
    
    for level in levels:
      let tx = newTransaction(db, level)
      check tx.isolationLevel == level
      
      tx.begin()
      check tx.isActive()
      tx.commit()
  
  test "Multiple savepoints management":
    ## Test management of multiple savepoints
    ## Тест за управление на множество savepoints
    let tx = newTransaction(db)
    tx.begin()
    
    # Create multiple savepoints
    # Създаване на множество savepoints
    tx.createSavepoint("sp1")
    tx.createSavepoint("sp2")
    tx.createSavepoint("sp3")
    
    check tx.savepoints.len == 3
    check "sp1" in tx.savepoints
    check "sp2" in tx.savepoints
    check "sp3" in tx.savepoints
    
    # Release middle savepoint
    # Освобождаване на средния savepoint
    tx.releaseSavepoint("sp2")
    check tx.savepoints.len == 2
    check "sp2" notin tx.savepoints
    
    # Rollback to first savepoint
    # Отмяна до първия savepoint
    tx.rollbackToSavepoint("sp1")
    
    tx.commit()
  
  test "Transaction cleanup on commit":
    ## Test that savepoints are cleared on commit
    ## Тест, че savepoints се изчистват при потвърждаване
    let tx = newTransaction(db)
    tx.begin()
    
    tx.createSavepoint("test_sp")
    check tx.savepoints.len == 1
    
    tx.commit()
    check tx.savepoints.len == 0
  
  test "Transaction cleanup on rollback":
    ## Test that savepoints are cleared on rollback
    ## Тест, че savepoints се изчистват при отмяна
    let tx = newTransaction(db)
    tx.begin()
    
    tx.createSavepoint("test_sp")
    check tx.savepoints.len == 1
    
    tx.rollback()
    check tx.savepoints.len == 0

# Performance tests
# Тестове за производителност
suite "Transaction Performance Tests":
  
  var db: DbConn
  
  setup:
    db = DbConn()
  
  teardown:
    if db != nil:
      db.close()
  
  test "High-frequency transaction operations":
    ## Test performance with many quick transactions
    ## Тест за производителност с много бързи транзакции
    let startTime = getTime()
    
    for i in 1..100:
      let tx = newTransaction(db)
      tx.begin()
      tx.incrementOperationCount()
      tx.commit()
    
    let endTime = getTime()
    let duration = endTime - startTime
    
    # Should complete within reasonable time (less than 1 second)
    # Трябва да се завърши в разумно време (по-малко от 1 секунда)
    check duration.inSeconds < 1
  
  test "Transaction with many operations":
    ## Test transaction with many operations
    ## Тест за транзакция с много операции
    let tx = newTransaction(db)
    tx.begin()
    
    for i in 1..1000:
      tx.incrementOperationCount()
      # Simulate database operation
      # Симулиране на операция с базата данни
      db.exec(sql"SELECT " & $i)
    
    check tx.stats.operationCount == 1000
    tx.commit()
    
    let stats = tx.getTransactionStats()
    check stats.operationCount == 1000

# Integration tests
# Интеграционни тестове
suite "Transaction Integration Tests":
  
  var db: DbConn
  
  setup:
    db = DbConn()
  
  teardown:
    if db != nil:
      db.close()
  
  test "Transaction with model operations":
    ## Test transaction integration with model operations
    ## Тест за интеграция на транзакции с операции на модели
    withTransaction(db):
      # Simulate model operations
      # Симулиране на операции с модели
      db.exec(sql"CREATE TABLE IF NOT EXISTS test_users (id INTEGER, name TEXT)")
      db.exec(sql"INSERT INTO test_users (id, name) VALUES (?, ?)", "1", "Test User")
      db.exec(sql"SELECT * FROM test_users WHERE id = ?", "1")
  
  test "Nested transaction simulation":
    ## Test nested transaction behavior
    ## Тест за поведение на вложени транзакции
    withTransaction(db):
      # Outer transaction operations
      # Операции на външната транзакция
      db.exec(sql"INSERT INTO test_table (value) VALUES (?)", "outer")
      
      # Simulate inner transaction with savepoint
      # Симулиране на вътрешна транзакция със savepoint
      let tx = newTransaction(db)
      if tx.isActive():  # In real scenario, we'd get current transaction
        tx.createSavepoint("inner_tx")
        
        try:
          db.exec(sql"INSERT INTO test_table (value) VALUES (?)", "inner")
          tx.releaseSavepoint("inner_tx")
        except:
          tx.rollbackToSavepoint("inner_tx")
          raise

when isMainModule:
  # Run all tests when executed directly
  # Изпълнение на всички тестове при директно изпълнение
  echo "Running Ormin Transaction API Tests"
  echo "Изпълняване на тестове за API за транзакции на Ormin"
  echo "=" .repeat(50)