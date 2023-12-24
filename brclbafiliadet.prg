// Programa   : BRCLBAFILIADET
// Fecha/Hora : 26/08/2022 07:47:12
// Propósito  : "Afiliaciones Detalladas del Socia"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodInv,cCodCli,lRun)
   LOCAL aData,aFechas,cFileMem:="USER\BRCLBAFILIADET.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

// ? dDesde,dHasta,"dDesde,dHasta,BRCLBAFILIADET"

   IF Type("oCLBAFILIADET")="O" .AND. oCLBAFILIADET:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCLBAFILIADET,GetScript())
   ENDIF

   DEFAULT cCodInv:="",;
           lRun   :=.F.,;
           cWhere :="DPG_CODINV"+GetWhere("=",cCodInv)

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Afiliaciones Detalladas del Socia" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oCLBAFILIADET

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oCLBAFILIADET","BRCLBAFILIADET.EDT")
// oCLBAFILIADET:CreateWindow(0,0,100,550)
   oCLBAFILIADET:Windows(0,0,aCoors[3]-160,MIN(900,aCoors[4]-10),.T.) // Maximizado


   oCLBAFILIADET:cCodSuc  :=cCodSuc
   oCLBAFILIADET:lMsgBar  :=.F.
   oCLBAFILIADET:cPeriodo :=aPeriodos[nPeriodo]
   oCLBAFILIADET:cCodSuc  :=cCodSuc
   oCLBAFILIADET:nPeriodo :=nPeriodo
   oCLBAFILIADET:cNombre  :=""
   oCLBAFILIADET:dDesde   :=dDesde
   oCLBAFILIADET:cServer  :=cServer
   oCLBAFILIADET:dHasta   :=dHasta
   oCLBAFILIADET:cWhere   :=cWhere
   oCLBAFILIADET:cWhere_  :=cWhere_
   oCLBAFILIADET:cWhereQry:=""
   oCLBAFILIADET:cSql     :=oDp:cSql
   oCLBAFILIADET:oWhere   :=TWHERE():New(oCLBAFILIADET)
   oCLBAFILIADET:cCodPar  :=cCodPar // Código del Parámetro
   oCLBAFILIADET:lWhen    :=.T.
   oCLBAFILIADET:cTextTit :="" // Texto del Titulo Heredado
   oCLBAFILIADET:oDb      :=oDp:oDb
   oCLBAFILIADET:cBrwCod  :="CLBAFILIADET"
   oCLBAFILIADET:lTmdi    :=.T.
   oCLBAFILIADET:aHead    :={}
   oCLBAFILIADET:lBarDef  :=.T. // Activar Modo Diseño.

   oCLBAFILIADET:cCodInv  :=cCodInv
   oCLBAFILIADET:cCodCli  :=cCodCli
   oCLBAFILIADET:lRun     :=lRun


   // Guarda los parámetros del Browse cuando cierra la ventana
   oCLBAFILIADET:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCLBAFILIADET)}

   oCLBAFILIADET:lBtnRun     :=.F.
   oCLBAFILIADET:lBtnMenuBrw :=.F.
   oCLBAFILIADET:lBtnSave    :=.F.
   oCLBAFILIADET:lBtnCrystal :=.F.
   oCLBAFILIADET:lBtnRefresh :=.F.
   oCLBAFILIADET:lBtnHtml    :=.T.
   oCLBAFILIADET:lBtnExcel   :=.T.
   oCLBAFILIADET:lBtnPreview :=.T.
   oCLBAFILIADET:lBtnQuery   :=.F.
   oCLBAFILIADET:lBtnOptions :=.T.
   oCLBAFILIADET:lBtnPageDown:=.T.
   oCLBAFILIADET:lBtnPageUp  :=.T.
   oCLBAFILIADET:lBtnFilters :=.T.
   oCLBAFILIADET:lBtnFind    :=.T.
   oCLBAFILIADET:lBtnColor   :=.T.

   oCLBAFILIADET:nClrPane1:=16775408
   oCLBAFILIADET:nClrPane2:=16771797

   oCLBAFILIADET:nClrText :=0
   oCLBAFILIADET:nClrText1:=0
   oCLBAFILIADET:nClrText2:=0
   oCLBAFILIADET:nClrText3:=0




   oCLBAFILIADET:oBrw:=TXBrowse():New( IF(oCLBAFILIADET:lTmdi,oCLBAFILIADET:oWnd,oCLBAFILIADET:oDlg ))
   oCLBAFILIADET:oBrw:SetArray( aData, .F. )
   oCLBAFILIADET:oBrw:SetFont(oFont)

   oCLBAFILIADET:oBrw:lFooter     := .T.
   oCLBAFILIADET:oBrw:lHScroll    := .F.
   oCLBAFILIADET:oBrw:nHeaderLines:= 2
   oCLBAFILIADET:oBrw:nDataLines  := 1
   oCLBAFILIADET:oBrw:nFooterLines:= 1




   oCLBAFILIADET:aData            :=ACLONE(aData)

   AEVAL(oCLBAFILIADET:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: DPG_CODIGO
  oCol:=oCLBAFILIADET:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIADET:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: CLI_NOMBRE
  oCol:=oCLBAFILIADET:oBrw:aCols[2]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIADET:oBrw:aArrayData ) } 
  oCol:nWidth       := 480

  // Campo: PRE_LISTA
  oCol:=oCLBAFILIADET:oBrw:aCols[3]
  oCol:cHeader      :='Lista'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIADET:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  // Campo: PRE_UNDMED
  oCol:=oCLBAFILIADET:oBrw:aCols[4]
  oCol:cHeader      :='Unidad'+CRLF+'Medida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIADET:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: PRE_CODMON
  oCol:=oCLBAFILIADET:oBrw:aCols[5]
  oCol:cHeader      :='Moneda'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIADET:oBrw:aArrayData ) } 
  oCol:nWidth       := 24

  // Campo: PRE_PRECIO
  oCol:=oCLBAFILIADET:oBrw:aCols[6]
  oCol:cHeader      :='Precio'+CRLF+'Venta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIADET:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBAFILIADET:oBrw:aArrayData[oCLBAFILIADET:oBrw:nArrayAt,6],;
                              oCol  := oCLBAFILIADET:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)


   oCLBAFILIADET:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCLBAFILIADET:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCLBAFILIADET:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCLBAFILIADET:nClrText,;
                                                 nClrText:=IF(.F.,oCLBAFILIADET:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCLBAFILIADET:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCLBAFILIADET:nClrPane1, oCLBAFILIADET:nClrPane2 ) } }

