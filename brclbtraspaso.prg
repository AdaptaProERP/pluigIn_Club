// Programa   : BRCLBTRASPASO
// Fecha/Hora : 12/12/2023 18:51:22
// Propósito  : "Traspaso de Acciones"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodInv)
   LOCAL aData,aFechas,cFileMem:="USER\BRCLBTRASPASO.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oCLBTRASPASO")="O" .AND. oCLBTRASPASO:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCLBTRASPASO,GetScript())
   ENDIF

//   DEFAULT cCodInv:=SQLGET("DPCOMPONENTES","


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Traspaso de Acciones" +IF(Empty(cTitle),"",cTitle)

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

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

//  ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle+CRLF+"Debes definir productos Compuestos","Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oCLBTRASPASO

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oCLBTRASPASO","BRCLBTRASPASO.EDT")
// oCLBTRASPASO:CreateWindow(0,0,100,550)
   oCLBTRASPASO:Windows(0,0,aCoors[3]-160,MIN(696,aCoors[4]-10),.T.) // Maximizado

   oCLBTRASPASO:cCodSuc  :=cCodSuc
   oCLBTRASPASO:lMsgBar  :=.F.
   oCLBTRASPASO:cPeriodo :=aPeriodos[nPeriodo]
   oCLBTRASPASO:cCodSuc  :=cCodSuc
   oCLBTRASPASO:nPeriodo :=nPeriodo
   oCLBTRASPASO:cNombre  :=""
   oCLBTRASPASO:dDesde   :=dDesde
   oCLBTRASPASO:cServer  :=cServer
   oCLBTRASPASO:dHasta   :=dHasta
   oCLBTRASPASO:cWhere   :=cWhere
   oCLBTRASPASO:cWhere_  :=cWhere_
   oCLBTRASPASO:cWhereQry:=""
   oCLBTRASPASO:cSql     :=oDp:cSql
   oCLBTRASPASO:oWhere   :=TWHERE():New(oCLBTRASPASO)
   oCLBTRASPASO:cCodPar  :=cCodPar // Código del Parámetro
   oCLBTRASPASO:lWhen    :=.T.
   oCLBTRASPASO:cTextTit :="" // Texto del Titulo Heredado
   oCLBTRASPASO:oDb      :=oDp:oDb
   oCLBTRASPASO:cBrwCod  :="CLBTRASPASO"
   oCLBTRASPASO:lTmdi    :=.T.
   oCLBTRASPASO:aHead    :={}
   oCLBTRASPASO:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCLBTRASPASO:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCLBTRASPASO)}

   oCLBTRASPASO:lBtnRun     :=.F.
   oCLBTRASPASO:lBtnMenuBrw :=.F.
   oCLBTRASPASO:lBtnSave    :=.F.
   oCLBTRASPASO:lBtnCrystal :=.F.
   oCLBTRASPASO:lBtnRefresh :=.F.
   oCLBTRASPASO:lBtnHtml    :=.T.
   oCLBTRASPASO:lBtnExcel   :=.T.
   oCLBTRASPASO:lBtnPreview :=.T.
   oCLBTRASPASO:lBtnQuery   :=.F.
   oCLBTRASPASO:lBtnOptions :=.T.
   oCLBTRASPASO:lBtnPageDown:=.T.
   oCLBTRASPASO:lBtnPageUp  :=.T.
   oCLBTRASPASO:lBtnFilters :=.T.
   oCLBTRASPASO:lBtnFind    :=.T.
   oCLBTRASPASO:lBtnColor   :=.T.

   oCLBTRASPASO:nClrPane1:=16775408
   oCLBTRASPASO:nClrPane2:=16771797

   oCLBTRASPASO:nClrText :=0
   oCLBTRASPASO:nClrText1:=0
   oCLBTRASPASO:nClrText2:=0
   oCLBTRASPASO:nClrText3:=0




   oCLBTRASPASO:oBrw:=TXBrowse():New( IF(oCLBTRASPASO:lTmdi,oCLBTRASPASO:oWnd,oCLBTRASPASO:oDlg ))
   oCLBTRASPASO:oBrw:SetArray( aData, .F. )
   oCLBTRASPASO:oBrw:SetFont(oFont)

   oCLBTRASPASO:oBrw:lFooter     := .T.
   oCLBTRASPASO:oBrw:lHScroll    := .F.
   oCLBTRASPASO:oBrw:nHeaderLines:= 2
   oCLBTRASPASO:oBrw:nDataLines  := 1
   oCLBTRASPASO:oBrw:nFooterLines:= 1




   oCLBTRASPASO:aData            :=ACLONE(aData)

   AEVAL(oCLBTRASPASO:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: INV_CODIGO
  oCol:=oCLBTRASPASO:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASO:oBrw:aArrayData ) } 
  oCol:nWidth       := 176

  // Campo: INV_DESCRI
  oCol:=oCLBTRASPASO:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASO:oBrw:aArrayData ) } 
  oCol:nWidth       := 380

  // Campo: INV_MONTO
  oCol:=oCLBTRASPASO:oBrw:aCols[3]
  oCol:cHeader      :='Monto'+CRLF+'USD'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASO:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBTRASPASO:oBrw:aArrayData[oCLBTRASPASO:oBrw:nArrayAt,3],;
                              oCol  := oCLBTRASPASO:oBrw:aCols[3],;
                              FDP(nMonto,oCol:cEditPicture)}



  // Campo: CUANTOS
  oCol:=oCLBTRASPASO:oBrw:aCols[4]
  oCol:cHeader      :='Cant.'+CRLF+'Comp.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBTRASPASO:oBrw:aArrayData ) } 
  oCol:nWidth       := 60
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBTRASPASO:oBrw:aArrayData[oCLBTRASPASO:oBrw:nArrayAt,4],;
                              oCol  := oCLBTRASPASO:oBrw:aCols[4],;
                              FDP(nMonto,oCol:cEditPicture)}



   oCLBTRASPASO:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCLBTRASPASO:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCLBTRASPASO:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCLBTRASPASO:nClrText,;
                                                 nClrText:=IF(.F.,oCLBTRASPASO:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCLBTRASPASO:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCLBTRASPASO:nClrPane1, oCLBTRASPASO:nClrPane2 ) } }

