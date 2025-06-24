# Ormin Model Flexibility Examples / Примери за гъвкавост на моделите в Ormin

This directory contains comprehensive examples demonstrating the flexibility of model definition in Ormin ORM.

Тази директория съдържа цялостни примери, демонстриращи гъвкавостта при дефиниране на модели в Ormin ORM.

## Overview / Преглед

Ormin provides multiple approaches for defining database models, allowing developers to choose the method that best fits their needs, experience level, and project requirements.

Ormin предоставя множество подходи за дефиниране на модели на бази данни, позволявайки на разработчиците да избират метода, който най-добре отговаря на техните нужди, ниво на опит и изисквания на проекта.

## Files / Файлове

### flexibility_example.nim

Comprehensive example demonstrating all model definition approaches:

Цялостен пример, демонстриращ всички подходи за дефиниране на модели:

- **Macro Approach** / **Макрос подход** - Simple and clean syntax
- **Object-Oriented Approach** / **Обектно-ориентиран подход** - Programmatic control
- **Dynamic Generation** / **Динамично генериране** - Configuration-driven models
- **Model Templates** / **Шаблони за модели** - Reusable components
- **Hybrid Approach** / **Хибриден подход** - Combining multiple methods
- **Model Evolution** / **Еволюция на модели** - How models grow over time

## Running the Examples / Изпълнение на примерите

### Prerequisites / Предварителни условия

Make sure you have Nim installed and the Ormin library available.

Уверете се, че имате инсталиран Nim и налична библиотеката Ormin.

### Compilation / Компилиране

```bash
# Compile and run the flexibility example
# Компилиране и изпълнение на примера за гъвкавост
nim compile --run flexibility_example.nim
```

### Expected Output / Очакван изход

The example will demonstrate various model definition approaches and generate SQL schema for all created models.

Примерът ще демонстрира различни подходи за дефиниране на модели и ще генерира SQL схема за всички създадени модели.

```
Ormin Model Definition Flexibility Examples
Примери за гъвкавост при дефиниране на модели в Ormin
==================================================

=== Macro Approach Example ===
=== Пример с макрос подход ===
Models defined using macro approach
Моделите са дефинирани с макрос подход

=== Object-Oriented Approach Example ===
=== Пример с обектно-ориентиран подход ===
Models created programmatically with conditional fields
Моделите са създадени програмно с условни полета

... (more output)

Generated SQL Schema:
Генерирана SQL схема:
CREATE TABLE IF NOT EXISTS User(
  id dbInt PRIMARY KEY,
  username dbVarchar NOT NULL,
  email dbVarchar NOT NULL,
  created_at dbTimestamp DEFAULT CURRENT_TIMESTAMP
);
... (more SQL)
```

## Demonstrated Approaches / Демонстрирани подходи

### 1. Macro Approach / Макрос подход

**Best for:** / **Най-добър за:**
- Simple models / Прости модели
- Rapid development / Бърза разработка
- Clean, readable code / Чист, четим код

```nim
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull
```

### 2. Object-Oriented Approach / Обектно-ориентиран подход

**Best for:** / **Най-добър за:**
- Programmatic model generation / Програмно генериране на модели
- Conditional fields / Условни полета
- Complex business logic / Сложна бизнес логика

```nim
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
userModel.build()
```

### 3. Dynamic Generation / Динамично генериране

**Best for:** / **Най-добър за:**
- Configuration-driven schemas / Схеми според конфигурацията
- Multi-tenant applications / Мулти-тенант приложения
- Runtime model creation / Създаване на модели по време на изпълнение

```nim
# Models generated from configuration
for config in modelConfigs:
  let model = newModelBuilder(config.name)
  # Add fields based on configuration
  model.build()
```

### 4. Model Templates / Шаблони за модели

**Best for:** / **Най-добър за:**
- Reusable components / Компоненти за многократна употреба
- Consistent patterns / Последователни шаблони
- DRY principle / DRY принцип

```nim
proc addAuditFields(model: ModelBuilder) =
  discard model.column("created_at", dbTimestamp)
  discard model.column("updated_at", dbTimestamp)

# Use template
articleModel.addAuditFields()
```

### 5. Hybrid Approach / Хибриден подход

**Best for:** / **Най-добър за:**
- Large projects / Големи проекти
- Team collaboration / Екипна работа
- Gradual migration / Постепенна миграция

```nim
# Simple models with macro
model "Role":
  id: int, primaryKey
  name: string, notNull

# Complex models with OO approach
let complexModel = newModelBuilder("Complex")
# ... detailed configuration
```

## Key Concepts Demonstrated / Основни концепции, демонстрирани

### Flexibility Benefits / Предимства на гъвкавостта

1. **Choice of Approach** / **Избор на подход**
   - Different methods for different needs
   - Различни методи за различни нужди

2. **Gradual Evolution** / **Постепенна еволюция**
   - Models can evolve over time
   - Моделите могат да еволюират с времето

