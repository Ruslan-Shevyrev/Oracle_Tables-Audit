CREATE OR REPLACE PACKAGE PKG_AUD
AS

vSCHEMA_DEFAULT	varchar2(100) DEFAULT SYS_CONTEXT ('USERENV', 'CURRENT_USER');

PROCEDURE CLEAR_AUD_TABLES;

END PKG_AUD;