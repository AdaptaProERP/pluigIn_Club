// Programa   : BRCLBALQUILER
// Fecha/Hora : 26/08/2022 07:23:21
// Propósito  : "Afiliaciones de Socios"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCli,cTipDoc)
   LOCAL aData,aFechas,cFileMem:="USER\BRCLBALQUILER.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oCLBALQUILER")="O" .AND. oCLBALQUILER:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCLBALQUILER,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   DEFAULT cTitle :="Alquileres ",;
           cWhere :="INV_UTILIZ"+GetWhere("=","Alquiler"),;
           cTipDoc:=oDp:cTipDocAlq

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=oDp:dFecha,;
           dHasta  :=FCHFINMES(dDesde)

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

   oDp:oFrm:=oCLBALQUILER

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oCLBALQUILER","BRCLBALQUILER.EDT")

// oCLBALQUILER:CreateWindow(0,0,100,550)
   oCLBALQUILER:Windows(0,0,aCoors[3]-160,MIN(744,aCoors[4]-10),.T.) // Maximizado

   oCLBALQUILER:cCodSuc  :=cCodSuc
   oCLBALQUILER:lMsgBar  :=.F.
   oCLBALQUILER:cPeriodo :=aPeriodos[nPeriodo]
   oCLBALQUILER:cCodSuc  :=cCodSuc
   oCLBALQUILER:nPeriodo :=nPeriodo
   oCLBALQUILER:cNombre  :=""
   oCLBALQUILER:dDesde   :=dDesde
   oCLBALQUILER:cServer  :=cServer
   oCLBALQUILER:dHasta   :=dHasta
   oCLBALQUILER:cWhere   :=cWhere
   oCLBALQUILER:cWhere_  :=cWhere_
   oCLBALQUILER:cWhereQry:=""
   oCLBALQUILER:cSql     :=oDp:cSql
   oCLBALQUILER:oWhere   :=TWHERE():New(oCLBALQUILER)
   oCLBALQUILER:cCodPar  :=cCodPar // Código del Parámetro
   oCLBALQUILER:lWhen    :=.T.
   oCLBALQUILER:cTextTit :="" // Texto del Titulo Heredado
   oCLBALQUILER:oDb      :=oDp:oDb
   oCLBALQUILER:cBrwCod  :="CLBAFILIACION"
   oCLBALQUILER:lTmdi    :=.T.
   oCLBALQUILER:aHead    :={}
   oCLBALQUILER:lBarDef  :=.T. // Activar Modo Diseño.
   oCLBALQUILER:cCodCli  :=cCodCli
   oCLBALQUILER:cNombre  :=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))
   oCLBALQUILER:cTipDoc  :=cTipDoc

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCLBALQUILER:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCLBALQUILER)}

   oCLBALQUILER:lBtnRun     :=.F.
   oCLBALQUILER:lBtnMenuBrw :=.F.
   oCLBALQUILER:lBtnSave    :=.F.
   oCLBALQUILER:lBtnCrystal :=.F.
   oCLBALQUILER:lBtnRefresh :=.F.
   oCLBALQUILER:lBtnHtml    :=.T.
   oCLBALQUILER:lBtnExcel   :=.T.
   oCLBALQUILER:lBtnPreview :=.T.
   oCLBALQUILER:lBtnQuery   :=.F.
   oCLBALQUILER:lBtnOptions :=.T.
   oCLBALQUILER:lBtnPageDown:=.T.
   oCLBALQUILER:lBtnPageUp  :=.T.
   oCLBALQUILER:lBtnFilters :=.T.
   oCLBALQUILER:lBtnFind    :=.T.
   oCLBALQUILER:lBtnColor   :=.T.

   oCLBALQUILER:nClrPane1:=16775408
   oCLBALQUILER:nClrPane2:=16771797

   oCLBALQUILER:nClrText :=0
   oCLBALQUILER:nClrText1:=0
   oCLBALQUILER:nClrText2:=0
   oCLBALQUILER:nClrText3:=0




   oCLBALQUILER:oBrw:=TXBrowse():New( IF(oCLBALQUILER:lTmdi,oCLBALQUILER:oWnd,oCLBALQUILER:oDlg ))
   oCLBALQUILER:oBrw:SetArray( aData, .F. )
   oCLBALQUILER:oBrw:SetFont(oFont)

   oCLBALQUILER:oBrw:lFooter     := .T.
   oCLBALQUILER:oBrw:lHScroll    := .F.
   oCLBALQUILER:oBrw:nHeaderLines:= 2
   oCLBALQUILER:oBrw:nDataLines  := 1
   oCLBALQUILER:oBrw:nFooterLines:= 1

   oCLBALQUILER:aData            :=ACLONE(aData)

   AEVAL(oCLBALQUILER:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: DPG_CODINV
  oCol:=oCLBALQUILER:oBrw:aCols[1]
  oCol:cHeader      :='Utilización'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBALQUILER:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: PRE_LISTA
  oCol:=oCLBALQUILER:oBrw:aCols[2]
  oCol:cHeader      :='Lista'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBALQUILER:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  // Campo: PRE_UNDMED
  oCol:=oCLBALQUILER:oBrw:aCols[3]
  oCol:cHeader      :='Unidad'+CRLF+'Medida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBALQUILER:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: PRE_CODMON
  oCol:=oCLBALQUILER:oBrw:aCols[4]
  oCol:cHeader      :='Moneda'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBALQUILER:oBrw:aArrayData ) } 
  oCol:nWidth       := 24

  // Campo: PRE_PRECIO
  oCol:=oCLBALQUILER:oBrw:aCols[5]
  oCol:cHeader      :='Precio'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBALQUILER:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBALQUILER:oBrw:aArrayData[oCLBALQUILER:oBrw:nArrayAt,5],;
                              oCol  := oCLBALQUILER:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}

  oCol:=oCLBALQUILER:oBrw:aCols[6]
  oCol:cHeader      :='Cant.'+CRLF+'Reg'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBALQUILER:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBALQUILER:oBrw:aArrayData[oCLBALQUILER:oBrw:nArrayAt,6],;
                              oCol  := oCLBALQUILER:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)


   oCLBALQUILER:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCLBALQUILER:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCLBALQUILER:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCLBALQUILER:nClrText,;
                                                 nClrText:=IF(.F.,oCLBALQUILER:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCLBALQUILER:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCLBALQUILER:nClrPane1, oCLBALQUILER:nClrPane2 ) } }

   oCLBALQUILER:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCLBALQUILER:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCLBALQUILER:oBrw:bLDblClick:={|oBrw|oCLBALQUILER:RUNCLICK() }

   oCLBALQUILER:oBrw:bChange:={||oCLBALQUILER:BRWCHANGE()}
   oCLBALQUILER:oBrw:CreateFromCode()


   oCLBALQUILER:oWnd:oClient := oCLBALQUILER:oBrw

   oCLBALQUILER:Activate({||oCLBALQUILER:ViewDatBar()})

   oCLBALQUILER:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCLBALQUILER:lTmdi,oCLBALQUILER:oWnd,oCLBALQUILER:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCLBALQUILER:oBrw:nWidth()

   oCLBALQUILER:oBrw:GoBottom(.T.)
   oCLBALQUILER:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRCLBAFILIACION.EDT")
