// Programa   : BRCLBAFILIACION
// Fecha/Hora : 26/08/2022 07:23:21
// Propósito  : "Afiliaciones de Socios"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCli)
   LOCAL aData,aFechas,cFileMem:="USER\BRCLBAFILIACION.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oCLBAFILIACION")="O" .AND. oCLBAFILIACION:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCLBAFILIACION,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   DEFAULT cTitle:="Afiliaciones de Socios "

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

   oDp:oFrm:=oCLBAFILIACION

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oCLBAFILIACION","BRCLBAFILIACION.EDT")

// oCLBAFILIACION:CreateWindow(0,0,100,550)
   oCLBAFILIACION:Windows(0,0,aCoors[3]-160,MIN(744,aCoors[4]-10),.T.) // Maximizado

   oCLBAFILIACION:cCodSuc  :=cCodSuc
   oCLBAFILIACION:lMsgBar  :=.F.
   oCLBAFILIACION:cPeriodo :=aPeriodos[nPeriodo]
   oCLBAFILIACION:cCodSuc  :=cCodSuc
   oCLBAFILIACION:nPeriodo :=nPeriodo
   oCLBAFILIACION:cNombre  :=""
   oCLBAFILIACION:dDesde   :=dDesde
   oCLBAFILIACION:cServer  :=cServer
   oCLBAFILIACION:dHasta   :=dHasta
   oCLBAFILIACION:cWhere   :=cWhere
   oCLBAFILIACION:cWhere_  :=cWhere_
   oCLBAFILIACION:cWhereQry:=""
   oCLBAFILIACION:cSql     :=oDp:cSql
   oCLBAFILIACION:oWhere   :=TWHERE():New(oCLBAFILIACION)
   oCLBAFILIACION:cCodPar  :=cCodPar // Código del Parámetro
   oCLBAFILIACION:lWhen    :=.T.
   oCLBAFILIACION:cTextTit :="" // Texto del Titulo Heredado
   oCLBAFILIACION:oDb      :=oDp:oDb
   oCLBAFILIACION:cBrwCod  :="CLBAFILIACION"
   oCLBAFILIACION:lTmdi    :=.T.
   oCLBAFILIACION:aHead    :={}
   oCLBAFILIACION:lBarDef  :=.T. // Activar Modo Diseño.
   oCLBAFILIACION:cCodCli  :=cCodCli
   oCLBAFILIACION:cNombre  :=SQLGET("DPCLIENTES","CLI_NOMBRE","CLI_CODIGO"+GetWhere("=",cCodCli))

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCLBAFILIACION:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCLBAFILIACION)}

   oCLBAFILIACION:lBtnRun     :=.F.
   oCLBAFILIACION:lBtnMenuBrw :=.F.
   oCLBAFILIACION:lBtnSave    :=.F.
   oCLBAFILIACION:lBtnCrystal :=.F.
   oCLBAFILIACION:lBtnRefresh :=.F.
   oCLBAFILIACION:lBtnHtml    :=.T.
   oCLBAFILIACION:lBtnExcel   :=.T.
   oCLBAFILIACION:lBtnPreview :=.T.
   oCLBAFILIACION:lBtnQuery   :=.F.
   oCLBAFILIACION:lBtnOptions :=.T.
   oCLBAFILIACION:lBtnPageDown:=.T.
   oCLBAFILIACION:lBtnPageUp  :=.T.
   oCLBAFILIACION:lBtnFilters :=.T.
   oCLBAFILIACION:lBtnFind    :=.T.
   oCLBAFILIACION:lBtnColor   :=.T.

   oCLBAFILIACION:nClrPane1:=16775408
   oCLBAFILIACION:nClrPane2:=16771797

   oCLBAFILIACION:nClrText :=0
   oCLBAFILIACION:nClrText1:=0
   oCLBAFILIACION:nClrText2:=0
   oCLBAFILIACION:nClrText3:=0




   oCLBAFILIACION:oBrw:=TXBrowse():New( IF(oCLBAFILIACION:lTmdi,oCLBAFILIACION:oWnd,oCLBAFILIACION:oDlg ))
   oCLBAFILIACION:oBrw:SetArray( aData, .F. )
   oCLBAFILIACION:oBrw:SetFont(oFont)

   oCLBAFILIACION:oBrw:lFooter     := .T.
   oCLBAFILIACION:oBrw:lHScroll    := .F.
   oCLBAFILIACION:oBrw:nHeaderLines:= 2
   oCLBAFILIACION:oBrw:nDataLines  := 1
   oCLBAFILIACION:oBrw:nFooterLines:= 1

   oCLBAFILIACION:aData            :=ACLONE(aData)

   AEVAL(oCLBAFILIACION:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: DPG_CODINV
  oCol:=oCLBAFILIACION:oBrw:aCols[1]
  oCol:cHeader      :='Código'+CRLF+'Servicio'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIACION:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: INV_DESCRI
  oCol:=oCLBAFILIACION:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIACION:oBrw:aArrayData ) } 
  oCol:nWidth       := 100

  // Campo: PRE_LISTA
  oCol:=oCLBAFILIACION:oBrw:aCols[3]
  oCol:cHeader      :='Lista'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIACION:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  // Campo: PRE_UNDMED
  oCol:=oCLBAFILIACION:oBrw:aCols[4]
  oCol:cHeader      :='Unidad'+CRLF+'Medida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIACION:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: PRE_CODMON
  oCol:=oCLBAFILIACION:oBrw:aCols[5]
  oCol:cHeader      :='Moneda'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIACION:oBrw:aArrayData ) } 
  oCol:nWidth       := 24

  // Campo: PRE_PRECIO
  oCol:=oCLBAFILIACION:oBrw:aCols[6]
  oCol:cHeader      :='Precio'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIACION:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBAFILIACION:oBrw:aArrayData[oCLBAFILIACION:oBrw:nArrayAt,6],;
                              oCol  := oCLBAFILIACION:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}

  // Campo: CUANTOS
  oCol:=oCLBAFILIACION:oBrw:aCols[7]
  oCol:cHeader      :='Cant.'+CRLF+'Reg'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBAFILIACION:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBAFILIACION:oBrw:aArrayData[oCLBAFILIACION:oBrw:nArrayAt,7],;
                              oCol  := oCLBAFILIACION:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


   oCLBAFILIACION:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCLBAFILIACION:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCLBAFILIACION:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCLBAFILIACION:nClrText,;
                                                 nClrText:=IF(.F.,oCLBAFILIACION:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCLBAFILIACION:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCLBAFILIACION:nClrPane1, oCLBAFILIACION:nClrPane2 ) } }

