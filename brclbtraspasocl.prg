// Programa   : BRCLBTRASPASOCL
// Fecha/Hora : 20/12/2023 22:51:51
// Propósito  : "Traspaso de Acciones de Socios"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodInv)
   LOCAL aData,aFechas,cFileMem:="USER\BRCLBTRASPASOCL.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oCLBTRASPASOCL")="O" .AND. oCLBTRASPASOCL:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCLBTRASPASOCL,GetScript())
   ENDIF

   DEFAULT cCodInv:=SQLGET("DPCOMPONENTES","CPT_CODIGO")

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Traspaso de Acciones de Socios" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

/*
   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)


   ELSEIF (.T.)
*/

   EJECUTAR("KPIDIVISAGET")

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

// ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oCLBTRASPASOCL

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL oData  :=DATASET("CBLCONTRATOS","ALL")
   LOCAL lVerDoc:=oData:Get("LVERDOC",.F.)
   LOCAL lVerFav:=oData:Get("LVERFAV",.F.)
   oData:End()


   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oCLBTRASPASOCL","BRCLBTRASPASOCL.EDT")
// oCLBTRASPASOCL:CreateWindow(0,0,100,550)
   oCLBTRASPASOCL:Windows(0,0,aCoors[3]-160,MIN(1160,aCoors[4]-10),.T.) // Maximizado

   oCLBTRASPASOCL:cCodSuc   :=cCodSuc
   oCLBTRASPASOCL:lMsgBar   :=.F.
   oCLBTRASPASOCL:cPeriodo  :=aPeriodos[nPeriodo]
   oCLBTRASPASOCL:cCodSuc   :=cCodSuc
   oCLBTRASPASOCL:nPeriodo  :=nPeriodo
   oCLBTRASPASOCL:cNombre   :=""
   oCLBTRASPASOCL:dDesde    :=dDesde
   oCLBTRASPASOCL:cServer   :=cServer
   oCLBTRASPASOCL:dHasta    :=dHasta
   oCLBTRASPASOCL:cWhere    :=cWhere
   oCLBTRASPASOCL:cWhere_   :=cWhere_
   oCLBTRASPASOCL:cWhereQry :=""
   oCLBTRASPASOCL:cSql      :=oDp:cSql
   oCLBTRASPASOCL:oWhere    :=TWHERE():New(oCLBTRASPASOCL)
   oCLBTRASPASOCL:cCodPar   :=cCodPar // Código del Parámetro
   oCLBTRASPASOCL:lWhen     :=.T.
   oCLBTRASPASOCL:cTextTit  :="" // Texto del Titulo Heredado
   oCLBTRASPASOCL:oDb       :=oDp:oDb
   oCLBTRASPASOCL:cBrwCod   :="CLBTRASPASOCL"
   oCLBTRASPASOCL:lTmdi     :=.T.
   oCLBTRASPASOCL:aHead     :={}
   oCLBTRASPASOCL:lBarDef   :=.T.     // Activar Modo Diseño.
   oCLBTRASPASOCL:lVerDoc   :=lVerDoc // Ver Documento
   oCLBTRASPASOCL:lVerFav   :=lVerFav // Ver Documento

   oCLBTRASPASOCL:cNomCli   :=SPACE(100)
   oCLBTRASPASOCL:cCodCli   :=SPACE(10)

   oCLBTRASPASOCL:cNomCliDes:=SPACE(100)
   oCLBTRASPASOCL:cCodDes   :=SPACE(10)
   oCLBTRASPASOCL:cCodInv   :=cCodInv
   oCLBTRASPASOCL:dFchIni   :=CTOD("")       // fecha de inicio del socio, Ultima fecha de salida
   oCLBTRASPASOCL:nValCam   :=oDp:nMonedaExt  // fecha de inicio del socio, Ultima fecha de salida

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCLBTRASPASOCL:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCLBTRASPASOCL)}

   oCLBTRASPASOCL:lBtnRun     :=.F.
   oCLBTRASPASOCL:lBtnMenuBrw :=.F.
   oCLBTRASPASOCL:lBtnSave    :=.F.
   oCLBTRASPASOCL:lBtnCrystal :=.F.
   oCLBTRASPASOCL:lBtnRefresh :=.F.
   oCLBTRASPASOCL:lBtnHtml    :=.T.
   oCLBTRASPASOCL:lBtnExcel   :=.T.
   oCLBTRASPASOCL:lBtnPreview :=.T.
   oCLBTRASPASOCL:lBtnQuery   :=.F.
   oCLBTRASPASOCL:lBtnOptions :=.T.
   oCLBTRASPASOCL:lBtnPageDown:=.T.
   oCLBTRASPASOCL:lBtnPageUp  :=.T.
   oCLBTRASPASOCL:lBtnFilters :=.T.
   oCLBTRASPASOCL:lBtnFind    :=.T.
   oCLBTRASPASOCL:lBtnColor   :=.F.

   oCLBTRASPASOCL:nClrPane1:=16775408
   oCLBTRASPASOCL:nClrPane2:=16771797

   oCLBTRASPASOCL:nClrText :=0
   oCLBTRASPASOCL:nClrText1:=0
   oCLBTRASPASOCL:nClrText2:=0
   oCLBTRASPASOCL:nClrText3:=0

   oCLBTRASPASOCL:oBrw:=TXBrowse():New( IF(oCLBTRASPASOCL:lTmdi,oCLBTRASPASOCL:oWnd,oCLBTRASPASOCL:oDlg ))
   oCLBTRASPASOCL:oBrw:SetArray( aData, .F. )
   oCLBTRASPASOCL:oBrw:SetFont(oFont)

   oCLBTRASPASOCL:oBrw:lFooter     := .T.
   oCLBTRASPASOCL:oBrw:lHScroll    := .F.
   oCLBTRASPASOCL:oBrw:nHeaderLines:= 2
   oCLBTRASPASOCL:oBrw:nDataLines  := 1
   oCLBTRASPASOCL:oBrw:nFooterLines:= 1

   oCLBTRASPASOCL:aData            :=ACLONE(aData)

   AEVAL(oCLBTRASPASOCL:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: CPT_COMPON
  oCol:=oCLBTRASPASOCL:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: INV_DESCRI
  oCol:=oCLBTRASPASOCL:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 380

  // Campo: CPT_UNDMED
  oCol:=oCLBTRASPASOCL:oBrw:aCols[3]
  oCol:cHeader      :='Unidad'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  // Campo: CPT_CANTID
  oCol:=oCLBTRASPASOCL:oBrw:aCols[4]
  oCol:cHeader      :='Cant.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 88
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBTRASPASOCL:oBrw:aArrayData[oCLBTRASPASOCL:oBrw:nArrayAt,4],;
                              oCol  := oCLBTRASPASOCL:oBrw:aCols[4],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[4],oCol:cEditPicture)


  // Campo: PRE_PRECIO
  oCol:=oCLBTRASPASOCL:oBrw:aCols[5]
  oCol:cHeader      :='Precio'+CRLF+'USD'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBTRASPASOCL:oBrw:aArrayData[oCLBTRASPASOCL:oBrw:nArrayAt,5],;
                              oCol  := oCLBTRASPASOCL:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}
//oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)


  // Campo: INV_IVA
  oCol:=oCLBTRASPASOCL:oBrw:aCols[6]
  oCol:cHeader      :='Tipo'+CRLF+'IVA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: PORIVA
  oCol:=oCLBTRASPASOCL:oBrw:aCols[7]
  oCol:cHeader      :='%'+CRLF+'IVA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 20
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBTRASPASOCL:oBrw:aArrayData[oCLBTRASPASOCL:oBrw:nArrayAt,7],;
                              oCol  := oCLBTRASPASOCL:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
//oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


  // Campo: CPT_TOTUSD
  oCol:=oCLBTRASPASOCL:oBrw:aCols[8]
  oCol:cHeader      :='Total'+CRLF+'Bs.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBTRASPASOCL:oBrw:aArrayData[oCLBTRASPASOCL:oBrw:nArrayAt,8],;
                              oCol  := oCLBTRASPASOCL:oBrw:aCols[8],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[8],oCol:cEditPicture)


  // Campo: CPT_TOTAL
  oCol:=oCLBTRASPASOCL:oBrw:aCols[9]
  oCol:cHeader      :='Total'+CRLF+'USD'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASOCL:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBTRASPASOCL:oBrw:aArrayData[oCLBTRASPASOCL:oBrw:nArrayAt,9],;
                              oCol  := oCLBTRASPASOCL:oBrw:aCols[9],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[9],oCol:cEditPicture)


   oCLBTRASPASOCL:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCLBTRASPASOCL:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCLBTRASPASOCL:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCLBTRASPASOCL:nClrText,;
                                                 nClrText:=IF(.F.,oCLBTRASPASOCL:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCLBTRASPASOCL:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCLBTRASPASOCL:nClrPane1, oCLBTRASPASOCL:nClrPane2 ) } }

