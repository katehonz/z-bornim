## Example of using the new DSL model definition approach

import ../../ormin
import ../../ormin/models
import ../../ormin/transactions
import ../../ormin/migrations
import times, strutils

# Определение моделей с использованием нового DSL
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

  model Comment:
    id {.primaryKey.}: int
    post_id {.notNull, foreignKey: ("Post", "id").}: int
    user_id {.notNull, foreignKey: ("User", "id").}: int
    content {.notNull.}: string
    created_at {.default: "CURRENT_TIMESTAMP".}: timestamp

# Генерация типов для моделей
createModels()

# Генерация SQL для моделей
let sql = generateSql(modelRegistry)
echo "Generated SQL:\n", sql

# Подключение к базе данных
var db = open("dsl_example.db", "", "", "")

# Настройка миграций
let mm = newMigrationManager(db, migrationsDir = "migrations")

# Создание миграции для наших моделей
let migrationFile = mm.createMigration("dsl_model_schema")
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

proc createComment(postId, userId: int, content: string): int =
  var commentId = 0
  transaction(db):
    # Вставка комментария
    let commentInsertSql = "INSERT INTO Comment (post_id, user_id, content) VALUES (?, ?, ?) RETURNING id"
    for row in db.fastRows(sql(commentInsertSql), $postId, $userId, content):
      commentId = parseInt(row[0])
  
  return commentId

# Создание примера данных
echo "Creating sample data..."

let user1Id = createUser("john_doe", "john@example.com")
echo "Created user with ID: ", user1Id

let user2Id = createUser("jane_smith", "jane@example.com")
echo "Created user with ID: ", user2Id

let post1Id = createPost(user1Id, "DSL Models in Nim", "This is a post about DSL model definition in Ormin!")
echo "Created post with ID: ", post1Id

let comment1Id = createComment(post1Id, user2Id, "Great post about DSL models!")
echo "Created comment with ID: ", comment1Id

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

# Получение всех комментариев с информацией о посте и пользователе
echo "\nAll comments with post and user information:"
let commentQuery = """
  SELECT c.id, c.content, p.title, u.username
  FROM Comment c
  JOIN Post p ON c.post_id = p.id
  JOIN User u ON c.user_id = u.id
"""
for row in db.fastRows(sql(commentQuery)):
  echo "Comment ID: ", row[0], ", Content: ", row[1], ", Post: ", row[2], ", Author: ", row[3]

# Очистка
db.close()
echo "\nExample completed successfully!"