// Programa   : CLBVISITANTE
// Fecha/Hora : 27/06/2020 03:43:55
// Propósito  : Registro de Visitante
// Creado Por : Juan Navas
// Llamado por: PlugIn (Club,GYM,EVENTOS, ACADEMICO) y Afines
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oFrmNm,cFileJpg,cDescri,cField)
  LOCAL oFont,oFontB,aData,cSql,oCol
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )
  LOCAL cTitle:="Registro de Visitante"
  LOCAL oMenu,lClick:=.T.
  LOCAL nStyle:=NIL,oDb


  cSql:=" SELECT MOV_ITEM,MOV_HORA,MOV_CODCTA,CLI_NOMBRE,MOV_ASODOC,MOV_TIPCAR,CRC_NOMBRE "+;
        " FROM DPMOVINV_REGP "+;
        " INNER JOIN DPCLIENTES    ON MOV_CODCTA=CLI_CODIGO "+;
        " LEFT  JOIN DPCLIENTESREC ON MOV_CODCTA=CRC_CODCLI AND MOV_TIPCAR=CRC_ID "+;
        " WHERE MOV_CODSUC"+GetWhere("=",oDp:cSucursal)+;
        "   AND MOV_FECHA "+GetWhere("=",oDp:dFecha   )+;
        " GROUP BY MOV_ITEM "+;
        " ORDER BY MOV_ITEM "

  aData:=ASQL(cSql)

  IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
  ENDIF

// ViewArray(aData)

  DEFAULT cDescri:=" Control de Ingreso "

  DEFAULT cFileJpg:=PADR("FOTOS\FILE"+STRTRAN(TIME(),":","")+".bmp",250)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//  DPEDIT():New(cTitle,"forms\CBLVISITANTE.EDT","oWebCam",.T.)
  DpMdi(cTitle,"oWebCam","CBLVISITANTE.EDT")
  oWebCam:Windows(0,0,aCoors[3]-170,MIN(1748,aCoors[4]-20),.T.) // Maximizado

  oWebCam:oWC      :=tWebCamPhoto():New() 
  oWebCam:lClick   := .F.
  oWebCam:cFileOrg :=cFileOrg
  oWebCam:cFileJpg :=cFileJpg
  oWebCam:cFileInv :="" // Invitado
  oWebCam:cDescri  :=cDescri
  oWebCam:oFrmNm   :=oFrmNm
  oWebCam:nQuien   :=1 // Ingresa el Socio
  oWebCam:lBarDef  :=.T.
  oWebCam:cNomCLi  :=SPACE(120)
  oWebCam:cCodCli  :=SPACE(10)
  oWebCam:nCuotas  :=0
  oWebCam:nCxCDiv  :=0
  oWebCam:nCxCBs   :=0
  oWebCam:oGrupo   :=NIL
  oWebCam:oInvitado:=NIL
  oWebCam:oFchNac  :=NIL
  oWebCam:oSexo    :=NIL
  oWebCam:oParent  :=NIL
  oWebCam:oMovInv  :=INSERTINTO("DPMOVINV_REGP") 
  oWebCam:oMovInv:lFileLog:=.T.

  oWebCam:oVisita  :=INSERTINTO("DPCLIENTESREC") 
  oWebCam:oVisita:lFileLog:=.T.
    

  oWebCam:lFindCLi :=.F.
  oWebCam:lFindInv :=.F. // Si no encuentra el Invitado solicita los datos
  oWebCam:aParent  :=GETOPTIONS("DPCLIENTESREC","CRC_PARENT",.T.)

//  IF Empty(oWebCam:aParent)
     AADD(oWebCam:aParent,"Ninguno")