//   oCLBTRASPASOCL:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCLBTRASPASOCL:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCLBTRASPASOCL:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCLBTRASPASOCL:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCLBTRASPASOCL:oBrw:bLDblClick:={|oBrw|oCLBTRASPASOCL:RUNCLICK() }

   oCLBTRASPASOCL:oBrw:bChange:={||oCLBTRASPASOCL:BRWCHANGE()}
   oCLBTRASPASOCL:oBrw:CreateFromCode()

   oCLBTRASPASOCL:oWnd:oClient := oCLBTRASPASOCL:oBrw

   oCLBTRASPASOCL:Activate({||oCLBTRASPASOCL:ViewDatBar()})

   oCLBTRASPASOCL:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,oFontB
   LOCAL oDlg:=IF(oCLBTRASPASOCL:lTmdi,oCLBTRASPASOCL:oWnd,oCLBTRASPASOCL:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCLBTRASPASOCL:oBrw:nWidth()

   oCLBTRASPASOCL:oBrw:GoBottom(.T.)
   oCLBTRASPASOCL:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRCLBTRASPASOCL.EDT")
//     oCLBTRASPASOCL:oBrw:Move(44,0,1160+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oCLBTRASPASOCL:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oCLBTRASPASOCL:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oCLBTRASPASOCL:oBrw:oLbx  :=oCLBTRASPASOCL    // MDI:GOTFOCUS()

   IF .F. .AND. Empty(oCLBTRASPASOCL:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
            TOP PROMPT "Ejecutar";
            ACTION oCLBTRASPASOCL:TRASPASO();
            WHEN ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodCli)) .AND.;
                 ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodDes)) .AND.;
                 !Empty(oCLBTRASPASOCL:dFchIni)


   oBtn:cToolTip:="Ejecutar Traspaso"


   oCLBTRASPASOCL:oBtnRun:=oBtn

