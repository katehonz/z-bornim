# DSL Подходи за Дефиниране на Модели в Ormin

## Преглед

Ormin предоставя три различни подхода за дефиниране на модели на бази данни, всеки с уникални предимства и случаи на употреба:

1. **Макрос подход** - Прост и чист синтаксис за бързо дефиниране
2. **Обектно-ориентиран подход** - Гъвкаво програмно дефиниране с верижно извикване на методи
3. **DSL подход с прагми** - Декларативен синтаксис за подобрена четимост

## 1. Макрос Подход

### Характеристики
- **Простота**: Най-простият начин за дефиниране на модели
- **Четимост**: Чист и интуитивен синтаксис
- **Бързина**: Минимален код за основни модели
- **Статичност**: Дефинициите се обработват по време на компилация

### Синтаксис

```nim
model "ModelName":
  column_name: type, constraint1, constraint2
  another_column: type, constraint
```

### Пример

```nim
import ormin/models

# Дефиниране на модел User
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

# Дефиниране на модел Post
model "Post":
  id: int, primaryKey
  user_id: int, notNull, foreignKey("User", "id")
  title: string, notNull
  content: string, notNull
  published: bool, default("false")
  created_at: timestamp, default("CURRENT_TIMESTAMP")
```

### Поддържани Ограничения
- `primaryKey` - Първичен ключ
- `notNull` - NOT NULL ограничение
- `default("value")` - Стойност по подразбиране
- `foreignKey("Table", "column")` - Външен ключ

### Предимства
- ✅ Много прост за използване
- ✅ Минимален код
- ✅ Добра четимост
- ✅ Бърза компилация

### Недостатъци
- ❌ Ограничена гъвкавост
- ❌ Трудно за динамично генериране
- ❌ Не поддържа условна логика

### Кога да използвате
- Прости модели с фиксирана структура
- Бързо прототипиране
- Статични схеми на бази данни
- Когато простотата е приоритет

## 2. Обектно-ориентиран Подход

### Характеристики
- **Гъвкавост**: Пълен програмен контрол над дефиницията
- **Динамичност**: Възможност за условно дефиниране на колони
- **Верижност**: Fluent API с верижно извикване на методи
- **Мощност**: Поддържа сложна логика за генериране на модели

### Синтаксис

```nim
let model = newModelBuilder("ModelName")
discard model.column("name", type).constraint1().constraint2()
model.build()
```

### Пример

```nim
import ormin/models

# Създаване на модел Comment с условни полета
let commentModel = newModelBuilder("Comment")
discard commentModel.column("id", dbInt).primaryKey()
discard commentModel.column("post_id", dbInt).notNull().foreignKey("Post", "id")
discard commentModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard commentModel.column("content", dbText).notNull()
discard commentModel.column("status", dbVarchar).default("pending")

# Условни полета според конфигурацията
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

### Поддържани Методи
- `column(name, type)` - Добавяне на колона
- `primaryKey()` - Задаване като първичен ключ
- `notNull()` - NOT NULL ограничение
- `default(value)` - Стойност по подразбиране
- `foreignKey(table, column)` - Външен ключ
- `unique()` - Уникално ограничение
- `indexed()` - Създаване на индекс
- `comment(text)` - Коментар към колоната
- `check(expression)` - Check ограничение

### Предимства
- ✅ Максимална гъвкавост
- ✅ Програмен контрол
- ✅ Условна логика
- ✅ Динамично генериране
- ✅ Повторна употреба на код

### Недостатъци
- ❌ Повече код
- ❌ По-сложен синтаксис
- ❌ Може да бъде прекалено сложен за прости случаи

### Кога да използвате
- Сложни модели с условна логика
- Динамично генериране на схеми
- Когато се нуждаете от програмен контрол
- Модели базирани на конфигурация
- Системи с модулна архитектура

## 3. DSL Подход с Прагми

### Характеристики
- **Четимост**: Най-четимият синтаксис
- **Декларативност**: Декларативен стил на дефиниране
- **Богатство**: Поддържа богати метаданни
- **Самодокументиращ**: Кодът служи като документация

### Синтаксис

```nim
model "ModelName":
  column_name {.constraint1, constraint2: value.}: type
