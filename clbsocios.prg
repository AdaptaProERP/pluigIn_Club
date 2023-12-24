// Programa   : CLBSOCIOS
// Fecha/Hora : 20/09/2021 23:10:42
// Propósito  : Registro de Socios
// Creado Por : Juan Navas
// Llamado por: PlugIn CLUB SOCIAL
// Aplicación : PlugIn CLUB SOCIAL
// Tabla      : DPCLIENTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(nOption,cCodCli)
  LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,oFontB,cScope,oFont,oFontG
  LOCAL cTitle :="Registro de Socios",cExcluye:="",cSql,oTable
  LOCAL cWhereMov:=""
  LOCAL aCoors   :=GetCoors( GetDesktopWindow() )
  LOCAL cCenCos  :=oDp:cCenCos
  LOCAL aSexo    :=GETOPTIONS("DPCLIENTESREC","CRC_SEXO"  ,.T.)
  LOCAL aParent  :=GETOPTIONS("DPCLIENTESREC","CRC_PARENT",.T.)
  LOCAL aEstado  :=GETOPTIONS("DPCLIENTESREC","CRC_ESTADO",.T.)
  LOCAL aCatego  :=GETOPTIONS("DPCLIENTES"   ,"CLI_CATEGO",.T.)

  ADEPURA(aCatego,{|a,n| !"Soci"$a})


  IF Empty(aEstado)
     aEstado:={}
     AADD(aEstado,"Activo")
  ENDIF

  DEFAULT nOption:=0

  cWhereMov:=IIF(Empty(cCodCli),"","CRC_CODCLI"+GetWhere("=",cCodCli))

  cScope:=GetWhereOr("CLI_CATEGO",aCatego)


  oDp:nClrDebe :=CLR_BLUE
  oDp:nClrHaber:=CLR_HRED

  // Font Para el Browse
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -14
  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14

  oCLBSOCIOS:=DOCENC(cTitle,"oCLBSOCIOS","CLBSOCIOS.EDT")
  oCLBSOCIOS:cList:="CLBSOCIOS.BRW"

  oCLBSOCIOS:lBar:=.T.
  oCLBSOCIOS:nBtnStyle:=1
  oCLBSOCIOS:SetScope(cScope)
  oCLBSOCIOS:SetTable("DPCLIENTES","CLI_CODIGO") // ,cScope)
  oCLBSOCIOS:lFind:=.T.
  oCLBSOCIOS:dOldFecha :=CTOD("")
  oCLBSOCIOS:cOldCodCli:=""
  oCLBSOCIOS:cView     :="VERCLGREPRES"
  oCLBSOCIOS:cCenCos   :=cCenCos
  oCLBSOCIOS:nTotal    :=0
  oCLBSOCIOS:cCodInv   :=SPACE(20)
  oCLBSOCIOS:oCodInv   :=NIL
  oCLBSOCIOS:oSayInv   :=NIL
  oCLBSOCIOS:cFileBrw  :="FORMS\CLBSOCIOS.BRW"


  oCLBSOCIOS:cPrimary:="CLI_CODIGO"
  oCLBSOCIOS:SetIncremental("CLI_CODIGO",cScope)
  oCLBSOCIOS:cPreSave :="PRESAVE"
  oCLBSOCIOS:cPostSave:="POSTGRABAR"

  oCLBSOCIOS:lAutoSize  :=(aCoors[4]>1200)  

  aCoors[4]:=MIN(aCoors[4],1920)
  // oCLBSOCIOS:Windows(0,0,aCoors[3]-180,aCoors[4]-20) 
  // oCLBSOCIOS:Windows(0,0,aCoors[3]-180+25,aCoors[4]-20) 

  IF aCoors[3]<=800
    oCLBSOCIOS:Windows(0,0,aCoors[3]-190,aCoors[4]-20) 
  ELSE
    oCLBSOCIOS:Windows(0,0,aCoors[3]-180+25,aCoors[4]-20) 
  ENDIF



  oCLBSOCIOS:AddBtn("MENUTRANSACCIONES.BMP","Menú de Transacciones","(oCLBSOCIOS:nOption=0)",;
                             "EJECUTAR('DPCLIENTESMNUTRAN',oCLBSOCIOS:CLI_CODIGO)","MOV")

  oCLBSOCIOS:AddBtn("XPERSONAL.BMP","Personal del Cliente","(oCLBSOCIOS:nOption=0)",;
                    [EJECUTAR("DPCLIENTESPER",oCLBSOCIOS:CLI_CODIGO)])

  oCLBSOCIOS:AddBtn("IMPORTAR.BMP","Inscripción","(oCLBSOCIOS:nOption=0)",;
                    [ EJECUTAR("CLGINSCRIPCIONES","CRC_CODCLI"+GetWhere("=",oCLBSOCIOS:CLI_CODIGO),NIL,NIL,NIL,NIL,NIL,oCLBSOCIOS:CLI_CODIGO)])

  @ 1.35, 0 FOLDER oCLBSOCIOS:oFolder ITEMS "Representante","Datos Adicionales";
                OF oCLBSOCIOS:oDlg SIZE 390,61

  SETFOLDER( 1)
 
  @ 1,1 SAY "Código:"    RIGHT
  @ 2,1 SAY "RIF:"       RIGHT
  @ 3,1 SAY "Nombre:"    RIGHT
  @ 4,1 SAY "Acciones:"  RIGHT
  @ 3,50 SAY "Dirección:" RIGHT
  @ 4,50 SAY "Teléfono:" RIGHT


  @ 1,10 GET oCLBSOCIOS:oCLI_CODIGO VAR oCLBSOCIOS:CLI_CODIGO;
         VALID CERO(oCLBSOCIOS:CLI_CODIGO);
         WHEN (AccessField("DPCLIENTES","CLI_CODIGO",oCLBSOCIOS:nOption);
              .AND. oCLBSOCIOS:nOption!=0);
         SIZE 45,NIL

  @ 2,10 GET oCLBSOCIOS:oCLI_RIF VAR oCLBSOCIOS:CLI_RIF;
        VALID oCLBSOCIOS:VALRIF(oCLBSOCIOS:CLI_RIF);
        WHEN (AccessField("DPCLIENTES","CLI_CODIGO",oCLBSOCIOS:nOption);
              .AND. oCLBSOCIOS:nOption!=0);
        SIZE 45,NIL


 @ 4,30 GET oCLBSOCIOS:oCLI_NOMBRE VAR oCLBSOCIOS:CLI_NOMBRE;
             WHEN (AccessField("DPCLIENTES","CLI_NOMBRE",oCLBSOCIOS:nOption);
                   .AND. oCLBSOCIOS:nOption!=0);
             SIZE NIL,22 PIXEL

  // Campo : CLI_CATEGO   
  // Uso   : Tipo de Socio                         
  //
  @ 6.1, 1.0 COMBOBOX oCLBSOCIOS:oCLI_CATEGO VAR oCLBSOCIOS:CLI_CATEGO     ITEMS aCatego;
                      WHEN (AccessField("DPCLIENTES","CLI_CATEGO",oCLBSOCIOS:nOption);
                     .AND. oCLBSOCIOS:nOption!=0);
                      FONT oFontB

  ComboIni(oCLBSOCIOS:oCLI_CATEGO   )

  oCLBSOCIOS:oCLI_CATEGO:cMsg    :="Tipo de Socio"
  oCLBSOCIOS:oCLI_CATEGO:cToolTip:="Tipo de Socio"

   @ 6,50 GET oCLBSOCIOS:oCLI_TRANSP VAR oCLBSOCIOS:CLI_TRANSP;
             WHEN (AccessField("DPCLIENTES","CLI_TRANSP",oCLBSOCIOS:nOption);
                   .AND. oCLBSOCIOS:nOption!=0);
             SIZE NIL,22 PIXEL RIGHT PICT "9" SPINNER

  oCLBSOCIOS:oCLI_TRANSP:cMsg    :="Cantidad de Acciones"
  oCLBSOCIOS:oCLI_TRANSP:cToolTip:="Cantidad de Acciones"
 
 @ 10,50 GET oCLBSOCIOS:oCLI_DIR1 VAR oCLBSOCIOS:CLI_DIR1;
             WHEN (AccessField("DPCLIENTES","CLI_DIR1",oCLBSOCIOS:nOption);
                   .AND. oCLBSOCIOS:nOption!=0);
             SIZE NIL,22 PIXEL

 @ 11,50 GET oCLBSOCIOS:oCLI_DIR2 VAR oCLBSOCIOS:CLI_DIR2;
             WHEN (AccessField("DPCLIENTES","CLI_DIR2",oCLBSOCIOS:nOption);
                   .AND. oCLBSOCIOS:nOption!=0);
             SIZE NIL,22 PIXEL

 @ 12,50 GET oCLBSOCIOS:oCLI_DIR3 VAR oCLBSOCIOS:CLI_DIR3;
             WHEN (AccessField("DPCLIENTES","CLI_DIR3",oCLBSOCIOS:nOption);
                   .AND. oCLBSOCIOS:nOption!=0);
             SIZE NIL,22 PIXEL

   @ 13,50 GET oCLBSOCIOS:oCLI_DIR4 VAR oCLBSOCIOS:CLI_DIR4;
               WHEN (AccessField("DPCLIENTES","CLI_DIR4",oCLBSOCIOS:nOption);
                .AND. oCLBSOCIOS:nOption!=0);
                SIZE NIL,22 PIXEL


   @ 10,180 GET oCLBSOCIOS:oCLI_TEL1 VAR oCLBSOCIOS:CLI_TEL1;
                WHEN (AccessField("DPCLIENTES","CLI_TEL1",oCLBSOCIOS:nOption);
                   .AND. oCLBSOCIOS:nOption!=0);
                SIZE NIL,22 PIXEL

   @ 11,180 GET oCLBSOCIOS:oCLI_TEL2 VAR oCLBSOCIOS:CLI_TEL2;
                WHEN (AccessField("DPCLIENTES","CLI_TEL2",oCLBSOCIOS:nOption);
                    .AND. oCLBSOCIOS:nOption!=0);
                SIZE NIL,22 PIXEL

  @ 12,180 GET oCLBSOCIOS:oCLI_TEL3 VAR oCLBSOCIOS:CLI_TEL3;
               WHEN (AccessField("DPCLIENTES","CLI_TEL3",oCLBSOCIOS:nOption);
                     .AND. oCLBSOCIOS:nOption!=0);
               SIZE NIL,22 PIXEL

  @ 6,50 SAY "Tipo" PIXEL;
         SIZE NIL,7 RIGHT

  @ 6,50 SAY "Tarifa" PIXEL;
         SIZE NIL,7 RIGHT

  @ 5.2,11.7 BMPGET oCLBSOCIOS:oCodInv VAR oCLBSOCIOS:cCodInv;
             VALID oCLBSOCIOS:VALCODINV();
             NAME "BITMAPS\FIND.BMP";
             WHEN (AccessField("DPCLIENTEPROG","DPG_CODINV",oCLBSOCIOS:nOption);
                     .AND. oCLBSOCIOS:nOption!=0);
             ACTION (oDpLbx:=DpLbx("dpinv_servicios.lbx",NIL,"LEFT(INV_ESTADO,1)"+GetWhere("=","A"),nil,nil,nil,nil,nil,nil,oCLBSOCIOS:oCodInv) , oDpLbx:GetValue("INV_CODIGO",oCLBSOCIOS:oCodInv)); 
             SIZE 60,21 FONT oFontB

  oCLBSOCIOS:oCodInv:bkeyDown:={|nkey| IIF(nKey=13, oCLBSOCIOS:ValCodInv(),NIL) }

  @ oCLBSOCIOS:oCodInv:nTop(),oCLBSOCIOS:oCodInv:nRight()+20 SAY oCLBSOCIOS:oSayInv PROMPT " "+SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oCLBSOCIOS:cCodInv))+" ";
    SIZE 390,20 PIXEL  COLOR CLR_WHITE,16761992


  @ 0.9,43 BMPGET oCLBSOCIOS:oCLI_FECHA   VAR oCLBSOCIOS:CLI_FECHA  ;
           PICTURE oDp:cFormatoFecha;
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oCLBSOCIOS:oCLI_FECHA  ,oCLBSOCIOS:CLI_FECHA );
           VALID .T.;
           WHEN (AccessField("DPCLIENTES","CLI_FECHA ",oCLBSOCIOS:nOption);
                 .AND. oCLBSOCIOS:nOption!=0);
           SIZE 41,10

  @ 0.9,43 BMPGET oCLBSOCIOS:oCLI_GACFCH   VAR oCLBSOCIOS:CLI_GACFCH  ;
           PICTURE oDp:cFormatoFecha;
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oCLBSOCIOS:oCLI_GACFCH  ,oCLBSOCIOS:CLI_GACFCH );
           VALID .T.;
           WHEN (AccessField("DPCLIENTES","CLI_GACFCH ",oCLBSOCIOS:nOption);
                .AND. oCLBSOCIOS:nOption!=0);
           SIZE 41,10

  @ 5,25 SAY "Ingreso";
         SIZE NIL,7 RIGHT

  @ 6,25 SAY "Nacimiento";
         SIZE NIL,7 RIGHT


  SETFOLDER( 2)
 
  oCLBSOCIOS:oScroll:=oCLBSOCIOS:SCROLLGET("DPCLIENTES","CLBSOCIOS.SCG",cExcluye)

  oCLBSOCIOS:oScroll:SetColSize(250,300-60,240-0)
  oCLBSOCIOS:oScroll:SetColorHead(CLR_BLACK ,oDp:nGrid_ClrPaneH,oFont) 

  oCLBSOCIOS:oScroll:SetColor(oDp:nClrPane1,oDp:nClrDPCLIENTES,1,oDp:nClrPane2,oFontB) 
  oCLBSOCIOS:oScroll:SetColor(oDp:nClrPane1,0,2,oDp:nClrPane2,oFont ) 
  oCLBSOCIOS:oScroll:SetColor(oDp:nClrPane1,0,3,oDp:nClrPane2,oFontB) 

  SETFOLDER(0)
  
