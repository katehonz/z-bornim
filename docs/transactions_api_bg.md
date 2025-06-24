# API за транзакции на Ormin

## Въведение

API за транзакции на Ormin предоставя цялостна поддръжка за управление на транзакции в базата данни. Този модул включва основни операции с транзакции, поддръжка на вложени транзакции със savepoints, автоматично управление на транзакции и разширени функции за мониторинг.

## Основни характеристики

- **Основни операции с транзакции**: `begin`, `commit`, `rollback`
- **Нива на изолация**: Поддръжка на всички стандартни нива на изолация
- **Savepoints**: Вложени транзакции с възможност за частично отменяне
- **Автоматичен повторен опит**: Справяне с deadlock ситуации
- **Статистики и мониторинг**: Проследяване на производителността на транзакциите
- **Удобни шаблони**: Автоматично управление на транзакции

## Типове данни

### TransactionIsolationLevel

Нивата на изолация на транзакциите:

```nim
type
  TransactionIsolationLevel* = enum
    tilReadUncommitted = "READ UNCOMMITTED"  # Най-ниско ниво
    tilReadCommitted = "READ COMMITTED"      # По подразбиране
    tilRepeatableRead = "REPEATABLE READ"    # Средно ниво
    tilSerializable = "SERIALIZABLE"         # Най-високо ниво
```

### TransactionState

Състоянията на транзакцията:

```nim
type
  TransactionState* = enum
    tsInactive     # Транзакцията не е активна
    tsActive       # Транзакцията е активна
    tsCommitted    # Транзакцията е потвърдена
    tsRolledBack   # Транзакцията е отменена
```

### Transaction

Основният обект за транзакция:

```nim
type
  Transaction* = ref object
    db*: DbConn                           # Връзка с базата данни
    state*: TransactionState              # Текущо състояние
    isolationLevel*: TransactionIsolationLevel  # Ниво на изолация
    savepoints*: seq[string]              # Активни savepoints
    stats*: TransactionStats              # Статистики
    autoRetry*: bool                      # Автоматичен повторен опит
    maxRetries*: int                      # Максимален брой опити
```

## Основни функции

### newTransaction

Създава нова транзакция с опции:

```nim
proc newTransaction*(db: DbConn, 
                    isolationLevel: TransactionIsolationLevel = tilReadCommitted,
                    autoRetry: bool = false, 
                    maxRetries: int = 3): Transaction
```

**Параметри:**
- `db`: Връзка с базата данни
- `isolationLevel`: Ниво на изолация (по подразбиране: READ COMMITTED)
- `autoRetry`: Автоматичен повторен опит при deadlock
- `maxRetries`: Максимален брой опити за повторение

**Пример:**
```nim
let tx = newTransaction(db, tilSerializable, autoRetry = true, maxRetries = 5)
```

### begin

Започва транзакция:

```nim
proc begin*(t: Transaction)
```

**Пример:**
```nim
let tx = newTransaction(db)
tx.begin()
```

### commit

Потвърждава транзакция:

```nim
proc commit*(t: Transaction)
```

**Пример:**
```nim
tx.commit()
```

### rollback

Отменя транзакция:

```nim
proc rollback*(t: Transaction)
```

**Пример:**
```nim
tx.rollback()
```

## Savepoints

### createSavepoint

Създава savepoint в активна транзакция:

```nim
proc createSavepoint*(t: Transaction, name: string)
```

**Пример:**
```nim
tx.createSavepoint("checkpoint1")
```

### rollbackToSavepoint

Отменя до определен savepoint:

```nim
proc rollbackToSavepoint*(t: Transaction, name: string)
```

**Пример:**
```nim
tx.rollbackToSavepoint("checkpoint1")
```

### releaseSavepoint

Освобождава savepoint:

```nim
proc releaseSavepoint*(t: Transaction, name: string)
```

**Пример:**
```nim
tx.releaseSavepoint("checkpoint1")
```

## Помощни функции

### isActive

Проверява дали транзакцията е активна:

