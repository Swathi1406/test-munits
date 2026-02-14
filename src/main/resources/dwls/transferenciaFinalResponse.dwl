%dw 2.0
output application/csv separator=";", header=true, encoding="ISO-8859-15"
var rows = read(vars.varOriginalFilePayload,"application/csv",{separator: ";",header: true})
fun trimStr(v) = ((v default "") as String) as String { class: "trim" }
fun statusFlag(a) = if (lower(trimStr(a)) == "anulado") "X" else ""
fun pickDate(r) = trimStr(r."Data_Efectiva")
---
(rows default [])
  map (r) -> {
    EMPLOYEE_ID: trimStr(r.Colaborador),
    BEGIN_DATE:  pickDate(r),
    END_DATE:    pickDate(r),
    UNIT_ID:r.Codigo_de_Centro_de_Custo,
    SECTION_ID:r.Organizacao,
    DELETED:statusFlag(r.Accao)
  }