//   oCLBAFILIADET:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCLBAFILIADET:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCLBAFILIADET:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCLBAFILIADET:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCLBAFILIADET:oBrw:bLDblClick:={|oBrw|oCLBAFILIADET:RUNCLICK() }

   oCLBAFILIADET:oBrw:bChange:={||oCLBAFILIADET:BRWCHANGE()}
   oCLBAFILIADET:oBrw:CreateFromCode()


   oCLBAFILIADET:oWnd:oClient := oCLBAFILIADET:oBrw



   oCLBAFILIADET:Activate({||oCLBAFILIADET:ViewDatBar()})

   oCLBAFILIADET:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCLBAFILIADET:lTmdi,oCLBAFILIADET:oWnd,oCLBAFILIADET:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCLBAFILIADET:oBrw:nWidth()

   oCLBAFILIADET:oBrw:GoBottom(.T.)
   oCLBAFILIADET:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRCLBAFILIADET.EDT")
//     oCLBAFILIADET:oBrw:Move(44,0,900+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15+40 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD


 // Emanager no Incluye consulta de Vinculos


  IF oCLBAFILIADET:lRun

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\RUN.BMP";
           ACTION oCLBAFILIADET:GENCUOTAS()

    oBtn:cToolTip:="Generar las Cuotas"

  ENDIF


