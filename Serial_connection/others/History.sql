BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "History" (
	"id"	INTEGER,
	"date_time"	DATETIME,
	"systolic_pressure"	INT,
	"medium_pressure"	INT,
	"diastolic_pressure"	INT,
	"pulse"	INT,
	PRIMARY KEY("id")
);
COMMIT;