//       " ,DATEDIFF("+GetWhere("",oDp:dFecha)+",CRC_FECHA)/360 AS CRC_EDAD,"+;

  cSql :=" SELECT "+SELECTFROM("DPCLIENTESREC",.F.)+;
         " ,TIMESTAMPDIFF(MONTH,CRC_FECHA,"+GetWhere("",oDp:dFecha)+")/12 AS CRC_EDAD,"+;
         " DPINV.INV_DESCRI,DPCENCOS.CEN_DESCRI "+;
         " FROM DPCLIENTESREC "+;
         " LEFT  JOIN DPINV     ON CRC_CODINV=INV_CODIGO"+;
         " LEFT  JOIN DPCENCOS  ON CRC_CENCOS=CEN_CODIGO"+;
         " "

  cScope:="" // MOV_TIPDOC='DINV' AND MOV_APLORG='I' AND MOV_INVACT=1"

  oGrid:=oCLBSOCIOS:GridEdit( "DPCLIENTESREC" ,"CLI_CODIGO" , "CRC_CODCLI" , cSql , cScope ) 

  oGrid:cScript     :="CLBSOCIOS"

//  oGrid:GRIDGETSIZE(135+200-85,0,aCoors[4]-30,200+30+170-100)
//  oGrid:aSize      := {135+200-85,0,aCoors[4]-30,MAX(aCoors[3]-540,200+30+170-100)} 
  oGrid:aSize      := {135+200-85,0,aCoors[4]-30,MAX(aCoors[3]-540,200+30+170-100)} 

  IF aCoors[3]<=800
    oGrid:aSize      := {135+200-110,0,aCoors[4]-30,aCoors[3]-520} 
  ENDIF

  oGrid:oFont       :=oFontB
  oGrid:bWhen       :="!EMPTY(oCLBSOCIOS:CLI_CODIGO)"
  oGrid:bValid      :="!EMPTY(oCLBSOCIOS:CLI_CODIGO)"
  oGrid:cItem       :="CRC_ITEM"
  oGrid:cLoad       :="GRIDLOAD"
  oGrid:cPresave    :="GRIDPRESAVE"
  oGrid:cPostSave   :="GRIDPOSTSAVE" 
  oGrid:cPreDelete  :="GRIDPREDELETE"
  oGrid:cPostDelete :="GRIDPOSTDELETE" 
  oGrid:cMetodo     :="P" // Método de Costo
  oGrid:cPreReg     :=""
  oGrid:lTotal      :=.T.
  oGrid:cMetodo     :="P"

  oGrid:nClrTextH   :=0 
  oGrid:lTallas     :=.F.
  oGrid:cTallas     :=""
  oGrid:nCostoLote  :=0
  oGrid:nLotes      :=0
  oGrid:aCapas      :={}
  oGrid:nHeaderLines:=2

  oGrid:nClrPane1   :=oDp:nClrPane1
  oGrid:nClrPane2   :=oDp:nClrPane2
  oGrid:nClrPaneH   :=oDp:nLbxClrHeaderPane
  oGrid:nClrTextH   :=0 
  oGrid:nRecSelColor:=oDp:nLbxClrHeaderPane

