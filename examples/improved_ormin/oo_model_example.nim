## Example of using the new object-oriented model definition API

import ../../ormin
import ../../ormin/models
import ../../ormin/transactions
import ../../ormin/migrations
import times, strutils

# Объектно-ориентированный подход к определению моделей
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

# Подключение к базе данных
var db = open("oo_example.db", "", "", "")

# Настройка миграций
let mm = newMigrationManager(db, migrationsDir = "migrations")

# Создание миграции для наших моделей
let migrationFile = mm.createMigration("oo_model_schema")
echo "Created migration file: ", migrationFile

# Запись SQL моделей в файл миграции
writeFile(migrationFile, sql)

# Применение миграций
mm.migrateUp()
echo "Applied migrations"

# Вставка данных с использованием транзакций
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

# Создание примера данных
echo "Creating sample data..."

let user1Id = createUser("john_doe", "john@example.com")
echo "Created user with ID: ", user1Id

let post1Id = createPost(user1Id, "Object-Oriented Models", "This is a post about OO model definition in Ormin!")
echo "Created post with ID: ", post1Id

# Запрос данных
echo "\nQuerying data..."

# Получение всех пользователей
echo "\nAll users:"
for row in db.fastRows(sql"SELECT id, username, email FROM User"):
  echo "User ID: ", row[0], ", Username: ", row[1], ", Email: ", row[2]

# Получение всех постов с информацией о пользователе
echo "\nAll posts with user information:"
let postQuery = """
  SELECT p.id, p.title, p.content, u.username
  FROM Post p
  JOIN User u ON p.user_id = u.id
"""
for row in db.fastRows(sql(postQuery)):
  echo "Post ID: ", row[0], ", Title: ", row[1], ", Content: ", row[2], ", Author: ", row[3]

# Очистка
db.close()
echo "\nExample completed successfully!"