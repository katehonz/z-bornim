## Test script for the new model definition approaches with SQLite

import ../../ormin
import ../../ormin/models
import ../../ormin/transactions
import ../../ormin/migrations
import times, strutils, os, tables

echo "Testing new model definition approaches with SQLite..."

# Удаляем старую тестовую базу данных, если она существует
if fileExists("test_sqlite.db"):
  removeFile("test_sqlite.db")
  echo "Removed old test database"

# Создаем директорию для миграций, если она не существует
if not dirExists("migrations"):
  createDir("migrations")
  echo "Created migrations directory"

# 1. Тестирование объектно-ориентированного подхода
echo "\n1. Testing Object-Oriented approach..."

let userModel = newModelBuilder("User")
discard userModel.column("id", dbInt).primaryKey()
discard userModel.column("username", dbVarchar).notNull()
discard userModel.column("email", dbVarchar).notNull()
discard userModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
userModel.build()

let postModel = newModelBuilder("Post")
discard postModel.column("id", dbInt).primaryKey()
discard postModel.column("user_id", dbInt).notNull().foreignKey("User", "id")
discard postModel.column("title", dbVarchar).notNull()
discard postModel.column("content", dbVarchar).notNull()
discard postModel.column("created_at", dbTimestamp).default("CURRENT_TIMESTAMP")
postModel.build()

# Генерация типов для моделей
createModels()

# Генерация SQL для моделей
let sql = generateSql(modelRegistry)
echo "Generated SQL:\n", sql

# Подключение к базе данных SQLite
var db = open("test_sqlite.db", "", "", "")
echo "Connected to SQLite database"

# Настройка миграций
let mm = newMigrationManager(db, migrationsDir = "migrations")

# Создание миграции для наших моделей
let migrationFile = mm.createMigration("test_sqlite_schema")
echo "Created migration file: ", migrationFile

# Запись SQL моделей в файл миграции
writeFile(migrationFile, sql)

# Применение миграций
mm.migrateUp()
echo "Applied migrations"

# Вставка тестовых данных
proc createUser(username, email: string): int =
  var userId = 0
  transaction(db):
    # Вставка пользователя
    let userInsertSql = "INSERT INTO User (username, email) VALUES (?, ?) RETURNING id"
    for row in db.fastRows(sql(userInsertSql), username, email):
      userId = parseInt(row[0])
  
  return userId

proc createPost(userId: int, title, content: string): int =
  var postId = 0
  transaction(db):
    # Вставка поста
    let postInsertSql = "INSERT INTO Post (user_id, title, content) VALUES (?, ?, ?) RETURNING id"
    for row in db.fastRows(sql(postInsertSql), $userId, title, content):
      postId = parseInt(row[0])
  
  return postId

echo "Creating test data..."
let user1Id = createUser("test_user", "test@example.com")
echo "Created user with ID: ", user1Id

let post1Id = createPost(user1Id, "Test Post", "This is a test post content")
echo "Created post with ID: ", post1Id

# Запрос данных
echo "\nQuerying data..."
echo "All users:"
for row in db.fastRows(sql"SELECT id, username, email FROM User"):
  echo "User ID: ", row[0], ", Username: ", row[1], ", Email: ", row[2]

echo "\nAll posts with user information:"
let postQuery = """
  SELECT p.id, p.title, p.content, u.username
  FROM Post p
  JOIN User u ON p.user_id = u.id
"""
for row in db.fastRows(sql(postQuery)):
  echo "Post ID: ", row[0], ", Title: ", row[1], ", Content: ", row[2], ", Author: ", row[3]

# Очистка перед следующим тестом
db.close()
modelRegistry = ModelRegistry(tables: initOrderedTable[string, models.Table]())
echo "Cleaned up for next test"

# 2. Тестирование DSL подхода
echo "\n2. Testing DSL approach..."

# Удаляем старую тестовую базу данных, если она существует
if fileExists("test_sqlite_dsl.db"):
  removeFile("test_sqlite_dsl.db")
  echo "Removed old test database"

# Определение моделей с использованием DSL
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
    content {.notNull.}: string
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp

# Генерация типов для моделей
createModels()

# Генерация SQL для моделей
let sqlDsl = generateSql(modelRegistry)
echo "Generated SQL:\n", sqlDsl

# Подключение к базе данных SQLite
var dbDsl = open("test_sqlite_dsl.db", "", "", "")
echo "Connected to SQLite database"

# Настройка миграций
let mmDsl = newMigrationManager(dbDsl, migrationsDir = "migrations")

# Создание миграции для наших моделей
let migrationFileDsl = mmDsl.createMigration("test_sqlite_dsl_schema")
echo "Created migration file: ", migrationFileDsl

# Запись SQL моделей в файл миграции
writeFile(migrationFileDsl, sqlDsl)

# Применение миграций
mmDsl.migrateUp()
echo "Applied migrations"

# Вставка тестовых данных
proc createUserDsl(username, email: string): int =
  var userId = 0
  transaction(dbDsl):
    # Вставка пользователя
    let userInsertSql = "INSERT INTO User (username, email) VALUES (?, ?) RETURNING id"
    for row in dbDsl.fastRows(sql(userInsertSql), username, email):
      userId = parseInt(row[0])
  
  return userId

proc createPostDsl(userId: int, title, content: string): int =
  var postId = 0
  transaction(dbDsl):
    # Вставка поста
    let postInsertSql = "INSERT INTO Post (user_id, title, content) VALUES (?, ?, ?) RETURNING id"
    for row in dbDsl.fastRows(sql(postInsertSql), $userId, title, content):
      postId = parseInt(row[0])
  
  return postId

echo "Creating test data..."
let user1IdDsl = createUserDsl("dsl_user", "dsl@example.com")
echo "Created user with ID: ", user1IdDsl

let post1IdDsl = createPostDsl(user1IdDsl, "DSL Test Post", "This is a test post content using DSL")
echo "Created post with ID: ", post1IdDsl

# Запрос данных
echo "\nQuerying data..."
echo "All users:"
for row in dbDsl.fastRows(sql"SELECT id, username, email FROM User"):
  echo "User ID: ", row[0], ", Username: ", row[1], ", Email: ", row[2]

echo "\nAll posts with user information:"
let postQueryDsl = """
  SELECT p.id, p.title, p.content, u.username
  FROM Post p
  JOIN User u ON p.user_id = u.id
"""
for row in dbDsl.fastRows(sql(postQueryDsl)):
  echo "Post ID: ", row[0], ", Title: ", row[1], ", Content: ", row[2], ", Author: ", row[3]

# Закрытие соединения с базой данных
dbDsl.close()
echo "\nTests completed successfully!"