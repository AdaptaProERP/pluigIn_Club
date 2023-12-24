// Programa   : BRCLBCONSUMOS
// Fecha/Hora : 26/08/2022 07:23:21
// Propósito  : Registro de Notas de Consumo
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCli,lDirecto)
   LOCAL aData,aFechas,cFileMem:="USER\BRCLBCONSUMOS.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oCLBCONSUMOS")="O" .AND. oCLBCONSUMOS:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCLBCONSUMOS,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Registro de Consumos por Socios" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=oDp:dFecha,;
           dHasta  :=FCHFINMES(dDesde),;
           lDirecto:=.F.

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
   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

   IF Empty(aData) .OR. Empty(aData[1,1])
      MensajeErr("no hay Plantillas Definidas")
      EJECUTAR("DPFACTURAV","PLA")    
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oCLBCONSUMOS

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oCLBCONSUMOS","BRCLBCONSUMOS.EDT")

// oCLBCONSUMOS:CreateWindow(0,0,100,550)
   oCLBCONSUMOS:Windows(0,0,aCoors[3]-160,MIN(744,aCoors[4]-10),.T.) // Maximizado

   oCLBCONSUMOS:cCodSuc  :=cCodSuc
   oCLBCONSUMOS:lMsgBar  :=.F.
   oCLBCONSUMOS:cPeriodo :=aPeriodos[nPeriodo]
   oCLBCONSUMOS:cCodSuc  :=cCodSuc
   oCLBCONSUMOS:nPeriodo :=nPeriodo
   oCLBCONSUMOS:cNombre  :=""
   oCLBCONSUMOS:dDesde   :=dDesde
   oCLBCONSUMOS:cServer  :=cServer
   oCLBCONSUMOS:dHasta   :=dHasta
   oCLBCONSUMOS:cWhere   :=cWhere
   oCLBCONSUMOS:cWhere_  :=cWhere_
   oCLBCONSUMOS:cWhereQry:=""
   oCLBCONSUMOS:cSql     :=oDp:cSql
   oCLBCONSUMOS:oWhere   :=TWHERE():New(oCLBCONSUMOS)
   oCLBCONSUMOS:cCodPar  :=cCodPar // Código del Parámetro
   oCLBCONSUMOS:lWhen    :=.T.
   oCLBCONSUMOS:cTextTit :="" // Texto del Titulo Heredado
   oCLBCONSUMOS:oDb      :=oDp:oDb
   oCLBCONSUMOS:cBrwCod  :="CLBAFILIACION"
   oCLBCONSUMOS:lTmdi    :=.T.
   oCLBCONSUMOS:aHead    :={}
   oCLBCONSUMOS:lBarDef  :=.T. // Activar Modo Diseño.
   oCLBCONSUMOS:cCodCli  :=cCodCli
   oCLBCONSUMOS:cNombre  :=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))
   oCLBCONSUMOS:lDirecto :=lDirecto

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCLBCONSUMOS:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCLBCONSUMOS)}

   oCLBCONSUMOS:lBtnRun     :=.F.
   oCLBCONSUMOS:lBtnMenuBrw :=.F.
   oCLBCONSUMOS:lBtnSave    :=.F.
   oCLBCONSUMOS:lBtnCrystal :=.F.
   oCLBCONSUMOS:lBtnRefresh :=.F.
   oCLBCONSUMOS:lBtnHtml    :=.T.
   oCLBCONSUMOS:lBtnExcel   :=.T.
   oCLBCONSUMOS:lBtnPreview :=.T.
   oCLBCONSUMOS:lBtnQuery   :=.F.
   oCLBCONSUMOS:lBtnOptions :=.T.
   oCLBCONSUMOS:lBtnPageDown:=.T.
   oCLBCONSUMOS:lBtnPageUp  :=.T.
   oCLBCONSUMOS:lBtnFilters :=.T.
   oCLBCONSUMOS:lBtnFind    :=.T.
   oCLBCONSUMOS:lBtnColor   :=.T.
   oCLBCONSUMOS:lDirecto    :=lDirecto

   oCLBCONSUMOS:nClrPane1:=16775408
   oCLBCONSUMOS:nClrPane2:=16771797

   oCLBCONSUMOS:nClrText :=0
   oCLBCONSUMOS:nClrText1:=0
   oCLBCONSUMOS:nClrText2:=0
   oCLBCONSUMOS:nClrText3:=0


   oCLBCONSUMOS:oBrw:=TXBrowse():New( IF(oCLBCONSUMOS:lTmdi,oCLBCONSUMOS:oWnd,oCLBCONSUMOS:oDlg ))
   oCLBCONSUMOS:oBrw:SetArray( aData, .F. )
   oCLBCONSUMOS:oBrw:SetFont(oFont)

   oCLBCONSUMOS:oBrw:lFooter     := .T.
   oCLBCONSUMOS:oBrw:lHScroll    := .F.
   oCLBCONSUMOS:oBrw:nHeaderLines:= 2
   oCLBCONSUMOS:oBrw:nDataLines  := 1
   oCLBCONSUMOS:oBrw:nFooterLines:= 1

   oCLBCONSUMOS:aData            :=ACLONE(aData)

   AEVAL(oCLBCONSUMOS:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: DPG_CODINV
  oCol:=oCLBCONSUMOS:oBrw:aCols[1]
  oCol:cHeader      :='Código'+CRLF+'Servicio'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: INV_DESCRI
  oCol:=oCLBCONSUMOS:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 100


  // Campo: PRE_LISTA
  oCol:=oCLBCONSUMOS:oBrw:aCols[3]
  oCol:cHeader      :='Lista'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  // Campo: PRE_UNDMED
  oCol:=oCLBCONSUMOS:oBrw:aCols[4]
  oCol:cHeader      :='Unidad'+CRLF+'Medida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: PRE_CODMON
  oCol:=oCLBCONSUMOS:oBrw:aCols[5]
  oCol:cHeader      :='Moneda'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 24

  // Campo: PRE_PRECIO
  oCol:=oCLBCONSUMOS:oBrw:aCols[6]
  oCol:cHeader      :='Precio'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBCONSUMOS:oBrw:aArrayData[oCLBCONSUMOS:oBrw:nArrayAt,6],;
                              oCol  := oCLBCONSUMOS:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}

   // Campo: PRE_CODMON
   oCol:=oCLBCONSUMOS:oBrw:aCols[7]
   oCol:cHeader      :='Plantilla'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
   oCol:nWidth       := 70

   // Campo: PRE_CODMON
   oCol:=oCLBCONSUMOS:oBrw:aCols[8]
   oCol:cHeader      :='DOC'+CRLF+"DES"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
   oCol:nWidth       := 70

