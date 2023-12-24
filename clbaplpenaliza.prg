// Programa   : CLBAPLPENALIZA
// Fecha/Hora : 26/08/2022 07:23:21
// Propósito  : "Aplicación de Penalizaciones"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dDesde,dHasta,dFecha,cCodCli)
   LOCAL cSql,cWhere:="",oDb:=OpenOdbc(oDp:cDsnData),lResp,cPor:=""

   DEFAULT dDesde:=NIL,;
           dHasta:=NIL,;
           dFecha:=oDp:dFecha

   DEFAULT oDp:cTipDocClb:="CUO",;
           oDp:nPorPenalz:=10,;
           oDp:nDiasVence:=10  

   IF !Empty(dDesde)
      cWhere:=GetWhereAnd("DOC_FECHA",dDesde,dHasta)
   ENDIF

   IF COUNT("DPDOCCLI","DOC_TIPDOC"+GetWhere("=",oDp:cTipDocClb))=0
      RETURN .T.
   ENDIF

   cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+;
           "DOC_TIPDOC"+GetWhere("=" ,oDp:cTipDocClb)+" AND "+;
           "DOC_FCHVEN"+GetWhere("<=",dFecha        )+" AND "+;
           "(DOC_VTAANT=0 OR DOC_VTAANT IS NULL) "

   cPor:=LSTR(1+(oDp:nPorPenalz/100))


   cSql:=[ UPDATE DPMOVINV ]+;
         [ INNER JOIN DPDOCCLI ON MOV_TIPDOC]+GetWhere("=",oDp:cTipDocClb)+[ AND MOV_CODSUC=DOC_CODSUC AND MOV_TIPDOC=DOC_TIPDOC AND MOV_DOCUME=DOC_NUMERO AND DOC_TIPTRA]+GetWhere("=","D")+;
         [ AND ]+cWhere+;
         [ SET ]+;
         [ MOV_PRECIO=MOV_PRECIO*]+cPor+[,]+CRLF+;
         [ MOV_TOTAL =MOV_TOTAL *]+cPor+[,]+CRLF+;
         [ MOV_MTODIV=MOV_MTODIV*]+cPor+[,]+CRLF+;
         [ MOV_X     =1 ]+;
         [ WHERE (MOV_X=0  OR MOV_X IS NULL) AND MOV_USUARI]+GetWhere("<>","MIX")

   lResp:=oDb:EXECUTE(cSql)

   cSql:=[ UPDATE DPDOCCLI  ]+CRLF+;
         [ SET ]+;
         [ DOC_NETO  =DOC_NETO  *]+cPor+[,]+CRLF+;
         [ DOC_BASNET=DOC_BASNET*]+cPor+[,]+CRLF+;
         [ DOC_MTOIVA=DOC_MTOIVA*]+cPor+[,]+CRLF+;
         [ DOC_VTAANT=1 ]+CRLF+;
         [ WHERE ]+cWhere+[ AND DOC_USUARI]+GetWhere("<>","MIX")
    
   lResp:=oDb:EXECUTE(cSql)
    
RETURN lResp
// EOF
