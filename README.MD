# Tables-Audit

An audit is needed to monitor the inserting, updating, or deleting records in the table.

## Instalation

Create all objects from
1. **AUDIT_TABLES_OBJECTS_LIST.sql**
2. **AUDIT_CLEAR.sql**
3. **CLEAR_AUDIT_TABLES_JOB.sql** - job for cleaning audit table. You can configurate your own job
4. **V_AUDIT_TABLES_OBJECTS_LIST.sql**
5. **PKG_AUD_(SPECIFICATION)**
6. **PKG_AUD_(BODY)**

:warning: Probably, you should add grants
1. ***GRANT SCHEDULER_ADMIN TO Your_Schema***
2. ***GRANT CREATE ANY TABLES TO Your_Schema***
3. ***GRANT CREATE ANY VIEW TO Your_Schema***
4. ***GRANT CREATE ANY SEQUENCE TO Your_Schema***
5. ***GRANT CREATE ANY TRIGGER TO Your_Schema***

## Using

### :one: Creating Audit Objects with Default Objects Names

```
PROCEDURE CREATE_AUDIT_OBJECTS(vTABLE_NAME              IN varchar2,
                               vSCHEMA                  IN varchar2 DEFAULT vSCHEMA_DEFAULT,
                               tGRANTS                  IN GRANTS DEFAULT NULL,
                               nINSERT                  IN NUMBER DEFAULT 1,
                               nUPDATE                  IN NUMBER DEFAULT 1,
                               nDELETE                  IN NUMBER DEFAULT 1,
                               nTIME_TYPE               IN NUMBER DEFAULT NULL,
                               nDAYS_CNT                IN NUMBER DEFAULT NULL,
                               nMONTHS_CNT              IN NUMBER DEFAULT NULL,
                               nCOPY_VALUES             IN NUMBER DEFAULT 0,
                               nAUTONOMOUS_TRANSACTION  IN NUMBER DEFAULT 1,
                               vINSERT_ADD_CONDITIONS   IN VARCHAR2 DEFAULT NULL,
                               vUPDATE_ADD_CONDITIONS   IN VARCHAR2 DEFAULT NULL,
                               vDELETE_ADD_CONDITIONS   IN VARCHAR2 DEFAULT NULL,
                               nSAVE_OLD_AND_NEW_VALUES IN NUMBER DEFAULT 0);
```

|PARAMETER|VALUES|NOTE|
|----------|------|----|
|**vTABLE_NAME**|varchar2|Table for audit|
|**vSCHEMA**|varchar2|Default schema is a schema where Package is|
|**tGRANTS**|PKG_AUDIT.GRANTS (TYPE GRANTS IS TABLE OF VARCHAR2(100))|List of schemas. Grant select will be added on **<AUDIT_TABLE>** to these schemas|
|**nINSERT**|1, 0|1 - add INSERT Audit, 0 - don't add|
|**nUPDATE**|1, 0|1 - add UPDATE Audit, 0 - don't add|
|**nDELETE**|1, 0|1 - add DELETE Audit, 0 - don't add|
|**nTIME_TYPE**|1, 2, null|1 - add Clearing **<AUDIT_TABLE>** with ***Days*** parameter, 2 - add Clearing **<AUDIT_TABLE>** with ***Month*** parameter, null - don't add Clearing for **<AUDIT_TABLE>**|
|**nDAYS_CNT**|number|if nTIME_TYPE = 1 then this parameter sets a Days count for Audit saving|
|**nMONTHS_CNT**|number|if nTIME_TYPE = 2 then this parameter sets a Months count for Audit saving|
|**nCOPY_VALUES**|1, 0|1 - add exists values in audit table as "I" values, 0 - don't add|
|**nAUTONOMOUS_TRANSACTION**|1, 0|1 - Create TABLE_TRIGGER as ***pragma autonomous_transaction***|
|**vINSERT_ADD_CONDITIONS**|varchar2|Additional conditions for ***INSERT LOG***|
|**vUPDATE_ADD_CONDITIONS**|varchar2|Additional conditions for ***UPDATE LOG***|
|**vDELETE_ADD_CONDITIONS**|varchar2|Additional conditions for ***DELETE LOG***|
|**nSAVE_OLD_AND_NEW_VALUES**|1, 0|1 - **<AUDIT_TABLE>** will be created as ***NEW_COLUMN_NAME***, ***OLD_COLUN_NAME***. This mode makes it easier to monitor Updates but Audit takes twice as much space.|

