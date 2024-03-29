CREATE OR REPLACE PACKAGE PKG_AUDIT
AS

vSCHEMA_DEFAULT	varchar2(100) DEFAULT SYS_CONTEXT ('USERENV', 'CURRENT_USER');

TYPE GRANTS IS TABLE OF VARCHAR2(100);

PROCEDURE CREATE_AUDIT_OBJECTS(vTABLE_NAME					IN varchar2,
								vSCHEMA						IN varchar2 DEFAULT vSCHEMA_DEFAULT,
								tGRANTS						IN GRANTS DEFAULT NULL,
								nINSERT						IN NUMBER DEFAULT 1,
								nUPDATE						IN NUMBER DEFAULT 1,
								nDELETE						IN NUMBER DEFAULT 1,
								nTIME_TYPE					IN NUMBER DEFAULT NULL,
								nDAYS_CNT					IN NUMBER DEFAULT NULL,
								nMONTHS_CNT					IN NUMBER DEFAULT NULL,
								nCOPY_VALUES				IN NUMBER DEFAULT 0,
								nAUTONOMOUS_TRANSACTION		IN NUMBER DEFAULT 1,
								vINSERT_ADD_CONDITIONS		IN VARCHAR2 DEFAULT NULL,
								vUPDATE_ADD_CONDITIONS		IN VARCHAR2 DEFAULT NULL,
								vDELETE_ADD_CONDITIONS		IN VARCHAR2 DEFAULT NULL,
								nSAVE_OLD_AND_NEW_VALUES	IN NUMBER DEFAULT 0);

PROCEDURE CREATE_AUDIT_OBJECTS_CUSTOM(vTABLE_NAME				IN varchar2,
									vSCHEMA						IN varchar2,
									vAUD_TABLE					IN varchar2,
									vAUD_SEQ					IN varchar2,
									nAUD_SEQ_CACHE				IN NUMBER DEFAULT NULL,
									vAUD_TRG_NAME				IN varchar2,
									vTABLE_TRG_NAME				IN varchar2,
									tGRANTS						IN GRANTS DEFAULT NULL,
									nINSERT						IN NUMBER DEFAULT 1,
									nUPDATE						IN NUMBER DEFAULT 1,
									nDELETE						IN NUMBER DEFAULT 1,
									nTIME_TYPE					IN NUMBER DEFAULT NULL,
									nDAYS_CNT					IN NUMBER DEFAULT NULL,
									nMONTHS_CNT					IN NUMBER DEFAULT NULL,
									nCOPY_VALUES				IN NUMBER DEFAULT 0,
									nAUTONOMOUS_TRANSACTION		IN NUMBER DEFAULT 1,
									vINSERT_ADD_CONDITIONS		IN VARCHAR2 DEFAULT NULL,
									vUPDATE_ADD_CONDITIONS		IN VARCHAR2 DEFAULT NULL,
									vDELETE_ADD_CONDITIONS		IN VARCHAR2 DEFAULT NULL,
									nSAVE_OLD_AND_NEW_VALUES	IN NUMBER DEFAULT 0);

PROCEDURE UPDATE_AUDIT_OBJECTS(nLIST_AUD_ID				IN NUMBER,
								nINSERT					IN NUMBER DEFAULT 1,
								nUPDATE					IN NUMBER DEFAULT 1,
								nDELETE					IN NUMBER DEFAULT 1,
								nAUTONOMOUS_TRANSACTION	IN NUMBER DEFAULT 1,
								vINSERT_ADD_CONDITIONS	IN VARCHAR2 DEFAULT NULL,
								vUPDATE_ADD_CONDITIONS	IN VARCHAR2 DEFAULT NULL,
								vDELETE_ADD_CONDITIONS	IN VARCHAR2 DEFAULT NULL);

PROCEDURE DROP_AUDIT_OBJECTS(nLIST_AUD_ID IN NUMBER);

PROCEDURE DROP_AUDIT_OBJECTS(vTABLE_NAME	IN varchar2,
							vSCHEMA			IN varchar2 DEFAULT vSCHEMA_DEFAULT);

PROCEDURE CREATE_AUDIT_CLEAR(P_vSCHEMA		IN VARCHAR2,
							P_vTABLE_NAME	IN VARCHAR2,
							P_vCOLUMN_NAME	IN VARCHAR2,
							P_nTIME_TYPE	IN NUMBER,
							P_nDAYS_CNT		IN NUMBER,
							P_nMONTHS_CNT	IN NUMBER,
							P_vIS_ACTIVE	IN VARCHAR2);

PROCEDURE UPDATE_AUDIT_CLEAR(P_nID			IN NUMBER,
							P_vSCHEMA		IN VARCHAR2,
							P_vTABLE_NAME	IN VARCHAR2,
							P_vCOLUMN_NAME	IN VARCHAR2,
							P_nTIME_TYPE	IN NUMBER,
							P_nDAYS_CNT		IN NUMBER,
							P_nMONTHS_CNT	IN NUMBER,
							P_vIS_ACTIVE	IN VARCHAR2);

PROCEDURE DELETE_AUDIT_CLEAR(P_nID IN NUMBER);

PROCEDURE CLEAR_AUDIT_TABLES;

END PKG_AUDIT;
/