/*
   IF Empty(oCLBAFILIADET:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CLBAFILIADET")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CLBAFILIADET"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCLBAFILIADET:oBrw,"CLBAFILIADET",oCLBAFILIADET:cSql,oCLBAFILIADET:nPeriodo,oCLBAFILIADET:dDesde,oCLBAFILIADET:dHasta,oCLBAFILIADET)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCLBAFILIADET:oBtnRun:=oBtn



       oCLBAFILIADET:oBrw:bLDblClick:={||EVAL(oCLBAFILIADET:oBtnRun:bAction) }


   ENDIF




IF oCLBAFILIADET:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCLBAFILIADET");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oCLBAFILIADET:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCLBAFILIADET:lBtnColor

     oCLBAFILIADET:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCLBAFILIADET:oBrw,oCLBAFILIADET,oCLBAFILIADET:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCLBAFILIADET,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCLBAFILIADET,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCLBAFILIADET:oBtnColor:=oBtn

ENDIF



IF oCLBAFILIADET:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oCLBAFILIADET:oBrw,oCLBAFILIADET:oFrm)
ENDIF

IF oCLBAFILIADET:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCLBAFILIADET),;
                  EJECUTAR("DPBRWMENURUN",oCLBAFILIADET,oCLBAFILIADET:oBrw,oCLBAFILIADET:cBrwCod,oCLBAFILIADET:cTitle,oCLBAFILIADET:aHead));
          WHEN !Empty(oCLBAFILIADET:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCLBAFILIADET:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oCLBAFILIADET:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCLBAFILIADET:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oCLBAFILIADET:oBrw,oCLBAFILIADET);
          ACTION EJECUTAR("BRWSETFILTER",oCLBAFILIADET:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCLBAFILIADET:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oCLBAFILIADET:oBrw);
          WHEN LEN(oCLBAFILIADET:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCLBAFILIADET:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oCLBAFILIADET:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCLBAFILIADET:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oCLBAFILIADET)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCLBAFILIADET:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oCLBAFILIADET:oBrw,oCLBAFILIADET:cTitle,oCLBAFILIADET:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCLBAFILIADET:oBtnXls:=oBtn

ENDIF

IF oCLBAFILIADET:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oCLBAFILIADET:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCLBAFILIADET:oBrw,NIL,oCLBAFILIADET:cTitle,oCLBAFILIADET:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCLBAFILIADET:oBtnHtml:=oBtn

ENDIF


IF oCLBAFILIADET:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oCLBAFILIADET:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCLBAFILIADET:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCLBAFILIADET")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oCLBAFILIADET:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCLBAFILIADET:oBtnPrint:=oBtn

   ENDIF

IF oCLBAFILIADET:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oCLBAFILIADET:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCLBAFILIADET:oBrw:GoTop(),oCLBAFILIADET:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCLBAFILIADET:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oCLBAFILIADET:oBrw:PageDown(),oCLBAFILIADET:oBrw:Setfocus())
  ENDIF

  IF  oCLBAFILIADET:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oCLBAFILIADET:oBrw:PageUp(),oCLBAFILIADET:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCLBAFILIADET:oBrw:GoBottom(),oCLBAFILIADET:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCLBAFILIADET:Close()

  oCLBAFILIADET:oBrw:SetColor(0,oCLBAFILIADET:nClrPane1)

  oCLBAFILIADET:SETBTNBAR(40,40,oBar)


  EVAL(oCLBAFILIADET:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  nCol:=32
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),nCol:=nCol+o:nWidth()})

  oCLBAFILIADET:oBar:=oBar


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -16 BOLD

  nLin:=15

  @ 47,nLin SAY " Mes "  OF oBar BORDER SIZE 45,22 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ 47,nLin+42 SAY " "+CMES(oCLBAFILIADET:dDesde)+" "+LSTR(YEAR(oCLBAFILIADET:dDesde)) ;
                   OF oBar SIZE 160,22 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont BORDER


  IF !Empty(oCLBAFILIADET:cCodInv)

     @ 00,nCol    SAY " Código ";
                  OF oBar PIXEL BORDER SIZE 080,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT

     @ 00,nCol+061+20 SAY " "+oCLBAFILIADET:cCodInv                                                         OF oBar PIXEL BORDER SIZE 120,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont 
     @ 22,nCol        SAY " "+SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oCLBAFILIADET:cCodInv)) OF oBar PIXEL BORDER SIZE 300,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  ENDIF
 

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

  oRep:=REPORTE("BRCLBAFILIADET",cWhere)
  oRep:cSql  :=oCLBAFILIADET:cSql
  oRep:cTitle:=oCLBAFILIADET:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCLBAFILIADET:oPeriodo:nAt,cWhere

  oCLBAFILIADET:nPeriodo:=nPeriodo


  IF oCLBAFILIADET:oPeriodo:nAt=LEN(oCLBAFILIADET:oPeriodo:aItems)

     oCLBAFILIADET:oDesde:ForWhen(.T.)
     oCLBAFILIADET:oHasta:ForWhen(.T.)
     oCLBAFILIADET:oBtn  :ForWhen(.T.)

     DPFOCUS(oCLBAFILIADET:oDesde)

  ELSE

     oCLBAFILIADET:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCLBAFILIADET:oDesde:VarPut(oCLBAFILIADET:aFechas[1] , .T. )
     oCLBAFILIADET:oHasta:VarPut(oCLBAFILIADET:aFechas[2] , .T. )

     oCLBAFILIADET:dDesde:=oCLBAFILIADET:aFechas[1]
     oCLBAFILIADET:dHasta:=oCLBAFILIADET:aFechas[2]

     cWhere:=oCLBAFILIADET:HACERWHERE(oCLBAFILIADET:dDesde,oCLBAFILIADET:dHasta,oCLBAFILIADET:cWhere,.T.)

     oCLBAFILIADET:LEERDATA(cWhere,oCLBAFILIADET:oBrw,oCLBAFILIADET:cServer,oCLBAFILIADET)

  ENDIF

  oCLBAFILIADET:SAVEPERIODO()

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

     IF !Empty(oCLBAFILIADET:cWhereQry)
       cWhere:=cWhere + oCLBAFILIADET:cWhereQry
     ENDIF

     oCLBAFILIADET:LEERDATA(cWhere,oCLBAFILIADET:oBrw,oCLBAFILIADET:cServer,oCLBAFILIADET)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCLBAFILIADET)
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
          "  DPG_CODIGO, "+;
          "  CLI_NOMBRE, "+;
          "  PRE_LISTA, "+;
          "  PRE_UNDMED, "+;
          "  PRE_CODMON, "+;
          "  PRE_PRECIO "+;
          "  FROM DPCLIENTEPROG "+;
          "  INNER JOIN DPCLIENTES ON DPG_CODIGO=CLI_CODIGO AND LEFT(CLI_SITUAC,1)='A' "+;
          "  INNER JOIN DPINV ON DPG_CODINV=INV_CODIGO "+;
          "  LEFT JOIN VIEW_UNDMEDXINV ON INV_CODIGO=IME_CODIGO  "+;
          "  LEFT JOIN VIEW_DPINVPRECIOS ON DPINV.INV_CODIGO=PRE_CODIGO  "+;
          " ORDER BY CLI_CODIGO"+;
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

   DPWRITE("TEMP\BRCLBAFILIADET.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','',0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCLBAFILIADET:cSql   :=cSql
      oCLBAFILIADET:cWhere_:=cWhere

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
      AEVAL(oCLBAFILIADET:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCLBAFILIADET:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCLBAFILIADET.MEM",V_nPeriodo:=oCLBAFILIADET:nPeriodo
  LOCAL V_dDesde:=oCLBAFILIADET:dDesde
  LOCAL V_dHasta:=oCLBAFILIADET:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCLBAFILIADET)
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


    IF Type("oCLBAFILIADET")="O" .AND. oCLBAFILIADET:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCLBAFILIADET:cWhere_),oCLBAFILIADET:cWhere_,oCLBAFILIADET:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCLBAFILIADET:LEERDATA(oCLBAFILIADET:cWhere_,oCLBAFILIADET:oBrw,oCLBAFILIADET:cServer)
      oCLBAFILIADET:oWnd:Show()
      oCLBAFILIADET:oWnd:Restore()

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

   oCLBAFILIADET:aHead:=EJECUTAR("HTMLHEAD",oCLBAFILIADET)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCLBAFILIADET)
RETURN .T.

FUNCTION GENCUOTAS()
  LOCAL cWhere:="DPG_CODINV"+GetWhere("=",oCLBAFILIADET:cCodInv)
  LOCAL lOk    :=.F.
  LOCAL lDelete:=.T.
  LOCAL lAsk   :=.T.

  IF !Empty(oCLBAFILIADET:cCodCli)
     cWhere:=cWhere+" AND DPG_CODIGO"+GetWhere("=",oCLBAFILIADET:cCodCli)
  ENDIF

  lOk:= EJECUTAR("CLBGENCUOTAS",cWhere,oCLBAFILIADET:dDesde,oCLBAFILIADET:dHasta,oCLBAFILIADET:cCodInv,oCLBAFILIADET:cCodCli,lDelete,lAsk)

  EJECUTAR("DPFACTURAV",oDp:cTipDocClb)

RETURN .T.

/*
// Genera Correspondencia Masiva
*/
// EOF

