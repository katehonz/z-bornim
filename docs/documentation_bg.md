# Ormin - ORM библиотека за Nim

## Въведение

Ormin е ORM (Object-Relational Mapping) библиотека за езика Nim, която позволява лесно взаимодействие с релационни бази данни. Библиотеката предлага типово безопасен начин за дефиниране на модели и изпълнение на заявки към базата данни.

## Основни характеристики

1. **Дефиниране на модели чрез SQL файлове**: Моделите се дефинират в SQL файлове и се импортират в кода на Nim.
2. **DSL за заявки**: Предоставя специфичен език за заявки, който е близък до SQL, но интегриран в Nim.
3. **Поддръжка на няколко бази данни**: Поддържа SQLite, PostgreSQL и MySQL.
4. **Генериране на код по време на компилация**: Използва макроси на Nim за генериране на код по време на компилация.
5. **Типова безопасност**: Осигурява проверка на типовете по време на компилация.

## Инсталация

```
nimble install ormin
```

## Как да използваме Ormin

### Традиционен подход с SQL файлове

#### Дефиниране на модел

Създайте SQL файл с дефиниция на вашите таблици:

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

#### Импортиране на модела

```nim
import ormin
importModel(DbBackend.sqlite, "model")
```

#### Изпълнение на заявки

```nim
# Създаване на потребител
proc create*(user: User) =
  query:
    insert user(username = ?user.username)

# Намиране на потребител
proc findUser*(username: string, user: var User): bool =
  let res = query:
    select user(username)
    where username == ?username
  if res.len == 0: return false
  else: user.username = res[0]
  return true
```

### Нов подход с дефиниране на модели в код

С новите подобрения, можете да дефинирате модели директно в кода на Nim по няколко начина:

#### 1. Използване на макроса `model`

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

# Генериране на типове за моделите
createModels()
```

#### 2. Обектно-ориентиран подход

Този подход позволява по-гъвкаво и програмно дефиниране на модели:

```nim
import ormin/models

# Създаване на модел за потребител
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
discard userModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
userModel.build()

# Създаване на модел за съобщение
let messageModel = newModelBuilder("Message")
discard messageModel.column("id", dbInt).primaryKey()
discard messageModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard messageModel.column("content", dbVarchar).notNull()
discard messageModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
messageModel.build()

# Генериране на типове за моделите
createModels()
```

#### 3. DSL подход

Този подход предлага по-декларативен и четим синтаксис:

```nim
import ormin/models

# Дефиниране на модели с DSL
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

# Генериране на типове за моделите
createModels()
```

### Използване на транзакции

С новата разширена поддръжка на транзакции, можете да изпълнявате множество заявки в една транзакция с пълен контрол и мониторинг:

#### Основно използване на транзакции

```nim
import ormin/transactions

# Метод 1: Ръчно управление на транзакции
let tx = newTransaction(db)
try:
  tx.begin()
  
  # Вашите операции с базата данни
  db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", "John", "john@example.com")
  tx.incrementOperationCount()
  
  db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "1", "My Post")
  tx.incrementOperationCount()
  
  tx.commit()
  echo "Транзакцията е потвърдена успешно"
except:
  if tx.isActive():
    tx.rollback()
  raise

# Метод 2: Използване на шаблона withTransaction (препоръчително)
withTransaction(db):
  # Вашите операции с базата данни
  db.exec(sql"INSERT INTO users (name, email) VALUES (?, ?)", "Jane", "jane@example.com")
  db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "2", "Jane's Post")
  # Автоматично потвърждава при успех или отменя при грешка

# Метод 3: Кратък синтаксис
transaction(db):
  # Вашите заявки тук
```

#### Нива на изолация на транзакции

```nim
# Използване на различни нива на изолация
transactionWithIsolation(db, tilSerializable):
  # Операции с най-високо ниво на изолация
  db.exec(sql"SELECT COUNT(*) FROM users")

transactionWithIsolation(db, tilReadCommitted):
  # Операции с READ COMMITTED изолация
  db.exec(sql"SELECT * FROM posts")

# Създаване на транзакция с определено ниво на изолация
let tx = newTransaction(db, isolationLevel = tilRepeatableRead)
```

#### Вложени транзакции със Savepoints

```nim
let tx = newTransaction(db)
try:
  tx.begin()
  
  # Основни операции
  db.exec(sql"INSERT INTO users (name) VALUES (?)", "Alice")
  
  # Създаване на savepoint
  tx.createSavepoint("user_created")
  
  try:
    # Рискови операции
    db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "999", "Invalid")
  except:
    # Връщане към savepoint при грешка
    tx.rollbackToSavepoint("user_created")
    echo "Върнахме се към savepoint"
  
  # Продължаване с валидни операции
  db.exec(sql"INSERT INTO posts (user_id, title) VALUES (?, ?)", "1", "Valid Post")
  
  # Освобождаване на savepoint
  tx.releaseSavepoint("user_created")
  
  tx.commit()
except:
  if tx.isActive():
    tx.rollback()
  raise