//  ENDIF

  oWebCam:cCedula  :=SPACE(011) // Cédula del Invitado
  oWebCam:cInvitado:=SPACE(120) // Cédula del Invitado
  oWebCam:dFchNac  :=CTOD("")
  oWebCam:cSexo    :="Femenino"
  oWebCam:cParent  :="Parentesco"
  oWebCam:cRelacion:=oWebCam:aParent[1]
  oWebCam:oRelacion:=NIL


  oWebCam:nClrText:=0
  oWebCam:nClrPane1:=oDp:nClrPane1
  oWebCam:nClrPane2:=oDp:nClrPane2

  oWebCam:oBrw:=TXBrowse():New( oWebCam:oWnd)

  oWebCam:oBrw:SetArray( aData, .F. )
  oWebCam:oBrw:SetFont(oFont)

  oWebCam:oBrw:lFooter     := .T.
  oWebCam:oBrw:lHScroll    := .T.
  oWebCam:oBrw:nHeaderLines:= 2
  oWebCam:oBrw:nDataLines  := 1
  oWebCam:oBrw:nFooterLines:= 1

   oWebCam:aData            :=ACLONE(aData)

   AEVAL(oWebCam:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  
  oCol:=oWebCam:oBrw:aCols[1]
  oCol:cHeader      :='CRR'+CRLF+"Día"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oWebCam:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

// Campo: CRC_ID
  oCol:=oWebCam:oBrw:aCols[2]
  oCol:cHeader      :='Hora'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oWebCam:oBrw:aArrayData ) } 
  oCol:nWidth       := 96


  // Campo: CRC_ID
  oCol:=oWebCam:oBrw:aCols[3]
  oCol:cHeader      :='Carnet'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oWebCam:oBrw:aArrayData ) } 
  oCol:nWidth       := 96

  oCol:=oWebCam:oBrw:aCols[4]
  oCol:cHeader      :='Nombre del Socio'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oWebCam:oBrw:aArrayData ) } 
  oCol:nWidth       := 220

  oCol:=oWebCam:oBrw:aCols[5]
  oCol:cHeader      :='Quien'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oWebCam:oBrw:aArrayData ) } 
  oCol:nWidth       := 220

  oCol:=oWebCam:oBrw:aCols[6]
  oCol:cHeader      :='Cédula'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oWebCam:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oWebCam:oBrw:aCols[7]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oWebCam:oBrw:aArrayData ) } 
  oCol:nWidth       := 220

  oWebCam:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oWebCam:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oWebCam:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oWebCam:nClrText,;
                                                 nClrText:=IF(.F.,oWebCam:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oWebCam:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oWebCam:nClrPane1, oWebCam:nClrPane2 ) } }

   oWebCam:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oWebCam:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oWebCam:oBrw:bLDblClick:={|oBrw|oWebCam:RUNCLICK() }

   oWebCam:oBrw:bChange:={||oWebCam:BRWCHANGE()}
   oWebCam:oBrw:CreateFromCode()


   oWebCam:oWnd:oClient := oWebCam:oBrw


  oWebCam:Activate({||oWebCam:VIEWBAR()},NIL,NIL,.T.)

  BMPGETBTN(oWebCam:oCodCli)
  BMPGETBTN(oWebCam:oCedula)
  BMPGETBTN(oWebCam:oFchNac)
  
  oWebCam:oCedula:ForWhen(.T.)
  oWebCam:oSexo:Refresh(.T.)
  oWebCam:oParent:Refresh(.T.)

RETURN oWebCam

FUNCTION RUNCLICK()
RETURN .T.

FUNCTION BRWCHANGE()
RETURN .T.

