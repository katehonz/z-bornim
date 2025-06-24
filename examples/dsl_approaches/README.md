# DSL Approaches Examples / Примери за DSL Подходи

This directory contains comprehensive examples demonstrating different approaches to model definition in Ormin.

Тази директория съдържа цялостни примери, демонстриращи различни подходи за дефиниране на модели в Ormin.

## Files / Файлове

### [`comprehensive_dsl_example.nim`](comprehensive_dsl_example.nim)
**English**: Complete example showcasing all three DSL approaches with real-world models and database operations.

**Български**: Пълен пример, показващ всички три DSL подхода с реални модели и операции с база данни.

## DSL Approaches / DSL Подходи

### 1. Macro Approach / Макрос Подход
**English**: Simple and clean syntax for quick model definition.

**Български**: Прост и чист синтаксис за бързо дефиниране на модели.

```nim
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull
  created_at: timestamp, default("CURRENT_TIMESTAMP")
```

### 2. Object-Oriented Approach / Обектно-ориентиран Подход
**English**: Flexible programmatic definition with method chaining.

**Български**: Гъвкаво програмно дефиниране с верижно извикване на методи.

```nim
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
userModel.build()
```

### 3. Pragma-based DSL Approach / DSL Подход с Прагми
**English**: Declarative syntax with pragmas for enhanced readability.

**Български**: Декларативен синтаксис с прагми за подобрена четимост.

```nim
model "User":
  id {.primaryKey.}: int
  username {.notNull, unique.}: string
  email {.notNull, indexed.}: string
  created_at {.default: "CURRENT_TIMESTAMP".}: timestamp
```

## Running the Examples / Изпълнение на Примерите

### Prerequisites / Предварителни изисквания
**English**: Make sure you have Nim installed and the Ormin library available.

**Български**: Уверете се, че имате инсталиран Nim и достъпна библиотеката Ormin.

### Compilation / Компилация
```bash
# Compile the comprehensive example
# Компилиране на цялостния пример
nim c -r examples/dsl_approaches/comprehensive_dsl_example.nim
```

### Expected Output / Очакван изход
**English**: The example will demonstrate all three approaches, generate SQL schema, create a database, and perform sample operations.

**Български**: Примерът ще демонстрира всички три подхода, ще генерира SQL схема, ще създаде база данни и ще извърши примерни операции.

## Features Demonstrated / Демонстрирани Функции

### Model Definition / Дефиниране на Модели
- **English**: Basic column types and constraints
- **Български**: Основни типове колони и ограничения
- Primary keys / Първични ключове
- Foreign keys / Външни ключове
- Default values / Стойности по подразбиране
- NOT NULL constraints / NOT NULL ограничения

### Advanced Features / Разширени Функции
- **English**: Conditional model generation
- **Български**: Условно генериране на модели
- Dynamic schema creation / Динамично създаване на схема
- Migration support / Поддръжка на миграции
- Transaction handling / Обработка на транзакции

### Database Operations / Операции с База Данни
- **English**: Schema generation and migration
- **Български**: Генериране на схема и миграция
- Data insertion / Вмъкване на данни
- Query execution / Изпълнение на заявки
- Transaction management / Управление на транзакции

## Model Examples / Примери за Модели

### Blog System / Блог Система
- User management / Управление на потребители
- Content organization / Организация на съдържание
- Comment system / Система за коментари
- Tag management / Управление на тагове

### CMS Features / CMS Функции
- Media management / Управление на медия
- Role-based permissions / Разрешения базирани на роли
- Audit logging / Одит логване
- Settings management / Управление на настройки

## Best Practices / Най-добри Практики

### Naming Conventions / Конвенции за Именуване
**English**: 
- Use PascalCase for model names: `User`, `BlogPost`
- Use snake_case for column names: `user_id`, `created_at`

**Български**:
- Използвайте PascalCase за имена на модели: `User`, `BlogPost`
- Използвайте snake_case за имена на колони: `user_id`, `created_at`

### Model Organization / Организация на Модели
**English**: Group related models together and use consistent patterns.

**Български**: Групирайте свързаните модели заедно и използвайте последователни шаблони.

### Performance / Производителност
**English**: Add indexes on frequently queried columns.

**Български**: Добавяйте индекси върху често заявявани колони.

## Troubleshooting / Отстраняване на Проблеми

### Common Issues / Често Срещани Проблеми

#### Compilation Errors / Грешки при Компилация
**English**: Make sure all imports are correct and the Ormin library is properly installed.

**Български**: Уверете се, че всички импорти са правилни и библиотеката Ormin е правилно инсталирана.

#### Database Errors / Грешки в Базата Данни
**English**: Check that the database file permissions are correct and the directory exists.

**Български**: Проверете дали разрешенията за файла на базата данни са правилни и директорията съществува.

#### Migration Issues / Проблеми с Миграции
**English**: Ensure the migrations directory exists and has write permissions.

**Български**: Уверете се, че директорията за миграции съществува и има разрешения за запис.

## Further Reading / Допълнително Четене

### Documentation / Документация
- [`../../docs/dsl_approaches_en.md`](../../docs/dsl_approaches_en.md) - English documentation
- [`../../docs/dsl_approaches_bg.md`](../../docs/dsl_approaches_bg.md) - Bulgarian documentation

### Related Examples / Свързани Примери
- [`../model_flexibility/`](../model_flexibility/) - Model flexibility examples
- [`../improved_ormin/`](../improved_ormin/) - Improved Ormin features

## Contributing / Принос

**English**: Feel free to contribute additional examples or improvements to existing ones.

**Български**: Не се колебайте да допринесете с допълнителни примери или подобрения на съществуващите.

### Guidelines / Насоки
- Follow existing code style / Следвайте съществуващия стил на код
- Add comments in both English and Bulgarian / Добавяйте коментари на английски и български
- Include comprehensive examples / Включвайте цялостни примери
- Test your code before submitting / Тествайте кода си преди изпращане

## License / Лиценз

**English**: This code is provided under the same license as the Ormin project.

**Български**: Този код се предоставя под същия лиценз като проекта Ormin.