%dw 2.0
output application/json
var cfg = readUrl("classpath://flows.json", "application/json")
var entry = cfg.flows[vars.varFlowName] default {}
var ext = (cfg.extension default ".csv") as String
var yyyyMMdd = (now() as String { format: "yyyyMMdd" })
var stamp = (now() as String { format: "yyyyMMddHHmmss" })
var specialPrefixes = ["Carga_Horaria", "Desligamento", "Transferencia"]
var workdayFileName =
    if (specialPrefixes contains (entry.inputPrefix default ""))
      (entry.inputPrefix default "") ++ "_" ++ yyyyMMdd ++ "_" ++ stamp ++ ext
    else
      (entry.inputPrefix default "") ++ yyyyMMdd ++ "_" ++ stamp ++ ext
---
  {
    InputFileName: (entry.inputPrefix default "") ++ yyyyMMdd ++ ext,
    WorkdayFileName: workdayFileName,
    OutputFileName: (entry.outputPrefix default "") ++ yyyyMMdd ++ "_" ++ stamp ++ ext,
    EncryptionFlag: (entry.encryptionFlag default false),
    dwlMappingFile: (entry.dwlMappingFile default "")
  }