***Example of Additional Conditions:***
```
vINSERT_ADD_CONDITIONS = ':NEW.ID > 10'
vUPDATE_ADD_CONDITIONS = ':NEW.ID > 15'
vDELETE_ADD_CONDITIONS = ':OLD.ID > 5'
```

### :two: Creating Audit Objects with Custom Objects Names

```
PROCEDURE CREATE_AUDIT_OBJECTS_CUSTOM(vTABLE_NAME             IN varchar2,
                                      vSCHEMA                 IN varchar2,
                                      vAUD_TABLE              IN varchar2,
                                      vAUD_SEQ                IN varchar2,
                                      nAUD_SEQ_CACHE          IN NUMBER DEFAULT NULL,
                                      vAUD_TRG_NAME           IN varchar2,
                                      vTABLE_TRG_NAME         IN varchar2,
                                      tGRANTS                 IN GRANTS DEFAULT NULL,
                                      nINSERT                 IN NUMBER DEFAULT 1,
                                      nUPDATE                 IN NUMBER DEFAULT 1,
                                      nDELETE                 IN NUMBER DEFAULT 1,
                                      nTIME_TYPE              IN NUMBER DEFAULT NULL,
                                      nDAYS_CNT               IN NUMBER DEFAULT NULL,
                                      nMONTHS_CNT             IN NUMBER DEFAULT NULL,
                                      nCOPY_VALUES            IN NUMBER DEFAULT 0,
                                      nAUTONOMOUS_TRANSACTION IN NUMBER DEFAULT 1,
                                      vINSERT_ADD_CONDITIONS  IN VARCHAR2 DEFAULT NULL,
                                      vUPDATE_ADD_CONDITIONS  IN VARCHAR2 DEFAULT NULL,
                                      vDELETE_ADD_CONDITIONS  IN VARCHAR2 DEFAULT NULL,
                                      nSAVE_OLD_AND_NEW_VALUES IN NUMBER DEFAULT 0);
```

|PARAMETER|NOTE|DEFAULT|
|----------|----|----|
|**vAUD_TABLE**|Audit table name|**AUD_<vTABLE_NAME>**|
|**vAUD_SEQ**|ID sequence name for **vAUD_TABLE**|**AUD_<vTABLE_NAME>_SEQ**|
|**nAUD_SEQ_CACHE**|Caсhe for **vAUD_SEQ**|100|
|**vAUD_TRG_NAME**|Trigger name for **vAUD_TABLE**|**AUD_<vTABLE_NAME>_I**|
|**vTABLE_TRG_NAME**|Trigger name for **vTABLE_NAME**|**LOG_<vTABLE_NAME>**|

### :three: Update Audit Objects by **AUDIT_TABLES_OBJECTS_LIST.ID**

```
PROCEDURE UPDATE_AUDIT_OBJECTS(nLIST_AUD_ID            IN NUMBER,
                               nINSERT                 IN NUMBER DEFAULT 1,
                               nUPDATE                 IN NUMBER DEFAULT 1,
                               nDELETE                 IN NUMBER DEFAULT 1,
                               nAUTONOMOUS_TRANSACTION IN NUMBER DEFAULT 1,
                               vINSERT_ADD_CONDITIONS  IN VARCHAR2 DEFAULT NULL,
                               vUPDATE_ADD_CONDITIONS  IN VARCHAR2 DEFAULT NULL,
                               vDELETE_ADD_CONDITIONS  IN VARCHAR2 DEFAULT NULL);
```

### :four: Drop Audit Objects by **AUDIT_TABLES_OBJECTS_LIST.ID**

```
PROCEDURE DROP_AUDIT_OBJECTS(nLIST_AUD_ID IN NUMBER);
```

### :five: Drop Audit Objects by **AUDIT_TABLES_OBJECTS_LIST.T_SCHEMA** and **AUDIT_TABLES_OBJECTS_LIST.SOURCE_TABLE**

