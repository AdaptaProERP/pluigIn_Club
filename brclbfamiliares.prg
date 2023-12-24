// Programa   : BRCLBFAMILIARES
// Fecha/Hora : 26/08/2022 07:13:17
// Propósito  : "Familiares de los Socios"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRCLBFAMILIARES.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oCLBFAMILIARES")="O" .AND. oCLBFAMILIARES:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCLBFAMILIARES,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Familiares de los Socios" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oCLBFAMILIARES

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oCLBFAMILIARES","BRCLBFAMILIARES.EDT")
// oCLBFAMILIARES:CreateWindow(0,0,100,550)
   oCLBFAMILIARES:Windows(0,0,aCoors[3]-160,MIN(1900,aCoors[4]-10),.T.) // Maximizado



   oCLBFAMILIARES:cCodSuc  :=cCodSuc
   oCLBFAMILIARES:lMsgBar  :=.F.
   oCLBFAMILIARES:cPeriodo :=aPeriodos[nPeriodo]
   oCLBFAMILIARES:cCodSuc  :=cCodSuc
   oCLBFAMILIARES:nPeriodo :=nPeriodo
   oCLBFAMILIARES:cNombre  :=""
   oCLBFAMILIARES:dDesde   :=dDesde
   oCLBFAMILIARES:cServer  :=cServer
   oCLBFAMILIARES:dHasta   :=dHasta
   oCLBFAMILIARES:cWhere   :=cWhere
   oCLBFAMILIARES:cWhere_  :=cWhere_
   oCLBFAMILIARES:cWhereQry:=""
   oCLBFAMILIARES:cSql     :=oDp:cSql
   oCLBFAMILIARES:oWhere   :=TWHERE():New(oCLBFAMILIARES)
   oCLBFAMILIARES:cCodPar  :=cCodPar // Código del Parámetro
   oCLBFAMILIARES:lWhen    :=.T.
   oCLBFAMILIARES:cTextTit :="" // Texto del Titulo Heredado
   oCLBFAMILIARES:oDb      :=oDp:oDb
   oCLBFAMILIARES:cBrwCod  :="CLBFAMILIARES"
   oCLBFAMILIARES:lTmdi    :=.T.
   oCLBFAMILIARES:aHead    :={}
   oCLBFAMILIARES:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCLBFAMILIARES:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCLBFAMILIARES)}

   oCLBFAMILIARES:lBtnRun     :=.F.
   oCLBFAMILIARES:lBtnMenuBrw :=.F.
   oCLBFAMILIARES:lBtnSave    :=.F.
   oCLBFAMILIARES:lBtnCrystal :=.F.
   oCLBFAMILIARES:lBtnRefresh :=.F.
   oCLBFAMILIARES:lBtnHtml    :=.T.
   oCLBFAMILIARES:lBtnExcel   :=.T.
   oCLBFAMILIARES:lBtnPreview :=.T.
   oCLBFAMILIARES:lBtnQuery   :=.F.
   oCLBFAMILIARES:lBtnOptions :=.T.
   oCLBFAMILIARES:lBtnPageDown:=.T.
   oCLBFAMILIARES:lBtnPageUp  :=.T.
   oCLBFAMILIARES:lBtnFilters :=.T.
   oCLBFAMILIARES:lBtnFind    :=.T.
   oCLBFAMILIARES:lBtnColor   :=.T.

   oCLBFAMILIARES:nClrPane1:=16775408
   oCLBFAMILIARES:nClrPane2:=16771797

   oCLBFAMILIARES:nClrText :=0
   oCLBFAMILIARES:nClrText1:=0
   oCLBFAMILIARES:nClrText2:=0
   oCLBFAMILIARES:nClrText3:=0




   oCLBFAMILIARES:oBrw:=TXBrowse():New( IF(oCLBFAMILIARES:lTmdi,oCLBFAMILIARES:oWnd,oCLBFAMILIARES:oDlg ))
   oCLBFAMILIARES:oBrw:SetArray( aData, .F. )
   oCLBFAMILIARES:oBrw:SetFont(oFont)

   oCLBFAMILIARES:oBrw:lFooter     := .T.
   oCLBFAMILIARES:oBrw:lHScroll    := .T.
   oCLBFAMILIARES:oBrw:nHeaderLines:= 2
   oCLBFAMILIARES:oBrw:nDataLines  := 1
   oCLBFAMILIARES:oBrw:nFooterLines:= 1




   oCLBFAMILIARES:aData            :=ACLONE(aData)

   AEVAL(oCLBFAMILIARES:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: CRC_NOMBRE
  oCol:=oCLBFAMILIARES:oBrw:aCols[1]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

  // Campo: CRC_ID
  oCol:=oCLBFAMILIARES:oBrw:aCols[2]
  oCol:cHeader      :='Carnet'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 96

  // Campo: CRC_CODIGO
  oCol:=oCLBFAMILIARES:oBrw:aCols[3]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: CRC_ESTADO
  oCol:=oCLBFAMILIARES:oBrw:aCols[4]
  oCol:cHeader      :='Estado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 56
oCol:bClrStd  := {|nClrText,uValue|uValue:=oCLBFAMILIARES:oBrw:aArrayData[oCLBFAMILIARES:oBrw:nArrayAt,4],;
                     nClrText:=COLOR_OPTIONS("DPCLIENTESREC ","CRC_ESTADO",uValue),;
                     {nClrText,iif( oCLBFAMILIARES:oBrw:nArrayAt%2=0, oCLBFAMILIARES:nClrPane1, oCLBFAMILIARES:nClrPane2 ) } } 

  // Campo: CRC_SEXO
  oCol:=oCLBFAMILIARES:oBrw:aCols[5]
  oCol:cHeader      :='Sexo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
oCol:bClrStd  := {|nClrText,uValue|uValue:=oCLBFAMILIARES:oBrw:aArrayData[oCLBFAMILIARES:oBrw:nArrayAt,5],;
                     nClrText:=COLOR_OPTIONS("DPCLIENTESREC ","CRC_SEXO",uValue),;
                     {nClrText,iif( oCLBFAMILIARES:oBrw:nArrayAt%2=0, oCLBFAMILIARES:nClrPane1, oCLBFAMILIARES:nClrPane2 ) } } 

  // Campo: CRC_PARENT
  oCol:=oCLBFAMILIARES:oBrw:aCols[6]
  oCol:cHeader      :='Parentesco'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 48
oCol:bClrStd  := {|nClrText,uValue|uValue:=oCLBFAMILIARES:oBrw:aArrayData[oCLBFAMILIARES:oBrw:nArrayAt,6],;
                     nClrText:=COLOR_OPTIONS("DPCLIENTESREC ","CRC_PARENT",uValue),;
                     {nClrText,iif( oCLBFAMILIARES:oBrw:nArrayAt%2=0, oCLBFAMILIARES:nClrPane1, oCLBFAMILIARES:nClrPane2 ) } } 

  // Campo: CRC_OBS1
  oCol:=oCLBFAMILIARES:oBrw:aCols[7]
  oCol:cHeader      :='Profesión'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

  // Campo: CRC_FECHA
  oCol:=oCLBFAMILIARES:oBrw:aCols[8]
  oCol:cHeader      :='Fecha'+CRLF+'Nac.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: CRC_EDAD
  oCol:=oCLBFAMILIARES:oBrw:aCols[9]
  oCol:cHeader      :='Edad.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCLBFAMILIARES:oBrw:aArrayData[oCLBFAMILIARES:oBrw:nArrayAt,9],;
                              oCol  := oCLBFAMILIARES:oBrw:aCols[9],;
                              FDP(nMonto,oCol:cEditPicture)}



  // Campo: CRC_FCHINI
  oCol:=oCLBFAMILIARES:oBrw:aCols[10]
  oCol:cHeader      :='Fecha'+CRLF+'Inicio'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: CRC_CODCLI
  oCol:=oCLBFAMILIARES:oBrw:aCols[11]
  oCol:cHeader      :='Código'+CRLF+'Socio'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: CLI_NOMBRE
  oCol:=oCLBFAMILIARES:oBrw:aCols[12]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCLBFAMILIARES:oBrw:aArrayData ) } 
  oCol:nWidth       := 480

   oCLBFAMILIARES:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCLBFAMILIARES:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCLBFAMILIARES:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCLBFAMILIARES:nClrText,;
                                                 nClrText:=IF(.F.,oCLBFAMILIARES:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCLBFAMILIARES:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCLBFAMILIARES:nClrPane1, oCLBFAMILIARES:nClrPane2 ) } }