/*
   IF Empty(oCLBTRASPASOCL:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CLBTRASPASOCL")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CLBTRASPASOCL"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCLBTRASPASOCL:oBrw,"CLBTRASPASOCL",oCLBTRASPASOCL:cSql,oCLBTRASPASOCL:nPeriodo,oCLBTRASPASOCL:dDesde,oCLBTRASPASOCL:dHasta,oCLBTRASPASOCL)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCLBTRASPASOCL:oBtnRun:=oBtn



       oCLBTRASPASOCL:oBrw:bLDblClick:={||EVAL(oCLBTRASPASOCL:oBtnRun:bAction) }


   ENDIF




IF oCLBTRASPASOCL:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCLBTRASPASOCL");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oCLBTRASPASOCL:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCLBTRASPASOCL:lBtnColor

     oCLBTRASPASOCL:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL,oCLBTRASPASOCL:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCLBTRASPASOCL,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCLBTRASPASOCL,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCLBTRASPASOCL:oBtnColor:=oBtn

ENDIF

IF oCLBTRASPASOCL:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Guardar";
             ACTION EJECUTAR("DPBRWSAVE",oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL:oFrm)

ENDIF

IF oCLBTRASPASOCL:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCLBTRASPASOCL),;
                  EJECUTAR("DPBRWMENURUN",oCLBTRASPASOCL,oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL:cBrwCod,oCLBTRASPASOCL:cTitle,oCLBTRASPASOCL:aHead));
          WHEN !Empty(oCLBTRASPASOCL:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCLBTRASPASOCL:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oCLBTRASPASOCL:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCLBTRASPASOCL:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL);
          ACTION EJECUTAR("BRWSETFILTER",oCLBTRASPASOCL:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCLBTRASPASOCL:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oCLBTRASPASOCL:oBrw);
          WHEN LEN(oCLBTRASPASOCL:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCLBTRASPASOCL:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oCLBTRASPASOCL:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCLBTRASPASOCL:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oCLBTRASPASOCL)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCLBTRASPASOCL:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL:cTitle,oCLBTRASPASOCL:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCLBTRASPASOCL:oBtnXls:=oBtn

ENDIF

IF oCLBTRASPASOCL:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oCLBTRASPASOCL:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCLBTRASPASOCL:oBrw,NIL,oCLBTRASPASOCL:cTitle,oCLBTRASPASOCL:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCLBTRASPASOCL:oBtnHtml:=oBtn

ENDIF


IF oCLBTRASPASOCL:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oCLBTRASPASOCL:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCLBTRASPASOCL:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCLBTRASPASOCL")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oCLBTRASPASOCL:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCLBTRASPASOCL:oBtnPrint:=oBtn

   ENDIF

IF oCLBTRASPASOCL:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oCLBTRASPASOCL:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oCLBTRASPASOCL:oBrw:GoTop(),oCLBTRASPASOCL:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCLBTRASPASOCL:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oCLBTRASPASOCL:oBrw:PageDown(),oCLBTRASPASOCL:oBrw:Setfocus())

  ENDIF

  IF  oCLBTRASPASOCL:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oCLBTRASPASOCL:oBrw:PageUp(),oCLBTRASPASOCL:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oCLBTRASPASOCL:oBrw:GoBottom(),oCLBTRASPASOCL:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oCLBTRASPASOCL:Close()

  oCLBTRASPASOCL:oBrw:SetColor(0,oCLBTRASPASOCL:nClrPane1)

  IF oDp:lBtnText
     oCLBTRASPASOCL:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oCLBTRASPASOCL:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oCLBTRASPASOCL:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oBar:SETSIZE(NIL,140+30+16,.T.)

  oCLBTRASPASOCL:oBar:=oBar

  DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 3.0+1.55,2 SAY " Origen "     RIGHT OF oBar BORDER SIZE 80,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane;
               FONT oFontB

  @ 3.7+1.7,11.7 BMPGET oCLBTRASPASOCL:oCodCli VAR oCLBTRASPASOCL:cCodCli;
              VALID oCLBTRASPASOCL:VALCODCLI();
              NAME "BITMAPS\FIND.BMP";
              ACTION (oDpLbx:=DpLbx("CLBSOCIOS.LBX",NIL,[LEFT(CLI_SITUAC,1)="A"],NIL,NIL,NIL,NIL,NIL,NIL,oCLBTRASPASOCL:oCodCli) , oDpLbx:GetValue("CLI_CODIGO",oCLBTRASPASOCL:oCodCli)); 
              SIZE 100,20 OF oCLBTRASPASOCL:oBar FONT oFontB

  @ oCLBTRASPASOCL:oCodCli:nTop(),oCLBTRASPASOCL:oCodCli:nRight()+20 SAY oCLBTRASPASOCL:oNomCli PROMPT " "+oCLBTRASPASOCL:cNomCli OF oBar;
                                                  SIZE 150+150,20 PIXEL FONT oFontB COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER

  oCLBTRASPASOCL:oCodCli:bkeyDown:={|nkey| IIF(nKey=13, oCLBTRASPASOCL:ValCodCli(),NIL) }


  @ 6.1,2 SAY " Destino "     RIGHT OF oBar BORDER SIZE 80,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane;
               FONT oFontB

  @ 7.2,11.7 BMPGET oCLBTRASPASOCL:oCodDes VAR oCLBTRASPASOCL:cCodDes;
              VALID oCLBTRASPASOCL:VALCodDes();
              NAME "BITMAPS\FIND.BMP";
              ACTION (oDpLbx:=DpLbx("CLBSOCIOS.LBX",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oCLBTRASPASOCL:oCodDes) , oDpLbx:GetValue("CLI_CODIGO",oCLBTRASPASOCL:oCodDes)); 
              SIZE 100,20 OF oCLBTRASPASOCL:oBar FONT oFontB;
              WHEN ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodCli))

  @ oCLBTRASPASOCL:oCodDes:nTop(),oCLBTRASPASOCL:oCodDes:nRight()+20 SAY oCLBTRASPASOCL:oNomCliDes PROMPT " "+oCLBTRASPASOCL:cNomCliDes OF oBar;
                                                  SIZE 150+150,20 PIXEL FONT oFontB COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER

  oCLBTRASPASOCL:oCodDes:bkeyDown:={|nkey| IIF(nKey=13, oCLBTRASPASOCL:ValCodDes(),NIL) }

  @ 7.6,2 SAY " Traspaso "     RIGHT OF oBar BORDER SIZE 80,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane;
               FONT oFontB

  @ 7.6,15.5 SAY oCLBTRASPASOCL:oCodInv PROMPT oCLBTRASPASOCL:cCodInv  RIGHT OF oBar BORDER SIZE 116,20 COLOR oDp:nClrYellowText,oDp:nClrYellow; 
               FONT oFontB

  @ oCLBTRASPASOCL:oCodInv:nTop(),oCLBTRASPASOCL:oCodDes:nRight()+20 SAY " "+SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodInv));
               RIGHT OF oBar BORDER SIZE 316,20 COLOR oDp:nClrYellowText,oDp:nClrYellow; 
               FONT oFontB PIXEL

  @ 9.1,2 SAY " Inicio "     RIGHT OF oBar BORDER SIZE 80,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane;
               FONT oFontB

  @ 10.7,11.7 BMPGET oCLBTRASPASOCL:oFchIni VAR oCLBTRASPASOCL:dFchIni OF oBar;
              ACTION LbxDate(oCLBTRASPASOCL:oFchIni ,oCLBTRASPASOCL:dFchIni);
              SIZE 88,20;
              FONT oFontB

  @ 10.6,2 SAY " Divisa "     RIGHT OF oBar BORDER SIZE 80,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane;
               FONT oFontB

  @ 12.4,11.7 GET oCLBTRASPASOCL:oValCam VAR oCLBTRASPASOCL:nValCam OF oBar;
              PICTURE oDp:cPictValCam;
              SIZE 110,20;
              FONT oFontB RIGHT

  @ 5.2,80 CHECKBOX oCLBTRASPASOCL:oVerDoc  VAR  oCLBTRASPASOCL:lVerDoc;
           PROMPT " Ver Traspaso";
           SIZE 200,20;
           UPDATE  FONT oFontB 

  oCLBTRASPASOCL:oVerDoc:cMsg    :="Ver Documento"
  oCLBTRASPASOCL:oVerDoc:cToolTip:="Ver Documento"

  @ 6.8,80 CHECKBOX oCLBTRASPASOCL:oVerFav  VAR  oCLBTRASPASOCL:lVerFav;
           PROMPT " Ver Factura";
           SIZE 200,20;
           UPDATE  FONT oFontB 

  oCLBTRASPASOCL:oVerFav:cMsg    :="Ver Factura"
  oCLBTRASPASOCL:oVerFav:cToolTip:="Ver Factura"


  BMPGETBTN(oCLBTRASPASOCL:oCodCli) 
  BMPGETBTN(oCLBTRASPASOCL:oCodDes)
  BMPGETBTN(oCLBTRASPASOCL:oFchIni)

  oCLBTRASPASOCL:oCodDes:ForWhen(.T.)


RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRCLBTRASPASOCL",cWhere)
  oRep:cSql  :=oCLBTRASPASOCL:cSql
  oRep:cTitle:=oCLBTRASPASOCL:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCLBTRASPASOCL:oPeriodo:nAt,cWhere

  oCLBTRASPASOCL:nPeriodo:=nPeriodo


  IF oCLBTRASPASOCL:oPeriodo:nAt=LEN(oCLBTRASPASOCL:oPeriodo:aItems)

     oCLBTRASPASOCL:oDesde:ForWhen(.T.)
     oCLBTRASPASOCL:oHasta:ForWhen(.T.)
     oCLBTRASPASOCL:oBtn  :ForWhen(.T.)

     DPFOCUS(oCLBTRASPASOCL:oDesde)

  ELSE

     oCLBTRASPASOCL:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCLBTRASPASOCL:oDesde:VarPut(oCLBTRASPASOCL:aFechas[1] , .T. )
     oCLBTRASPASOCL:oHasta:VarPut(oCLBTRASPASOCL:aFechas[2] , .T. )

     oCLBTRASPASOCL:dDesde:=oCLBTRASPASOCL:aFechas[1]
     oCLBTRASPASOCL:dHasta:=oCLBTRASPASOCL:aFechas[2]

     cWhere:=oCLBTRASPASOCL:HACERWHERE(oCLBTRASPASOCL:dDesde,oCLBTRASPASOCL:dHasta,oCLBTRASPASOCL:cWhere,.T.)

     oCLBTRASPASOCL:LEERDATA(cWhere,oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL:cServer,oCLBTRASPASOCL)

  ENDIF

  oCLBTRASPASOCL:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF ""$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCLBTRASPASOCL:cWhereQry)
       cWhere:=cWhere + oCLBTRASPASOCL:cWhereQry
     ENDIF

     oCLBTRASPASOCL:LEERDATA(cWhere,oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL:cServer,oCLBTRASPASOCL)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCLBTRASPASOCL)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nAt,nRowSel,nCol:=2,I

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT "+;
          " CPT_COMPON,"+;
          " INV_DESCRI,"+;
          " DPCOMPONENTES.CPT_UNDMED,"+;
          " CPT_CANTID,"+;
          " PRE_PRECIO,"+;
          " INV_IVA,"+;
          " 0 AS PORIVA,"+;
          " ROUND(CPT_CANTID*PRE_PRECIO,2)       AS CPT_TOTUSD,"+;
          " ROUND(CPT_CANTID*PRE_PRECIO*35.55,2) AS CPT_TOTAL"+;
          " FROM DPCOMPONENTES  "+;
          " INNER JOIN DPINV     ON INV_CODIGO=CPT_COMPON  "+;
          " LEFT  JOIN DPPRECIOS ON PRE_CODIGO=INV_CODIGO AND "+;
          "                         PRE_UNDMED=CPT_UNDMED AND "+;
          " 					   PRE_CODMON"+GetWhere("=",oDp:cMonedaExt)+" AND "+;
          " 					  PRE_LISTA" +GetWhere("=",oDp:cLista    )+;
          ""

/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRCLBTRASPASOCL.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',0,0,'',0,0,0})
   ENDIF

   FOR I=1 TO LEN(aData)
      aData[I,7]:=EJECUTAR("IVACAL",aData[I,6],nCol,oDp:dFecha) // IVA (Nacional o Zona Libre
   NEXT I

   IF ValType(oBrw)="O"

      oCLBTRASPASOCL:cSql   :=cSql
      oCLBTRASPASOCL:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oCLBTRASPASOCL:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCLBTRASPASOCL:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCLBTRASPASOCL.MEM",V_nPeriodo:=oCLBTRASPASOCL:nPeriodo
  LOCAL V_dDesde:=oCLBTRASPASOCL:dDesde
  LOCAL V_dHasta:=oCLBTRASPASOCL:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCLBTRASPASOCL)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oCLBTRASPASOCL")="O" .AND. oCLBTRASPASOCL:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCLBTRASPASOCL:cWhere_),oCLBTRASPASOCL:cWhere_,oCLBTRASPASOCL:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCLBTRASPASOCL:LEERDATA(oCLBTRASPASOCL:cWhere_,oCLBTRASPASOCL:oBrw,oCLBTRASPASOCL:cServer,oCLBTRASPASOCL)
      oCLBTRASPASOCL:oWnd:Show()
      oCLBTRASPASOCL:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oCLBTRASPASOCL:aHead:=EJECUTAR("HTMLHEAD",oCLBTRASPASOCL)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCLBTRASPASOCL)
RETURN .T.

FUNCTION VALCODCLI()
  LOCAL lValid:=.F.
  LOCAL dFchIni

  lValid:=EJECUTAR("VALCODCLINOMBRE",oCLBTRASPASOCL:oCodCli)

  oCLBTRASPASOCL:cNomCli:=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodCli))
  oCLBTRASPASOCL:oNomCli:Refresh(.T.)

  oCLBTRASPASOCL:oCodDes:ForWhen(.T.)

  IF !ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodCli))
     oCLBTRASPASOCL:oCodCli:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF

  dFchIni:=SQLGET("DPDOCCLI","DOC_FECHA","DOC_TIPDOC"+GetWhere("=","CUO")+" ORDER BY DOC_FECHA DESC LIMIT 1")

  IF !Empty(dFchIni)
    dFchIni:=FCHFINMES(dFchIni)+1
    oCLBTRASPASOCL:oFchIni:VarPut(dFchIni,.T.)
  ENDIF

//? dFchIni,"dFchIni"

RETURN .T.


FUNCTION VALCODDES()
  LOCAL lValid:=EJECUTAR("VALCODCLINOMBRE",oCLBTRASPASOCL:oCodDes,.T.)


  oCLBTRASPASOCL:cNomCliDes:=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodDes))
  oCLBTRASPASOCL:oNomCliDes:Refresh(.T.)

  IF !ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodDes))
     oCLBTRASPASOCL:oCodDes:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF

  IF ALLTRIM(oCLBTRASPASOCL:cCodDes)==ALLTRIM(oCLBTRASPASOCL:cCodCli)
     oCLBTRASPASOCL:oCodDes:MsgErr("Código de Origen "+oCLBTRASPASOCL:cCodCli+" debe ser Diferente "+oCLBTRASPASOCL:cCodDes,"Validación del Código de Socio")
     RETURN .F.
  ENDIF

  oCLBTRASPASOCL:oBtnRun:ForWhen(.T.)

RETURN .T.

/*
// Genera Correspondencia Masiva
*/