```

### Пример

```nim
import ormin/dsl_models

# Дефиниране на модел с богати прагми
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

# Дефиниране на модел с ограничения
model "Product":
  id {.primaryKey.}: int
  name {.notNull, maxLength: 200.}: string
  price {.notNull, check: "price > 0".}: float
  category_id {.notNull, foreignKey: ("Category", "id").}: int
  stock_quantity {.default: "0", check: "stock_quantity >= 0".}: int
  active {.default: "true".}: bool
  created_at {.default: "CURRENT_TIMESTAMP".}: timestamp
```

### Поддържани Прагми
- `{.primaryKey.}` - Първичен ключ
- `{.notNull.}` - NOT NULL ограничение
- `{.unique.}` - Уникално ограничение
- `{.indexed.}` - Създаване на индекс
- `{.autoIncrement.}` - Автоматично увеличение
- `{.default: "value".}` - Стойност по подразбиране
- `{.foreignKey: ("Table", "column").}` - Външен ключ
- `{.maxLength: 100.}` - Максимална дължина
- `{.minLength: 3.}` - Минимална дължина
- `{.comment: "text".}` - Коментар
- `{.check: "expression".}` - Check ограничение

### Предимства
- ✅ Отлична четимост
- ✅ Самодокументиращ код
- ✅ Богати метаданни
- ✅ Декларативен стил
- ✅ Лесен за разбиране

### Недостатъци
- ❌ По-дълъг синтаксис
- ❌ Ограничена гъвкавост
- ❌ Не поддържа условна логика

### Кога да използвате
- Когато четимостта е приоритет
- Сложни модели с много ограничения
- Документирани схеми
- Когато искате самодокументиращ код
- Модели с богати метаданни

## Хибриден Подход

### Комбиниране на подходите

Можете да комбинирате различните подходи в един проект:

```nim
# Основни модели с макрос подход
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull

# Сложни модели с обектно-ориентиран подход
let auditModel = newModelBuilder("AuditLog")
discard auditModel.column("id", dbInt).primaryKey()
discard auditModel.column("table_name", dbVarchar).notNull()
discard auditModel.column("action", dbVarchar).notNull()

# Условни полета
let enableDetailedLogging = true
if enableDetailedLogging:
  discard auditModel.column("old_values", dbText)
  discard auditModel.column("new_values", dbText)

auditModel.build()

# Конфигурационни модели с прагми
model "Setting":
  id {.primaryKey.}: int
  key {.notNull, unique, maxLength: 100.}: string
  value {.maxLength: 1000.}: string
  type {.default: "string".}: string
  description {.comment: "Setting description".}: string
```

## Разширени Функции

### Схеми

```nim
defineSchema "BlogCMS":
  # Дефиниране на множество модели
  model User:
    # ...
  
  model Post:
    # ...
```

### Миграции

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

### Валидация

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

### Връзки

```nim
relationships "User":
  hasMany Post, foreignKey: "user_id"
  hasOne UserProfile, foreignKey: "user_id"
  belongsToMany Role, through: "UserRole"
```

## Сравнение на Подходите

| Характеристика | Макрос | Обектно-ориентиран | Прагми |
|----------------|--------|-------------------|--------|
| Простота | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Четимост | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Гъвкавост | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Мощност | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Динамичност | ⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| Метаданни | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## Препоръки

### За начинаещи
Започнете с **макрос подхода** за простота и лесно учене.

### За сложни проекти
Използвайте **обектно-ориентирания подход** за максимална гъвкавост.

### За документирани схеми
Изберете **DSL подхода с прагми** за най-добра четимост.

### За големи проекти
Комбинирайте всички подходи според нуждите на различните части от системата.

## Заключение

Ormin предоставя гъвкави и мощни начини за дефиниране на модели на бази данни. Изборът на подход зависи от:

- Сложността на вашите модели
- Нуждата от динамично генериране
- Приоритета на четимостта
- Размера и сложността на проекта
- Опита на екипа

Всеки подход има своето място и може да бъде използван ефективно в подходящия контекст.