/*
  oGrid:bClrText :={|a,n,o,nClrText| nClrText:=0,;
                                     nClrText:=IF(LEFT(a[4],1)="E",oDp:nClrDebe ,nClrText),;
                                     nClrText:=IF(LEFT(a[4],1)="S",oDp:nClrHaber,nClrText) }
*/

  oGrid:SetMemo("CRC_NUMMEM","Descripción Amplia",1,1,100,200)

  IF oDp:nVersion>=5
    oGrid:SetAdjuntos("CRC_FILMAI")
  ENDIF


  // Almacén
  oGrid:cAlmacen:=oDp:cAlmacen

  // Campo Código
  oCol:=oGrid:AddCol("CRC_ITEM")
  oCol:cTitle   :="ID"
  oCol:nWidth   :=30
  oCol:lItems   :=.T.


  // Campo Carnet
  oCol:=oGrid:AddCol("CRC_ID")
  oCol:cTitle   :="Carnet"
  oCol:nWidth   :=30
 

  // Campo Código
  oCol:=oGrid:AddCol("CRC_CODIGO")
  oCol:cTitle   :="Código"
  oCol:nWidth   :=125+8

  oCol:=oGrid:AddCol("CRC_NOMBRE")
  oCol:cTitle:="Apellidos"+CRLF+"Nombre"
  oCol:nWidth:=255

  oCol:=oGrid:AddCol("CRC_FECHA")
  oCol:cTitle   :="Fecha"+CRLF+"Nac."
  oCol:nWidth   :=90
  oCol:nEditType:=EDIT_GET_BUTTON
  oCol:bAction  :={||EJECUTAR("GRIDFECHA",oGrid)}

  oCol:=oGrid:AddCol("CRC_EDAD")
  oCol:cTitle:="Edad"+CRLF+"Años"
  oCol:nWidth:=40
  oCol:cPicture:="99.9"
  oCol:bWhen   :=".F."


  oCol:=oGrid:AddCol("CRC_SEXO")
  oCol:cTitle:="Sexo"
  oCol:nWidth:=80
  oCol:aItems:=ACLONE(aSexo)

  oCol:=oGrid:AddCol("CRC_PARENT")
  oCol:cTitle:="Parentesco"
  oCol:nWidth:=80
  oCol:aItems:=ACLONE(aParent)

  oCol:=oGrid:AddCol("CRC_FCHINI")
  oCol:cTitle:="Fecha"+CRLF+"Inicio"
  oCol:nEditType:=EDIT_GET_BUTTON
  oCol:bAction  :={||EJECUTAR("GRIDFECHA",oGrid)}
  oCol:nWidth:=90

  oCol:=oGrid:AddCol("CRC_OBS1")
  oCol:cTitle:="Profesión"
  oCol:nWidth:=90

  oCol:=oGrid:AddCol("CRC_ESTADO")
  oCol:cTitle:="Estado"
  oCol:nWidth:=80
  oCol:aItems:=ACLONE(aEstado)

  oCLBSOCIOS:oFocus:=oCLBSOCIOS:oCLI_NOMBRE
