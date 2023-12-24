// Programa   : CLBGENCUOTAS
// Fecha/Hora : 28/08/2022 08:02:37
// Propósito  : Generar Cuotas de Todos los Socios
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhereAdd,dDesde,dHasta,cCodInv,cCodCli,lDelete,lAsk,aFechas,nValCam,oRecibo,cTipDoc)
  LOCAL cSql,oTable,oDocCli,oMovInv,nMonto:=0,nIva:=0,dFchVen,cNumero,cWhere,oTipDoc
  LOCAL cNumero,cCodInv,nCant,nPrecio,cUnd,nCxUnd,nCostoD,cLote,dFechaV,cOrg,cTipIva:="GN",nPorIva:=0,nIva:=0,nRata
  LOCAL oDb    :=OpenOdbc(oDp:cDsnData)
  LOCAL nCol   :=3,nPor:=0,nBase,cWhereMov:=" 1=1 ",cWhereDoc:=" 1=1 ",I
  LOCAL lIva   :=.F.,lFind:=.F.
  LOCAL nCuotas:=0 // Si no Existe Cuota en el Periodo no Valida cliente por Cliente
  LOCAL oTipDoc,nCxC,cInner,cWhereEx

  DEFAULT cWhereAdd:=" 1=1 ",;
          lAsk     :=.T.,;
          dDesde   :=FCHINIMES(oDp:dFecha),;
          dHasta   :=FCHFINMES(oDp:dFecha),;
          lDelete  :=.F.

  DEFAULT oDp:cTipDocClb:="CUO",;
          oDp:nDiasPlazo:=0,;
          aFechas       :={dDesde},;
          cTipDoc       :=oDp:cTipDocClb,;
          oDp:cTipDocTRA:="TRA"

  IF !Empty(cCodInv)
     cWhereAdd:=cWhereAdd+" AND DPG_CODINV"+GetWhere("=",cCodInv)
     cWhereMov:=cWhereMov+" AND MOV_CODIGO"+GetWhere("=",cCodInv)
  ENDIF

  IF !Empty(cCodCli)
     cWhereAdd:=cWhereAdd+" AND DPG_CODIGO"+GetWhere("=",cCodCli)
     cWhereMov:=cWhereMov+" AND MOV_CODCTA"+GetWhere("=",cCodCli)
     cWhereDoc:=cWhereDoc+" AND DOC_CODIGO"+GetWhere("=",cCodInv)
  ENDIF

  dFchVen:=dDesde+oDp:nDiasPlazo

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  oTipDoc:=OpenTable("SELECT * FROM DPTIPDOCCLI WHERE TDC_TIPO"+GetWhere("=",cTipDoc)) // 28/11/2023 oDp:cTipDocClb))
  oTipDoc:End()

  lIva   :=SQLGET("DPTIPDOCCLI","TDC_IVA","TDC_TIPO"+GetWhere("=",cTipDoc)) // 28/11/2023 oDp:cTipDocClb))


  DEFAULT nValCam:=EJECUTAR("DPGETVALCAM",oDp:cMonedaExt,dDesde)

  IF lIva
    nPorIva:=EJECUTAR("IVACAL",cTipIva,nCol,dDesde)
    nPor   :=1 // (nPorIva/100)+1
  ELSE
    nPor   :=1
  ENDIF

  nCxC   :=EJECUTAR("DPTIPCXC",cTipDoc) // oDp:cTipDocClb)

