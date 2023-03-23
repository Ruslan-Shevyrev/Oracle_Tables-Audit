CREATE OR REPLACE PACKAGE BODY PKG_AUDIT
AS
 
PROCEDURE CREATE_AUDIT_OBJECTS(vTABLE_NAME	IN varchar2,
								vSCHEMA		IN varchar2 DEFAULT vSCHEMA_DEFAULT,
								tGRANTS		IN GRANTS DEFAULT NULL,
								nINSERT		IN NUMBER DEFAULT 1,
								nUPDATE		IN NUMBER DEFAULT 1,
								nDELETE		IN NUMBER DEFAULT 1,
								nTIME_TYPE	IN NUMBER DEFAULT NULL,
								nDAYS_CNT	IN NUMBER DEFAULT NULL,
								nMONTHS_CNT	IN NUMBER DEFAULT NULL)
AS
BEGIN
	PKG_AUDIT.CREATE_AUDIT_OBJECTS_CUSTOM(vTABLE_NAME	=>vTABLE_NAME,
										vSCHEMA			=>vSCHEMA,
										vAUD_TABLE		=>'AUD_'||vTABLE_NAME,
										vAUD_SEQ		=>'AUD_'||vTABLE_NAME||'_SEQ',
										nAUD_SEQ_CACHE	=>100,
										vAUD_TRG_NAME	=>'AUD_'||vTABLE_NAME||'_I',
										vTABLE_TRG_NAME	=>'LOG_'||vTABLE_NAME,
										tGRANTS			=>tGRANTS,
										nINSERT			=>nINSERT,
										nUPDATE			=>nUPDATE,
										nDELETE			=>nDELETE,
										nTIME_TYPE		=>nTIME_TYPE,
										nDAYS_CNT		=>nDAYS_CNT,
										nMONTHS_CNT		=>nMONTHS_CNT);
END CREATE_AUDIT_OBJECTS;

PROCEDURE CREATE_AUDIT_OBJECTS_CUSTOM(vTABLE_NAME	IN varchar2,
									vSCHEMA			IN varchar2,
									vAUD_TABLE		IN varchar2,
									vAUD_SEQ		IN varchar2,
									nAUD_SEQ_CACHE	IN NUMBER DEFAULT NULL,
									vAUD_TRG_NAME	IN varchar2,
									vTABLE_TRG_NAME	IN varchar2,
									tGRANTS			IN GRANTS DEFAULT NULL,
									nINSERT			IN NUMBER DEFAULT 1,
									nUPDATE			IN NUMBER DEFAULT 1,
									nDELETE			IN NUMBER DEFAULT 1,
									nTIME_TYPE		IN NUMBER DEFAULT NULL,
									nDAYS_CNT		IN NUMBER DEFAULT NULL,
									nMONTHS_CNT		IN NUMBER DEFAULT NULL)
AS
	AUD_TABLE		varchar2(100);
	SOURCE_TABLE	varchar2(100);
	AUD_SEQ_CACHE	varchar2(50);
	AUD_SEQ			varchar2(100);
	AUD_TRG_NAME	varchar2(100);
	TABLE_TRG_NAME	varchar2(100);
	vINSERT			varchar2(4000);
	vUPDATE			varchar2(4000);
	vDELETE			varchar2(4000);
	LIST_AUD_ID		NUMBER;