// Coloca la Barra de Botones
FUNCTION VIEWBAR()
  LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif,oFontB
  LOCAL nWidth :=0 // Ancho Calculado segœn Columnas
  LOCAL nHeight:=0 // Alto
  LOCAL nLines :=0 // Lineas
  LOCAL oDlg  := oWebCam:oDlg
  LOCAL nStyle:= NIL 

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  DEFINE CURSOR oCursor HAND

  DEFINE BUTTONBAR oBar SIZE 60,60+155+150 OF oDlg 3D CURSOR oCursor

  DEFINE BUTTON oWebCam:oBtnRun OF oBar NOBORDER;
         FONT oFont FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
         TOP PROMPT "Guardar";
         FONT oFontB;
         ACTION oWebCam:VISGUARDAR();
         WHEN oWebCam:lFindCli

  DEFINE BUTTON oWebCam:oBtnRun OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\PHOTO.BMP";
         TOP PROMPT "Foto";
         FONT oFontB;
         ACTION oWebCam:WEBCAMSAVE()

  oWebCam:oBtnRun:cToolTip:="Obtener la Foto"

  DEFINE BUTTON oBtn OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\XSALIR.BMP";
         TOP PROMPT "Salir";
         FONT oFontB;
         ACTION oWebCam:oWc:Disconnect(),;		
                oWebCam:Close()

  oBtn:cToolTip:="Salir y Regresar"

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oWebCam:SETBTNBAR(60,60,oBar)

  oBar:SetColor(CLR_BLACK,oDp:nGris2)
  oBar:Refresh(.T.)

  oWebCam:oWC:CreateWnd(oWebCam:oBar,40,100,70,70,nStyle) // ,30,20,20,40,nStyle,"AQUI")
  oWebCam:oWC:Connect()

  SetWindowPos(oWebCam:oWC:hWnd,1,70,15,140,140)

  @ 70, 180 IMAGE oWebCam:oImg OF oBar SIZE 140,140 PIXEL ADJUST UPDATE

  @ 160, 380 IMAGE oWebCam:oImgVisita OF oBar SIZE 140,140 PIXEL ADJUST UPDATE

  __objAddData( oWebCam:oImg, "nProgress" )
  __objSendMsg( oWebCam:oImg, "nProgress" , 0 )

  oWebCam:oImg:nProgress:=0

  @ .5,50+05 SAY oWebCam:oFileJpg PROMPT oWebCam:cFileJpg SIZE 300,20 OF oBar BORDER COLOR CLR_WHITE,16755027

  @ 2,50+05 SAY oWebCam:oDescri PROMPT oWebCam:cDescri SIZE 300,20 OF oBar BORDER COLOR CLR_WHITE,16755027 CENTER

//  oWebCam:WEBCAMSAVE() 

  @ 5,48 RADIO oWebCam:oQuien VAR oWebCam:nQuien;
         ITEMS "Socio", "Familiar", "Invitado" SIZE 70,15 ;
         ON CHANGE oWebCam:ACTIVARINGRESO();
         WHEN .T. OF oBar 

  @ 6,48 SAY "Código "  OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 7,48 SAY "Nombre "  OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 9,48 SAY "Cuotas "  OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @10,48 SAY "Deuda  "  OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  @ 7,60 BMPGET oWebCam:oCodCli VAR oWebCam:cCodCli;
         VALID oWebCam:VALCODCLI();
         NAME "BITMAPS\FIND.BMP";
         ACTION oWebCam:LBXCLIENTES();
         SIZE 130,21 OF oWebCam:oBar FONT oFontB

  @ oWebCam:oCodCli:nTop(),oWebCam:oCodCli:nRight()+20 SAY oWebCam:oNomCli PROMPT oWebCam:cNomCLi ;
                                                           OF oBar;
                                                           SIZE 150+150,20 PIXEL FONT oFontB BORDER

  oWebCam:oCodCli:bkeyDown:={|nkey| IIF(nKey=13, oWebCam:VALCODCLI(),NIL) }


  @ 09,48 SAY oWebCam:oCuotas  PROMPT " "+TRAN(oWebCam:nCuotas,"999")+" "          OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ 10,48 SAY oWebCam:oCxCDiv     PROMPT ALLTRIM(TRAN(oWebCam:nCxCDiv,"999,999,999.99"))+" " OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  @10,48 SAY "Reservado"                            OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @10,68 SAY oWebCam:oReservado  PROMPT "RESERVADO" OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrYellowText,oDp:nClrYellow   FONT oFont

  @ 20,1 GROUP oWebCam:oGrupo TO 24, 21.5 PROMPT " Vinculo " OF oBar

  @ 15.5,10 SAY "Cédula "     OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 17.5,10 SAY "Nombre "     OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 18.5,10 SAY "Fecha Nac. " OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 18.5,30 SAY "Sexo   "     OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 18.5,70 SAY "Parentesco " OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont
  @ 18.5,70 SAY "Relación   " OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