//   oCLBFAMILIARES:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oCLBFAMILIARES:oBrw:bClrFooter            := {|| {0,14671839 }}

   oCLBFAMILIARES:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCLBFAMILIARES:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCLBFAMILIARES:oBrw:bLDblClick:={|oBrw|oCLBFAMILIARES:RUNCLICK() }

   oCLBFAMILIARES:oBrw:bChange:={||oCLBFAMILIARES:BRWCHANGE()}
   oCLBFAMILIARES:oBrw:CreateFromCode()


   oCLBFAMILIARES:oWnd:oClient := oCLBFAMILIARES:oBrw



   oCLBFAMILIARES:Activate({||oCLBFAMILIARES:ViewDatBar()})

   oCLBFAMILIARES:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCLBFAMILIARES:lTmdi,oCLBFAMILIARES:oWnd,oCLBFAMILIARES:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCLBFAMILIARES:oBrw:nWidth()

   oCLBFAMILIARES:oBrw:GoBottom(.T.)
   oCLBFAMILIARES:oBrw:Refresh(.T.)

   IF !File("FORMS\BRCLBFAMILIARES.EDT")
     oCLBFAMILIARES:oBrw:Move(44,0,1900+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oCLBFAMILIARES:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oCLBFAMILIARES:oBrw,oCLBFAMILIARES:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oCLBFAMILIARES:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CLBFAMILIARES")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CLBFAMILIARES"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCLBFAMILIARES:oBrw,"CLBFAMILIARES",oCLBFAMILIARES:cSql,oCLBFAMILIARES:nPeriodo,oCLBFAMILIARES:dDesde,oCLBFAMILIARES:dHasta,oCLBFAMILIARES)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCLBFAMILIARES:oBtnRun:=oBtn



       oCLBFAMILIARES:oBrw:bLDblClick:={||EVAL(oCLBFAMILIARES:oBtnRun:bAction) }


   ENDIF