BEGIN

	IF nINSERT NOT IN (1, 0) THEN
		raise_application_error(-20555, 'nINSERT must be 1 or 0');
	END IF;

	IF nUPDATE NOT IN (1, 0) THEN
		raise_application_error(-20555, 'nUPDATE must be 1 or 0');
	END IF;

	IF nDELETE NOT IN (1, 0) THEN
		raise_application_error(-20555, 'nDELETE must be 1 or 0');
	END IF;
	
	BEGIN
		SELECT OWNER||'.'||TABLE_NAME
			INTO SOURCE_TABLE
			FROM ALL_TABLES 
				WHERE TABLE_NAME = UPPER(vTABLE_NAME);
	EXCEPTION WHEN no_data_found THEN
		raise_application_error(-20555, 'Table not found');
	END;

	BEGIN
		SELECT ID
			INTO LIST_AUD_ID
			FROM AUDIT_TABLES_OBJECTS_LIST
			WHERE T_SCHEMA = upper(vSCHEMA)
				AND SOURCE_TABLE = upper(vTABLE_NAME);
		raise_application_error(-20555, 'Audit already exists');
	EXCEPTION WHEN no_data_found THEN
		LIST_AUD_ID:=NULL;
	END;

	AUD_TABLE:=upper(vSCHEMA)||'.'||upper(vAUD_TABLE);
	AUD_SEQ	:=upper(vSCHEMA)||'.'||upper(vAUD_SEQ);
	AUD_TRG_NAME :=upper(vSCHEMA)||'.'||upper(vAUD_TRG_NAME);
	TABLE_TRG_NAME :=upper(vSCHEMA)||'.'||upper(vTABLE_TRG_NAME);

	INSERT INTO AUDIT_TABLES_OBJECTS_LIST(T_SCHEMA,
										SOURCE_TABLE)
		VALUES (UPPER(vSCHEMA),
				UPPER(vTABLE_NAME)) RETURNING ID INTO LIST_AUD_ID;
	COMMIT;

	EXECUTE IMMEDIATE 'CREATE TABLE '||AUD_TABLE||' AS (SELECT * FROM '||SOURCE_TABLE||' WHERE 1=0)';

	EXECUTE IMMEDIATE 'ALTER TABLE '||AUD_TABLE|| ' ADD AUD_ID NUMBER PRIMARY KEY';
	EXECUTE IMMEDIATE 'ALTER TABLE '||AUD_TABLE|| ' ADD OPERATION varchar2(1)';
	EXECUTE IMMEDIATE 'ALTER TABLE '||AUD_TABLE|| ' ADD AUD_USER_ID NUMBER';
	EXECUTE IMMEDIATE 'ALTER TABLE '||AUD_TABLE|| ' ADD AUD_USER varchar2(200)';
	EXECUTE IMMEDIATE 'ALTER TABLE '||AUD_TABLE|| ' ADD AUD_DATE DATE';

	UPDATE AUDIT_TABLES_OBJECTS_LIST
		SET AUD_TABLE = UPPER(vAUD_TABLE) 
		WHERE ID = LIST_AUD_ID;
	COMMIT;

	IF tGRANTS IS NOT NULL THEN
		FOR i IN tGRANTS.FIRST .. tGRANTS.LAST LOOP
			EXECUTE IMMEDIATE 'GRANT SELECT ON '||AUD_TABLE||' TO '||tGRANTS(i);
		END LOOP;
	END IF;

	IF nAUD_SEQ_CACHE IS NULL THEN
		AUD_SEQ_CACHE:='NOCACHE';
	ELSE
		AUD_SEQ_CACHE:='CACHE '||nAUD_SEQ_CACHE;
	END IF;

	EXECUTE IMMEDIATE 'CREATE SEQUENCE '||AUD_SEQ||' '||
						'START WITH 1 '||
						'INCREMENT BY 1 '||
						AUD_SEQ_CACHE||' '||
						'NOCYCLE';
					
	UPDATE AUDIT_TABLES_OBJECTS_LIST
		SET AUD_SEQ = UPPER(vAUD_SEQ) 
		WHERE ID = LIST_AUD_ID;
	COMMIT;

	EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '|| AUD_TRG_NAME||' '||chr(10)||chr(13)||
						'BEFORE INSERT '||chr(10)||chr(13)||
						'ON '||AUD_TABLE||' '||chr(10)||chr(13)||
						'FOR EACH ROW '||chr(10)||chr(13)||
						'DECLARE '||chr(10)||chr(13)||
						'BEGIN '||chr(10)||chr(13)||
							':NEW.AUD_ID := '||AUD_SEQ||'.nextval; '||chr(10)||chr(13)||
						'END '||upper(vAUD_TRG_NAME)||';';

	UPDATE AUDIT_TABLES_OBJECTS_LIST
		SET AUD_TRIGGER = UPPER(vAUD_TRG_NAME)
		WHERE ID = LIST_AUD_ID;
	COMMIT;

	IF nINSERT = 1 THEN 
		vINSERT:='INSERT INTO '||AUD_TABLE||'( '||chr(10)||chr(13);
		FOR c IN (SELECT COLUMN_NAME 
					FROM all_tab_columns 
					WHERE OWNER = vSCHEMA
						AND TABLE_NAME = vTABLE_NAME)
		LOOP
				vINSERT:=vINSERT||c.COLUMN_NAME||', '||chr(10)||chr(13);
		END LOOP;

		vINSERT:=vINSERT||
				'OPERATION, '||chr(10)||chr(13)||
				'AUD_USER_ID, '||chr(10)||chr(13)||
				'AUD_USER, '||chr(10)||chr(13)||
				'AUD_DATE) '||chr(10)||chr(13)||
				'VALUES( '||chr(10)||chr(13);
		
		FOR c IN (SELECT COLUMN_NAME 
					FROM all_tab_columns 
					WHERE OWNER = vSCHEMA
						AND TABLE_NAME = vTABLE_NAME)
		LOOP 
			vINSERT:=vINSERT||':new.'||c.COLUMN_NAME||', '||chr(10)||chr(13);
		END LOOP;

		vINSERT:=vINSERT||
			'''I'', '||chr(10)||chr(13)||
			'nAUD_USER_ID, '||chr(10)||chr(13)||
			'vAUD_USER, '||chr(10)||chr(13)||
			'SYSDATE); '||chr(10)||chr(13);
		
	ELSE
		vINSERT:='null;';
	END IF;

	IF nUPDATE = 1 THEN 
		vUPDATE:='INSERT INTO '||AUD_TABLE||'( '||chr(10)||chr(13);
		FOR c IN (SELECT COLUMN_NAME 
					FROM all_tab_columns 
					WHERE OWNER = vSCHEMA
						AND TABLE_NAME = vTABLE_NAME)
		LOOP 
				vUPDATE:=vUPDATE||c.COLUMN_NAME||', '||chr(10)||chr(13);
		END LOOP;

		vUPDATE:=vUPDATE||
				'OPERATION, '||chr(10)||chr(13)||
				'AUD_USER_ID, '||chr(10)||chr(13)||
				'AUD_USER, '||chr(10)||chr(13)||
				'AUD_DATE) '||chr(10)||chr(13)||
				'VALUES( '||chr(10)||chr(13);

		FOR c IN (SELECT COLUMN_NAME 
					FROM all_tab_columns 
					WHERE OWNER = vSCHEMA
						AND TABLE_NAME = vTABLE_NAME)
		LOOP
			vUPDATE:=vUPDATE||':new.'||c.COLUMN_NAME||', '||chr(10)||chr(13);
		END LOOP;

		vUPDATE:=vUPDATE||
			'''U'', '||chr(10)||chr(13)||
			'nAUD_USER_ID, '||chr(10)||chr(13)||
			'vAUD_USER, '||chr(10)||chr(13)||
			'SYSDATE); '||chr(10)||chr(13);

	ELSE
		vUPDATE:='null;';
	END IF;