//  @ 19.5, 17 SAY oWebCam:cRelacion

  @ 19.5,20 SAY oWebCam:oRelacion PROMPT oWebCam:cRelacion OF oBar SIZE 70,20 BORDER RIGHT COLOR oDp:nClrYellowText,oDp:nClrYellow  FONT oFont

  @ 18,17 BMPGET oWebCam:oCedula VAR oWebCam:cCedula;
         VALID oWebCam:VALCEDULA();
         NAME "BITMAPS\FIND.BMP";
         ACTION oWebCam:LBXFAMILIARES();
         WHEN oWebCam:nQuien>1 .AND. oWebCam:lFindCli ;
         SIZE 130,21 OF oWebCam:oBar FONT oFontB UPDATE

  oWebCam:oCedula:bkeyDown:={|nkey| IIF(nKey=13, oWebCam:VALCEDULA(),NIL) }

  @ 19,14 GET oWebCam:oInvitado VAR oWebCam:cInvitado;
          VALID oWebCam:VALINVITADO();
          WHEN oWebCam:nQuien=3 .AND. oWebCam:lFindCli;
          SIZE 230,21 OF oWebCam:oBar FONT oFontB UPDATE

  @ 19,14 BMPGET oWebCam:oFchNac  VAR oWebCam:dFchNac;
          PICTURE oDp:cFormatoFecha;
          NAME "BITMAPS\Calendar.bmp";
          ACTION LbxDate(oWebCam:oFchNac,oWebCam:dFchNac);
          OF oWebCam:oBar SIZE 87,20;
          WHEN oWebCam:nQuien=3 .AND. oWebCam:lFindCli UPDATE

  @ 21,14 COMBOBOX oWebCam:oSexo  VAR oWebCam:cSexo ITEMS {"Femenino","Masculino"};
          OF oWebCam:oBar SIZE 87,20;
          WHEN oWebCam:lFindCli .AND. oWebCam:nQuien=3 UPDATE 

  @ 22,14 COMBOBOX oWebCam:oParent VAR oWebCam:cParent ITEMS oWebCam:aParent;
          OF oWebCam:oBar SIZE 87,20;
          WHEN oWebCam:lFindCli .AND. oWebCam:nQuien=3 UPDATE

RETURN .T.

FUNCTION CAMPUTFOTO(oImage1)

    IF file(oWebCam:cFileJpg)
        oImage1:LoadBmp( oWebCam:cFileJpg )
    ENDIF

RETURN (.T.)

FUNCTION CAMCANCEL(lClick)
    LOCAL lReturn := .F.
RETURN (lReturn)

FUNCTION WEBCAMSAVE()

  IF oWebCam:nQuien=1
    oWebCam:oWC:Save(oWebCam:oImg,ALLTRIM(oWebCam:cFileJpg),80)
  ELSE
    oWebCam:oWC:Save(oWebCam:oImgVisita,ALLTRIM(oWebCam:cFileInv),80)
  ENDIF

  oWebCam:lClick := .T.

  oWebCam:oWnd:Update()

RETURN .T.

FUNCTION ONCLOSE()
  
 oWebCam:oWc:Disconnect()
 oWebCam:oWC:End()

 oWebCam:oMovInv:End()
 oWebCam:oVisita:End()

RETURN .T.

