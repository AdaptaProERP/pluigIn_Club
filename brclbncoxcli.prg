// Programa   : BRCLBNCOXCLI
// Fecha/Hora : 02/09/2023 17:48:50
// Propósito  : "Resumen de Notas de Consumo por Cliente"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRCLBNCOXCLI.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oCLBNCOXCLI")="O" .AND. oCLBNCOXCLI:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCLBNCOXCLI,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Resumen de Notas de Consumo por Cliente" +IF(Empty(cTitle),"",cTitle)

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

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oCLBNCOXCLI

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oCLBNCOXCLI","BRCLBNCOXCLI.EDT")
// oCLBNCOXCLI:CreateWindow(0,0,100,550)
   oCLBNCOXCLI:Windows(0,0,aCoors[3]-160,MIN(1588,aCoors[4]-10),.T.) // Maximizado



   oCLBNCOXCLI:cCodSuc  :=cCodSuc
   oCLBNCOXCLI:lMsgBar  :=.F.
   oCLBNCOXCLI:cPeriodo :=aPeriodos[nPeriodo]
   oCLBNCOXCLI:cCodSuc  :=cCodSuc
   oCLBNCOXCLI:nPeriodo :=nPeriodo
   oCLBNCOXCLI:cNombre  :=""
   oCLBNCOXCLI:dDesde   :=dDesde
   oCLBNCOXCLI:cServer  :=cServer
   oCLBNCOXCLI:dHasta   :=dHasta
   oCLBNCOXCLI:cWhere   :=cWhere
   oCLBNCOXCLI:cWhere_  :=cWhere_
   oCLBNCOXCLI:cWhereQry:=""
   oCLBNCOXCLI:cSql     :=oDp:cSql
   oCLBNCOXCLI:oWhere   :=TWHERE():New(oCLBNCOXCLI)
   oCLBNCOXCLI:cCodPar  :=cCodPar // Código del Parámetro
   oCLBNCOXCLI:lWhen    :=.T.
   oCLBNCOXCLI:cTextTit :="" // Texto del Titulo Heredado
   oCLBNCOXCLI:oDb      :=oDp:oDb
   oCLBNCOXCLI:cBrwCod  :="CLBNCOXCLI"
   oCLBNCOXCLI:lTmdi    :=.T.
   oCLBNCOXCLI:aHead    :={}
   oCLBNCOXCLI:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCLBNCOXCLI:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCLBNCOXCLI)}

   oCLBNCOXCLI:lBtnRun     :=.F.
   oCLBNCOXCLI:lBtnMenuBrw :=.F.
   oCLBNCOXCLI:lBtnSave    :=.F.
   oCLBNCOXCLI:lBtnCrystal :=.F.
   oCLBNCOXCLI:lBtnRefresh :=.F.
   oCLBNCOXCLI:lBtnHtml    :=.T.
   oCLBNCOXCLI:lBtnExcel   :=.T.
   oCLBNCOXCLI:lBtnPreview :=.T.
   oCLBNCOXCLI:lBtnQuery   :=.F.
   oCLBNCOXCLI:lBtnOptions :=.T.
   oCLBNCOXCLI:lBtnPageDown:=.T.
   oCLBNCOXCLI:lBtnPageUp  :=.T.
   oCLBNCOXCLI:lBtnFilters :=.T.
   oCLBNCOXCLI:lBtnFind    :=.T.
   oCLBNCOXCLI:lBtnColor   :=.T.

   oCLBNCOXCLI:nClrPane1:=16775408
   oCLBNCOXCLI:nClrPane2:=16771797

   oCLBNCOXCLI:nClrText :=0
   oCLBNCOXCLI:nClrText1:=0
   oCLBNCOXCLI:nClrText2:=0
   oCLBNCOXCLI:nClrText3:=0
   oCLBNCOXCLI:nClrText4:=0



   oCLBNCOXCLI:oBrw:=TXBrowse():New( IF(oCLBNCOXCLI:lTmdi,oCLBNCOXCLI:oWnd,oCLBNCOXCLI:oDlg ))
   oCLBNCOXCLI:oBrw:SetArray( aData, .F. )
   oCLBNCOXCLI:oBrw:SetFont(oFont)

   oCLBNCOXCLI:oBrw:lFooter     := .T.
   oCLBNCOXCLI:oBrw:lHScroll    := .F.
   oCLBNCOXCLI:oBrw:nHeaderLines:= 1
   oCLBNCOXCLI:oBrw:nDataLines  := 1
   oCLBNCOXCLI:oBrw:nFooterLines:= 1




   oCLBNCOXCLI:aData            :=ACLONE(aData)

   AEVAL(oCLBNCOXCLI:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: MOV_CODCTA
  oCol:=oCLBNCOXCLI:oBrw:aCols[1]
  oCol:cHeader      :='Cliente'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBNCOXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: CLI_NOMBRE
  oCol:=oCLBNCOXCLI:oBrw:aCols[2]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBNCOXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: DESDE
  oCol:=oCLBNCOXCLI:oBrw:aCols[3]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBNCOXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: HASTA
  oCol:=oCLBNCOXCLI:oBrw:aCols[4]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBNCOXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: CANTID
  oCol:=oCLBNCOXCLI:oBrw:aCols[5]
  oCol:cHeader      :='Cant.'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBNCOXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBNCOXCLI:oBrw:aArrayData[oCLBNCOXCLI:oBrw:nArrayAt,5],;
                              oCol  := oCLBNCOXCLI:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)


  // Campo: CANEXP
  oCol:=oCLBNCOXCLI:oBrw:aCols[6]
  oCol:cHeader      :='Cant.'+CRLF+'Exportada'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBNCOXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 128
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBNCOXCLI:oBrw:aArrayData[oCLBNCOXCLI:oBrw:nArrayAt,6],;
                              oCol  := oCLBNCOXCLI:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)


  // Campo: CANT
  oCol:=oCLBNCOXCLI:oBrw:aCols[7]
  oCol:cHeader      :='CANT'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBNCOXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBNCOXCLI:oBrw:aArrayData[oCLBNCOXCLI:oBrw:nArrayAt,7],;
                              oCol  := oCLBNCOXCLI:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


   oCLBNCOXCLI:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCLBNCOXCLI:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCLBNCOXCLI:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCLBNCOXCLI:nClrText,;
                                                 nClrText:=IF(.F.,oCLBNCOXCLI:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCLBNCOXCLI:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCLBNCOXCLI:nClrPane1, oCLBNCOXCLI:nClrPane2 ) } }

