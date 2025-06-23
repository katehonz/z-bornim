# Ormin - Improved ORM for Nim

This is an improved version of the Ormin ORM library for Nim, with additional features and enhancements.

## New Features

### 1. Model Definition in Code

You can now define your models directly in Nim code, similar to SQLAlchemy in Python:

```nim
import ormin/models

model "User":
  username: string, primaryKey
  email: string, notNull
  age: int

# Generate types for the models
createModels()
```

### 2. Transaction Support

Execute multiple queries in a single transaction:

```nim
import ormin/transactions

transaction(db):
  query:
    insert user(username = ?user.username)
  
  query:
    insert message(username = ?user.username, content = ?content)
```

### 3. Database Migrations

Manage changes to your database schema:

```nim
import ormin/migrations

# Create a migration manager
let mm = newMigrationManager(db)

# Create a new migration
let migrationFile = mm.createMigration("add_user_table")

# Apply all pending migrations
mm.migrateUp()

# Roll back the last migration
mm.migrateDown(1)
```

## Documentation

- [Documentation in English](docs/documentation_en.md)
- [Documentation in Bulgarian](docs/documentation_bg.md)

## Examples

Check out the [improved example](examples/improved_ormin/example.nim) to see how to use all the new features together.

## Original Ormin Features

The original Ormin features are still available:

- Define models in SQL files
- Type-safe query DSL
- Support for SQLite, PostgreSQL, and MySQL
- Compile-time code generation
- Type safety

## Future Improvements

Planned improvements for future versions:

1. **Improved Relationship Support**: More explicit API for working with relationships between tables in Nim code.
2. **Asynchronous Operation Support**: Adding support for asynchronous database queries.
3. **Query Caching**: Implementation of a caching mechanism to improve performance.
4. **Lazy Loading**: Adding support for lazy loading of related objects.
5. **Data Validation**: Adding a mechanism for validating data before saving to the database.
6. **Complex Query Support**: Extending the DSL to support more complex queries, such as subqueries, window functions, etc.

## License

MIT License