FUNCTION ACTIVARINGRESO()
  LOCAL aLine:={"Ninguno","Familiar","Invitado"}
  LOCAL cText:=aLine[oWebCam:nQuien]

  IF ValType(oWebCam:oGrupo)="O"
     oWebCam:oGrupo:SetText(" "+cText+" ")
  ENDIF

  IF ValType(oWebCam:oRelacion)="O"
    oWebCam:cRelacion:=cText
    oWebCam:oRelacion:Refresh(.T.)
  ENDIF

  IF ValType(oWebCam:oSexo)="O"
    oWebCam:oInvitado:ForWhen(.T.)
    oWebCam:oFchNac:ForWhen(.T.)
    oWebCam:oSexo:ForWhen(.T.)
    oWebCam:oParent:ForWhen(.T.)
  ENDIF

  IF oWebCam:nQuien=3
     oWebCam:cFileInv:="FOTOS\INVITADO_"+ALLTRIM(oWebCam:cCedula)+".BMP"
  ELSE
     oWebCam:cFileInv:="FOTOS\FAMILIAR_"+ALLTRIM(oWebCam:cCedula)+".BMP"
  ENDIF

RETURN .T.

FUNCTION LBXCLIENTES()
  LOCAL oDpLbx

  oDpLbx:=DpLbx("DPCLIENTES",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oWebCam:oCodCli)
  oDpLbx:GetValue("CLI_CODIGO",oWebCam:oCodCli)

RETURN .T.


FUNCTION VALCODCLI()
  LOCAL lOk,cWhere
  LOCAL cNombre  :=SQLGET("DPCLIENTES","CLI_NOMBRE,CLI_FILBMP","CLI_CODIGO"+GetWhere("=",oWebCam:cCodCli))
  LOCAL cFileBmp :=DPSQLROW(2)
  LOCAL nCant    :=0,cCodigo,nCxC,nCxCBs,nCuotas
  LOCAL cWhereCli:="CLI_CODIGO LIKE "+GetWhere("","%"+ALLTRIM(oWebCam:cCodCli)+"%")+" OR "+;
                   "CLI_RIF LIKE "+GetWhere("","%"+ALLTRIM(oWebCam:cCodCli)+"%")
  
//? "AQUI VALCODCLI",cWhereCli

  oWebCam:cNomCli:=cNombre

  IF Empty(cNombre)

     cWhereCli:=cWhereCli+" OR "+EJECUTAR("GETWHERELIKE","DPCLIENTES","CLI_NOMBRE",oWebCam:cCodCli,"CLI_CODIGO")
     nCant    := COUNT("DPCLIENTES",cWhereCli)
     cCodigo  :=""

     IF nCant=1

         cCodigo:=SQLGET("DPCLIENTES","CLI_CODIGO",cWhereCli)
         oWebCam:oCodCli:VarPut(cCodigo,.T.)
         oWebCam:cCodCli:=cCodigo
         oWebCam:oCodCli:KeyBoard(13)

      ENDIF

      IF Empty(cCodigo) .AND. nCant>1

         cCodigo:=EJECUTAR("REPBDLIST","DPCLIENTES","CLI_CODIGO,CLI_NOMBRE,CLI_RIF",.F.,cWhereCli,NIL,NIL,oWebCam:cCodCli,NIL,NIL,"CLI_CODIGO",oWebCam:oCodCli)

         IF !Empty(cCodigo) .AND. ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",cCodigo))
           oWebCam:oCodCli:VarPut(cCodigo,.T.)
           oWebCam:cCodCli:=cCodigo
           oWebCam:oCodCli:KeyBoard(13)
         ENDIF

      ENDIF

      IF Empty(cCodigo)

         cCodigo:=SQLGET("DPCLIENTESREC","CRC_CODCLI","CRC_ID"    +GetWhere("=",oWebCam:cCodCli)+" OR "+;
                                                      "CRC_CODIGO"+GetWhere("=",oWebCam:cCodCli))

         IF !Empty(cCodigo)

            oWebCam:oCedula:VarPut(oWebCam:cCodCli,.T.)
            oWebCam:oCodCli:VarPut(cCodigo,.T.)
            oWebCam:cCodCli:=cCodigo
            oWebCam:oCodCli:KeyBoard(13)

            oWebCam:oQuien:SetOption(2) // Familiar, Pendiente para Verificar si es Familiar VAR oWebCam:nQuien

            oWebCam:lFindInv:=.T.
            oWebCam:VALCEDULA()

         ENDIF

      ENDIF

  ENDIF

  IF !Empty(cNombre)

     oWebCam:oNomCli:SetText(" "+cNombre,.T.)
     oWebCam:lFindCLi:=.T.

     IF Empty(cFileBmp) .OR. !FILE(cFileBmp)
        cFileBmp:="FOTOS\SOCIO_"+ALLTRIM(oWebCam:cCodCli)+".bmp"
     ENDIF

     oWebCam:cFileJpg:=cFileBmp // FILEBMP del Cliente
     oWebCam:oFileJpg:Refresh(.T.)

     IF FILE(oWebCam:cFileJpg)
       oWebCam:oImg:LoadBmp(oWebCam:cFileJpg)
     ENDIF

     cWhere:="CXD_CODSUC"+GetWhere("=" ,oDp:cSucursal )+" AND "+;
             "CXD_CODIGO"+GetWhere("=",oWebCam:cCodCli)+" AND "+;
             "CXD_FCHMAX"+GetWhere("<=",oDp:dFecha    )

     oWebCam:nCxCDiv:=SQLGET("view_docclicxcdiv","SUM(CXD_CXCDIV) AS CXD_CXCDIV,SUM(CXD_NETO)   AS DOC_NETO,  COUNT(*) AS CUANTOS",cWhere)
     oWebCam:nCuotas:=DPSQLROW(3)

     oWebCam:oCxCDiv:Refresh(.T.)
     oWebCam:oCuotas:Refresh(.T.)

  ELSE

     oWebCam:oNomCli:SetText("Registro no Encontrado",.T.)
     oWebCam:lFindCLi:=.F.
     DPFOCUS(oWebCam:oCodCli)

  ENDIF

  oWebCam:oCedula:ForWhen(.T.)

