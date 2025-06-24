## Quick test for SQL Integration
## Бърз тест за SQL интеграция

import "z-bornim/ormin/sql_schema_importer"
import "z-bornim/ormin/models"
import tables

proc testSqlIntegration() =
  echo "=== Testing SQL Integration ==="
  echo "=== Тестване на SQL интеграция ==="
  
  let sampleSql = """
  CREATE TABLE IF NOT EXISTS User (
    id INTEGER PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  
  CREATE TABLE IF NOT EXISTS Post (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    FOREIGN KEY (user_id) REFERENCES User(id)
  );
  """
  
  let importer = newSqlSchemaImporter()
  importer.importFromString(sampleSql)
  
  echo "Tables imported / Импортирани таблици:"
  for name, table in pairs(importer.tables):
    echo "- " & name & " (" & $table.columns.len & " columns)"
  
  echo "\nGenerated Nim code:"
  echo importer.generateNimModels()

when isMainModule:
  testSqlIntegration()