//oGrid:oSayOpc   :=oCLBSOCIOS:oProducto
  oCLBSOCIOS:oFocusFind:=oCLBSOCIOS:oCLI_CODIGO

  oCLBSOCIOS:Activate()

// {||ErrorSys(.T.)})

/*
  IF ValType(oGrid:bChange)="B"
    EVAL(oGrid:bChange)
  ELSE
    MacroEje(oGrid:bChange)
  ENDIF
*/

//  EJECUTAR("FRMMOVEDOWN",oCLBSOCIOS:oTotal,oCLBSOCIOS,{oCLBSOCIOS:aGrids[1]:oBrw})

RETURN

/*
// Carga los Datos
*/
FUNCTION LOAD()
  LOCAL nAsientos:={},cWhere:=""
  
  cWhere:="DPG_CODIGO"+GetWhere("=",oCLBSOCIOS:CLI_CODIGO)+" AND DPG_NUMERO"+GetWhere("=",STRZERO(1,8))

  oCLBSOCIOS:cCodInv   :=SQLGET("DPCLIENTEPROG","DPG_CODINV",cWhere)

  IF ValType(oCLBSOCIOS:oCodInv)="O"
    oCLBSOCIOS:oCodInv:VarPut(oCLBSOCIOS:cCodInv,.T.)
    oCLBSOCIOS:oSayInv:Refresh(.T.)
  ENDIF

  oCLBSOCIOS:cOldCodCli:=""
  
  IF oCLBSOCIOS:nOption=1

  ELSE

     oCLBSOCIOS:cOldCodCli:=oCLBSOCIOS:CLI_CODIGO

  ENDIF


  IF  oCLBSOCIOS:nOption<>0 