//     oCLBALQUILER:oBrw:Move(44,0,744+50,460)
// ENDIF

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oCLBALQUILER:cServer)

  oCLBALQUILER:oFontBtn   :=oFont    
  oCLBALQUILER:nClrPaneBar:=oDp:nGris
  oCLBALQUILER:oBrw:oLbx  :=oCLBALQUILER

   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta"; 
            ACTION  EJECUTAR("BRWRUNLINK",oCLBALQUILER:oBrw,oCLBALQUILER:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

 


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Crear"; 
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oCLBALQUILER:VERDETALLES(.T.)

   oBtn:cToolTip:="Generar Cuotas"


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\CXC.BMP";
            TOP PROMPT "Cobrar"; 
            ACTION  EJECUTAR("BRAQLXCOBRAR")

   oBtn:cToolTip:="Alquiler por Cobrar y Facturar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CLIENTE.BMP";
          TOP PROMPT "Inquilinos"; 
          ACTION  EJECUTAR("BRINVXCLIPRG","INV_UTILIZ"+GetWhere("=",oCLBALQUILER:oBrw:aArrayData[oCLBALQUILER:oBrw:nArrayAt,1]),NIL,;
                          oDp:nIndefinida,NIL,NIL,"Inquilinos",oCLBALQUILER:oBrw:aArrayData[oCLBALQUILER:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Inquilinos"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PRODUCTO.BMP";
          TOP PROMPT "Producto"; 
          ACTION  EJECUTAR("DPINV",0,oCLBALQUILER:oBrw:aArrayData[oCLBALQUILER:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Ver Producto"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Tarifas"; 
          FILENAME "BITMAPS\PLANTILLAS.BMP";
          ACTION EJECUTAR("DPINVCARACTERISTICA",oCLBALQUILER:oBrw:aArrayData[oCLBALQUILER:oBrw:nArrayAt,1],NIL,.F.)

   oBtn:cToolTip:="Tarifas por Característica"

/*
   IF Empty(oCLBALQUILER:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CLBAFILIACION")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CLBAFILIACION"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles"; 
       ACTION  EJECUTAR("BRWRUNBRWLINK",oCLBALQUILER:oBrw,"CLBAFILIACION",oCLBALQUILER:cSql,oCLBALQUILER:nPeriodo,oCLBALQUILER:dDesde,oCLBALQUILER:dHasta,oCLBALQUILER)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCLBALQUILER:oBtnRun:=oBtn



       oCLBALQUILER:oBrw:bLDblClick:={||EVAL(oCLBALQUILER:oBtnRun:bAction) }


   ENDIF




IF oCLBALQUILER:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCLBALQUILER");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oCLBALQUILER:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCLBALQUILER:lBtnColor

     oCLBALQUILER:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Colorear"; 
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCLBALQUILER:oBrw,oCLBALQUILER,oCLBALQUILER:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCLBALQUILER,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCLBALQUILER,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCLBALQUILER:oBtnColor:=oBtn

ENDIF



IF oCLBALQUILER:lBtnSave
/*
      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
               TOP PROMPT "Grabar"; 
              ACTION  EJECUTAR("DPBRWSAVE",oCLBALQUILER:oBrw,oCLBALQUILER:oFrm)
*/
ENDIF

IF oCLBALQUILER:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú"; 
          ACTION  (EJECUTAR("BRWBUILDHEAD",oCLBALQUILER),;
                   EJECUTAR("DPBRWMENURUN",oCLBALQUILER,oCLBALQUILER:oBrw,oCLBALQUILER:cBrwCod,oCLBALQUILER:cTitle,oCLBALQUILER:aHead));
          WHEN !Empty(oCLBALQUILER:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCLBALQUILER:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oCLBALQUILER:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCLBALQUILER:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oCLBALQUILER:oBrw,oCLBALQUILER);
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oCLBALQUILER:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCLBALQUILER:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oCLBALQUILER:oBrw);
          WHEN LEN(oCLBALQUILER:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCLBALQUILER:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
            TOP PROMPT "Refrescar"; 
              ACTION  oCLBALQUILER:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCLBALQUILER:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
            TOP PROMPT "Crystal"; 
              ACTION  EJECUTAR("BRWTODBF",oCLBALQUILER)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCLBALQUILER:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
              TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oCLBALQUILER:oBrw,oCLBALQUILER:cTitle,oCLBALQUILER:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCLBALQUILER:oBtnXls:=oBtn

ENDIF

IF oCLBALQUILER:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (oCLBALQUILER:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCLBALQUILER:oBrw,NIL,oCLBALQUILER:cTitle,oCLBALQUILER:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCLBALQUILER:oBtnHtml:=oBtn

ENDIF


IF oCLBALQUILER:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oCLBALQUILER:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCLBALQUILER:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCLBAFILIACION")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
              TOP PROMPT "Imprimir"; 
              ACTION  oCLBALQUILER:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCLBALQUILER:oBtnPrint:=oBtn

   ENDIF

IF oCLBALQUILER:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oCLBALQUILER:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oCLBALQUILER:oBrw:GoTop(),oCLBALQUILER:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCLBALQUILER:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
              TOP PROMPT "Avance"; 
              ACTION  (oCLBALQUILER:oBrw:PageDown(),oCLBALQUILER:oBrw:Setfocus())
  ENDIF

  IF  oCLBALQUILER:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
             TOP PROMPT "Anterior"; 
              ACTION  (oCLBALQUILER:oBrw:PageUp(),oCLBALQUILER:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oCLBALQUILER:oBrw:GoBottom(),oCLBALQUILER:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oCLBALQUILER:Close()

  oCLBALQUILER:oBrw:SetColor(0,oCLBALQUILER:nClrPane1)

  oCLBALQUILER:SETBTNBAR(40+20,40+10,oBar)


  EVAL(oCLBALQUILER:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCLBALQUILER:oBar:=oBar

  nLin:=32
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.),nLin:=nLin+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -16 BOLD

  @ 2,nLin SAY " Mes "  OF oBar BORDER SIZE 45,22 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ 2,nLin+42 SAY " "+CMES(oCLBALQUILER:dDesde)+" "+LSTR(YEAR(oCLBALQUILER:dDesde)) ;
                   OF oBar SIZE 160,22 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont BORDER

  nLin:=32
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.),nLin:=nLin+o:nWidth()})

  IF !Empty(oCLBALQUILER:cCodCli)

    oBar:SetSize(NIL,75+35,.T.)

    nLin:=15

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

    @ 1+45,nLin SAY " Código "  OF oBar BORDER SIZE 75,20 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
    @22+45,nLin SAY " Nombre "  OF oBar BORDER SIZE 75,20 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

    @ 01+45,nLin+320-240 SAYREF oCLBALQUILER:oCodCli PROMPT " "+oCLBALQUILER:cCodCli+" ";
                  OF oBar SIZE 95,20 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

    @ 22+45,nLin+320-240 SAY " "+oCLBALQUILER:cNombre;
                  OF oBar SIZE 395,20 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont BORDER

    SayAction(oCLBALQUILER:oCodCli,{||EJECUTAR("DPCLIENTES",0,oCLBALQUILER:cCodCli)})

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

  oRep:=REPORTE("BRCLBAFILIACION",cWhere)
  oRep:cSql  :=oCLBALQUILER:cSql
  oRep:cTitle:=oCLBALQUILER:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCLBALQUILER:oPeriodo:nAt,cWhere

  oCLBALQUILER:nPeriodo:=nPeriodo


  IF oCLBALQUILER:oPeriodo:nAt=LEN(oCLBALQUILER:oPeriodo:aItems)

     oCLBALQUILER:oDesde:ForWhen(.T.)
     oCLBALQUILER:oHasta:ForWhen(.T.)
     oCLBALQUILER:oBtn  :ForWhen(.T.)

     DPFOCUS(oCLBALQUILER:oDesde)

  ELSE

     oCLBALQUILER:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCLBALQUILER:oDesde:VarPut(oCLBALQUILER:aFechas[1] , .T. )
     oCLBALQUILER:oHasta:VarPut(oCLBALQUILER:aFechas[2] , .T. )

     oCLBALQUILER:dDesde:=oCLBALQUILER:aFechas[1]
     oCLBALQUILER:dHasta:=oCLBALQUILER:aFechas[2]

     cWhere:=oCLBALQUILER:HACERWHERE(oCLBALQUILER:dDesde,oCLBALQUILER:dHasta,oCLBALQUILER:cWhere,.T.)

     oCLBALQUILER:LEERDATA(cWhere,oCLBALQUILER:oBrw,oCLBALQUILER:cServer,oCLBALQUILER)

  ENDIF

  oCLBALQUILER:SAVEPERIODO()

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

     IF !Empty(oCLBALQUILER:cWhereQry)
       cWhere:=cWhere + oCLBALQUILER:cWhereQry
     ENDIF

     oCLBALQUILER:LEERDATA(cWhere,oCLBALQUILER:oBrw,oCLBALQUILER:cServer,oCLBALQUILER)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCLBALQUILER)
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
          "  INV_UTILIZ, "+;
          "  PRE_LISTA, "+;
          "  PRE_UNDMED, "+;
          "  PRE_CODMON, "+;
          "  PRE_PRECIO, "+;
          "  COUNT(*) AS CUANTOS "+;
          "  FROM DPCLIENTEPROG "+;
          "  INNER JOIN DPINV      ON DPG_CODINV=INV_CODIGO "+;
          "  INNER JOIN DPCLIENTES ON DPG_CODIGO=CLI_CODIGO AND LEFT(CLI_SITUAC,1)='A' "+;
          "  INNER JOIN VIEW_UNDMEDXINV ON INV_CODIGO=IME_CODIGO  "+;
          "  INNER JOIN VIEW_DPINVPRECIOS ON DPINV.INV_CODIGO=PRE_CODIGO  "+;
          "  GROUP BY INV_UTILIZ,PRE_UNDMED"+;
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

   DPWRITE("TEMP\BRCLBALQUILER.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere

   // innecesario,a hora incluye Alquileres, 27/11/2023
   // AEVAL(aData,{|a,n| SQLUPDATE("DPINV","INV_UTILIZ","Afiliación","INV_CODIGO"+GetWhere("=",a[1]))})

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','',0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCLBALQUILER:cSql   :=cSql
      oCLBALQUILER:cWhere_:=cWhere

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
      AEVAL(oCLBALQUILER:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCLBALQUILER:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCLBAFILIACION.MEM",V_nPeriodo:=oCLBALQUILER:nPeriodo
  LOCAL V_dDesde:=oCLBALQUILER:dDesde
  LOCAL V_dHasta:=oCLBALQUILER:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCLBALQUILER)
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


    IF Type("oCLBALQUILER")="O" .AND. oCLBALQUILER:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCLBALQUILER:cWhere_),oCLBALQUILER:cWhere_,oCLBALQUILER:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCLBALQUILER:LEERDATA(oCLBALQUILER:cWhere_,oCLBALQUILER:oBrw,oCLBALQUILER:cServer)
      oCLBALQUILER:oWnd:Show()
      oCLBALQUILER:oWnd:Restore()

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

   oCLBALQUILER:aHead:=EJECUTAR("HTMLHEAD",oCLBALQUILER)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCLBALQUILER)
RETURN .T.

FUNCTION VERDETALLES()
  LOCAL aLine:=oCLBALQUILER:oBrw:aArrayData[oCLBALQUILER:oBrw:nArrayAt]
  LOCAL cCodInv:=aLine[1]

  EJECUTAR("BRCSCLIRESCUO",NIL,NIL,NIL,NIL,NIL,NIL,"",NIL,cCodInv,NIL,NIL,NIL,oCLBALQUILER:cTipDoc)

  //PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCli,lCodInv,cCodInv,dFecha,nValCam,oFrmMain)

RETURN .T.

FUNCTION VERCLIENTES()
RETURN .T.

FUNCTION VERDETALLES_OLD(lRun)
  LOCAL cWhere:="",cCodSuc,nPeriodo,dDesde,dHasta,cTitle
  LOCAL aLine:=oCLBALQUILER:oBrw:aArrayData[oCLBALQUILER:oBrw:nArrayAt]
  LOCAL cCodInv:=aLine[1]

  cWhere:="DPG_CODINV"+GetWhere("=",cCodInv)

  IF !Empty(oCLBALQUILER:cCodCli)
     cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+" DPG_CODIGO"+GetWhere("=",oCLBALQUILER:cCodCli)
  ENDIF

  EJECUTAR("BRCLBAFILIADET",cWhere,cCodSuc,nPeriodo,oCLBALQUILER:dDesde,oCLBALQUILER:dHasta,cTitle,cCodInv,oCLBALQUILER:cCodCli,lRun)

RETURN .T.

// EOF