3. **Team Adaptation** / **Адаптация на екипа**
   - Suitable for different skill levels
   - Подходящ за различни нива на умения

4. **Project Scalability** / **Мащабируемост на проекта**
   - From simple to complex requirements
   - От прости до сложни изисквания

### Conditional Model Building / Условно изграждане на модели

The examples show how to:

Примерите показват как да:

- Add fields based on configuration / Добавяте полета според конфигурацията
- Enable/disable features dynamically / Включвате/изключвате функции динамично
- Create different model variants / Създавате различни варианти на модели
- Maintain backward compatibility / Поддържате обратна съвместимост

### Model Templates and Reusability / Шаблони за модели и многократна употреба

Learn how to:

Научете как да:

- Create reusable field templates / Създавате шаблони за полета за многократна употреба
- Apply common patterns consistently / Прилагате общи шаблони последователно
- Reduce code duplication / Намалявате дублирането на код
- Maintain consistency across models / Поддържате последователност между моделите

### Model Evolution Strategies / Стратегии за еволюция на модели

Understand how to:

Разберете как да:

- Start with simple models / Започвате с прости модели
- Add complexity gradually / Добавяте сложност постепенно
- Maintain multiple model versions / Поддържате множество версии на модели
- Plan for future requirements / Планирате за бъдещи изисквания

## Best Practices Shown / Показани най-добри практики

### 1. Start Simple / Започнете просто

```nim
# Version 1: Basic model
model "User":
  id: int, primaryKey
  username: string, notNull
```

### 2. Add Complexity When Needed / Добавете сложност при нужда

```nim
# Version 2: Enhanced model
let userModel = newModelBuilder("User")
# Add conditional fields based on requirements
```

### 3. Use Templates for Common Patterns / Използвайте шаблони за общи шаблони

```nim
proc addTimestamps(model: ModelBuilder) =
  discard model.column("created_at", dbTimestamp)
  discard model.column("updated_at", dbTimestamp)
```

### 4. Plan for Evolution / Планирайте за еволюция

```nim
# Design models with future extensibility in mind
let futureProofModel = newModelBuilder("Entity")
# Add core fields first, then optional modules
```

## Integration Examples / Примери за интеграция

### With Transactions / С транзакции

```nim
withTransaction(db):
  # Create models and insert data
  createModels()
  # Insert sample data using generated models
```

### With Migrations / С миграции

```nim
# Models can be used with migration system
let migration = createMigration("add_user_models")
# Generate SQL from models for migration
```

### With Queries / Със заявки

```nim
# Generated models work seamlessly with query system
query:
  select user(username, email)
  where user.id == ?userId
```

## Troubleshooting / Отстраняване на неизправности

### Common Issues / Общи проблеми

1. **Model Name Conflicts** / **Конфликти в имената на модели**
   - Use unique names for each model
   - Използвайте уникални имена за всеки модел

2. **Circular Dependencies** / **Кръгови зависимости**
   - Plan foreign key relationships carefully
   - Планирайте връзките с външни ключове внимателно

3. **Type Mismatches** / **Несъответствия в типовете**
   - Ensure consistent type usage across approaches
   - Осигурете последователна употреба на типове в различните подходи

### Debug Tips / Съвети за отстраняване на грешки

- Use `generateSql()` to inspect generated schema
- Използвайте `generateSql()` за проверка на генерираната схема

- Check model registry with `modelRegistry.tables`
- Проверете регистъра на модели с `modelRegistry.tables`

- Validate foreign key references before building
- Валидирайте референциите към външни ключове преди изграждане

## Performance Considerations / Съображения за производителност

### Model Creation / Създаване на модели

- Macro approach: Compile-time generation (fastest)
- Макрос подход: Генериране по време на компилация (най-бърз)

- Object-oriented: Runtime generation (flexible)
- Обектно-ориентиран: Генериране по време на изпълнение (гъвкав)

### Memory Usage / Използване на памет

- Simple models use less memory
- Простите модели използват по-малко памет

- Complex models with many fields require more memory
- Сложните модели с много полета изискват повече памет

### SQL Generation / Генериране на SQL

- All approaches generate equivalent SQL
- Всички подходи генерират еквивалентен SQL

- Performance difference is in model creation, not usage
- Разликата в производителността е при създаването на модели, не при използването

## Further Reading / Допълнително четене

- [Model Flexibility Documentation (Bulgarian)](../../docs/model_flexibility_bg.md)
- [Model Flexibility Documentation (English)](../../docs/model_flexibility_en.md)
- [Main Ormin Documentation (Bulgarian)](../../docs/documentation_bg.md)
- [Main Ormin Documentation (English)](../../docs/documentation_en.md)
- [Transaction API Documentation](../../docs/transactions_api_en.md)

## Contributing / Принос

Feel free to add more examples or improve existing ones. The flexibility examples should demonstrate real-world scenarios and best practices.

Не се колебайте да добавите повече примери или да подобрите съществуващите. Примерите за гъвкавост трябва да демонстрират реални сценарии и най-добри практики.