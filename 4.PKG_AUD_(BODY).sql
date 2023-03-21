CREATE OR REPLACE PACKAGE BODY PKG_AUD
AS

PROCEDURE CLEAR_AUD_TABLES
AS
	vERROR CLOB;
BEGIN

	FOR c IN (SELECT	ID,
						RUN_SCRIPT
				FROM CLEAR_AUD
				WHERE IS_ACTIVE = 'Y')
	LOOP
		BEGIN
			EXECUTE IMMEDIATE c.RUN_SCRIPT;
			UPDATE CLEAR_AUD
				SET ERROR_LOG = NULL,
					LAST_RUN_SUCCESS = 1,
					LAST_RUN_SUCCESS_DATE = SYSDATE
				WHERE ID = c.ID;
		EXCEPTION WHEN OTHERS THEN 
			vERROR := SQLERRM;
			UPDATE DBADMINDATA.CLEAR_LOGS
				SET ERROR_LOG = vERROR,
					LAST_RUN_SUCCESS = 0
				WHERE ID = c.ID;
		END;
	END LOOP;

END CLEAR_AUD_TABLES;

PROCEDURE CREATE_CLEAR_AUD(	P_vSCHEMA		IN VARCHAR2,
							P_vTABLE_NAME	IN VARCHAR2,
							P_vCOLUMN_NAME	IN VARCHAR2,
							P_nTIME_TYPE	IN NUMBER,
							P_nDAYS_CNT		IN NUMBER,
							P_nMONTHS_CNT	IN NUMBER,
							P_vIS_ACTIVE	IN VARCHAR2)
AS
BEGIN

	INSERT INTO CLEAR_LOGS
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
				P_nDAYS_CNT
				P_nMONTHS_CNT
				P_vIS_ACTIVE);

END CREATE_CLEAR_AUD;

PROCEDURE UPDATE_CLEAR_AUD(	P_nID			IN NUMBER,
							P_vSCHEMA		IN VARCHAR2,
							P_vTABLE_NAME	IN VARCHAR2,
							P_vCOLUMN_NAME	IN VARCHAR2,
							P_nTIME_TYPE	IN NUMBER,
							P_nDAYS_CNT		IN NUMBER,
							P_nMONTHS_CNT	IN NUMBER,
							P_vIS_ACTIVE	IN VARCHAR2)
AS
BEGIN

	UPDATE CLEAR_LOGS
		SET T_SCHEMA = P_vSCHEMA,
			TABLE_NAME = P_vTABLE_NAME,
			COLUMN_NAME = P_vCOLUMN_NAME,
			TIME_TYPE = P_nTIME_TYPE,
			DAYS_CNT = P_nDAYS_CNT,
			MONTHS_CNT = P_nMONTHS_CNT,
			IS_ACTIVE = P_vIS_ACTIVE
		WHERE ID = P_nID;

END UPDATE_CLEAR_AUD;

PROCEDURE DELETE_CLEAR_AUD(P_nID IN NUMBER)
AS
BEGIN

	DELETE FROM CLEAR_LOGS
		WHERE ID = P_nID;

END DELETE_CLEAR_AUD;

END PKG_AUD;