%dw 2.0
output application/csv separator=";", header=true, encoding="ISO-8859-15"
var rows = read(vars.varOriginalFilePayload, "application/csv", { separator: ";", header: true })
fun t(v) = ((v default "") as String) as String { class: "trim" }
fun empStatus(s) =
  if (lower(t(s)) == "activo") "A"
  else if (lower(t(s)) == "inactivo") "I"
  else "B"
---
(rows default [])
  map (r) -> {
    EMPLOYEE_ID:         t(r.Colaborador),
    ADMISSION_DT:        t(r.Data_de_admissao),
    NIF:                 t(r.Colaborador),
    NAME:                t(r.Nome_Abreviado),
    UNIT_ID:             t(r.Codigo_do_local),
    SECTION_DESC:        t(r.Organizacao),
    ROLE_ID:             t(r.Codigo_do_cargo),
    ANTIQUITY_DT:        "",
    EMPLOYEE_ST:         empStatus(r.Status_do_contrato),
    LEAVE_DT:            t(r.Data_de_termino_do_contrato),
    TT_WEEK_TIME:        t(r.Carga_horaria_semanal),
    WORK_SHIFT_COMPLETE: t(r.Turno_de_Trabalho),
    IHT:                 if (t(r.IHT) == "") "" else "X",
    DELETED:             if (lower(t(r.Accao)) == "anulado") "X" else ""
  }