IF oCLBFAMILIARES:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCLBFAMILIARES");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oCLBFAMILIARES:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCLBFAMILIARES:lBtnColor

     oCLBFAMILIARES:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCLBFAMILIARES:oBrw,oCLBFAMILIARES,oCLBFAMILIARES:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCLBFAMILIARES,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCLBFAMILIARES,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCLBFAMILIARES:oBtnColor:=oBtn

ENDIF



IF oCLBFAMILIARES:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oCLBFAMILIARES:oBrw,oCLBFAMILIARES:oFrm)
ENDIF

IF oCLBFAMILIARES:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCLBFAMILIARES),;
                  EJECUTAR("DPBRWMENURUN",oCLBFAMILIARES,oCLBFAMILIARES:oBrw,oCLBFAMILIARES:cBrwCod,oCLBFAMILIARES:cTitle,oCLBFAMILIARES:aHead));
          WHEN !Empty(oCLBFAMILIARES:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCLBFAMILIARES:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oCLBFAMILIARES:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCLBFAMILIARES:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oCLBFAMILIARES:oBrw,oCLBFAMILIARES);
          ACTION EJECUTAR("BRWSETFILTER",oCLBFAMILIARES:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCLBFAMILIARES:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oCLBFAMILIARES:oBrw);
          WHEN LEN(oCLBFAMILIARES:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCLBFAMILIARES:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oCLBFAMILIARES:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCLBFAMILIARES:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oCLBFAMILIARES)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCLBFAMILIARES:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oCLBFAMILIARES:oBrw,oCLBFAMILIARES:cTitle,oCLBFAMILIARES:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCLBFAMILIARES:oBtnXls:=oBtn

ENDIF

