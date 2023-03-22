CREATE TABLE AUDIT_TABLES_OBJECTS_LIST (
	ID NUMBER(38,0) NOT NULL,
	T_SCHEMA VARCHAR2(100),
	SOURCE_TABLE VARCHAR2(100),
	AUD_TABLE VARCHAR2(100),
	AUD_SEQ VARCHAR2(100),
	AUD_TRIGGER VARCHAR2(100),
	TABLE_TRIGGER VARCHAR2(100),
	CONSTRAINT AUDIT_TABLES_OBJECTS_LIST_PK PRIMARY KEY (ID),
	CONSTRAINT AUDIT_TABLES_OBJECTS_LIST_UN UNIQUE (T_SCHEMA, SOURCE_TABLE)
);

CREATE SEQUENCE AUDIT_TABLES_OBJECTS_LIST_SEQ
	START WITH 1
	INCREMENT BY 1
	NOCACHE
	NOCYCLE;

CREATE OR REPLACE TRIGGER AUDIT_TABLES_OBJECTS_LIST_I_U
	BEFORE INSERT OR UPDATE
		ON AUDIT_TABLES_OBJECTS_LIST
	FOR EACH ROW
DECLARE
BEGIN
	IF INSERTING THEN
		:NEW.ID := AUDIT_TABLES_OBJECTS_LIST_SEQ.nextval;
	END IF;

	IF(UPDATING) THEN
		IF :NEW.ID <> :OLD.ID THEN 
			raise_application_error(-20555, 'Can`t change id');
		END IF;
	END IF;
	
	:NEW.T_SCHEMA:= UPPER(:NEW.T_SCHEMA);
	:NEW.SOURCE_TABLE:= UPPER(:NEW.SOURCE_TABLE);
	:NEW.AUD_TABLE:=UPPER(:NEW.AUD_TABLE);

END AUDIT_TABLES_OBJECTS_LIST_I_U;
/