//   oCLBNCOXCLI:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCLBNCOXCLI:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCLBNCOXCLI:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCLBNCOXCLI:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCLBNCOXCLI:oBrw:bLDblClick:={|oBrw|oCLBNCOXCLI:RUNCLICK() }

   oCLBNCOXCLI:oBrw:bChange:={||oCLBNCOXCLI:BRWCHANGE()}
   oCLBNCOXCLI:oBrw:CreateFromCode()


   oCLBNCOXCLI:oWnd:oClient := oCLBNCOXCLI:oBrw



   oCLBNCOXCLI:Activate({||oCLBNCOXCLI:ViewDatBar()})

   oCLBNCOXCLI:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCLBNCOXCLI:lTmdi,oCLBNCOXCLI:oWnd,oCLBNCOXCLI:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCLBNCOXCLI:oBrw:nWidth()

   oCLBNCOXCLI:oBrw:GoBottom(.T.)
   oCLBNCOXCLI:oBrw:Refresh(.T.)

   IF !File("FORMS\BRCLBNCOXCLI.EDT")
     oCLBNCOXCLI:oBrw:Move(44,0,1588+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oCLBNCOXCLI:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oCLBNCOXCLI:oBrw,oCLBNCOXCLI:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oCLBNCOXCLI:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CLBNCOXCLI")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CLBNCOXCLI"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCLBNCOXCLI:oBrw,"CLBNCOXCLI",oCLBNCOXCLI:cSql,oCLBNCOXCLI:nPeriodo,oCLBNCOXCLI:dDesde,oCLBNCOXCLI:dHasta,oCLBNCOXCLI)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCLBNCOXCLI:oBtnRun:=oBtn



       oCLBNCOXCLI:oBrw:bLDblClick:={||EVAL(oCLBNCOXCLI:oBtnRun:bAction) }


   ENDIF




IF oCLBNCOXCLI:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCLBNCOXCLI");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oCLBNCOXCLI:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCLBNCOXCLI:lBtnColor

     oCLBNCOXCLI:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCLBNCOXCLI:oBrw,oCLBNCOXCLI,oCLBNCOXCLI:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCLBNCOXCLI,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCLBNCOXCLI,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCLBNCOXCLI:oBtnColor:=oBtn

ENDIF



IF oCLBNCOXCLI:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oCLBNCOXCLI:oBrw,oCLBNCOXCLI:oFrm)
ENDIF