```
PROCEDURE DROP_AUDIT_OBJECTS(vTABLE_NAME IN varchar2,
                             vSCHEMA     IN varchar2 DEFAULT vSCHEMA_DEFAULT);
```

### :six: Add Table to clear in Job

```
PROCEDURE CREATE_AUDIT_CLEAR(P_vSCHEMA      IN VARCHAR2,
                             P_vTABLE_NAME  IN VARCHAR2,
                             P_vCOLUMN_NAME IN VARCHAR2,
                             P_nTIME_TYPE   IN NUMBER,
                             P_nDAYS_CNT    IN NUMBER,
                             P_nMONTHS_CNT  IN NUMBER,
                             P_vIS_ACTIVE   IN VARCHAR2);
```

|PARAMETER|VALUES|NOTE|
|----------|------|----|
|**P_vSCHEMA**|varchar2|Default schema is a schema where Package is|
|**P_vTABLE_NAME**|varchar2|Table for clearing|
|**P_vCOLUMN_NAME**|varchar2|Column with Date type|
|**nTIME_TYPE**|1, 2, null|1 - add Clearing **<AUDIT_TABLE>** with ***Days*** parameter, 2 - add Clearing **<AUDIT_TABLE>** with ***Month*** parameter, null - don't add Clearing for **<AUDIT_TABLE>**|
|**nDAYS_CNT**|number|if nTIME_TYPE = 1 then this parameter sets a Days count for Audit saving|
|**nMONTHS_CNT**|number|if nTIME_TYPE = 2 then this parameter sets a Month count for Audit saving|
|**P_vIS_ACTIVE**|'Y', 'N'|'Y' - active clearing, 'N' - inactive clearing|

### :seven: Update Table to clear in Job

```
PROCEDURE UPDATE_AUDIT_CLEAR(P_nID          IN NUMBER,
                             P_vSCHEMA      IN VARCHAR2,
                             P_vTABLE_NAME  IN VARCHAR2,
                             P_vCOLUMN_NAME IN VARCHAR2,
                             P_nTIME_TYPE   IN NUMBER,
                             P_nDAYS_CNT    IN NUMBER,
                             P_nMONTHS_CNT  IN NUMBER,
                             P_vIS_ACTIVE   IN VARCHAR2);
```

|PARAMENTER|VALUES|NOTE|
|----------|------|----|
|**P_nID**|number|**AUDIT_CLEAR.ID**|

### :eight: Delete Table to clear in Job

```
PROCEDURE DELETE_AUDIT_CLEAR(P_nID IN NUMBER);
```

|PARAMENTER|VALUES|NOTE|
|----------|------|----|
|**P_nID**|number|**AUDIT_CLEAR.ID**|

### :nine: Clearing Job

```
PROCEDURE CLEAR_AUDIT_TABLES;
```

Procedure for **CLEAR_AUDIT_TABLES_JOB**

## Example

```
CREATE TABLE TEST_AUDIT
( ID NUMBER(38,0), 
  NAME VARCHAR2(100)
);

BEGIN
	PKG_AUDIT.CREATE_AUDIT_OBJECTS(vTABLE_NAME => 'TEST_AUDIT');
END;

INSERT INTO TEST_AUDIT (ID, NAME) VALUES(1, 'TEST');

UPDATE TEST_AUDIT SET NAME = 'TEST_2' WHERE ID = 1;

DELETE FROM TEST_AUDIT WHERE ID = 1;

SELECT * FROM AUD_TEST_AUDIT;
```

<p align="center">
	<img src="https://github.com/Ruslan-Shevyrev/MediaFilesToGitHub/blob/master/Oracle_Tables-Audit/media/Example-Oracle_Tables-Audit.gif" title="Example">
</p>


<table>
	<tr>
		<td valign="center" width="49%"><img src="https://github.com/Ruslan-Shevyrev/Ruslan-Shevyrev/blob/main/logoRS/logo_mini.gif" title="logo"></td>
		<td valign="center" width="49%"><img src="https://github.com/Ruslan-Shevyrev/Ruslan-Shevyrev/blob/main/logoRS/logoRS_FULL.png" title="RuslanShevyrev"></td>
	</tr>
</table>