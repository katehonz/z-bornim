# Z-Bornim - Enhanced Ormin ORM for Nim
# Z-Bornim - Подобрена Ormin ORM за Nim
# Z-Bornim - Улучшенная Ormin ORM для Nim

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Nim](https://img.shields.io/badge/nim-2.0+-yellow.svg)](https://nim-lang.org)
[![GitHub](https://img.shields.io/badge/github-katehonz/z--bornim-blue.svg)](https://github.com/katehonz/z-bornim)

**Author / Автор / Автор:** Gigov

## English

### Overview

Z-Bornim is an enhanced version of the Ormin Object-Relational Mapping (ORM) library for the Nim programming language. This fork introduces significant improvements including direct SQL schema integration, enhanced migration support, and a more developer-friendly API.

### Key Features

🚀 **SQL Schema Integration**
- Import database schemas directly from SQL DDL files
- Automatic conversion between SQL and Nim model definitions
- Support for standard SQL constraints and relationships
- Bidirectional schema conversion

🔧 **Enhanced Model Definition**
- Object-oriented model builder API
- DSL-style model definitions
- Automatic type mapping and validation
- Foreign key relationship support

📦 **Advanced Migration System**
- Timestamp-based migration files
- Up/down migration support
- Automatic migration tracking
- Schema versioning

🎯 **Developer Experience**
- Comprehensive documentation
- Rich examples and tutorials
- Type-safe database operations
- Intuitive API design

### Quick Start

#### Installation

```bash
git clone https://github.com/katehonz/z-bornim.git
cd z-bornim
nim install
```

#### Basic Usage

```nim
import ormin/models
import ormin/sql_schema_importer

# Define models using SQL
let sqlSchema = """
CREATE TABLE User (
  id INTEGER PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""

# Import and generate Nim models
let importer = newSqlSchemaImporter()
importer.importFromString(sqlSchema)
let nimCode = importer.generateNimModels()
```

#### Object-Oriented API

```nim
# Create models using the builder pattern
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
userModel.build()
```

### Documentation

- [SQL Integration Guide](docs/sql_integration_guide.md)
- [Migration System](ormin/migrations.nim)
- [Model Definition](ormin/models.nim)
- [Examples](examples/)

### Examples

Check out the comprehensive examples in the `examples/` directory:
- [SQL Integration Examples](examples/sql_integration/)
- [Chat Application](examples/chat/)
- [Forum System](examples/forum/)
- [Twitter Clone](examples/tweeter/)

---

## Русский

### Обзор

Z-Bornim - это улучшенная версия библиотеки объектно-реляционного отображения (ORM) Ormin для языка программирования Nim. Этот форк вводит значительные улучшения, включая прямую интеграцию SQL-схем, расширенную поддержку миграций и более дружелюбный к разработчику API.

### Ключевые особенности

🚀 **Интеграция SQL-схем**
- Импорт схем баз данных напрямую из SQL DDL файлов
- Автоматическое преобразование между SQL и определениями моделей Nim
- Поддержка стандартных SQL ограничений и связей
- Двунаправленное преобразование схем

🔧 **Улучшенное определение моделей**
- Объектно-ориентированный API построителя моделей
- Определения моделей в стиле DSL
- Автоматическое сопоставление типов и валидация
- Поддержка связей внешних ключей

📦 **Продвинутая система миграций**
- Файлы миграций на основе временных меток
- Поддержка миграций вверх/вниз
- Автоматическое отслеживание миграций
- Версионирование схем

🎯 **Опыт разработчика**
- Исчерпывающая документация
- Богатые примеры и руководства
- Типобезопасные операции с базой данных
- Интуитивный дизайн API

### Быстрый старт

#### Установка

```bash
git clone https://github.com/katehonz/z-bornim.git
cd z-bornim
nim install
```

#### Базовое использование

```nim
import ormin/models
import ormin/sql_schema_importer

# Определение моделей с помощью SQL
let sqlSchema = """
CREATE TABLE User (
  id INTEGER PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""

# Импорт и генерация моделей Nim
let importer = newSqlSchemaImporter()
importer.importFromString(sqlSchema)
let nimCode = importer.generateNimModels()
```

#### Объектно-ориентированный API

```nim
# Создание моделей с использованием паттерна строитель
let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
userModel.build()
```

### Документация

- [Руководство по интеграции SQL](docs/sql_integration_guide.md)
- [Система миграций](ormin/migrations.nim)
- [Определение моделей](ormin/models.nim)
- [Примеры](examples/)

---

## Български

### Преглед

Z-Bornim е подобрена версия на библиотеката за обектно-релационно съпоставяне (ORM) Ormin за програмния език Nim. Този форк въвежда значителни подобрения, включително директна интеграция на SQL схеми, подобрена поддръжка на миграции и по-приятелски към разработчиците API.

### Основни характеристики

🚀 **SQL схема интеграция**
- Импортиране на схеми на бази данни директно от SQL DDL файлове
- Автоматично преобразуване между SQL и дефиниции на модели в Nim
- Поддръжка на стандартни SQL ограничения и връзки
- Двупосочно преобразуване на схеми

🔧 **Подобрено дефиниране на модели**
- Обектно-ориентиран API за изграждане на модели
- Дефиниции на модели в DSL стил
- Автоматично съпоставяне на типове и валидация
- Поддръжка на връзки с външни ключове

📦 **Разширена система за миграции**
- Файлове за миграции базирани на времеви печати
- Поддръжка на миграции нагоре/надолу
- Автоматично проследяване на миграции
- Версиониране на схеми

🎯 **Опит на разработчика**
- Изчерпателна документация
- Богати примери и ръководства
- Типово-безопасни операции с бази данни
- Интуитивен дизайн на API

### Бърз старт

#### Инсталация

```bash
git clone https://github.com/katehonz/z-bornim.git
cd z-bornim
nim install
```

#### Основно използване

```nim
import ormin/models
import ormin/sql_schema_importer

# Дефиниране на модели чрез SQL
let sqlSchema = """
CREATE TABLE User (
  id INTEGER PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""

# Импорт и генериране на Nim модели
let importer = newSqlSchemaImporter()
importer.importFromString(sqlSchema)
let nimCode = importer.generateNimModels()
```

## Project Structure / Структура проекта / Структура проекта

```
z-bornim/
├── ormin/                    # Core ORM modules / Основни ORM модули
│   ├── models.nim           # Model definitions / Дефиниции на модели
│   ├── sql_schema_importer.nim  # SQL integration / SQL интеграция
│   ├── migrations.nim       # Migration system / Система за миграции
│   ├── queries.nim          # Query builder / Конструктор на заявки
│   └── ...
├── examples/                # Usage examples / Примери за използване
│   ├── sql_integration/     # SQL integration examples
│   ├── chat/               # Chat application
│   ├── forum/              # Forum system
│   └── tweeter/            # Twitter clone
├── docs/                   # Documentation / Документация
│   └── sql_integration_guide.md
├── tests/                  # Test suite / Тестове
└── README.md              # This file / Този файл
```

## Contributing / Участие / Участие

We welcome contributions! Please feel free to submit issues, feature requests, or pull requests.

Приветстваме приноси! Моля, не се колебайте да изпращате проблеми, заявки за функции или pull request-и.

Мы приветствуем вклады! Пожалуйста, не стесняйтесь отправлять проблемы, запросы функций или pull request-ы.

## License / Лиценз / Лицензия

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Този проект е лицензиран под MIT лиценза - вижте файла [LICENSE](LICENSE) за подробности.

Этот проект лицензирован под лицензией MIT - см. файл [LICENSE](LICENSE) для получения подробной информации.

## Acknowledgments / Благодарности / Благодарности

- Original Ormin library authors / Автори на оригиналната Ormin библиотека / Авторы оригинальной библиотеки Ormin
- Nim community / Nim общност / Nim сообщество
- All contributors / Всички участници / Все участники

---

**Repository:** https://github.com/katehonz/z-bornim  
**Author:** Gigov  
**Version:** Enhanced Ormin with SQL Integration