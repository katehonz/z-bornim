## Example of using improved Ormin features

import ../../ormin
import ../../ormin/models
import ../../ormin/transactions
import ../../ormin/migrations
import times, strutils

# Define models using the new code-based approach
model "User":
  id: int, primaryKey
  username: string, notNull
  email: string, notNull
  created_at: timestamp, default("CURRENT_TIMESTAMP")

model "Post":
  id: int, primaryKey
  user_id: int, foreignKey("User", "id"), notNull
  title: string, notNull
  content: string, notNull
  created_at: timestamp, default("CURRENT_TIMESTAMP")

model "Comment":
  id: int, primaryKey
  post_id: int, foreignKey("Post", "id"), notNull
  user_id: int, foreignKey("User", "id"), notNull
  content: string, notNull
  created_at: timestamp, default("CURRENT_TIMESTAMP")

# Generate types for the models
createModels()

# Generate SQL for the models
let sql = generateSql(modelRegistry)
echo "Generated SQL:\n", sql

# Connect to the database
var db = open("example.db", "", "", "")

# Set up migrations
let mm = newMigrationManager(db, migrationsDir = "migrations")

# Create a migration for our models
let migrationFile = mm.createMigration("initial_schema")
echo "Created migration file: ", migrationFile

# Write our model SQL to the migration file
writeFile(migrationFile, sql)

# Apply migrations
mm.migrateUp()
echo "Applied migrations"

# Insert data using transactions
proc createUser(username, email: string): int =
  var userId = 0
  transaction(db):
    # Insert user
    let userInsertSql = "INSERT INTO User (username, email) VALUES (?, ?) RETURNING id"
    for row in db.fastRows(sql(userInsertSql), username, email):
      userId = parseInt(row[0])
  
  return userId

proc createPost(userId: int, title, content: string): int =
  var postId = 0
  transaction(db):
    # Insert post
    let postInsertSql = "INSERT INTO Post (user_id, title, content) VALUES (?, ?, ?) RETURNING id"
    for row in db.fastRows(sql(postInsertSql), $userId, title, content):
      postId = parseInt(row[0])
  
  return postId

proc createComment(postId, userId: int, content: string): int =
  var commentId = 0
  transaction(db):
    # Insert comment
    let commentInsertSql = "INSERT INTO Comment (post_id, user_id, content) VALUES (?, ?, ?) RETURNING id"
    for row in db.fastRows(sql(commentInsertSql), $postId, $userId, content):
      commentId = parseInt(row[0])
  
  return commentId

# Create some sample data
echo "Creating sample data..."

let user1Id = createUser("john_doe", "john@example.com")
echo "Created user with ID: ", user1Id

let user2Id = createUser("jane_smith", "jane@example.com")
echo "Created user with ID: ", user2Id

let post1Id = createPost(user1Id, "Hello World", "This is my first post!")
echo "Created post with ID: ", post1Id

let post2Id = createPost(user2Id, "Nim is awesome", "I love programming in Nim!")
echo "Created post with ID: ", post2Id

let comment1Id = createComment(post1Id, user2Id, "Welcome to the blog!")
echo "Created comment with ID: ", comment1Id

let comment2Id = createComment(post2Id, user1Id, "I agree, Nim is great!")
echo "Created comment with ID: ", comment2Id

# Query data
echo "\nQuerying data..."

# Get all users
echo "\nAll users:"
for row in db.fastRows(sql"SELECT id, username, email FROM User"):
  echo "User ID: ", row[0], ", Username: ", row[1], ", Email: ", row[2]

# Get all posts with user information
echo "\nAll posts with user information:"
let postQuery = """
  SELECT p.id, p.title, p.content, u.username
  FROM Post p
  JOIN User u ON p.user_id = u.id
"""
for row in db.fastRows(sql(postQuery)):
  echo "Post ID: ", row[0], ", Title: ", row[1], ", Content: ", row[2], ", Author: ", row[3]

# Get all comments with post and user information
echo "\nAll comments with post and user information:"
let commentQuery = """
  SELECT c.id, c.content, p.title, u.username
  FROM Comment c
  JOIN Post p ON c.post_id = p.id
  JOIN User u ON c.user_id = u.id
"""
for row in db.fastRows(sql(commentQuery)):
  echo "Comment ID: ", row[0], ", Content: ", row[1], ", Post: ", row[2], ", Author: ", row[3]

# Clean up
db.close()
echo "\nExample completed successfully!"