```

#### Автоматичен повторен опит при Deadlock

```nim
# Автоматичен повторен опит при deadlock (до 3 пъти)
withTransactionRetry(db, 3):
  # Операции, които могат да причинят deadlock
  db.exec(sql"UPDATE users SET email = ? WHERE id = ?", "new@example.com", "1")
  db.exec(sql"UPDATE posts SET title = ? WHERE user_id = ?", "New Title", "1")
```

#### Статистики и мониторинг на транзакции

```nim
let tx = newTransaction(db)
try:
  tx.begin()
  
  # Изпълнение на операции
  for i in 1..10:
    db.exec(sql"INSERT INTO test (value) VALUES (?)", $i)
    tx.incrementOperationCount()
  
  tx.commit()
  
  # Получаване на статистики
  let stats = tx.getTransactionStats()
  echo "Брой операции: ", stats.operationCount
  echo "Продължителност: ", tx.getDuration()
  echo "Брой отмени: ", stats.rollbackCount
  
except:
  if tx.isActive():
    tx.rollback()
  raise

# Мониторинг на активни транзакции
let activeTx = getActiveTransactions()
echo "Активни транзакции: ", activeTx.len

# Почистване на неактивни транзакции
cleanupInactiveTransactions()
```

#### Опции за създаване на транзакции

```nim
# Създаване на транзакция с всички опции
let tx = newTransaction(
  db = db,
  isolationLevel = tilSerializable,    # Ниво на изолация
  autoRetry = true,                    # Автоматичен повторен опит
  maxRetries = 5                       # Максимален брой опити
)
```

#### Обработка на грешки в транзакции

```nim
# Специфични типове грешки за транзакции
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

### Миграции на базата данни

С новата поддръжка на миграции, можете да управлявате промените в схемата на базата данни:

```nim
import ormin/migrations

# Създаване на мениджър на миграции
let mm = newMigrationManager(db)

# Създаване на нова миграция
let migrationFile = mm.createMigration("add_user_table")
echo "Created migration: ", migrationFile

# Прилагане на всички чакащи миграции
mm.migrateUp()

# Връщане на последната миграция
mm.migrateDown(1)
```

## Предимства на Ormin

1. **Производителност**: Генерирането на код по време на компилация може да осигури по-добра производителност.
2. **Типова безопасност**: Силната типизация на Nim в комбинация с проверки по време на компилация.
3. **Лесна употреба**: DSL за заявки е много близък до SQL, което улеснява изучаването.
4. **Интеграция с SQL**: Директното използване на SQL файлове за дефиниране на схемата може да бъде удобно за разработчици, които вече са запознати с SQL.
5. **Гъвкавост**: С новите подобрения, можете да избирате между дефиниране на модели в SQL или в код.

## Предложения за подобрения

Следните подобрения са реализирани в последната версия:

1. **Поддръжка на миграции**: Инструменти за управление на промените в схемата на базата данни.
2. **Поддръжка на транзакции**: API за работа с транзакции.
3. **Алтернативни начини за дефиниране на модели**: Възможност за дефиниране на модели в кода на Nim по различни начини:
   - **Макрос `model`**: Базов начин за дефиниране на модели с прост синтаксис.
   - **Обектно-ориентиран подход**: Програмно дефиниране на модели с верижен синтаксис (method chaining).
   - **DSL подход**: Декларативен синтаксис с използване на прагми за по-добра четимост.

## Подробно описание на новите начини за дефиниране на модели

### Макрос `model`

Най-простият начин за дефиниране на модели в кода на Nim:

```nim
model "User":
  username: string, primaryKey
  email: string, notNull
  age: int
```

Този подход е лесен за използване и разбиране, но има ограничена гъвкавост.

### Обектно-ориентиран подход

Този подход позволява програмно дефиниране на модели и е особено полезен, когато моделите трябва да се създават динамично:

```nim
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
userModel.build()
```

Предимства:
- Програмно създаване на модели
- Възможност за условно добавяне на колони
- Верижен синтаксис за по-четим код

### DSL подход

Този подход предлага най-декларативния и четим синтаксис, използвайки прагми на Nim:

```nim
defineModel:
  model User:
    id {.primaryKey.}: int
    username {.notNull.}: string
    email {.notNull.}: string
```

Предимства:
- Много четим синтаксис
- Възможност за дефиниране на множество модели в един блок
- Използване на прагми за атрибути на колоните

## Планирани подобрения за бъдещи версии

1. **Подобрена поддръжка на релации**: По-явен API за работа с релации между таблици в кода на Nim.
2. **Подобрена документация**: Създаване на по-подробна документация с примери за използване.
3. **Поддръжка на асинхронни операции**: Добавяне на поддръжка за асинхронни заявки към базата данни.
4. **Кеширане на заявки**: Реализация на механиз

5. **Мързеливо зареждане**: Добавяне на поддръжка за мързеливо зареждане на свързани обекти.
6. **Валидация на данни**: Добавяне на механизъм за валидация на данни преди запазване в базата данни.
7. **Поддръжка на сложни заявки**: Разширяване на DSL за поддръжка на по-сложни заявки, като подзаявки, прозоречни функции и др.ъм за кеширане за подобряване на производителността
