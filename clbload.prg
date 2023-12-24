// Programa   : CLBLOAD
// Fecha/Hora : 25/12/2023 00:10:26
// Propósito  : Lectura de Valores
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL oData   :=DATACONFIG("CLBCONFIG","ALL")

   oDp:cTipDocClb:=oData:Get("cTipDocClb","CUO")
   oDp:cTipDocAlq:=oData:Get("cTipDocAlq","ALQ")
   oDp:cTipDocTra:=oData:Get("cTipDocTra","TRA")

   oDp:nPorPenalz:=oData:Get("nPorPenalz",10)  // 10% de penalización
   oDp:nDiasVence:=oData:Get("nPorPenalz",10)  // Vence a los 10 dias, se coloca cuando se general las cuotas en campo DOC_FCHVEN

   oData:End()

RETURN
