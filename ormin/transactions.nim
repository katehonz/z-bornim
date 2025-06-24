## Ormin -- ORM for Nim.
## Transaction support module

import models

type
  Transaction* = ref object
    db*: DbConn
    active*: bool

proc newTransaction*(db: DbConn): Transaction =
  ## Creates a new transaction
  result = Transaction(
    db: db,
    active: false
  )

proc begin*(t: Transaction) =
  ## Begins a transaction
  if t.active:
    raise newException(DbError, "Transaction already active")
  
  t.db.exec(sql"BEGIN TRANSACTION")
  t.active = true

proc commit*(t: Transaction) =
  ## Commits a transaction
  if not t.active:
    raise newException(DbError, "No active transaction to commit")
  
  t.db.exec(sql"COMMIT")
  t.active = false

proc rollback*(t: Transaction) =
  ## Rolls back a transaction
  if not t.active:
    raise newException(DbError, "No active transaction to rollback")
  
  t.db.exec(sql"ROLLBACK")
  t.active = false

template withTransaction*(db: DbConn, body: untyped) =
  ## Executes the body within a transaction
  ## Automatically commits if successful or rolls back if an exception is raised
  var transaction = newTransaction(db)
  transaction.begin()
  try:
    body
    transaction.commit()
  except:
    if transaction.active:
      transaction.rollback()
    raise

template transaction*(db: DbConn, body: untyped) =
  ## Alias for withTransaction
  withTransaction(db, body)