//   oCLBTRASPASO:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCLBTRASPASO:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCLBTRASPASO:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCLBTRASPASO:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCLBTRASPASO:oBrw:bLDblClick:={|oBrw|oCLBTRASPASO:RUNCLICK() }

   oCLBTRASPASO:oBrw:bChange:={||oCLBTRASPASO:BRWCHANGE()}
   oCLBTRASPASO:oBrw:CreateFromCode()


   oCLBTRASPASO:oWnd:oClient := oCLBTRASPASO:oBrw



   oCLBTRASPASO:Activate({||oCLBTRASPASO:ViewDatBar()})

   oCLBTRASPASO:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCLBTRASPASO:lTmdi,oCLBTRASPASO:oWnd,oCLBTRASPASO:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCLBTRASPASO:oBrw:nWidth()

   oCLBTRASPASO:oBrw:GoBottom(.T.)
   oCLBTRASPASO:oBrw:Refresh(.T.)

   IF !File("FORMS\BRCLBTRASPASO.EDT")
     oCLBTRASPASO:oBrw:Move(44,0,696+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oCLBTRASPASO:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oCLBTRASPASO:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oCLBTRASPASO:oBrw:oLbx  :=oCLBTRASPASO    // MDI:GOTFOCUS()




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oCLBTRASPASO:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oCLBTRASPASO:oBrw,oCLBTRASPASO:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Ejecutar";
            ACTION EJECUTAR("BRCLBTRASPASOCL",NIL,NIL,NIL,NIL,NIL,NIL,oCLBTRASPASO:oBrw:aArrayData[oCLBTRASPASO:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Ejecutar Traspaso"


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\PRECIOS.BMP";
            TOP PROMPT "Precio";
            ACTION EJECUTAR("DPCOMPONENTES",oCLBTRASPASO:oBrw:aArrayData[oCLBTRASPASO:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Componentes y Precio"



   


/*
   IF Empty(oCLBTRASPASO:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CLBTRASPASO")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CLBTRASPASO"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCLBTRASPASO:oBrw,"CLBTRASPASO",oCLBTRASPASO:cSql,oCLBTRASPASO:nPeriodo,oCLBTRASPASO:dDesde,oCLBTRASPASO:dHasta,oCLBTRASPASO)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCLBTRASPASO:oBtnRun:=oBtn



       oCLBTRASPASO:oBrw:bLDblClick:={||EVAL(oCLBTRASPASO:oBtnRun:bAction) }


   ENDIF




IF oCLBTRASPASO:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCLBTRASPASO");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oCLBTRASPASO:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCLBTRASPASO:lBtnColor

     oCLBTRASPASO:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCLBTRASPASO:oBrw,oCLBTRASPASO,oCLBTRASPASO:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCLBTRASPASO,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCLBTRASPASO,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCLBTRASPASO:oBtnColor:=oBtn

ENDIF

IF oCLBTRASPASO:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Guardar";
             ACTION EJECUTAR("DPBRWSAVE",oCLBTRASPASO:oBrw,oCLBTRASPASO:oFrm)

ENDIF

IF oCLBTRASPASO:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCLBTRASPASO),;
                  EJECUTAR("DPBRWMENURUN",oCLBTRASPASO,oCLBTRASPASO:oBrw,oCLBTRASPASO:cBrwCod,oCLBTRASPASO:cTitle,oCLBTRASPASO:aHead));
          WHEN !Empty(oCLBTRASPASO:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCLBTRASPASO:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oCLBTRASPASO:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCLBTRASPASO:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oCLBTRASPASO:oBrw,oCLBTRASPASO);
          ACTION EJECUTAR("BRWSETFILTER",oCLBTRASPASO:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCLBTRASPASO:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oCLBTRASPASO:oBrw);
          WHEN LEN(oCLBTRASPASO:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCLBTRASPASO:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oCLBTRASPASO:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCLBTRASPASO:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oCLBTRASPASO)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCLBTRASPASO:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oCLBTRASPASO:oBrw,oCLBTRASPASO:cTitle,oCLBTRASPASO:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCLBTRASPASO:oBtnXls:=oBtn

ENDIF

IF oCLBTRASPASO:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oCLBTRASPASO:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCLBTRASPASO:oBrw,NIL,oCLBTRASPASO:cTitle,oCLBTRASPASO:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCLBTRASPASO:oBtnHtml:=oBtn

ENDIF


IF oCLBTRASPASO:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oCLBTRASPASO:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCLBTRASPASO:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCLBTRASPASO")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oCLBTRASPASO:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCLBTRASPASO:oBtnPrint:=oBtn

   ENDIF

IF oCLBTRASPASO:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oCLBTRASPASO:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oCLBTRASPASO:oBrw:GoTop(),oCLBTRASPASO:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCLBTRASPASO:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oCLBTRASPASO:oBrw:PageDown(),oCLBTRASPASO:oBrw:Setfocus())

  ENDIF

  IF  oCLBTRASPASO:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oCLBTRASPASO:oBrw:PageUp(),oCLBTRASPASO:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oCLBTRASPASO:oBrw:GoBottom(),oCLBTRASPASO:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oCLBTRASPASO:Close()

  oCLBTRASPASO:oBrw:SetColor(0,oCLBTRASPASO:nClrPane1)

  IF oDp:lBtnText
     oCLBTRASPASO:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oCLBTRASPASO:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oCLBTRASPASO:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCLBTRASPASO:oBar:=oBar

  

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

  oRep:=REPORTE("BRCLBTRASPASO",cWhere)
  oRep:cSql  :=oCLBTRASPASO:cSql
  oRep:cTitle:=oCLBTRASPASO:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCLBTRASPASO:oPeriodo:nAt,cWhere

  oCLBTRASPASO:nPeriodo:=nPeriodo


  IF oCLBTRASPASO:oPeriodo:nAt=LEN(oCLBTRASPASO:oPeriodo:aItems)

     oCLBTRASPASO:oDesde:ForWhen(.T.)
     oCLBTRASPASO:oHasta:ForWhen(.T.)
     oCLBTRASPASO:oBtn  :ForWhen(.T.)

     DPFOCUS(oCLBTRASPASO:oDesde)

  ELSE

     oCLBTRASPASO:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCLBTRASPASO:oDesde:VarPut(oCLBTRASPASO:aFechas[1] , .T. )
     oCLBTRASPASO:oHasta:VarPut(oCLBTRASPASO:aFechas[2] , .T. )

     oCLBTRASPASO:dDesde:=oCLBTRASPASO:aFechas[1]
     oCLBTRASPASO:dHasta:=oCLBTRASPASO:aFechas[2]

     cWhere:=oCLBTRASPASO:HACERWHERE(oCLBTRASPASO:dDesde,oCLBTRASPASO:dHasta,oCLBTRASPASO:cWhere,.T.)

     oCLBTRASPASO:LEERDATA(cWhere,oCLBTRASPASO:oBrw,oCLBTRASPASO:cServer,oCLBTRASPASO)

  ENDIF

  oCLBTRASPASO:SAVEPERIODO()

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

     IF !Empty(oCLBTRASPASO:cWhereQry)
       cWhere:=cWhere + oCLBTRASPASO:cWhereQry
     ENDIF

     oCLBTRASPASO:LEERDATA(cWhere,oCLBTRASPASO:oBrw,oCLBTRASPASO:cServer,oCLBTRASPASO)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCLBTRASPASO)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nAt,nRowSel

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

   cSql:=" SELECT  "+;
          " INV_CODIGO, "+;
          " INV_DESCRI, "+;
          " SUM(CPT_CANTID*PRE_PRECIO) AS INV_MONTO, "+;
          " COUNT(*) AS CUANTOS "+;
          " FROM DPINV "+;
          " INNER JOIN DPCOMPONENTES ON INV_CODIGO=CPT_CODIGO "+;
          " LEFT  JOIN DPPRECIOS ON PRE_CODIGO=CPT_COMPON AND  "+;
          "                         PRE_UNDMED=CPT_UNDMED AND  "+;
          "                         PRE_CODMON"+GetWhere("=",oDp:cMonedaExt)+" AND "+;
          "                         PRE_LISTA "+GetWhere("=",oDp:cLista)+;
          " WHERE LEFT(INV_ESTADO,1)='A' "+;
          " GROUP BY INV_CODIGO"+;
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


   oDp:lExcluye:=.F.

   DPWRITE("TEMP\BRCLBTRASPASO.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCLBTRASPASO:cSql   :=cSql
      oCLBTRASPASO:cWhere_:=cWhere

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
      AEVAL(oCLBTRASPASO:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCLBTRASPASO:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCLBTRASPASO.MEM",V_nPeriodo:=oCLBTRASPASO:nPeriodo
  LOCAL V_dDesde:=oCLBTRASPASO:dDesde
  LOCAL V_dHasta:=oCLBTRASPASO:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCLBTRASPASO)
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


    IF Type("oCLBTRASPASO")="O" .AND. oCLBTRASPASO:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCLBTRASPASO:cWhere_),oCLBTRASPASO:cWhere_,oCLBTRASPASO:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCLBTRASPASO:LEERDATA(oCLBTRASPASO:cWhere_,oCLBTRASPASO:oBrw,oCLBTRASPASO:cServer,oCLBTRASPASO)
      oCLBTRASPASO:oWnd:Show()
      oCLBTRASPASO:oWnd:Restore()

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

   oCLBTRASPASO:aHead:=EJECUTAR("HTMLHEAD",oCLBTRASPASO)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCLBTRASPASO)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

