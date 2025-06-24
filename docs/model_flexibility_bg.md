# Гъвкавост при дефиниране на модели в Ormin

## Въведение

Една от най-важните характеристики на Ormin е гъвкавостта при дефиниране на модели. Разработчиците могат да избират между различни подходи според техните нужди, опит и предпочитания. Тази гъвкавост прави Ormin подходящ както за начинаещи, така и за опитни разработчици.

## Налични подходи

### 1. Традиционен подход с SQL файлове

Този подход е идеален за разработчици, които:
- Имат опит с SQL
- Предпочитат директен контрол върху схемата на базата данни
- Работят с вече съществуващи бази данни
- Искат да използват специфични функции на базата данни

#### Предимства:
- **Пълен контрол**: Директно дефиниране на SQL схемата
- **Съвместимост**: Лесно интегриране с съществуващи бази данни
- **Специфични функции**: Използване на уникални възможности на различните СУБД
- **Познат синтаксис**: Стандартен SQL синтаксис

#### Пример:
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

### 2. Макрос подход

Този подход предлага баланс между простота и гъвкавост:

#### Предимства:
- **Прост синтаксис**: Лесен за изучаване и използване
- **Интеграция с Nim**: Дефиниране на модели в същия файл
- **Типова безопасност**: Автоматична проверка на типовете
- **Бърза разработка**: Минимален код за дефиниране на модели

#### Пример:
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

### 3. Обектно-ориентиран подход

Този подход е най-подходящ за:
- Програмно генериране на модели
- Динамично създаване на схеми
- Сложни бизнес логики при дефиниране на модели
- Условно добавяне на полета

#### Предимства:
- **Програмен контрол**: Пълна гъвкавост при създаване на модели
- **Динамичност**: Възможност за условно добавяне на колони
- **Верижен синтаксис**: Четим и интуитивен код
- **Многократна употреба**: Възможност за създаване на шаблони

#### Пример:
```nim
import ormin/models

# Създаване на модел за потребител
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
discard userModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")

# Условно добавяне на колони
if needsProfilePicture:
  discard userModel.column("profile_picture", dbVarchar)

userModel.build()

# Създаване на модел за пост
let postModel = newModelBuilder("Post")
discard postModel.column("id", dbInt).primaryKey()
discard postModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard postModel.column("title", dbVarchar).notNull()
discard postModel.column("content", dbText)
discard postModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
postModel.build()

createModels()
```

### 4. DSL подход

Този подход предлага най-декларативния синтаксис:

#### Предимства:
- **Декларативност**: Много четим и ясен синтаксис
- **Групиране**: Възможност за дефиниране на множество модели заедно
- **Прагми**: Използване на Nim прагми за атрибути
- **Естетичност**: Най-красивия синтаксис

#### Пример:
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

## Сравнение на подходите

| Характеристика | SQL файлове | Макрос | Обектно-ориентиран | DSL |
|----------------|-------------|--------|-------------------|-----|
| **Лесота на изучаване** | Средна | Висока | Средна | Висока |
| **Гъвкавост** | Висока | Средна | Много висока | Средна |
| **Програмен контрол** | Ниска | Ниска | Висока | Ниска |
| **Четимост** | Средна | Висока | Средна | Много висока |
| **Интеграция с Nim** | Ниска | Висока | Висока | Висока |
| **Динамичност** | Ниска | Ниска | Висока | Ниска |

## Кога да използвате кой подход

### SQL файлове - използвайте когато:
- Работите с вече съществуваща база данни
- Имате сложни SQL схеми с специфични функции
- Екипът ви има силен SQL опит
- Искате максимален контрол върху генерирания SQL

### Макрос подход - използвайте когато:
- Започвате нов проект
- Искате бърза разработка
- Предпочитате прост синтаксис
- Моделите ви са относително прости

### Обектно-ориентиран подход - използвайте когато:
- Нуждаете се от програмно генериране на модели
- Имате сложна бизнес логика за моделите
- Искате условно добавяне на полета
- Създавате инструменти за генериране на схеми

### DSL подход - използвайте когато:
- Искате най-четимия код
- Дефинирате множество модели заедно
- Предпочитате декларативен стил
- Естетиката на кода е важна

## Комбиниране на подходи

Ormin позволява комбиниране на различните подходи в един проект:

```nim
# Импортиране на основни модели от SQL
importModel(DbBackend.sqlite, "core_models")

# Добавяне на допълнителни модели с макрос
model "UserSession":
  id: int, primaryKey
  user_id: int, foreignKey("User", "id")
  token: string, notNull
  expires_at: timestamp

# Програмно създаване на модели за логове
let logModel = newModelBuilder("ActivityLog")
discard logModel.column("id", dbInt).primaryKey()
discard logModel.column("user_id", dbInt).foreignKey("User", "id")
discard logModel.column("action", dbVarchar).notNull()
discard logModel.column("timestamp", dbTimestamp).default("CURRENT_TIMESTAMP")

# Условно добавяне на полета според конфигурацията
if config.enableDetailedLogging:
  discard logModel.column("details", dbText)
  discard logModel.column("ip_address", dbVarchar)

logModel.build()

createModels()
```

## Миграция между подходи

### От SQL файлове към код

```nim
# Стара версия - SQL файл
# CREATE TABLE User(id INTEGER PRIMARY KEY, name TEXT);

# Нова версия - макрос
model "User":
  id: int, primaryKey
  name: string
```

### От макрос към обектно-ориентиран

```nim
# Стара версия - макрос
# model "User":
#   id: int, primaryKey
#   name: string

# Нова версия - обектно-ориентиран
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("name", dbVarchar)
userModel.build()
```

## Най-добри практики

### 1. Избор на подход според проекта
- **Малки проекти**: Макрос или DSL подход
- **Средни проекти**: Комбинация от макрос и обектно-ориентиран
- **Големи проекти**: SQL файлове или обектно-ориентиран подход

### 2. Консистентност в екипа
- Изберете един основен подход за екипа
- Документирайте причините за избора
- Използвайте други подходи само при необходимост

### 3. Еволюция на проекта
- Започнете с по-прост подход
- Мигрирайте към по-сложни подходи при нужда
- Поддържайте обратна съвместимост

### 4. Тестване
- Тествайте всички подходи в проекта
- Уверете се, че генерираният SQL е правилен
- Проверявайте производителността

## Заключение

Гъвкавостта на Ormin при дефиниране на модели е една от най-силните му страни. Тя позволява на разработчиците да избират подхода, който най-добре отговаря на техните нужди, опит и изисквания на проекта. Независимо дали предпочитате традиционния SQL подход или модерните програмни методи, Ormin предоставя инструментите, от които се нуждаете.

Тази гъвкавост прави Ormin подходящ за широк спектър от проекти - от прости уеб приложения до сложни корпоративни системи. Възможността за комбиниране на различните подходи в един проект дава допълнителна свобода и позволява постепенна еволюция на кодовата база.