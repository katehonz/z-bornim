# Ormin Transaction Examples / Примери за транзакции на Ormin

This directory contains examples demonstrating the Ormin Transaction API functionality.

Тази директория съдържа примери, демонстриращи функционалността на API за транзакции на Ormin.

## Files / Файлове

### transaction_example.nim

Comprehensive example demonstrating all aspects of the Transaction API:

Цялостен пример, демонстриращ всички аспекти на API за транзакции:

- **Basic transaction management** / **Основно управление на транзакции**
- **Template usage** / **Използване на шаблони**
- **Isolation levels** / **Нива на изолация**
- **Savepoints** / **Savepoints**
- **Automatic retry** / **Автоматичен повторен опит**
- **Statistics and monitoring** / **Статистики и мониторинг**

## Running the Examples / Изпълнение на примерите

### Prerequisites / Предварителни условия

Make sure you have Nim installed and the Ormin library available.

Уверете се, че имате инсталиран Nim и налична библиотеката Ormin.

### Compilation / Компилиране

```bash
# Compile the transaction example
# Компилиране на примера за транзакции
nim compile --run transaction_example.nim
```

### Expected Output / Очакван изход

The example will demonstrate various transaction scenarios and print detailed information about each operation.

Примерът ще демонстрира различни сценарии с транзакции и ще отпечата подробна информация за всяка операция.

```
Ormin Transaction API Examples
Примери за API за транзакции на Ormin
================================

=== Basic Transaction Example ===
=== Основен пример за транзакции ===
Transaction started / Транзакцията започна
Transaction committed successfully / Транзакцията е потвърдена успешно

=== Template Transaction Example ===
=== Пример с шаблон за транзакции ===
Inside transaction template / Вътре в шаблона за транзакции
Operations completed / Операциите са завършени

... (more output)
```

## Key Concepts Demonstrated / Основни концепции, демонстрирани

### 1. Manual Transaction Management / Ръчно управление на транзакции

```nim
let tx = newTransaction(db)
try:
  tx.begin()
  # Your operations
  tx.commit()
except:
  if tx.isActive():
    tx.rollback()
  raise
```

### 2. Automatic Transaction Management / Автоматично управление на транзакции

```nim
withTransaction(db):
  # Your operations
  # Automatically commits or rolls back
```

### 3. Isolation Levels / Нива на изолация

```nim
transactionWithIsolation(db, tilSerializable):
  # Operations with SERIALIZABLE isolation
```

### 4. Savepoints / Savepoints

```nim
tx.createSavepoint("checkpoint")
try:
  # Risky operations
  tx.releaseSavepoint("checkpoint")
except:
  tx.rollbackToSavepoint("checkpoint")
```

### 5. Automatic Retry / Автоматичен повторен опит

```nim
withTransactionRetry(db, 3):
  # Operations that might deadlock
```

### 6. Statistics and Monitoring / Статистики и мониторинг

```nim
let stats = tx.getTransactionStats()
echo "Operations: ", stats.operationCount
echo "Duration: ", tx.getDuration()
```

## Best Practices Shown / Показани най-добри практики

1. **Always use templates for automatic management** / **Винаги използвайте шаблони за автоматично управление**
2. **Choose appropriate isolation levels** / **Избирайте подходящи нива на изолация**
3. **Use savepoints for complex operations** / **Използвайте savepoints за сложни операции**
4. **Monitor transaction performance** / **Мониторирайте производителността на транзакциите**
5. **Handle errors appropriately** / **Обработвайте грешките подходящо**

## Error Handling Examples / Примери за обработка на грешки

The examples demonstrate proper error handling for:

Примерите демонстрират правилна обработка на грешки за:

- **TransactionError** - General transaction errors / Общи грешки в транзакции
- **DeadlockError** - Deadlock situations / Ситуации с deadlock
- **SavepointError** - Savepoint-related errors / Грешки свързани със savepoints

## Performance Considerations / Съображения за производителност

The examples show how to:

Примерите показват как да:

- Monitor transaction duration / Мониторирате продължителността на транзакциите
- Count operations / Броите операциите
- Track rollbacks / Проследявате отменените операции
- Clean up inactive transactions / Почиствате неактивните транзакции

## Integration with Ormin Models / Интеграция с моделите на Ormin

The examples demonstrate how transactions work with:

Примерите демонстрират как транзакциите работят с:

- Database connections / Връзки с базата данни
- SQL operations / SQL операции
- Model operations / Операции с модели
- Query execution / Изпълнение на заявки

## Troubleshooting / Отстраняване на неизправности

### Common Issues / Общи проблеми

1. **Transaction already active** / **Транзакцията вече е активна**
   - Make sure to commit or rollback before starting a new transaction
   - Уверете се, че потвърждавате или отменяте преди да започнете нова транзакция

2. **No active transaction** / **Няма активна транзакция**
   - Always call `begin()` before `commit()` or `rollback()`
   - Винаги извиквайте `begin()` преди `commit()` или `rollback()`

3. **Savepoint errors** / **Грешки със savepoints**
   - Savepoints can only be created in active transactions
   - Savepoints могат да се създават само в активни транзакции

4. **Deadlock situations** / **Ситуации с deadlock**
   - Use `withTransactionRetry` for automatic retry
   - Използвайте `withTransactionRetry` за автоматичен повторен опит

### Debug Tips / Съвети за отстраняване на грешки

- Enable transaction monitoring to track active transactions
- Включете мониторинга на транзакции за проследяване на активните транзакции

- Use transaction statistics to identify performance bottlenecks
- Използвайте статистиките на транзакциите за идентифициране на проблеми с производителността

- Check transaction state before operations
- Проверявайте състоянието на транзакцията преди операции

## Further Reading / Допълнително четене

- [Transaction API Documentation (Bulgarian)](../docs/transactions_api_bg.md)
- [Transaction API Documentation (English)](../docs/transactions_api_en.md)
- [Main Ormin Documentation (Bulgarian)](../docs/documentation_bg.md)
- [Main Ormin Documentation (English)](../docs/documentation_en.md)