IF oCLBNCOXCLI:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCLBNCOXCLI),;
                  EJECUTAR("DPBRWMENURUN",oCLBNCOXCLI,oCLBNCOXCLI:oBrw,oCLBNCOXCLI:cBrwCod,oCLBNCOXCLI:cTitle,oCLBNCOXCLI:aHead));
          WHEN !Empty(oCLBNCOXCLI:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCLBNCOXCLI:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oCLBNCOXCLI:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCLBNCOXCLI:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oCLBNCOXCLI:oBrw,oCLBNCOXCLI);
          ACTION EJECUTAR("BRWSETFILTER",oCLBNCOXCLI:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCLBNCOXCLI:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oCLBNCOXCLI:oBrw);
          WHEN LEN(oCLBNCOXCLI:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCLBNCOXCLI:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oCLBNCOXCLI:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCLBNCOXCLI:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oCLBNCOXCLI)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCLBNCOXCLI:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oCLBNCOXCLI:oBrw,oCLBNCOXCLI:cTitle,oCLBNCOXCLI:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCLBNCOXCLI:oBtnXls:=oBtn

ENDIF

IF oCLBNCOXCLI:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oCLBNCOXCLI:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCLBNCOXCLI:oBrw,NIL,oCLBNCOXCLI:cTitle,oCLBNCOXCLI:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCLBNCOXCLI:oBtnHtml:=oBtn

ENDIF


IF oCLBNCOXCLI:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oCLBNCOXCLI:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCLBNCOXCLI:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCLBNCOXCLI")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oCLBNCOXCLI:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCLBNCOXCLI:oBtnPrint:=oBtn

   ENDIF