/*
  // Campo: CUANTOS
  oCol:=oCLBCONSUMOS:oBrw:aCols[7]
  oCol:cHeader      :='Cant.'+CRLF+'Reg'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBCONSUMOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBCONSUMOS:oBrw:aArrayData[oCLBCONSUMOS:oBrw:nArrayAt,7],;
                              oCol  := oCLBCONSUMOS:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)

*/
   oCLBCONSUMOS:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCLBCONSUMOS:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCLBCONSUMOS:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCLBCONSUMOS:nClrText,;
                                                 nClrText:=IF(.F.,oCLBCONSUMOS:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCLBCONSUMOS:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCLBCONSUMOS:nClrPane1, oCLBCONSUMOS:nClrPane2 ) } }

//   oCLBCONSUMOS:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCLBCONSUMOS:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCLBCONSUMOS:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCLBCONSUMOS:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCLBCONSUMOS:oBrw:bLDblClick:={|oBrw|oCLBCONSUMOS:RUNCLICK() }

   oCLBCONSUMOS:oBrw:bChange:={||oCLBCONSUMOS:BRWCHANGE()}
   oCLBCONSUMOS:oBrw:CreateFromCode()


   oCLBCONSUMOS:oWnd:oClient := oCLBCONSUMOS:oBrw

   oCLBCONSUMOS:Activate({||oCLBCONSUMOS:ViewDatBar()})

   oCLBCONSUMOS:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCLBCONSUMOS:lTmdi,oCLBCONSUMOS:oWnd,oCLBCONSUMOS:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCLBCONSUMOS:oBrw:nWidth()

   oCLBCONSUMOS:oBrw:GoBottom(.T.)
   oCLBCONSUMOS:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRCLBCONSUMOS.EDT")
