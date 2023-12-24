// Programa   : ADDON_CLB
// Fecha/Hora : 18/09/2010 17:22:34
// Propósito  : Menú Librerias
// Creado Por : Juan Navas
// Llamado por: DPINVCON
// Aplicación : Inventario
// Tabla      : DPINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodAdd)
   LOCAL cNombre:="",cSql,I,nGroup,cUtiliz
   LOCAL oFont,oFontB,oOut,oCursor,oBtn,oBar,oBmp
   LOCAL oBtn,nGroup,bAction,aBtn:={}
   LOCAL aMes    :=oDp:aMeses
//   LOCAL oData   :=DATACONFIG("CLBCONFIG","ALL")
   LOCAL aMes    :=oDp:aMeses

   EJECUTAR("DPTIPDOCCLICREA","CUO","Cuotas Mensuales","D")

   EJECUTAR("CLBLOAD")

//   oDp:cTipDocClb:=oData:Get("cTipDocClb","CUO")
//   oDp:cTipDocAlq:=oData:Get("cTipDocAlq","ALQ")
//   oDp:nPorPenalz:=oData:Get("nPorPenalz",10)  // 10% de penalización
//   oDp:nDiasVence:=oData:Get("nPorPenalz",10)  // Vence a los 10 dias, se coloca cuando se general las cuotas en campo DOC_FCHVEN

   oDp:lClub     :=.T.

//   oData:End()

   DEFAULT cCodAdd:="CLB",;
           oDp:aCoors:=GetCoors( GetDesktopWindow() )

   cNombre:=""
   cUtiliz:=""

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-14 BOLD

   DpMdi("Menú Club Social","oClub","")

   oClub:cCodAdd   :=cCodAdd
   oClub:cNombre   :=cNombre
   oClub:lSalir    :=.F.
   oClub:nHeightD  :=45
   oClub:lMsgBar   :=.F.
   oClub:oGrp      :=NIL
   oClub:ADD_AUTEJE:=SQLGET("DPADDON","ADD_AUTEJE","ADD_CODIGO"+GetWhere("=","CLB"))
   oClub:cUtiliz   :=cUtiliz

   SetScript("ADDON_CLB")

   AADD(aBtn,{"Socios"                     ,"CLIENTE.BMP"       ,"CLIENTES"  }) 
   AADD(aBtn,{"Familiares"                 ,"FAMILIA.BMP"       ,"FAMILIARES"})
   AADD(aBtn,{"Inquilinos"                 ,"FACTURAPER.BMP"    ,"INQUILINOS"})
   AADD(aBtn,{"Tarifas"                    ,"PRECIOS.BMP"       ,"TARIFAS"   })
   AADD(aBtn,{"Generar Cuotas Socios"      ,"RUN.BMP"           ,"GENCUOTAS" })
   AADD(aBtn,{"Generar Cuotas Alquileres"  ,"RUNPROCESO.BMP"    ,"GENCUOTASAQL" })
   AADD(aBtn,{"Notas de Consumo"           ,"notasdeconsumo.bmp","CONSUMOS" })

   AADD(aBtn,{"Traspasos"                  ,"exports.bmp"      ,"TRASPASOS" })

   AADD(aBtn,{"Tarifas x Afiliados"        ,"XBROWSE.BMP"       ,"AFILIADOS" })
   AADD(aBtn,{"Cuadro de Mando"            ,"PLANTILLAS.BMP"    ,"CMICUOTAS" })
   AADD(aBtn,{"Registro de Visitantes"     ,"XPERSONAL.BMP"     ,"VISITAS"   })


   AADD(aBtn,{"Iniciación de Cuotas para Socios"       ,"semaf01.BMP"         ,"INICUOTAS" })
   AADD(aBtn,{"Impotar cuotas pendientes desde MIX-NET","import.BMP"          ,"IMPMIXNET" })
   AADD(aBtn,{"Visualizar Cuotas desde MIXNET"         ,"xbrowse.BMP"         ,"VIEWCUO" })
   AADD(aBtn,{"Visualizar Anticipos desde MIXNET"      ,"xbrowseamarillo.BMP" ,"VIEWANT" })