RETURN .T.

FUNCTION VALCEDULA()
   LOCAL cInvitado:=SQLGET("DPCLIENTESREC","CRC_NOMBRE,CRC_TIPO,CRC_FECHA,CRC_PARENT","CRC_ID"+GetWhere("=",oWebCam:cCedula))

   IF !Empty(cInvitado)

      oWebCam:cRelacion:=DPSQLROW(2)
      oWebCam:oFchNac:VarPut(DPSQLROW(3),.T.)
      oWebCam:oParent:VarPut(DPSQLROW(4),.T.)

      IF Empty(oWebCam:cParent)
         oWebCam:oParent:VarPut("Ninguno",.T.)
      ENDIF

      oWebCam:oInvitado:VarPut(cInvitado,.T.)
      oWebCam:lFindInv:=.T.

      IF oWebCam:nQuien=3
        oWebCam:cFileInv:="FOTOS\INVITADO_"+ALLTRIM(oWebCam:cCedula)+".BMP"
      ELSE
        oWebCam:cFileInv:="FOTOS\FAMILIAR_"+ALLTRIM(oWebCam:cCedula)+".BMP"
      ENDIF

// ? oWebCam:cFileInv,"oWebCam:cFileInv",FILE(oWebCam:cFileInv)

   ELSE

      oWebCam:lFindInv:=.F.

   ENDIF

   oWebCam:oFchNac:ForWhen(.T.)
   oWebCam:oParent:ForWhen(.T.)

RETURN .T.

FUNCTION LBXFAMILIARES()
  LOCAL cWhereCli:="CRC_CODCLI"+GetWhere("=",oWebCam:cCodCli)
  LOCAL cCedula:=EJECUTAR("REPBDLIST","DPCLIENTESREC","CRC_ID,CRC_NOMBRE,CRC_PARENT,CRC_TIPO",.F.,cWhereCli,NIL,NIL,oWebCam:cCedula,NIL,NIL,"CRC_ID",oWebCam:oCedula)

  IF !Empty(cCedula) .AND. ISSQLFIND("DPCLIENTES","CLI_CODIGO"+GetWhere("=",cCedula))
     oWebCam:oCedula:VarPut(cCedula,.T.)
     oWebCam:cCedula:=cCedula
     oWebCam:oCedula:KeyBoard(13)
  ENDIF

RETURN .T.