// ? lIva,"lIva",nValCam,"nValCam",CLPCOPY(oDp:cSql)

  // cNumero:=SQLINCREMENTAL("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc )+" AND DOC_TIPTRA"+GetWhere("=","D"))
  cNumero:=SQLGETMAX("DPDOCCLI","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc )+" AND DOC_TIPTRA"+GetWhere("=","D"))
  cNumero:=EJECUTAR("DPINCREMENTAL",cNumero,.T.)

// ? cNumero
  
  FOR I=1 TO LEN(aFechas)

   dDesde:=aFechas[I]
   dHasta:=FCHFINMES(dDesde)

   IF lDelete
//? "NO ELIMINA"
//     SQLDELETE("DPDOCCLI","DOC_TIPDOC"+GetWhere("=",oDp:cTipDocClb)+" AND "+GetWhereAnd("DOC_FECHA",dDesde,dHasta)+" AND "+cWhereDoc)
//     SQLDELETE("DPMOVINV","MOV_TIPDOC"+GetWhere("=",oDp:cTipDocClb)+" AND "+GetWhereAnd("MOV_FECHA",dDesde,dHasta)+" AND "+cWhereMov)
   ENDIF

/*
   cSql  :=[ SELECT DPG_CODIGO,DPG_CODINV,PRE_LISTA,PRE_UNDMED,PRE_CODMON,PRE_PRECIO,CLI_TRANSP,TPP_INCIVA,CLI_TRANSP,PRE_LISTA ]+;
           [ FROM DPCLIENTEPROG ]+;
           [ INNER JOIN DPCLIENTES       ON DPG_CODIGO=CLI_CODIGO AND LEFT(CLI_SITUAC,1)='A'  ]+;
           [ INNER JOIN DPINV            ON DPG_CODINV=INV_CODIGO ]+;
           [ LEFT JOIN VIEW_UNDMEDXINV   ON INV_CODIGO=IME_CODIGO ]+;
           [ LEFT JOIN VIEW_DPINVPRECIOS ON DPINV.INV_CODIGO=PRE_CODIGO ]+;
           [ INNER JOIN DPPRECIOTIP      ON TPP_CODIGO=PRE_LISTA ]+;
           [ LEFT  JOIN DPMOVINV         ON MOV_CODSUC]+GetWhere("=",oDp:cSucursal)+[ AND DPG_CODINV=MOV_CODIGO AND MOV_FECHA]+GetWhere("=",dDesde)+[ AND MOV_APLORG="V" AND MOV_TIPDOC]+GetWhere("=",oDp:cTipDocClb)+[ AND DPG_CODIGO=MOV_CODCTA ]+;
           [ WHERE ]+cWhereAdd+[ AND MOV_CODIGO IS NULL ]+;
           [ GROUP BY CLI_CODIGO,DPG_CODINV ]+;
           [ ORDER BY CLI_CODIGO,DPG_CODINV ] 
*/

  // 28/11/2023, agrega tipo de documento y fechas de inicio/fin

  cWhereAdd:=cWhereAdd+if(Empty(cWhereAdd),"", " AND ")+;
            " DPG_TIPDES"+GetWhere("=",cTipDoc)


  IF cTipDoc="ALQ"

    cWhereAdd:=cWhereAdd+if(Empty(cWhereAdd),"", " AND ")+;
               "DPG_FCHINI"+GetWhere("<=",dDesde)+" AND "+;
               "DPG_FCHFIN"+GetWhere(">=",dHasta)

  ENDIF
 
  cSql  :=[ SELECT DPG_CODIGO,DPG_CODINV,PRE_LISTA,PRE_UNDMED,PRE_CODMON,PRE_PRECIO,CLI_TRANSP,TPP_INCIVA,CLI_TRANSP,PRE_LISTA,DPG_PERIOD, ]+;
          [ DPG_MONTO, ]+;
          [ (SELECT MOV_FECHA FROM dpmovinv ]+;
          [ WHERE MOV_CODSUC]+GetWhere("=",oDp:cSucursal)+;
          [   AND DPG_CODINV=MOV_CODIGO ]+;
          [   AND DPG_CODIGO=MOV_CODCTA ]+;
          [   AND MONTH(MOV_FECHA)]+GetWhere("=",MONTH(dDesde))+;
          [   AND  YEAR(MOV_FECHA)]+GetWhere("=", YEAR(dDesde))+;
          [   AND MOV_APLORG="V" ]+;
          [   AND MOV_TIPDOC ]+GetWhere("=",cTipDoc)+;
          [ LIMIT 1) AS MOV_FECHA ]+;
          [ FROM DPCLIENTEPROG ]+;
          [ INNER JOIN DPCLIENTES       ON DPG_CODIGO=CLI_CODIGO AND LEFT(CLI_SITUAC,1)='A'  ]+;
          [ INNER JOIN DPINV            ON DPG_CODINV=INV_CODIGO ]+;
          [ LEFT JOIN VIEW_UNDMEDXINV   ON INV_CODIGO=IME_CODIGO ]+;
          [ LEFT JOIN VIEW_DPINVPRECIOS ON DPINV.INV_CODIGO=PRE_CODIGO ]+;
          [ LEFT JOIN DPPRECIOTIP       ON TPP_CODIGO=PRE_LISTA ]+;
          [ WHERE ]+cWhereAdd+[ ]+;
          [ GROUP BY CLI_CODIGO ]+;
          [ HAVING MOV_FECHA IS NULL ]+;
          [ ORDER BY CLI_CODIGO ] 

//  ? CLPCOPY(cSql)
// return  

   oTable :=OpenTable(cSql,.T.)

// ? oTable:RecCount()
// oTable:Browse()
// RETURN NIL

   DpMsgRun("","Generando Documentos "+DTOC(dDesde)+" "+DTOC(dHasta),NIL,oTable:RecCount())

   DpMsgSetTotal(oTable:RecCount())

   IF !Empty(cCodCli)

     oDocCli:=OpenTable("SELECT * FROM DPDOCCLI",.F.)
     oMovInv:=OpenTable("SELECT * FROM DPMOVINV",.F.)

   ELSE

     oDocCli:=INSERTINTO("DPDOCCLI",NIL,10)
     // oDocCli:nInsert:=20

     oMovInv:=INSERTINTO("DPMOVINV",NIL,10)
     // oMovInv:nInsert:=20

   ENDIF
      
   WHILE !oTable:Eof()

     nPrecio:=0

     IF oTable:RecNo()%10=0
        DpMsgSet(oTable:RecNo(),.T.,NIL,"Cliente "+oTable:DPG_CODIGO+" ["+LSTR(oTable:RecNo())+"/"+LSTR(oTable:RecCount())+"]")
        SysRefresh(.T.)
     ENDIF

     nCant  :=IF(oTable:CLI_TRANSP=0,1,oTable:CLI_TRANSP)

     IF oTable:DPG_MONTO>0 .AND. cTipDoc="ALQ"
        nPrecio:=ROUND(oTable:DPG_MONTO*nValCam,2)
     ENDIF

     IF nPrecio=0
        nPrecio:=ROUND(oTable:PRE_PRECIO*nValCam,2)
     ENDIF

     // Omisiones en la Lista de precios.
     IF Empty(oTable:PRE_CODMON)
        oTable:Replace("PRE_CODMON",oDp:cMonedaExt )
        oTable:Replace("TPP_INCIVA",oTipDoc:TDC_IVA)
        oTable:Replace("PRE_UNDMED",oTable:DPG_PERIOD)
     ENDIF

     // 13/01/2023, Precio Incluye IVA
     IF oTable:TPP_INCIVA .AND. oTipDoc:TDC_IVA
        nRata  :=DIV(nPorIva,100)+1
        nPrecio:=DIV(nPrecio,nRata)
     ENDIF

     IF nPor<>0
       nPrecio:=nPrecio/nPor
     ENDIF

     nMonto :=(nPrecio*nCant)
     nIva   :=PORCEN(nMonto,nPorIva)

     // cNumero:= 10/05/2023 Envia el Numero

    
    
     EJECUTAR("DPDOCCLICREA",oDp:cSucursal,cTipDoc,cNumero,oTable:DPG_CODIGO,dDesde,oTable:PRE_CODMON,NIL,NIL,nMonto+nIva,nIva,nValCam,dFchVen,oTable,oDocCli,"N",nCxC)
   
     cNumero:=IF(!ValType(cNumero)="C",oDp:cNumero,cNumero)

     // 10/04/2023       EJECUTAR("DPMOVINVCREA",oDp:cSucursal,oDp:cTipDocClb,cNumero,oTable:DPG_CODINV,nCant,nPrecio,oTable:PRE_UNDMED,1,0,"",CTOD(""),"V",dDesde,oTable:DPG_CODIGO,cTipIva,nPorIva,nValCam,oMovInv,oTable:PRE_LISTA)
     EJECUTAR("DPMOVINVCREA",oDp:cSucursal,cTipDoc,cNumero,oTable:DPG_CODINV,nCant,nPrecio,oTable:PRE_UNDMED,1,0,"",dDesde,"V",dDesde,oTable:DPG_CODIGO,cTipIva,nPorIva,nValCam,oMovInv,oTable:PRE_LISTA)

     cNumero:=EJECUTAR("DPINCREMENTAL",cNumero,.T.)

     oTable:DbSkip()

   ENDDO

   oDocCli:End()
   oMovInv:End()
   oTable:End()

// cWhere:="DOC_TIPDOC"+GetWhere("=",oDp:cTipDocClb)+" AND DOC_FECHA"+GetWhere("=",dFecha)
   cWhere:="DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND DOC_FECHA"+GetWhere("=",dFecha)

   cSql  :=[ UPDATE DPDOCCLI ]+;
           [ SET DOC_ZONANL="N",DOC_CXC]+GetWhere("=",nCxC)+;
           [ WHERE ]+cWhere

   oDb:Execute(cSql)

   cSql  :=[ UPDATE DPDOCCLI ]+;
           [ SET DOC_TIPAFE="" ]+;
           [ WHERE DOC_TIPAFE IS NULL]

   oDb:Execute(cSql)

   cSql  :=[ UPDATE DPDOCCLI ]+;
           [ INNER JOIN DPCLIENTES ON DOC_CODIGO=CLI_CODIGO AND ]+cWhere+;
           [ SET DOC_PLAZO=CLI_DIAS,DOC_CODVEN=CLI_CODVEN]

   oDb:Execute(cSql)

  NEXT I

  DpMsgClose()

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

  IF ValType(oRecibo)="O"
    oRecibo:RELOADDOCS(.T.)
  ENDIF

RETURN .T.
// EOF