IF oCLBFAMILIARES:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oCLBFAMILIARES:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCLBFAMILIARES:oBrw,NIL,oCLBFAMILIARES:cTitle,oCLBFAMILIARES:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCLBFAMILIARES:oBtnHtml:=oBtn

ENDIF


IF oCLBFAMILIARES:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oCLBFAMILIARES:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCLBFAMILIARES:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCLBFAMILIARES")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oCLBFAMILIARES:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCLBFAMILIARES:oBtnPrint:=oBtn

   ENDIF

IF oCLBFAMILIARES:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oCLBFAMILIARES:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCLBFAMILIARES:oBrw:GoTop(),oCLBFAMILIARES:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCLBFAMILIARES:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oCLBFAMILIARES:oBrw:PageDown(),oCLBFAMILIARES:oBrw:Setfocus())
  ENDIF

  IF  oCLBFAMILIARES:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oCLBFAMILIARES:oBrw:PageUp(),oCLBFAMILIARES:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCLBFAMILIARES:oBrw:GoBottom(),oCLBFAMILIARES:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCLBFAMILIARES:Close()

  oCLBFAMILIARES:oBrw:SetColor(0,oCLBFAMILIARES:nClrPane1)

  oCLBFAMILIARES:SETBTNBAR(40,40,oBar)


  EVAL(oCLBFAMILIARES:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCLBFAMILIARES:oBar:=oBar

    nCol:=1540
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oCLBFAMILIARES:oPeriodo  VAR oCLBFAMILIARES:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oCLBFAMILIARES:LEEFECHAS();
                WHEN oCLBFAMILIARES:lWhen


  ComboIni(oCLBFAMILIARES:oPeriodo )

  @ nLin, nCol+103 BUTTON oCLBFAMILIARES:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCLBFAMILIARES:oPeriodo:nAt,oCLBFAMILIARES:oDesde,oCLBFAMILIARES:oHasta,-1),;
                         EVAL(oCLBFAMILIARES:oBtn:bAction));
                WHEN oCLBFAMILIARES:lWhen


  @ nLin, nCol+130 BUTTON oCLBFAMILIARES:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oCLBFAMILIARES:oPeriodo:nAt,oCLBFAMILIARES:oDesde,oCLBFAMILIARES:oHasta,+1),;
                         EVAL(oCLBFAMILIARES:oBtn:bAction));
                WHEN oCLBFAMILIARES:lWhen


  @ nLin, nCol+160 BMPGET oCLBFAMILIARES:oDesde  VAR oCLBFAMILIARES:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCLBFAMILIARES:oDesde ,oCLBFAMILIARES:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oCLBFAMILIARES:oPeriodo:nAt=LEN(oCLBFAMILIARES:oPeriodo:aItems) .AND. oCLBFAMILIARES:lWhen ;
                FONT oFont

   oCLBFAMILIARES:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oCLBFAMILIARES:oHasta  VAR oCLBFAMILIARES:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oCLBFAMILIARES:oHasta,oCLBFAMILIARES:dHasta);
                SIZE 76-2,24;
                WHEN oCLBFAMILIARES:oPeriodo:nAt=LEN(oCLBFAMILIARES:oPeriodo:aItems) .AND. oCLBFAMILIARES:lWhen ;
                OF oBar;
                FONT oFont

   oCLBFAMILIARES:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oCLBFAMILIARES:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oCLBFAMILIARES:oPeriodo:nAt=LEN(oCLBFAMILIARES:oPeriodo:aItems);
               ACTION oCLBFAMILIARES:HACERWHERE(oCLBFAMILIARES:dDesde,oCLBFAMILIARES:dHasta,oCLBFAMILIARES:cWhere,.T.);
               WHEN oCLBFAMILIARES:lWhen

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

  oRep:=REPORTE("BRCLBFAMILIARES",cWhere)
  oRep:cSql  :=oCLBFAMILIARES:cSql
  oRep:cTitle:=oCLBFAMILIARES:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCLBFAMILIARES:oPeriodo:nAt,cWhere

  oCLBFAMILIARES:nPeriodo:=nPeriodo


  IF oCLBFAMILIARES:oPeriodo:nAt=LEN(oCLBFAMILIARES:oPeriodo:aItems)

     oCLBFAMILIARES:oDesde:ForWhen(.T.)
     oCLBFAMILIARES:oHasta:ForWhen(.T.)
     oCLBFAMILIARES:oBtn  :ForWhen(.T.)

     DPFOCUS(oCLBFAMILIARES:oDesde)

  ELSE

     oCLBFAMILIARES:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCLBFAMILIARES:oDesde:VarPut(oCLBFAMILIARES:aFechas[1] , .T. )
     oCLBFAMILIARES:oHasta:VarPut(oCLBFAMILIARES:aFechas[2] , .T. )

     oCLBFAMILIARES:dDesde:=oCLBFAMILIARES:aFechas[1]
     oCLBFAMILIARES:dHasta:=oCLBFAMILIARES:aFechas[2]

     cWhere:=oCLBFAMILIARES:HACERWHERE(oCLBFAMILIARES:dDesde,oCLBFAMILIARES:dHasta,oCLBFAMILIARES:cWhere,.T.)

     oCLBFAMILIARES:LEERDATA(cWhere,oCLBFAMILIARES:oBrw,oCLBFAMILIARES:cServer,oCLBFAMILIARES)

  ENDIF

  oCLBFAMILIARES:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPCLIENTES.CLI_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPCLIENTES.CLI_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPCLIENTES.CLI_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCLBFAMILIARES:cWhereQry)
       cWhere:=cWhere + oCLBFAMILIARES:cWhereQry
     ENDIF

     oCLBFAMILIARES:LEERDATA(cWhere,oCLBFAMILIARES:oBrw,oCLBFAMILIARES:cServer,oCLBFAMILIARES)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCLBFAMILIARES)
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
          " CRC_NOMBRE,"+;
          " CRC_ID,"+;
          " CRC_CODIGO,"+;
          " CRC_ESTADO,"+;
          " CRC_SEXO,"+;
          " CRC_PARENT,"+;
          " CRC_PROFES,"+;
          " CRC_FECHA,"+;
          " TIMESTAMPDIFF(MONTH,CRC_FECHA,NOW())/12 AS CRC_EDAD,"+;
          " CRC_FCHINI,"+;
          " CRC_CODCLI,"+;
          " CLI_NOMBRE"+;
          " FROM DPCLIENTESREC"+;
          " LEFT JOIN DPCLIENTES ON CRC_CODCLI=CLI_CODIGO"+;
          " ORDER BY CRC_NOMBRE"+;
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

   DPWRITE("TEMP\BRCLBFAMILIARES.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','','','',CTOD(""),0,CTOD(""),'',''})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,4]:=SAYOPTIONS("DPCLIENTESREC","CRC_ESTADO",a[4]),;
          aData[n,5]:=SAYOPTIONS("DPCLIENTESREC","CRC_SEXO",a[5]),;
          aData[n,6]:=SAYOPTIONS("DPCLIENTESREC","CRC_PARENT",a[6])})

   IF ValType(oBrw)="O"

      oCLBFAMILIARES:cSql   :=cSql
      oCLBFAMILIARES:cWhere_:=cWhere

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
      AEVAL(oCLBFAMILIARES:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCLBFAMILIARES:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCLBFAMILIARES.MEM",V_nPeriodo:=oCLBFAMILIARES:nPeriodo
  LOCAL V_dDesde:=oCLBFAMILIARES:dDesde
  LOCAL V_dHasta:=oCLBFAMILIARES:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCLBFAMILIARES)
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


    IF Type("oCLBFAMILIARES")="O" .AND. oCLBFAMILIARES:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCLBFAMILIARES:cWhere_),oCLBFAMILIARES:cWhere_,oCLBFAMILIARES:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCLBFAMILIARES:LEERDATA(oCLBFAMILIARES:cWhere_,oCLBFAMILIARES:oBrw,oCLBFAMILIARES:cServer)
      oCLBFAMILIARES:oWnd:Show()
      oCLBFAMILIARES:oWnd:Restore()

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

   oCLBFAMILIARES:aHead:=EJECUTAR("HTMLHEAD",oCLBFAMILIARES)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCLBFAMILIARES)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

