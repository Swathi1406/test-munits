%dw 2.0
output application/csv separator=";", header=true, encoding="ISO-8859-15"

var rows = read(vars.varOriginalFilePayload, "application/csv", { separator: ";", header: true })

fun blank(v) = ((v as String default "") as String {class: "trim"}) == ""
fun first4(v) = (v as String default "")[0 to 3]

fun isNullOrZero(v) =
  v == null
  or lower(((v as String default "") as String {class: "trim"})) == "null"
  or (
        (
          (
            (v as String default "") replace /,/ with "."
          ) as Number default 999999
        ) == 0.0
     )

fun anyDate(r) =
  not (blank(r.Absence_Date) and blank(r.First_Day_of_Leave) and blank(r.Last_Day_of_Leave))

fun motId(r) =
  if (!blank(r.MOT_AP_ID_Licenca)) first4(r.MOT_AP_ID_Licenca)
  else if (!blank(r.MOT_AP_ID_Ferias))
          (if (startsWith(((r.MOT_AP_ID_Ferias as String) default "") as String {class:"trim"}, "F")) "2072"
           else (r.MOT_AP_ID_Ferias as String default ""))
  else if (!blank(r.MOT_AP_ID_Time_off)) first4(r.MOT_AP_ID_Time_off)
  else ""

fun startDate(r) =
  if (blank(r.First_Day_of_Leave))
    (r.Absence_Date as String default "")
  else
    (r.First_Day_of_Leave as String default "")

fun endDate(r) =
  if (blank(r.Last_Day_of_Leave))
    (r.Absence_Date as String default "")
  else
    (r.Last_Day_of_Leave as String default "")

fun status(a) =
  if (lower(((a as String default "") as String {class:"trim"})) == "corrigido") "X"
  else ""

---
(rows default [])
  filter isNullOrZero($.Quantidade_Calculada_Horas)
  filter anyDate($)
  map {
    MOT_APP_ID:  motId($),
    EMPLOYEE_ID: ($.Employee_ID as String),
    START_DATE:  startDate($),
    END_DATE:    endDate($),
    STATUS:      status($.Accao)
  }