IF oCLBNCOXCLI:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oCLBNCOXCLI:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCLBNCOXCLI:oBrw:GoTop(),oCLBNCOXCLI:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCLBNCOXCLI:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oCLBNCOXCLI:oBrw:PageDown(),oCLBNCOXCLI:oBrw:Setfocus())
  ENDIF

  IF  oCLBNCOXCLI:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oCLBNCOXCLI:oBrw:PageUp(),oCLBNCOXCLI:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCLBNCOXCLI:oBrw:GoBottom(),oCLBNCOXCLI:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCLBNCOXCLI:Close()

  oCLBNCOXCLI:oBrw:SetColor(0,oCLBNCOXCLI:nClrPane1)

  oCLBNCOXCLI:SETBTNBAR(40,40,oBar)


  EVAL(oCLBNCOXCLI:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCLBNCOXCLI:oBar:=oBar

    nCol:=1228
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oCLBNCOXCLI:oPeriodo  VAR oCLBNCOXCLI:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oCLBNCOXCLI:LEEFECHAS();
                WHEN oCLBNCOXCLI:lWhen


  ComboIni(oCLBNCOXCLI:oPeriodo )

  @ nLin, nCol+103 BUTTON oCLBNCOXCLI:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCLBNCOXCLI:oPeriodo:nAt,oCLBNCOXCLI:oDesde,oCLBNCOXCLI:oHasta,-1),;
                         EVAL(oCLBNCOXCLI:oBtn:bAction));
                WHEN oCLBNCOXCLI:lWhen


  @ nLin, nCol+130 BUTTON oCLBNCOXCLI:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCLBNCOXCLI:oPeriodo:nAt,oCLBNCOXCLI:oDesde,oCLBNCOXCLI:oHasta,+1),;
                         EVAL(oCLBNCOXCLI:oBtn:bAction));
                WHEN oCLBNCOXCLI:lWhen


  @ nLin, nCol+160 BMPGET oCLBNCOXCLI:oDesde  VAR oCLBNCOXCLI:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCLBNCOXCLI:oDesde ,oCLBNCOXCLI:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oCLBNCOXCLI:oPeriodo:nAt=LEN(oCLBNCOXCLI:oPeriodo:aItems) .AND. oCLBNCOXCLI:lWhen ;
                FONT oFont

   oCLBNCOXCLI:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oCLBNCOXCLI:oHasta  VAR oCLBNCOXCLI:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCLBNCOXCLI:oHasta,oCLBNCOXCLI:dHasta);
                SIZE 76-2,24;
                WHEN oCLBNCOXCLI:oPeriodo:nAt=LEN(oCLBNCOXCLI:oPeriodo:aItems) .AND. oCLBNCOXCLI:lWhen ;
                OF oBar;
                FONT oFont

   oCLBNCOXCLI:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oCLBNCOXCLI:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oCLBNCOXCLI:oPeriodo:nAt=LEN(oCLBNCOXCLI:oPeriodo:aItems);
               ACTION oCLBNCOXCLI:HACERWHERE(oCLBNCOXCLI:dDesde,oCLBNCOXCLI:dHasta,oCLBNCOXCLI:cWhere,.T.);
               WHEN oCLBNCOXCLI:lWhen

  BMPGETBTN(oBar,oFont,13)

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})



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

  oRep:=REPORTE("BRCLBNCOXCLI",cWhere)
  oRep:cSql  :=oCLBNCOXCLI:cSql
  oRep:cTitle:=oCLBNCOXCLI:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCLBNCOXCLI:oPeriodo:nAt,cWhere

  oCLBNCOXCLI:nPeriodo:=nPeriodo


  IF oCLBNCOXCLI:oPeriodo:nAt=LEN(oCLBNCOXCLI:oPeriodo:aItems)

     oCLBNCOXCLI:oDesde:ForWhen(.T.)
     oCLBNCOXCLI:oHasta:ForWhen(.T.)
     oCLBNCOXCLI:oBtn  :ForWhen(.T.)

     DPFOCUS(oCLBNCOXCLI:oDesde)

  ELSE

     oCLBNCOXCLI:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCLBNCOXCLI:oDesde:VarPut(oCLBNCOXCLI:aFechas[1] , .T. )
     oCLBNCOXCLI:oHasta:VarPut(oCLBNCOXCLI:aFechas[2] , .T. )

     oCLBNCOXCLI:dDesde:=oCLBNCOXCLI:aFechas[1]
     oCLBNCOXCLI:dHasta:=oCLBNCOXCLI:aFechas[2]

     cWhere:=oCLBNCOXCLI:HACERWHERE(oCLBNCOXCLI:dDesde,oCLBNCOXCLI:dHasta,oCLBNCOXCLI:cWhere,.T.)

     oCLBNCOXCLI:LEERDATA(cWhere,oCLBNCOXCLI:oBrw,oCLBNCOXCLI:cServer,oCLBNCOXCLI)

  ENDIF

  oCLBNCOXCLI:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPMOVINV_ORDPRO.MOV_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPMOVINV_ORDPRO.MOV_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPMOVINV_ORDPRO.MOV_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCLBNCOXCLI:cWhereQry)
       cWhere:=cWhere + oCLBNCOXCLI:cWhereQry
     ENDIF

     oCLBNCOXCLI:LEERDATA(cWhere,oCLBNCOXCLI:oBrw,oCLBNCOXCLI:cServer,oCLBNCOXCLI)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCLBNCOXCLI)
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

   cSql:=" SELECT "+;
          " MOV_CODCTA,"+;
          " CLI_NOMBRE,"+;
          " MIN(MOV_FECHA)  AS DESDE,"+;
          " MAX(MOV_FECHA)  AS HASTA,"+;
          " SUM(MOV_CANTID) AS CANTID,"+;
          " SUM(MOV_EXPORT) AS CANEXP,"+;
          " COUNT(*) AS CANT"+;
          " FROM DPMOVINV_ORDPRO"+;
          " INNER JOIN DPCLIENTES ON CLI_CODIGO=MOV_CODCTA"+;
          " GROUP BY MOV_CODCTA"+;
          " ORDER BY CLI_NOMBRE"+;
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

   DPWRITE("TEMP\BRCLBNCOXCLI.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',CTOD(""),CTOD(""),0,0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCLBNCOXCLI:cSql   :=cSql
      oCLBNCOXCLI:cWhere_:=cWhere

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
      AEVAL(oCLBNCOXCLI:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCLBNCOXCLI:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCLBNCOXCLI.MEM",V_nPeriodo:=oCLBNCOXCLI:nPeriodo
  LOCAL V_dDesde:=oCLBNCOXCLI:dDesde
  LOCAL V_dHasta:=oCLBNCOXCLI:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCLBNCOXCLI)
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


    IF Type("oCLBNCOXCLI")="O" .AND. oCLBNCOXCLI:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCLBNCOXCLI:cWhere_),oCLBNCOXCLI:cWhere_,oCLBNCOXCLI:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCLBNCOXCLI:LEERDATA(oCLBNCOXCLI:cWhere_,oCLBNCOXCLI:oBrw,oCLBNCOXCLI:cServer,oCLBNCOXCLI)
      oCLBNCOXCLI:oWnd:Show()
      oCLBNCOXCLI:oWnd:Restore()

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

   oCLBNCOXCLI:aHead:=EJECUTAR("HTMLHEAD",oCLBNCOXCLI)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCLBNCOXCLI)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

