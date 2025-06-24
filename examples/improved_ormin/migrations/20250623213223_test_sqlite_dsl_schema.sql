CREATE TABLE IF NOT EXISTS User(
  id dbInt PRIMARY KEY,
  username dbVarchar,
  email dbVarchar,
  created_at dbTimestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Post(
  id dbInt,
  user_id dbInt,
  title dbVarchar,
  content dbVarchar,
  created_at dbTimestamp
);