//.AND. !Empty(oCLBSOCIOS:DOC_NUMCBT)

    IF !oCLBSOCIOS:ISANULMOD()
       RETURN .F.
    ENDIF

  ENDIF

RETURN .T.

/*
// Permiso para Modificar o Anular
*/
FUNCTION ISANULMOD(nOption)

  LOCAL nAsientos:={},cWhere:="",uKey

  DEFAULT nOption:=oCLBSOCIOS:nOption


RETURN .T.


FUNCTION PRESAVE()

  DEFAULT oDp:cCodVen:=SQLGET("DPVENDEDOR","VEN_CODIGO")

  oCLBSOCIOS:CLI_CODVEN:=oDp:cCodVen
  oCLBSOCIOS:CLI_CODCLA:=SQLGET("DPCLICLA"     ,"CLC_CODIGO")
  oCLBSOCIOS:CLI_ACTIVI:=SQLGET("DPACTIVIDAD_E","ACT_CODIGO")
	
RETURN .T.

FUNCTION GRIDLOAD()
  LOCAL I,cItem

  IF oGrid:nOption=1 

     cItem:=SQLINCREMENTAL("DPCLIENTESREC","CRC_ITEM","CRC_CODCLI"+GetWhere("=",oCLBSOCIOS:CLI_CODIGO))
     cItem:=STRZERO(VAL(cItem),3)
     oGrid:Set("CRC_ITEM",cItem,.T.)

     oGrid:Set("CRC_FCHINI",oDp:dFecha,.T.)

  ELSE
  ENDIF