```nim
proc isActive*(t: Transaction): bool
```

### getDuration

Получава продължителността на транзакцията:

```nim
proc getDuration*(t: Transaction): Duration
```

### incrementOperationCount

Увеличава брояча на операциите:

```nim
proc incrementOperationCount*(t: Transaction)
```

## Шаблони за управление

### withTransaction

Автоматично управление на транзакции:

```nim
template withTransaction*(db: DbConn, body: untyped)
```

**Пример:**
```nim
withTransaction(db):
  db.exec(sql"INSERT INTO users (name) VALUES (?)", "John")
  db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "1", "My Post")
  # Автоматично потвърждава при успех или отменя при грешка
```

### withTransactionRetry

Транзакция с автоматичен повторен опит:

```nim
template withTransactionRetry*(db: DbConn, maxRetries: int, body: untyped)
```

**Пример:**
```nim
withTransactionRetry(db, 3):
  # Операции, които могат да причинят deadlock
  db.exec(sql"UPDATE users SET email = ? WHERE id = ?", "new@example.com", "1")
  db.exec(sql"UPDATE posts SET title = ? WHERE user_id = ?", "New Title", "1")
```

### transactionWithIsolation

Транзакция с определено ниво на изолация:

```nim
template transactionWithIsolation*(db: DbConn, isolationLevel: TransactionIsolationLevel, body: untyped)
```

**Пример:**
```nim
transactionWithIsolation(db, tilSerializable):
  db.exec(sql"SELECT COUNT(*) FROM users")
  db.exec(sql"UPDATE users SET last_login = NOW()")
```

## Мониторинг и статистики

### getActiveTransactions

Получава списък на активните транзакции:

```nim
proc getActiveTransactions*(): seq[Transaction]
```

**Пример:**
```nim
let activeTx = getActiveTransactions()
echo "Активни транзакции: ", activeTx.len
```

### getTransactionStats

Получава статистики за транзакция:

```nim
proc getTransactionStats*(t: Transaction): TransactionStats
```

**Пример:**
```nim
let stats = tx.getTransactionStats()
echo "Брой операции: ", stats.operationCount
echo "Брой отмени: ", stats.rollbackCount
```

### cleanupInactiveTransactions

Почиства неактивни транзакции от регистъра:

```nim
proc cleanupInactiveTransactions*()
```

**Пример:**
```nim
cleanupInactiveTransactions()
```

## Обработка на грешки

### TransactionError

Основен тип грешка за транзакции:

```nim
type
  TransactionError* = object of DbError
```

### DeadlockError

Грешка при deadlock:

```nim
type
  DeadlockError* = object of TransactionError
```

### SavepointError

Грешка при работа със savepoints:

```nim
type
  SavepointError* = object of TransactionError
```

**Пример за обработка:**
```nim
try:
  withTransaction(db):
    # Вашите операции
    pass
except TransactionError as e:
  echo "Грешка в транзакцията: ", e.msg
except DeadlockError as e:
  echo "Deadlock грешка: ", e.msg
except SavepointError as e:
  echo "Savepoint грешка: ", e.msg
```

## Практически примери

### Пример 1: Основна транзакция

```nim
import ormin/transactions

let db = open("database.db", "", "", "")
let tx = newTransaction(db)

try:
  tx.begin()
  
  # Създаване на потребител
  db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", 
          "John Doe", "john@example.com")
  tx.incrementOperationCount()
  
  # Създаване на профил
  db.exec(sql"INSERT INTO profiles (user_id, bio) VALUES (?, ?)", 
          "1", "Software Developer")
  tx.incrementOperationCount()
  
  tx.commit()
  echo "Потребителят е създаден успешно"
  
except Exception as e:
  if tx.isActive():
    tx.rollback()
  echo "Грешка: ", e.msg
  raise
finally:
  db.close()
```

### Пример 2: Използване на savepoints