FUNCTION VALINVITADO()
RETURN .T.

/*
// Guardar Ingreso
*/
FUNCTION VISGUARDAR()
   LOCAL aLine  :={"Socio","Familiar","Invitado"}
   LOCAL cText  :=aLine[oWebCam:nQuien]
   LOCAL cNumero:="",cItem:="",cWhere:=""

   IF !MsgNoYes("Desea Guardar Registro de Visita")
      RETURN .F.
   ENDIF

   oWebCam:oVisita:oTable:SetForeignkeyOff()
   // Visitante
   cWhere:="CRC_CODCLI"+GetWhere("=",oWebCam:cCodCli)+" AND CRC_ID "+GetWhere("=",oWebCam:cCedula)

   IF oWebCam:nQuien=3 .AND. !ISSQLFIND("DPCLIENTESREC",cWhere)
      oWebCam:oVisita:AppendBlank()
      oWebCam:oVisita:Replace("CRC_ID"    ,oWebCam:cCedula  )
      oWebCam:oVisita:Replace("CRC_TIPO"  ,"INVITADO"       )
      oWebCam:oVisita:Replace("CRC_CODIGO",oWebCam:cCedula  )
      oWebCam:oVisita:Replace("CRC_NOMBRE",oWebCam:cInvitado)
      oWebCam:oVisita:Replace("CRC_FECHA" ,oWebCam:dFchNac  )
      oWebCam:oVisita:Replace("CRC_SEXO"  ,oWebCam:cSexo    )
      oWebCam:oVisita:Replace("CRC_PARENT",oWebCam:cParent  )
      oWebCam:oVisita:Replace("CRC_CODCLI",oWebCam:cCodCli  )
      oWebCam:oVisita:Replace("CRC_ACTIVO",.T.              )
      oWebCam:oVisita:Commit()

   ENDIF

   cNumero:=SQLINCREMENTAL("DPMOVINV_REGP","MOV_DOCUME",NIL,NIL,NIL,.T.,6)
   cItem  :=SQLINCREMENTAL("DPMOVINV_REGP","MOV_ITEM"  ,"MOV_FECHA"+GetWhere("=",oDp:dFecha),NIL,NIL,.T.,5)

   oWebCam:oMovInv:AppendBlank()
   oWebCam:oMovInv:Replace("MOV_FECHA"   ,oDp:dFecha     )
   oWebCam:oMovInv:Replace("MOV_HORA"    ,oDp:cHora      )
   oWebCam:oMovInv:Replace("MOV_CODCTA"  ,oWebCam:cCodCli)
   oWebCam:oMovInv:Replace("MOV_INVACT"  ,oWebCam:nQuien )
   oWebCam:oMovInv:Replace("MOV_TIPCAR"  ,oWebCam:cCedula)
   oWebCam:oMovInv:Replace("MOV_ASODOC"  ,cText          )
   oWebCam:oMovInv:Replace("MOV_DOCUME"  ,cNumero        )
   oWebCam:oMovInv:Replace("MOV_ITEM"    ,cItem          )
   oWebCam:oMovInv:Commit()

   oWebCam:oVisita:oTable:SetForeignkeyOn()
   
   aLine  :=ACLONE(oWebCam:oBrw:aArrayData[1])
   AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(a)})

   aLine[1]:=cItem
   aLine[2]:=oDp:cHora 
   aLine[3]:=oWebCam:cCodCli
   aLine[4]:=oWebCam:cNomCli
   aLine[5]:=cText
   aLine[6]:=oWebCam:cCedula
   aLine[7]:=oWebCam:cInvitado

   IF LEN(oWebCam:oBrw:aArrayData)=1 .AND. Empty(oWebCam:oBrw:aArrayData[1,1])
     oWebCam:oBrw:aArrayData[1]:=ACLONE(aLine)
   ELSE
     AADD(oWebCam:oBrw:aArrayData,ACLONE(aLine))
   ENDIF

   oWebCam:oBrw:GoBottom()
   oWebCam:oBrw:Refresh(.F.)

RETURN .T.