//     oCLBCONSUMOS:oBrw:Move(44,0,744+50,460)
// ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oCLBCONSUMOS:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oCLBCONSUMOS:oBrw,oCLBCONSUMOS:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oCLBCONSUMOS:VERDETALLES(.T.)

   oBtn:cToolTip:="Generar Cuotas"

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CLIENTE.BMP";
          ACTION oCLBCONSUMOS:VERDETALLES(.F.)

   oBtn:cToolTip:="Detalle de Clientes"
*/

/*
   IF Empty(oCLBCONSUMOS:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CLBAFILIACION")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CLBAFILIACION"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCLBCONSUMOS:oBrw,"CLBAFILIACION",oCLBCONSUMOS:cSql,oCLBCONSUMOS:nPeriodo,oCLBCONSUMOS:dDesde,oCLBCONSUMOS:dHasta,oCLBCONSUMOS)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCLBCONSUMOS:oBtnRun:=oBtn



       oCLBCONSUMOS:oBrw:bLDblClick:={||EVAL(oCLBCONSUMOS:oBtnRun:bAction) }


   ENDIF




IF oCLBCONSUMOS:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCLBCONSUMOS");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oCLBCONSUMOS:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCLBCONSUMOS:lBtnColor

     oCLBCONSUMOS:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCLBCONSUMOS:oBrw,oCLBCONSUMOS,oCLBCONSUMOS:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCLBCONSUMOS,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCLBCONSUMOS,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCLBCONSUMOS:oBtnColor:=oBtn

ENDIF



IF oCLBCONSUMOS:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oCLBCONSUMOS:oBrw,oCLBCONSUMOS:oFrm)
ENDIF

IF oCLBCONSUMOS:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCLBCONSUMOS),;
                  EJECUTAR("DPBRWMENURUN",oCLBCONSUMOS,oCLBCONSUMOS:oBrw,oCLBCONSUMOS:cBrwCod,oCLBCONSUMOS:cTitle,oCLBCONSUMOS:aHead));
          WHEN !Empty(oCLBCONSUMOS:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCLBCONSUMOS:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oCLBCONSUMOS:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCLBCONSUMOS:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oCLBCONSUMOS:oBrw,oCLBCONSUMOS);
          ACTION EJECUTAR("BRWSETFILTER",oCLBCONSUMOS:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCLBCONSUMOS:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oCLBCONSUMOS:oBrw);
          WHEN LEN(oCLBCONSUMOS:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCLBCONSUMOS:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oCLBCONSUMOS:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCLBCONSUMOS:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oCLBCONSUMOS)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCLBCONSUMOS:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oCLBCONSUMOS:oBrw,oCLBCONSUMOS:cTitle,oCLBCONSUMOS:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCLBCONSUMOS:oBtnXls:=oBtn

ENDIF

IF oCLBCONSUMOS:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oCLBCONSUMOS:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCLBCONSUMOS:oBrw,NIL,oCLBCONSUMOS:cTitle,oCLBCONSUMOS:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCLBCONSUMOS:oBtnHtml:=oBtn

ENDIF


IF oCLBCONSUMOS:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oCLBCONSUMOS:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCLBCONSUMOS:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCLBCONSUMOS")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oCLBCONSUMOS:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCLBCONSUMOS:oBtnPrint:=oBtn

   ENDIF

IF oCLBCONSUMOS:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oCLBCONSUMOS:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCLBCONSUMOS:oBrw:GoTop(),oCLBCONSUMOS:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCLBCONSUMOS:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oCLBCONSUMOS:oBrw:PageDown(),oCLBCONSUMOS:oBrw:Setfocus())
  ENDIF

  IF  oCLBCONSUMOS:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oCLBCONSUMOS:oBrw:PageUp(),oCLBCONSUMOS:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCLBCONSUMOS:oBrw:GoBottom(),oCLBCONSUMOS:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCLBCONSUMOS:Close()

  oCLBCONSUMOS:oBrw:SetColor(0,oCLBCONSUMOS:nClrPane1)

  oCLBCONSUMOS:SETBTNBAR(40,40,oBar)


  EVAL(oCLBCONSUMOS:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCLBCONSUMOS:oBar:=oBar

  nLin:=32
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.),nLin:=nLin+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -16 BOLD

  @ 2,nLin SAY " Mes "  OF oBar BORDER SIZE 45,22 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ 2,nLin+42 SAY " "+CMES(oCLBCONSUMOS:dDesde)+" "+LSTR(YEAR(oCLBCONSUMOS:dDesde)) ;
                   OF oBar SIZE 160,22 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont BORDER

  nLin:=32
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.),nLin:=nLin+o:nWidth()})

  IF !Empty(oCLBCONSUMOS:cCodCli)

    oBar:SetSize(NIL,75+35,.T.)

    nLin:=15

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

    @ 1+45,nLin SAY " Código "  OF oBar BORDER SIZE 75,20 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
    @22+45,nLin SAY " Nombre "  OF oBar BORDER SIZE 75,20 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

    @ 01+45,nLin+320-240 SAYREF oCLBCONSUMOS:oCodCli PROMPT " "+oCLBCONSUMOS:cCodCli+" ";
                  OF oBar SIZE 95,20 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

    @ 22+45,nLin+320-240 SAY " "+oCLBCONSUMOS:cNombre;
                  OF oBar SIZE 395,20 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont BORDER

    SayAction(oCLBCONSUMOS:oCodCli,{||EJECUTAR("DPCLIENTES",0,oCLBCONSUMOS:cCodCli)})

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

  oRep:=REPORTE("BRCLBCONSUMOS",cWhere)
  oRep:cSql  :=oCLBCONSUMOS:cSql
  oRep:cTitle:=oCLBCONSUMOS:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCLBCONSUMOS:oPeriodo:nAt,cWhere

  oCLBCONSUMOS:nPeriodo:=nPeriodo


  IF oCLBCONSUMOS:oPeriodo:nAt=LEN(oCLBCONSUMOS:oPeriodo:aItems)

     oCLBCONSUMOS:oDesde:ForWhen(.T.)
     oCLBCONSUMOS:oHasta:ForWhen(.T.)
     oCLBCONSUMOS:oBtn  :ForWhen(.T.)

     DPFOCUS(oCLBCONSUMOS:oDesde)

  ELSE

     oCLBCONSUMOS:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCLBCONSUMOS:oDesde:VarPut(oCLBCONSUMOS:aFechas[1] , .T. )
     oCLBCONSUMOS:oHasta:VarPut(oCLBCONSUMOS:aFechas[2] , .T. )

     oCLBCONSUMOS:dDesde:=oCLBCONSUMOS:aFechas[1]
     oCLBCONSUMOS:dHasta:=oCLBCONSUMOS:aFechas[2]

     cWhere:=oCLBCONSUMOS:HACERWHERE(oCLBCONSUMOS:dDesde,oCLBCONSUMOS:dHasta,oCLBCONSUMOS:cWhere,.T.)

     oCLBCONSUMOS:LEERDATA(cWhere,oCLBCONSUMOS:oBrw,oCLBCONSUMOS:cServer,oCLBCONSUMOS)

  ENDIF

  oCLBCONSUMOS:SAVEPERIODO()

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

     IF !Empty(oCLBCONSUMOS:cWhereQry)
       cWhere:=cWhere + oCLBCONSUMOS:cWhereQry
     ENDIF

     oCLBCONSUMOS:LEERDATA(cWhere,oCLBCONSUMOS:oBrw,oCLBCONSUMOS:cServer,oCLBCONSUMOS)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCLBCONSUMOS)
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

  cSql:=[ SELECT  MOV_CODIGO,INV_DESCRI,DOC_DESTIN,MOV_UNDMED,DOC_CODMON,PRE_PRECIO,DOC_NUMERO,DOC_TIPAFE ]+;
        [ FROM DPMOVINV ]+;
        [ INNER JOIN dpinv ON MOV_CODIGO=INV_CODIGO AND LEFT(INV_ESTADO,1)="A" ]+;
        [ INNER JOIN dpdoccli ON DOC_CODSUC=MOV_CODSUC AND DOC_NUMERO=MOV_DOCUME AND DOC_TIPDOC="PLA" AND DOC_ACT=1 ]+;
        [ INNER JOIN dpprecios ON PRE_CODIGO=MOV_CODIGO AND PRE_UNDMED=MOV_UNDMED AND PRE_CODMON=DOC_CODMON AND PRE_LISTA=DOC_DESTIN ]+;
        [ WHERE MOV_TIPDOC="PLA" AND MOV_INVACT=1 ]+;
        [ GROUP BY MOV_CODIGO,DOC_NUMERO ]

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
	
   DPWRITE("TEMP\BRCLBCONSUMOS.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere

//   AEVAL(aData,{|a,n| SQLUPDATE("DPINV","INV_UTILIZ","Afiliación","INV_CODIGO"+GetWhere("=",a[1]))})

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','',0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCLBCONSUMOS:cSql   :=cSql
      oCLBCONSUMOS:cWhere_:=cWhere

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
      AEVAL(oCLBCONSUMOS:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCLBCONSUMOS:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCLBCONSUMOS.MEM",V_nPeriodo:=oCLBCONSUMOS:nPeriodo
  LOCAL V_dDesde:=oCLBCONSUMOS:dDesde
  LOCAL V_dHasta:=oCLBCONSUMOS:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCLBCONSUMOS)
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


    IF Type("oCLBCONSUMOS")="O" .AND. oCLBCONSUMOS:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCLBCONSUMOS:cWhere_),oCLBCONSUMOS:cWhere_,oCLBCONSUMOS:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCLBCONSUMOS:LEERDATA(oCLBCONSUMOS:cWhere_,oCLBCONSUMOS:oBrw,oCLBCONSUMOS:cServer)
      oCLBCONSUMOS:oWnd:Show()
      oCLBCONSUMOS:oWnd:Restore()

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

   oCLBCONSUMOS:aHead:=EJECUTAR("HTMLHEAD",oCLBCONSUMOS)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCLBCONSUMOS)
RETURN .T.

FUNCTION VERDETALLES()
  LOCAL aLine:=oCLBCONSUMOS:oBrw:aArrayData[oCLBCONSUMOS:oBrw:nArrayAt]
  LOCAL cCodInv:=aLine[1]
  LOCAL dFecha :=NIL,nValCam:=NIL,oFrmMain:=NIL,cTipDoc:=aLine[8],cNumPla:=aLine[9]
  LOCAL cWhere :=NIL

  IF oCLBCONSUMOS:lDirecto
    EJECUTAR("BRNCOREGMOV",cWhere,oCLBCONSUMOS:cCodSuc,oDp:nMensual,oCLBCONSUMOS:dDesde,oCLBCONSUMOS:dHasta,NIL,cTipDoc,cCodInv,cNumpla)
  ELSE
    EJECUTAR("BRCSCLIRESCONSUMO",NIL,NIL,NIL,NIL,NIL,NIL,"",NIL,cCodInv,dFecha,nValCam,oFrmMain,cTipDoc,cNumPla)
  ENDIF

RETURN .T.

FUNCTION VERDETALLES_OLD(lRun)
  LOCAL cWhere:="",cCodSuc,nPeriodo,dDesde,dHasta,cTitle
  LOCAL aLine:=oCLBCONSUMOS:oBrw:aArrayData[oCLBCONSUMOS:oBrw:nArrayAt]
  LOCAL cCodInv:=aLine[1]

  cWhere:="DPG_CODINV"+GetWhere("=",cCodInv)

  IF !Empty(oCLBCONSUMOS:cCodCli)
     cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+" DPG_CODIGO"+GetWhere("=",oCLBCONSUMOS:cCodCli)
  ENDIF

  EJECUTAR("BRCLBAFILIADET",cWhere,cCodSuc,nPeriodo,oCLBCONSUMOS:dDesde,oCLBCONSUMOS:dHasta,cTitle,cCodInv,oCLBCONSUMOS:cCodCli,lRun)

RETURN .T.

// EOF