RETURN .T.

/*
// Pregrabar
*/
FUNCTION GRIDPRESAVE()

   IF Empty(oGrid:CRC_CODIGO)
      oGrid:CRC_CODIGO:=oGrid:CRC_ITEM
   ENDIF

RETURN .T.

/*
// Grabación del Item
*/
FUNCTION GRIDPOSTSAVE()
RETURN .T.

/*
// Ejecución Antes de Eliminar el Item
*/
FUNCTION GRIDPREDELETE()
RETURN .T.

/*
// PostGrabar
*/
FUNCTION GRIDPOSTDELETE()
RETURN .T.

FUNCTION VCRC_CODCLI(cCodInv)
RETURN .T.


FUNCTION POSTGRABAR()
  LOCAL cSql,oTable
  LOCAL cWhere

  IF !Empty(oCLBSOCIOS:cOldCodCli)
    cWhere:="DPG_CODIGO"+GetWhere("=",oCLBSOCIOS:cOldCodCli)+" AND DPG_NUMERO"+GetWhere("=",STRZERO(1,08))
  ELSE
    cWhere:="DPG_CODIGO"+GetWhere("=",oCLBSOCIOS:CLI_CODIGO)+" AND DPG_NUMERO"+GetWhere("=",STRZERO(1,08))
  ENDIF

  oTable:=OpenTable("SELECT * FROM DPCLIENTEPROG WHERE "+cWhere,.T.)

  IF oTable:RecCount()=0
     oTable:AppendBlank()
     oTable:cWhere:=""
  ENDIF

  oTable:Replace("DPG_CODSUC",oDp:cSucursal)
  oTable:Replace("DPG_NUMERO",STRZERO(1,08))
  oTable:Replace("DPG_CODIGO",oCLBSOCIOS:CLI_CODIGO)
  oTable:Replace("DPG_CODINV",oCLBSOCIOS:cCodInv)
  oTable:Commit(oTable:cWhere)
  oTable:End()

  EJECUTAR("CLGCLIENTESMNU",oCLBSOCIOS:CLI_CODIGO)