```nim
import ormin/transactions

let db = open("database.db", "", "", "")

withTransaction(db):
  # Създаване на основен запис
  db.exec(sql"INSERT INTO orders (customer_id, total) VALUES (?, ?)", 
          "1", "100.00")
  
  # Създаване на savepoint преди добавяне на артикули
  let tx = newTransaction(db)  # В реална имплементация ще получаваме текущата транзакция
  tx.createSavepoint("before_items")
  
  try:
    # Добавяне на артикули към поръчката
    db.exec(sql"INSERT INTO order_items (order_id, product_id, quantity) VALUES (?, ?, ?)", 
            "1", "101", "2")
    db.exec(sql"INSERT INTO order_items (order_id, product_id, quantity) VALUES (?, ?, ?)", 
            "1", "102", "1")
    
    # Освобождаване на savepoint при успех
    tx.releaseSavepoint("before_items")
    
  except Exception as e:
    # Връщане към savepoint при грешка
    tx.rollbackToSavepoint("before_items")
    echo "Грешка при добавяне на артикули: ", e.msg
    
    # Добавяне на празна поръчка
    echo "Създаваме празна поръчка"
```

### Пример 3: Мониторинг на транзакции

```nim
import ormin/transactions

proc monitorTransactions() =
  # Получаване на активни транзакции
  let activeTx = getActiveTransactions()
  
  echo "=== Мониторинг на транзакции ==="
  echo "Активни транзакции: ", activeTx.len
  
  for i, tx in activeTx:
    let stats = tx.getTransactionStats()
    echo "Транзакция ", i + 1, ":"
    echo "  Състояние: ", tx.state
    echo "  Ниво на изолация: ", tx.isolationLevel
    echo "  Брой операции: ", stats.operationCount
    echo "  Продължителност: ", tx.getDuration()
    echo "  Активни savepoints: ", tx.savepoints.len
  
  # Почистване на неактивни транзакции
  cleanupInactiveTransactions()
  echo "Неактивните транзакции са почистени"

# Извикване на мониторинга
monitorTransactions()
```

## Най-добри практики

### 1. Използвайте шаблони за автоматично управление

```nim
# Препоръчително
withTransaction(db):
  # Вашите операции

# Вместо ръчно управление
let tx = newTransaction(db)
tx.begin()
try:
  # Вашите операции
  tx.commit()
except:
  tx.rollback()
  raise
```

### 2. Използвайте подходящо ниво на изолация

```nim
# За четене на данни
transactionWithIsolation(db, tilReadCommitted):
  # Операции за четене

# За критични операции
transactionWithIsolation(db, tilSerializable):
  # Критични операции
```

### 3. Използвайте savepoints за сложни операции

```nim
withTransaction(db):
  # Основни операции
  db.exec(sql"INSERT INTO main_table (...) VALUES (...)")
  
  # Създаване на savepoint преди рискови операции
  let tx = getCurrentTransaction()  # Хипотетична функция
  tx.createSavepoint("safe_point")
  
  try:
    # Рискови операции
    performRiskyOperations()
    tx.releaseSavepoint("safe_point")
  except:
    tx.rollbackToSavepoint("safe_point")
    # Алтернативни операции
```

### 4. Мониторирайте производителността

```nim
let tx = newTransaction(db)
try:
  tx.begin()
  
  # Вашите операции с инкрементиране на брояча
  for i in 1..1000:
    db.exec(sql"INSERT INTO test (value) VALUES (?)", $i)
    tx.incrementOperationCount()
  
  tx.commit()
  
  # Анализ на производителността
  let stats = tx.getTransactionStats()
  let duration = tx.getDuration()
  let opsPerSecond = stats.operationCount.float / duration.inSeconds.float
  
  echo "Операции в секунда: ", opsPerSecond
  
except:
  if tx.isActive():
    tx.rollback()
  raise
```

## Заключение

API за транзакции на Ormin предоставя мощни инструменти за управление на транзакции в базата данни. Използвайте подходящите методи според нуждите на вашето приложение и следвайте най-добрите практики за оптимална производителност и надеждност.