IF nDELETE = 1 THEN 
		vDELETE:='INSERT INTO '||AUD_TABLE||'( '||chr(10)||chr(13);
		FOR c IN (SELECT COLUMN_NAME 
					FROM all_tab_columns 
					WHERE OWNER = vSCHEMA
						AND TABLE_NAME = vTABLE_NAME)
		LOOP
				vDELETE:=vDELETE||c.COLUMN_NAME||', '||chr(10)||chr(13);
		END LOOP;

		vDELETE:=vDELETE||
				'OPERATION, '||chr(10)||chr(13)||
				'AUD_USER_ID, '||chr(10)||chr(13)||
				'AUD_USER, '||chr(10)||chr(13)||
				'AUD_DATE) '||chr(10)||chr(13)||
				'VALUES( '||chr(10)||chr(13);

		FOR c IN (SELECT COLUMN_NAME 
					FROM all_tab_columns 
					WHERE OWNER = vSCHEMA
						AND TABLE_NAME = vTABLE_NAME)
		LOOP 
			vDELETE:=vDELETE||':old.'||c.COLUMN_NAME||', '||chr(10)||chr(13);
		END LOOP;

		vDELETE:=vDELETE||
			'''D'', '||chr(10)||chr(13)||
			'nAUD_USER_ID, '||chr(10)||chr(13)||
			'vAUD_USER, '||chr(10)||chr(13)||
			'SYSDATE); '||chr(10)||chr(13);

	ELSE
		vDELETE:='null;';
	END IF;

	EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '||TABLE_TRG_NAME||' '||chr(10)||chr(13)||
						'AFTER INSERT OR UPDATE OR DELETE '||chr(10)||chr(13)||
						'ON '||SOURCE_TABLE||' '||chr(10)||chr(13)||
						'FOR EACH ROW '||chr(10)||chr(13)||
						'DECLARE '||chr(10)||chr(13)||
						'pragma autonomous_transaction; '||chr(10)||chr(13)||
						'vAUD_USER		VARCHAR2(4000); '||chr(10)||chr(13)||
						'nAUD_USER_ID	NUMBER; '||chr(10)||chr(13)||
						'BEGIN '||chr(10)||chr(13)||
							'vAUD_USER :=nvl(v(''APP_USER''), sys_context(''userenv'',''os_user'')); '||chr(10)||chr(13)||
							'nAUD_USER_ID	:=v(''EXT_USERID''); '||chr(10)||chr(13)||
							'IF INSERTING THEN '||chr(10)||chr(13)||
								vINSERT||chr(10)||chr(13)||
							'ELSIF UPDATING THEN '||chr(10)||chr(13)||
								vUPDATE||chr(10)||chr(13)||
							'ELSIF DELETING THEN '||chr(10)||chr(13)||
								vDELETE||chr(10)||chr(13)||
							'END IF; '||chr(10)||chr(13)||
							'COMMIT; '||chr(10)||chr(13)||
						'END '||upper(vAUD_TRG_NAME)||';';

	UPDATE AUDIT_TABLES_OBJECTS_LIST
		SET TABLE_TRIGGER = UPPER(vTABLE_TRG_NAME) 
		WHERE ID = LIST_AUD_ID;
	COMMIT;

	IF nTIME_TYPE IS NOT NULL THEN
		PKG_AUDIT.CREATE_AUDIT_CLEAR(P_vSCHEMA		=>UPPER(vSCHEMA),
									P_vTABLE_NAME	=>UPPER(vAUD_TABLE),
									P_vCOLUMN_NAME	=>'AUD_DATE',
									P_nTIME_TYPE	=>nTIME_TYPE,
									P_nDAYS_CNT		=>nDAYS_CNT,
									P_nMONTHS_CNT	=>nMONTHS_CNT,
									P_vIS_ACTIVE	=>'Y');
	END IF;

END CREATE_AUDIT_OBJECTS_CUSTOM;

PROCEDURE DROP_AUDIT_OBJECTS(nID IN NUMBER)
AS
	vSCHEMA 	varchar2(100);
	vTABLE_NAME varchar2(100);
BEGIN
	
	BEGIN
		SELECT T_SCHEMA,
				SOURCE_TABLE
			INTO
				vSCHEMA,
				vTABLE_NAME
			FROM AUDIT_TABLES_OBJECTS_LIST
			WHERE ID = nID;
		
	EXCEPTION WHEN no_data_found THEN
		raise_application_error(-20555, 'Audit not found');
	END;

	PKG_AUDIT.DROP_AUDIT_OBJECTS(vSCHEMA	=>vSCHEMA,
								vTABLE_NAME	=>vTABLE_NAME);
							
END DROP_AUDIT_OBJECTS;

PROCEDURE DROP_AUDIT_OBJECTS(vTABLE_NAME	IN varchar2,
							vSCHEMA			IN varchar2 DEFAULT vSCHEMA_DEFAULT)
AS
	AUD_TABLE varchar2(100);
	AUD_SEQ varchar2(100);
	AUD_TRG varchar2(100);
	TABLE_TRG varchar2(100);
BEGIN
	
	BEGIN
		SELECT AUD_TABLE,
				AUD_SEQ,
				TABLE_TRIGGER
			INTO
				AUD_TABLE,
				AUD_SEQ,
				TABLE_TRG
			FROM AUDIT_TABLES_OBJECTS_LIST
			WHERE T_SCHEMA = upper(vSCHEMA)
				AND SOURCE_TABLE = upper(vTABLE_NAME);
	EXCEPTION WHEN no_data_found THEN
		raise_application_error(-20555, 'Table has no audit');
	END;

	IF AUD_TABLE IS NOT NULL THEN
		
		DELETE FROM AUDIT_CLEAR
			WHERE T_SCHEMA = upper(vSCHEMA)
				AND TABLE_NAME = upper(AUD_TABLE);
		
		AUD_TABLE:=upper(vSCHEMA)||'.'||upper(AUD_TABLE);
	END IF;

	IF AUD_SEQ IS NOT NULL THEN
		AUD_SEQ	:=upper(vSCHEMA)||'.'||upper(AUD_SEQ);
	END IF;

	IF TABLE_TRG IS NOT NULL THEN
		TABLE_TRG	:=upper(vSCHEMA)||'.'||upper(TABLE_TRG);
	END IF;

	IF AUD_TABLE IS NOT NULL THEN
		EXECUTE IMMEDIATE 'DROP TABLE '||AUD_TABLE;
	END IF;

	IF AUD_SEQ IS NOT NULL THEN
		EXECUTE IMMEDIATE 'DROP SEQUENCE '||AUD_SEQ;
	END IF;

	IF TABLE_TRG IS NOT NULL THEN
		EXECUTE IMMEDIATE 'DROP TRIGGER '||TABLE_TRG;
	END IF;

	DELETE FROM AUDIT_TABLES_OBJECTS_LIST
		WHERE T_SCHEMA = upper(vSCHEMA)
			AND SOURCE_TABLE = upper(vTABLE_NAME);
		
END DROP_AUDIT_OBJECTS;

PROCEDURE CREATE_AUDIT_CLEAR(P_vSCHEMA		IN VARCHAR2,
							P_vTABLE_NAME	IN VARCHAR2,
							P_vCOLUMN_NAME	IN VARCHAR2,
							P_nTIME_TYPE	IN NUMBER,
							P_nDAYS_CNT		IN NUMBER,
							P_nMONTHS_CNT	IN NUMBER,
							P_vIS_ACTIVE	IN VARCHAR2)
AS
BEGIN

	INSERT INTO AUDIT_CLEAR
			(T_SCHEMA,
			TABLE_NAME,
			COLUMN_NAME,
			TIME_TYPE,
			DAYS_CNT,
			MONTHS_CNT,
			IS_ACTIVE)
		VALUES(P_vSCHEMA,
				P_vTABLE_NAME,
				P_vCOLUMN_NAME,
				P_nTIME_TYPE,
				P_nDAYS_CNT,
				P_nMONTHS_CNT,
				P_vIS_ACTIVE);

END CREATE_AUDIT_CLEAR;

PROCEDURE UPDATE_AUDIT_CLEAR(P_nID			IN NUMBER,
							P_vSCHEMA		IN VARCHAR2,
							P_vTABLE_NAME	IN VARCHAR2,
							P_vCOLUMN_NAME	IN VARCHAR2,
							P_nTIME_TYPE	IN NUMBER,
							P_nDAYS_CNT		IN NUMBER,
							P_nMONTHS_CNT	IN NUMBER,
							P_vIS_ACTIVE	IN VARCHAR2)
AS
BEGIN

	UPDATE AUDIT_CLEAR
		SET T_SCHEMA = P_vSCHEMA,
			TABLE_NAME = P_vTABLE_NAME,
			COLUMN_NAME = P_vCOLUMN_NAME,
			TIME_TYPE = P_nTIME_TYPE,
			DAYS_CNT = P_nDAYS_CNT,
			MONTHS_CNT = P_nMONTHS_CNT,
			IS_ACTIVE = P_vIS_ACTIVE
		WHERE ID = P_nID;

END UPDATE_AUDIT_CLEAR;

PROCEDURE DELETE_AUDIT_CLEAR(P_nID IN NUMBER)
AS
BEGIN

	DELETE FROM AUDIT_CLEAR
		WHERE ID = P_nID;

END DELETE_AUDIT_CLEAR;

PROCEDURE CLEAR_AUDIT_TABLES
AS
	vERROR CLOB;
BEGIN

	FOR c IN (SELECT	ID,
						RUN_SCRIPT
				FROM AUDIT_CLEAR
				WHERE IS_ACTIVE = 'Y')
	LOOP
		BEGIN
			EXECUTE IMMEDIATE c.RUN_SCRIPT;
			UPDATE AUDIT_CLEAR
				SET ERROR_LOG = NULL,
					IS_LAST_RUN_SUCCESS = 1,
					LAST_RUN_SUCCESS_DATE = SYSDATE
				WHERE ID = c.ID;
		EXCEPTION WHEN OTHERS THEN 
			vERROR := SQLERRM;
			UPDATE AUDIT_CLEAR
				SET ERROR_LOG = vERROR,
					IS_LAST_RUN_SUCCESS = 0
				WHERE ID = c.ID;
		END;
	END LOOP;

END CLEAR_AUDIT_TABLES;

END PKG_AUDIT;