RETURN .T.

FUNCTION PREDELETE()
RETURN .T.

FUNCTION POSTDELETE()
RETURN .T.


FUNCTION PRINTER()
 
  REPORTE("DPCLIENTES")

  oDp:oGenRep:SetRango(1,oCLBSOCIOS:DOC_CODSUC,oCLBSOCIOS:DOC_CODSUC)
  oDp:oGenRep:SetRango(2,oCLBSOCIOS:CLI_CODIGO,oCLBSOCIOS:CLI_CODIGO)

RETURN .T.

/*
// Consultar Documento de Inventario
*/
FUNCTION DOCMOVVIEW()
RETURN .T.


/*
// LOTE
*/
FUNCTION VMOV_LOTE(cLote)
RETURN .T.

FUNCTION VALRIF()
RETURN .T.

FUNCTION VCRC_CODINV()
RETURN .T.

FUNCTION VCRC_CENCOS()
  LOCAL cCodInv:=SQLGET("DPCENCOS","CEN_CODINV","CEN_CODIGO"+GetWhere("=",oGrid:CRC_CENCOS))

  IF !Empty(cCodInv)
     oGrid:Set("CRC_CODINV",cCodInv,.T.)
     oGrid:ColCalc("INV_DESCRI")
  ENDIF

RETURN .T.


FUNCTION VERCLGREPRES()
   EJECUTAR("DPCLIENTESCON",NIL,oCLBSOCIOS:CLI_CODIGO)
RETURN .T.


FUNCTION VALCODINV()
  LOCAL lOk
  LOCAL cNombre:=SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oCLBSOCIOS:cCodInv))
  
  IF !Empty(cNombre)
     oCLBSOCIOS:oSayInv:VarPut(cNombre,.T.)
  ELSE
     EVAL(oCLBSOCIOS:bAction)
     RETURN .F.
  ENDIF

  oCLBSOCIOS:oSayInv:Refresh(.T.)

RETURN .T.
// EOF
