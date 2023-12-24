// Programa   : CBLTRATOFAV
// Fecha/Hora : 23/12/2023 11:14:31
// Propósito  : Crear factura de venta desde transacciones Pagadas.
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cRecibo)
  LOCAL cSql
  LOCAL aNumDoc  :={},dFecha,cWhere
  LOCAL oDb      :=OpenOdbc(oDp:cDsnData)
  LOCAL x        :=EJECUTAR("CLBLOAD")
  LOCAL cTipCuo  :=oDp:cTipDocClb
  LOCAL cTipTra  :=oDp:cTipDocTra
  LOCAL cTipFav  :="FAV",cNumero:=NIL,cTipTra:=NIL,oMovInv,cSql,nContar:=0,dFchIni,nMonto:=0,cNumFav,cItem,nItem:=0
  LOCAL oDpDocCli:=OpenTable("SELECT * FROM DPDOCCLI",.F.)
  LOCAL oNew     :=OpenTable("SELECT * FROM DPMOVINV",.F.)
  LOCAL nCxC     :=0 //  Cuotas ya fueron Pagadas 
  LOCAL nDesc:=0,nRecarg:=0,nDocOtros:=0,I
     
  SysRefresh(.T.)
   
  DEFAULT cCodSuc:=oDp:cSucursal,;        
          cRecibo:=SQLGET("DPDOCCLI","DOC_RECNUM","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND DOC_TIPDOC"+GetWhere("=",cTipTra)+" AND DOC_TIPTRA"+GetWhere("=","P"))

  // lee todas las traspasos del recibo
  aNumDoc:=ATABLE("SELECT DOC_NUMERO FROM DPDOCCLI WHERE DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND DOC_RECNUM"+GetWhere("=",cRecibo)+" AND DOC_TIPDOC"+GetWhere("=",cTipTra)+" AND DOC_TIPTRA"+GetWhere("=","P"))

  IF Empty(cRecibo)
     MsgMemo("No hay recibo de Ingreso")
     RETURN NIL
  ENDIF

  IF Empty(aNumDoc) 
     MsgMemo("No hay Registros de Traspasos en Recibo "+cRecibo)
     RETURN NIL
  ENDIF
  
  // Ultima Factura
  cNumFav:=EJECUTAR("DPDOCCLIGETNUM",cTipFav)

  cWhere :="MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",cTipTra)+" AND "+;
           GetWhereOr("MOV_DOCUME",aNumDoc  )+" AND "+;
           "MOV_APLORG"+GetWhere("=","V"    )+" AND "+;
           "MOV_INVACT=1"

  // lectura del cuerpo del traspaso
  cSql   :=" SELECT * FROM DPMOVINV "+;
           " INNER JOIN DPINV        ON MOV_CODIGO=INV_CODIGO "+;
           " INNER JOIN DPDOCCLI     ON MOV_CODSUC=DOC_CODSUC AND MOV_TIPDOC=DOC_TIPDOC AND DOC_NUMERO=MOV_DOCUME AND DOC_TIPTRA"+GetWhere("=","D")+;
           " INNER JOIN DPRECIBOSCLI ON DOC_CODSUC=REC_CODSUC AND DOC_RECNUM=REC_NUMERO "+;
           " WHERE "+cWhere

  // ? CLPCOPY(cSql)

  oMovInv:=OpenTable(cSql,.T.)

  // Crear la factura 
  nCxC:=1 // Factura pagada mediante transferencia de CxC
  EJECUTAR("DPDOCCLICREA",NIL,cTipFav,cNumFav,oMovInv:MOV_CODCTA,oMovInv:REC_FECHA,oDp:cMonedaExt,"V",NIL,nMonto,0,oMovInv:REC_VALCAM,oMovInv:REC_FECHA,NIL,oDpDocCli,"N",nCxC)

  WHILE !oMovInv:EOF()

     nCxC:=0  // Cuota está pagada

     IF LEFT(oMovInv:INV_UTILIZ,1)="A"

       nContar:=0
       dFchIni:=FCHINIMES(oMovInv:MOV_FCHVEN)

       DpMsgRun("Traspaso "+aNumDoc[1]+" Recibo "+cRecibo,"Generando Cuotas "+LSTR(oMovInv:MOV_CANTID),NIL,oMovInv:MOV_CANTID)

       WHILE nContar<=oMovInv:MOV_CANTID

           DpMsgSet(nContar,.T.,NIL,"Cuota "+DTOC(dFchIni)+" ["+LSTR(nContar)+"/"+LSTR(oMovInv:MOV_CANTID)+"]")
           SysRefresh(.T.)


           cItem  :=STRZERO(nItem++)

           nContar++
           dFchIni:=FCHFINMES(dFchIni)+1
           cNumero:=EJECUTAR("DPDOCCLIGETNUM",cTipCuo)
           nMonto :=oMovInv:MOV_PRECIO
           EJECUTAR("DPDOCCLICREA",NIL,cTipCuo,cNumero,oMovInv:MOV_CODCTA,dFchIni,oDp:cMonedaExt,"V",NIL,nMonto,oMovInv:MOV_IVA,oMovInv:DOC_VALCAM,dFchIni,NIL,oDpDocCli,"N",nCxC)

           EJECUTAR("DPMOVINVCREA",cCodSuc,cTipCuo,cNumero,oMovInv:MOV_CODIGO,1,nMonto,oMovInv:MOV_UNDMED,1,0,"",dFchIni,"V",dFchIni,oMovInv:MOV_CODCTA,oMovInv:MOV_IVA,0,oMovInv:DOC_VALCAM,oNew,oMovInv:MOV_LISTA,0,cItem)

           // Cuerpo de la factura
           cItem:=STRZERO(oMovInv:Recno()+nContar,5)
           EJECUTAR("DPMOVINVCREA",cCodSuc,cTipFav,cNumFav,oMovInv:MOV_CODIGO,1,nMonto,oMovInv:MOV_UNDMED,1,0,"",dFchIni,"V",oMovInv:REC_FECHA,oMovInv:MOV_CODCTA,oMovInv:MOV_IVA,0,oMovInv:DOC_VALCAM,oNew,oMovInv:MOV_LISTA,0,cItem)

           cWhere :="MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                    "MOV_TIPDOC"+GetWhere("=",cTipFav)+" AND "+;
                    "MOV_DOCUME"+GetWhere("=",cNumFav)+" AND "+;
                    "MOV_APLORG"+GetWhere("=","V"    )+" AND "+;
                    "MOV_ITEM"  +GetWhere("=",cItem  )+" AND "+;
                    "MOV_INVACT=1"

           SQLUPDATE("DPMOVINV",{"MOV_ASODOC","MOV_ASOTIP"},{oMovInv:MOV_DOCUME,oMovInv:MOV_TIPDOC},cWhere)

       ENDDO

     ELSE
     
          oNew:AppendBlank()
          AEVAL(oNew:aFields,{|a,n| oNew:Replace(a[1],oMovInv:FieldGet(a[1])) })
          oNew:Replace("MOV_DOCUME",cNumFav)
          oNew:Replace("MOV_TIPDOC",cTipFav)
          oNew:Replace("MOV_FECHA" ,oMovInv:REC_FECHA)
          oNew:Replace("MOV_ITEM"  ,STRZERO(oMovInv:Recno(),5))
          oNew:Replace("MOV_ASOTIP",oMovInv:MOV_TIPDOC)
          oNew:Replace("MOV_ASODOC",oMovInv:MOV_DOCUME)
          oNew:Commit()

     ENDIF

     

     oMovInv:DbSkip()

  ENDDO

  SysRefresh(.T.)
  // Recalcular la factura

  cWhere :="MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",cTipFav)+" AND "+;
           "MOV_DOCUME"+GetWhere("=",cNumFav)+" AND "+;
           "MOV_APLORG"+GetWhere("=","V"    )+" AND "+;
           "MOV_INVACT=1"

 
 
  EJECUTAR("DPDOCCLIIMP",cCodSuc,cTipFav,oMovInv:MOV_CODCTA,cNumFav,.T.,nDesc,nRecarg,nDocOtros,"V")

  DpMsgClose()

//? oMovInv:ClassName(),oDpDocCli:ClassName()

  oMovInv:End()
  oDpDocCli:End()

  EJECUTAR("VERDOCCLI",cCodSuc,cTipFav,oMovInv:MOV_CODCTA,cNumFav,"D")

RETURN NIL
// EOF