//   oCLBAFILIACION:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCLBAFILIACION:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCLBAFILIACION:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCLBAFILIACION:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCLBAFILIACION:oBrw:bLDblClick:={|oBrw|oCLBAFILIACION:RUNCLICK() }

   oCLBAFILIACION:oBrw:bChange:={||oCLBAFILIACION:BRWCHANGE()}
   oCLBAFILIACION:oBrw:CreateFromCode()


   oCLBAFILIACION:oWnd:oClient := oCLBAFILIACION:oBrw

   oCLBAFILIACION:Activate({||oCLBAFILIACION:ViewDatBar()})

   oCLBAFILIACION:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCLBAFILIACION:lTmdi,oCLBAFILIACION:oWnd,oCLBAFILIACION:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCLBAFILIACION:oBrw:nWidth()

   oCLBAFILIACION:oBrw:GoBottom(.T.)
   oCLBAFILIACION:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRCLBAFILIACION.EDT")
//     oCLBAFILIACION:oBrw:Move(44,0,744+50,460)
// ENDIF

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oCLBAFILIACION:cServer)

     oCLBAFILIACION:oFontBtn   :=oFont    
   oCLBAFILIACION:nClrPaneBar:=oDp:nGris
   oCLBAFILIACION:oBrw:oLbx  :=oCLBAFILIACION

 DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta"; 
            ACTION  EJECUTAR("BRWRUNLINK",oCLBAFILIACION:oBrw,oCLBAFILIACION:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Crear"; 
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oCLBAFILIACION:VERDETALLES(.T.)

   oBtn:cToolTip:="Generar Cuotas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CLIENTE.BMP";
          TOP PROMPT "Socio"; 
          ACTION  EJECUTAR("BRINVXCLIPRG","DPG_CODINV"+GetWhere("=",oCLBAFILIACION:oBrw:aArrayData[oCLBAFILIACION:oBrw:nArrayAt,1]),NIL,;
                          oDp:nIndefinida,NIL,NIL,NIL,oCLBAFILIACION:oBrw:aArrayData[oCLBAFILIACION:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Clientes Afiliados"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PRODUCTO.BMP";
          TOP PROMPT "Producto"; 
          ACTION  EJECUTAR("DPINV",0,oCLBAFILIACION:oBrw:aArrayData[oCLBAFILIACION:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Ver Producto"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Tarifas"; 
          FILENAME "BITMAPS\PLANTILLAS.BMP";
          ACTION EJECUTAR("DPINVCARACTERISTICA",oCLBAFILIACION:oBrw:aArrayData[oCLBAFILIACION:oBrw:nArrayAt,1],NIL,.F.)

   oBtn:cToolTip:="Tarifas por Característica"

/*
   IF Empty(oCLBAFILIACION:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CLBAFILIACION")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CLBAFILIACION"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
         TOP PROMPT "Detalles"; 
              ACTION  EJECUTAR("BRWRUNBRWLINK",oCLBAFILIACION:oBrw,"CLBAFILIACION",oCLBAFILIACION:cSql,oCLBAFILIACION:nPeriodo,oCLBAFILIACION:dDesde,oCLBAFILIACION:dHasta,oCLBAFILIACION)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCLBAFILIACION:oBtnRun:=oBtn



       oCLBAFILIACION:oBrw:bLDblClick:={||EVAL(oCLBAFILIACION:oBtnRun:bAction) }


   ENDIF




IF oCLBAFILIACION:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCLBAFILIACION");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oCLBAFILIACION:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCLBAFILIACION:lBtnColor

     oCLBAFILIACION:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Colorear"; 
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCLBAFILIACION:oBrw,oCLBAFILIACION,oCLBAFILIACION:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCLBAFILIACION,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCLBAFILIACION,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCLBAFILIACION:oBtnColor:=oBtn

ENDIF



IF oCLBAFILIACION:lBtnSave
/*
      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
               TOP PROMPT "Grabar"; 
              ACTION  EJECUTAR("DPBRWSAVE",oCLBAFILIACION:oBrw,oCLBAFILIACION:oFrm)
*/
ENDIF

IF oCLBAFILIACION:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
            TOP PROMPT "Menú"; 
              ACTION  (EJECUTAR("BRWBUILDHEAD",oCLBAFILIACION),;
                  EJECUTAR("DPBRWMENURUN",oCLBAFILIACION,oCLBAFILIACION:oBrw,oCLBAFILIACION:cBrwCod,oCLBAFILIACION:cTitle,oCLBAFILIACION:aHead));
          WHEN !Empty(oCLBAFILIACION:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCLBAFILIACION:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
            TOP PROMPT "Buscar"; 
              ACTION  EJECUTAR("BRWSETFIND",oCLBAFILIACION:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCLBAFILIACION:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oCLBAFILIACION:oBrw,oCLBAFILIACION);
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oCLBAFILIACION:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCLBAFILIACION:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
            TOP PROMPT "Opciones"; 
              ACTION  EJECUTAR("BRWSETOPTIONS",oCLBAFILIACION:oBrw);
          WHEN LEN(oCLBAFILIACION:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCLBAFILIACION:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
            TOP PROMPT "Refrescar"; 
              ACTION  oCLBAFILIACION:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCLBAFILIACION:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
            TOP PROMPT "Crystal"; 
              ACTION  EJECUTAR("BRWTODBF",oCLBAFILIACION)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCLBAFILIACION:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
              TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oCLBAFILIACION:oBrw,oCLBAFILIACION:cTitle,oCLBAFILIACION:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCLBAFILIACION:oBtnXls:=oBtn

ENDIF

IF oCLBAFILIACION:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
            TOP PROMPT "Html"; 
              ACTION  (oCLBAFILIACION:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCLBAFILIACION:oBrw,NIL,oCLBAFILIACION:cTitle,oCLBAFILIACION:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCLBAFILIACION:oBtnHtml:=oBtn

ENDIF


IF oCLBAFILIACION:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
            TOP PROMPT "Preview"; 
              ACTION  (EJECUTAR("BRWPREVIEW",oCLBAFILIACION:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCLBAFILIACION:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCLBAFILIACION")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
              TOP PROMPT "Imprimir"; 
              ACTION  oCLBAFILIACION:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCLBAFILIACION:oBtnPrint:=oBtn

   ENDIF

IF oCLBAFILIACION:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oCLBAFILIACION:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oCLBAFILIACION:oBrw:GoTop(),oCLBAFILIACION:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCLBAFILIACION:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
              TOP PROMPT "Avance"; 
              ACTION  (oCLBAFILIACION:oBrw:PageDown(),oCLBAFILIACION:oBrw:Setfocus())
  ENDIF

  IF  oCLBAFILIACION:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
             TOP PROMPT "Anterior"; 
              ACTION  (oCLBAFILIACION:oBrw:PageUp(),oCLBAFILIACION:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oCLBAFILIACION:oBrw:GoBottom(),oCLBAFILIACION:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oCLBAFILIACION:Close()

  oCLBAFILIACION:oBrw:SetColor(0,oCLBAFILIACION:nClrPane1)

  oCLBAFILIACION:SETBTNBAR(40+20,40+10,oBar)


  EVAL(oCLBAFILIACION:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCLBAFILIACION:oBar:=oBar

  nLin:=32
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.),nLin:=nLin+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -16 BOLD

  @ 2,nLin SAY " Mes "  OF oBar BORDER SIZE 45,22 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ 2,nLin+42 SAY " "+CMES(oCLBAFILIACION:dDesde)+" "+LSTR(YEAR(oCLBAFILIACION:dDesde)) ;
                   OF oBar SIZE 160,22 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont BORDER

  nLin:=32
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.),nLin:=nLin+o:nWidth()})

  IF !Empty(oCLBAFILIACION:cCodCli)

    oBar:SetSize(NIL,75+35,.T.)

    nLin:=15

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

    @ 1+45,nLin SAY " Código "  OF oBar BORDER SIZE 75,20 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
    @22+45,nLin SAY " Nombre "  OF oBar BORDER SIZE 75,20 PIXEL RIGHT  COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 UNDERLINE BOLD

    @ 01+45,nLin+320-240 SAYREF oCLBAFILIACION:oCodCli PROMPT " "+oCLBAFILIACION:cCodCli+" ";
                  OF oBar SIZE 95,20 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

    @ 22+45,nLin+320-240 SAY " "+oCLBAFILIACION:cNombre;
                  OF oBar SIZE 395,20 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont BORDER

    SayAction(oCLBAFILIACION:oCodCli,{||EJECUTAR("DPCLIENTES",0,oCLBAFILIACION:cCodCli)})

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
  oRep:cSql  :=oCLBAFILIACION:cSql
  oRep:cTitle:=oCLBAFILIACION:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCLBAFILIACION:oPeriodo:nAt,cWhere

  oCLBAFILIACION:nPeriodo:=nPeriodo


  IF oCLBAFILIACION:oPeriodo:nAt=LEN(oCLBAFILIACION:oPeriodo:aItems)

     oCLBAFILIACION:oDesde:ForWhen(.T.)
     oCLBAFILIACION:oHasta:ForWhen(.T.)
     oCLBAFILIACION:oBtn  :ForWhen(.T.)

     DPFOCUS(oCLBAFILIACION:oDesde)

  ELSE

     oCLBAFILIACION:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCLBAFILIACION:oDesde:VarPut(oCLBAFILIACION:aFechas[1] , .T. )
     oCLBAFILIACION:oHasta:VarPut(oCLBAFILIACION:aFechas[2] , .T. )

     oCLBAFILIACION:dDesde:=oCLBAFILIACION:aFechas[1]
     oCLBAFILIACION:dHasta:=oCLBAFILIACION:aFechas[2]

     cWhere:=oCLBAFILIACION:HACERWHERE(oCLBAFILIACION:dDesde,oCLBAFILIACION:dHasta,oCLBAFILIACION:cWhere,.T.)

     oCLBAFILIACION:LEERDATA(cWhere,oCLBAFILIACION:oBrw,oCLBAFILIACION:cServer,oCLBAFILIACION)

  ENDIF

  oCLBAFILIACION:SAVEPERIODO()

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

     IF !Empty(oCLBAFILIACION:cWhereQry)
       cWhere:=cWhere + oCLBAFILIACION:cWhereQry
     ENDIF

     oCLBAFILIACION:LEERDATA(cWhere,oCLBAFILIACION:oBrw,oCLBAFILIACION:cServer,oCLBAFILIACION)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCLBAFILIACION)
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
          "  DPG_CODINV, "+;
          "  INV_DESCRI, "+;
          "  PRE_LISTA, "+;
          "  PRE_UNDMED, "+;
          "  PRE_CODMON, "+;
          "  PRE_PRECIO, "+;
          "  COUNT(*) AS CUANTOS "+;
          "  FROM DPCLIENTEPROG "+;
          "  INNER JOIN DPINV      ON DPG_CODINV=INV_CODIGO "+;
          "  INNER JOIN DPCLIENTES ON DPG_CODIGO=CLI_CODIGO AND LEFT(CLI_SITUAC,1)='A' "+;
          "  LEFT JOIN VIEW_UNDMEDXINV ON INV_CODIGO=IME_CODIGO  "+;
          "  LEFT JOIN VIEW_DPINVPRECIOS ON DPINV.INV_CODIGO=PRE_CODIGO  "+;
          "  GROUP BY DPG_CODINV"+;
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

   DPWRITE("TEMP\BRCLBAFILIACION.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere

   // innecesario,a hora incluye Alquileres, 27/11/2023
   // AEVAL(aData,{|a,n| SQLUPDATE("DPINV","INV_UTILIZ","Afiliación","INV_CODIGO"+GetWhere("=",a[1]))})

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','',0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCLBAFILIACION:cSql   :=cSql
      oCLBAFILIACION:cWhere_:=cWhere

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
      AEVAL(oCLBAFILIACION:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCLBAFILIACION:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCLBAFILIACION.MEM",V_nPeriodo:=oCLBAFILIACION:nPeriodo
  LOCAL V_dDesde:=oCLBAFILIACION:dDesde
  LOCAL V_dHasta:=oCLBAFILIACION:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCLBAFILIACION)
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


    IF Type("oCLBAFILIACION")="O" .AND. oCLBAFILIACION:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCLBAFILIACION:cWhere_),oCLBAFILIACION:cWhere_,oCLBAFILIACION:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCLBAFILIACION:LEERDATA(oCLBAFILIACION:cWhere_,oCLBAFILIACION:oBrw,oCLBAFILIACION:cServer)
      oCLBAFILIACION:oWnd:Show()
      oCLBAFILIACION:oWnd:Restore()

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

   oCLBAFILIACION:aHead:=EJECUTAR("HTMLHEAD",oCLBAFILIACION)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCLBAFILIACION)
RETURN .T.

FUNCTION VERDETALLES()
  LOCAL aLine:=oCLBAFILIACION:oBrw:aArrayData[oCLBAFILIACION:oBrw:nArrayAt]
  LOCAL cCodInv:=aLine[1]

  EJECUTAR("BRCSCLIRESCUO",NIL,NIL,NIL,NIL,NIL,NIL,"",NIL,cCodInv)

  //PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCli,lCodInv,cCodInv,dFecha,nValCam,oFrmMain)

RETURN .T.

FUNCTION VERCLIENTES()
RETURN .T.

FUNCTION VERDETALLES_OLD(lRun)
  LOCAL cWhere:="",cCodSuc,nPeriodo,dDesde,dHasta,cTitle
  LOCAL aLine:=oCLBAFILIACION:oBrw:aArrayData[oCLBAFILIACION:oBrw:nArrayAt]
  LOCAL cCodInv:=aLine[1]

  cWhere:="DPG_CODINV"+GetWhere("=",cCodInv)

  IF !Empty(oCLBAFILIACION:cCodCli)
     cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+" DPG_CODIGO"+GetWhere("=",oCLBAFILIACION:cCodCli)
  ENDIF

  EJECUTAR("BRCLBAFILIADET",cWhere,cCodSuc,nPeriodo,oCLBAFILIACION:dDesde,oCLBAFILIACION:dHasta,cTitle,cCodInv,oCLBAFILIACION:cCodCli,lRun)

RETURN .T.

// EOF