/*
   AADD(aBtn,{"Tarifas"                    ,"PRECIOS.BMP"      ,"TARIFAS" })
   AADD(aBtn,{"Inscripciones"              ,"IMPORTS.BMP"      ,"INSCRIPCIONES"}) 
   AADD(aBtn,{"Facturación Cuotas Anuales" ,"PLANTILLAS.BMP"   ,"CUOTAS"  }) 
   AADD(aBtn,{"Aulas"                      ,"CENTRODECOSTO.BMP","AULAS"   })
   AADD(aBtn,{"Estado Situacional por Aula","XBROWSE.BMP"      ,"BRWXAULA"}) 
*/
 
   oClub:Windows(0,0,oDp:aCoors[3]-160,415)  

  @ 48, -1 OUTLOOK oClub:oOut ;
     SIZE 150+250, oClub:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFont ;
     OF oClub:oWnd;
     COLOR CLR_BLACK,16774120

   DEFINE GROUP OF OUTLOOK oClub:oOut PROMPT "&Opciones "

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oClub:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oClub:oOut:aGroup)
      oBtn:=ATAIL(oClub:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oClub:INVACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oClub:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction

   NEXT I

   oClub:Activate("oClub:FRMINIT()",,"oClub:oSpl:AdjRight()")
 
RETURN

FUNCTION FRMINIT()
   LOCAL oCursor,oBar,oBtn,oFont,nCol:=12

   DEFINE BUTTONBAR oBar SIZE 44,44 OF oClub:oWnd 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONFIG.BMP";
          ACTION EJECUTAR("CLBCONFIG");
          WHEN .T.
*/

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oClub:End()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

 @ 1,40 CHECKBOX oClub:oADD_AUTEJE VAR oClub:ADD_AUTEJE  PROMPT "Auto-Ejecución";
                 WHEN  (AccessField("DPADDON","ADD_AUTEJE",1));
                 FONT oFont;
                 SIZE 180,20 OF oBar;
                 ON CHANGE EJECUTAR("ADDONUPDATE","ADD_AUTEJE",oClub:ADD_AUTEJE,"CLB")

  oClub:oADD_AUTEJE:cMsg    :="Auto-Ejecución cuando se Inicia el Sistema"
  oClub:oADD_AUTEJE:cToolTip:="Auto-Ejecución cuando se Inicia el Sistema"

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11  BOLD

//  @ 00.0,20 SAY " "+DTOC(oClub:dFchIniCol)+" " OF oBar BORDER SIZE 76,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 
//  @ 01.4,20 SAY " "+DTOC(oClub:dFchFinCol)+" " OF oBar BORDER SIZE 76,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 

  oBar:Refresh(.T.)

  oClub:oWnd:bResized:={||oClub:oWnd:oClient := oClub:oOut,;
                          oClub:oWnd:bResized:=NIL}
                      
RETURN .T.

FUNCTION INVACTION(cAction)
   LOCAL cTitle:=NIL,cWhere
 
   IF cAction="CLIENTES"
     EJECUTAR("CLBSOCIOS")
   ENDIF

   IF cAction="FAMILIARES"
     EJECUTAR("BRCLBFAMILIARES")
   ENDIF

   IF cAction="AFILIADOS"
     EJECUTAR("BRCLBAFILIACION")
   ENDIF

   IF cAction="TARIFAS"
     DpLbx("dpinv_afiliaciones.lbx")
   ENDIF

   IF cAction=="GENCUOTAS"
      EJECUTAR("BRCLBAFILIACION","INV_UTILIZ"+GetWhere("=","Afiliación"))
   ENDIF

   IF cAction=="GENCUOTASAQL"

      EJECUTAR("BRCLBALQUILER","INV_UTILIZ"+GetWhere("=","Alquiler"),nil,nil,nil,"Generación de Registro de Alquileres",nil,nil,nil,nil,nil,nil,oDp:cTipDocAlq)

   ENDIF

   IF cAction="CUOTAS"
     EJECUTAR("BRGIRTOFAC",cWhere,NIL,12,oDp:dFchIniClg,oDp:dFchFinClg,cTitle)
   ENDIF

   IF cAction="AULAS"
     DPLBX("CLBAULAS.LBX")
   ENDIF

   IF cAction="INSCRIPCIONES"
     EJECUTAR("BRINSCRIP")
   ENDIF

   IF cAction="BRWXAULA"
     EJECUTAR("BRGIRTOFACXCEN")
   ENDIF

   IF cAction="CMICUOTAS"
     EJECUTAR("BRCSCMI")
   ENDIF

   IF cAction="INICUOTAS" .AND. MsgNoYes("Desea Generar la Programación  Mensual de Cuotas para los Socios")
      MsgRun("Generando Programación")
      EJECUTAR("CDDPCLIENTEPRG")
      EJECUTAR("BRCLBAFILIACION")
   ENDIF

  IF cAction="CONSUMOS"
     EJECUTAR("BRCLBCONSUMOS")
     RETURN NIL
  ENDIF
   
  IF cAction="IMPMIXNET" .AND. MsgNoYes("Desea Importar las cuotas desde c:\mixclub\comp01\")
      MsgRun("Importando Cuotas")
      EJECUTAR("IMPORTMXCLI") //
      EJECUTAR("IMPORTMIXENCALB")
      EJECUTAR("IMPORTANTMIX")
      EJECUTAR("CLBAPLPENALIZA") // Aplica Penalizaciones
      EJECUTAR("BRCXC")
   ENDIF

   IF cAction="VISITAS"
      EJECUTAR("CLBVISITANTE")
   ENDIF

  IF cAction="VIEWCUO"
     EJECUTAR("VIEWMIXENCALB")
  ENDIF

  IF cAction="VIEWANT"
     EJECUTAR("VIEWMIXENCALB")
  ENDIF

  IF cAction="INQUILINOS"
     EJECUTAR("BRINVXCLIPRG","INV_UTILIZ"+GetWhere("=","alquiler"))
  ENDIF

  IF cAction="TRASPASOS"
     EJECUTAR("BRCLBTRASPASO")     
  ENDIF

RETURN .T.
// EOF