FUNCTION TRASPASO()
  LOCAL cNumero:=NIL,nCol:=2,I
  LOCAL nIva   :=EJECUTAR("IVACAL","GN",nCol,oDp:dFecha) // IVA (Nacional o Zona Libre
  LOCAL oDocCli:=NIL,oTable:=NIL,nMonto:=0,I,cItem
  LOCAL nCxC   :=0
  LOCAL aData  :=oCLBTRASPASOCL:oBrw:aArrayData
  LOCAL oMovInv,oTable,cSql,cWhere
  LOCAL cCodCli:=oCLBTRASPASOCL:cCodDes
  LOCAL nDesc  :=0,nRecarg:=0,nDocOtros:=0
  LOCAL cDescri
  LOCAL oData  :=DATASET("CBLCONTRATOS","ALL")

  DEFAULT oDp:cTipDocTRA:="TRA"

  EJECUTAR("DPTIPDOCCLICREA",oDp:cTipDocTRA,"Traspaso de CxC","D")

  SQLUPDATE("DPTIPDOCCLI","TDC_PAGOS",.T.,"TDC_TIPO"+GetWhere("=",oDp:cTipDocTRA))

  cDescri:=ALLTRIM(SQLGET("DPTIPDOCCLI","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oDp:cTipDocTRA)))

  cNumero:=EJECUTAR("DPDOCCLIGETNUM",oDp:cTipDocTRA)

  IF !MsgNoYes("Desea Crear Registro "+cNumero,"Crear "+cDescri)
      RETURN .T.
  ENDIF

  nCxC   :=EJECUTAR("DPTIPCXC",oDp:cTipDocTRA)

  oTable:=INSERTINTO("DPDOCCLI",NIL,10)
  oTable:lAuditar:=.F.
  oTable:lFileLog:=.T.
  oTable:EXECUTE("SET FOREIGN_KEY_CHECKS = 0")

/*
  oMovInv:=INSERTINTO("DPMOVINV",NIL,10)
  oMovInv:lAuditar:=.F.
  oMovInv:lFileLog:=.F.
*/

  EJECUTAR("DPDOCCLICREA",oDp:cSucursal,oDp:cTipDocTRA,cNumero,oCLBTRASPASOCL:cCodDes,oDp:dFecha,oDp:cMonedaExt,"V",NIL,nMonto,nIva,oCLBTRASPASOCL:nValCam,oDp:dFecha,NIL,oTable,"N",nCxC)

  FOR I=1 TO LEN(aData)
       // PROCE MAIN(cCodSuc,cTipDoc,cNumero,cCodInv,nCant,nPrecio,cUnd,nCxUnd,nCostoD,cLote,dFechaV,cOrg,dFecha,cCodCli,cTipIva,nPorIva,nValCam,oTableMov,cLista,nPena)
       nMonto:=ROUND(aData[I,5]*oCLBTRASPASOCL:nValCam,2)
       cItem :=STRZERO(I,5)
       oDp:cItem:=cItem 
       EJECUTAR("DPMOVINVCREA",oDp:cSucursal,oDp:cTipDocTRA,cNumero,aData[I,1],aData[I,4],nMonto,aData[I,3],1,0,"",oDp:dFecha,"V",oCLBTRASPASOCL:dFchIni,oCLBTRASPASOCL:cCodDes,aData[I,6],aData[I,7],oCLBTRASPASOCL:nValCam,oMovInv,oDp:cLista,0,cItem)
  NEXT I

  cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal )+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",oDp:cTipDocTRA)+" AND "+;
          "DOC_NUMERO"+GetWhere("=",cNumero       )+" AND "+;
          "DOC_TIPTRA"+GetWhere("=","D")

  SQLUPDATE("DPDOCCLI","DOC_PLAEXP",oCLBTRASPASOCL:cCodCli,cWhere)

  IF(oMovInv=NIL,NIL,oMovInv:End())

  oTable:EXECUTE(" UPDATE dpdoccli    SET DOC_BASNET=DOC_NETO-DOC_MTOIVA WHERE DOC_TIPDOC"+GetWhere("=",oDp:cTipDocTRA))

  cSql:=[UPDATE DPDOCCLI SET DOC_VALCAM=IF(DOC_VALCAM=0,1,DOC_VALCAM),DOC_MTODIV=IF(DOC_DIVISA,DOC_NETO,ROUND(DOC_NETO/DOC_VALCAM,2)) WHERE DOC_TIPTRA="D" AND DOC_VALCAM<>1 ]
  oTable:EXECUTE(cSql)

  cSql:=[ UPDATE DPMOVINV ]+;
        [ INNER JOIN DPDOCCLI      ON MOV_CODSUC=DOC_CODSUC AND MOV_TIPDOC=DOC_TIPDOC AND MOV_DOCUME=DOC_NUMERO AND DOC_TIPTRA='D'   AND DOC_VALCAM>0 ]+;
        [ SET MOV_MTODIV=ROUND(MOV_TOTAL/DOC_VALCAM,2), ]+;
        [ MOV_ASOTIP="TRA",MOV_IVA]+GetWhere("=",nIva)+[,MOV_PRECIO=DOC_BASNET,MOV_LISTA]+GetWhere("=",oDp:cLista)+[,MOV_FECHA=DOC_FECHA ]+;
        [ WHERE MOV_MTODIV=0 OR MOV_MTODIV=MOV_TOTAL OR MOV_MTODIV IS NULL ]

  oTable:Execute(cSql)

  SQLUPDATE("DPDOCCLI",{"DOC_TIPORG","DOC_CODTER","DOC_USUARI"},{oDp:cTipDocTRA,oDp:cCodter,oDp:cTipDocTRA},"DOC_TIPDOC"+GetWhere("=",oDp:cTipDocTRA))
  SQLUPDATE("DPMOVINV",{"MOV_USUARI","MOV_ASOTIP"             },{oDp:cTipDocTRA,oDp:cTipDocTRA            },"MOV_TIPDOC"+GetWhere("=",oDp:cTipDocTRA))

  SQLUPDATE("DPCLIENTES","CLI_SITUAC","Inactivo","CLI_CODIGO"+GetWhere("=",oCLBTRASPASOCL:cCodCli))

  oTable:EXECUTE("SET FOREIGN_KEY_CHECKS = 1")
  oTable:End()

  EJECUTAR("DPDOCCLIIMP",oDp:cSucursal,oDp:cTipDocTRA,cCodCli,cNumero,.T.,nDesc,nRecarg,nDocOtros,"V")

  IF oCLBTRASPASOCL:lVerDoc
     EJECUTAR("VERDOCCLI",oDp:cSucursal,oDp:cTipDocTRA,cCodCli,cNumero,"D")
  ENDIF

  oData:Set("LVERDOC",oCLBTRASPASOCL:lVerDoc)
  oData:Set("LVERFAV",oCLBTRASPASOCL:lVerFav)

  oData:SAVE()
  oData:End()

  oDp:lVerFac:=oCLBTRASPASOCL:lVerFav // Ver factura CBLTRATOFAV


  oCLBTRASPASOCL:oCodCli:VarPut(SPACE(10),.T.)
  oCLBTRASPASOCL:oCodDes:VarPut(SPACE(10),.T.)
  oCLBTRASPASOCL:oFchIni:VarPut(CTOD("") ,.T.)

  EJECUTAR("DPRECIBODIV",cCodCli)

RETURN .T.
// EOF

