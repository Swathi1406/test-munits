%dw 2.0
output application/csv separator=";", header=true
import * from dw::core::Strings
var inputRows = read(vars.varOriginalFilePayload, "application/csv", {separator: ";",header: true,
ignoreEmptyLine: true
})
fun asTrimmedString(value) = if (value == null) "" else trim(value as String)

// Convert "yyyyMMdd HH:mm" (e.g., "20250901 09:00") to minutes from midnight (e.g., 540)
fun minutesFromWorkdayStamp(stamp) =
  if (stamp == null or sizeOf(stamp as String) < 14) null
  else do {
    var s = stamp as String
    var hh = (s[9 to 10]  as Number default null)
    var mm = (s[12 to 13] as Number default null)
    ---
    if (hh == null or mm == null) null else (hh * 60 + mm)
  }

// Compose "yyyy-MM-dd HH:mm" from a day string ("yyyy-MM-dd") and minutes since midnight
fun formatDayAndMinutes(dayString, minutes) =
  if (minutes == null or (trim(dayString as String) == "")) null
  else dayString
          ++ " "
          ++ ((floor((minutes as Number)/60)) as String {format:"00"})
          ++ ":"
          ++ (((minutes as Number) mod 60)   as String {format:"00"})

// Build grouping key "Employee_ID|Start_Date"
fun buildEmployeeDayKey(row) =
  (asTrimmedString(row.Employee_ID) default "")
    ++ "|"
    ++ (asTrimmedString(row.Start_Date) default "")

// groupBy requires a (value, index) function; provide a named adapter (no lambdas)
fun groupByEmployeeDay(value, index) = buildEmployeeDayKey(value)

// Get the first non‑blank Turno string within a day's group (mirrors tAggregateRow "first")
fun firstNonBlankTurnoInGroup(dayRows) =
  do {
    var nonBlank = dayRows filter (asTrimmedString($.Turno) != "")
    ---
    if (sizeOf(nonBlank) > 0) asTrimmedString(nonBlank[0].Turno) else ""
  }

// Aggregations and Split rules
fun buildDailyOutputRow(dayRows) =
  do {
    var firstRow     = dayRows[0]
    var employeeId   = asTrimmedString(firstRow.Employee_ID)
    var punchDay     = asTrimmedString(firstRow.Start_Date)
    var turnoOfDay   = firstNonBlankTurnoInGroup(dayRows)
    var turnoHasSix  = (turnoOfDay contains "6")

    // Convert all Begin/End stamps to minutes (drop invalids)
    var dayBeginMinutesList = dayRows map (minutesFromWorkdayStamp($.Punch_Begin_Hour)) filter ($ != null)
    var dayEndMinutesList   = dayRows map (minutesFromWorkdayStamp($.Punch_End_Hour))   filter ($ != null)

    ---
    if (sizeOf(dayBeginMinutesList) == 0 or sizeOf(dayEndMinutesList) == 0)
      []  // No usable punches for that day → emit nothing
    else
      do {
        var dayBegin = (dayBeginMinutesList orderBy $)[0]      // earliest begin
        var dayEnd   = (dayEndMinutesList   orderBy $)[-1]     // latest end
        var durationMinutes = dayEnd - dayBegin
        var punchCount      = sizeOf(dayBeginMinutesList)
        var halfDuration    = floor(durationMinutes / 2)       // mirror Java int division

        var end1Minutes =
          if (durationMinutes > 300)
            if (turnoHasSix)           dayBegin + (halfDuration - 30)
            else if (punchCount == 3)  dayBegin + (halfDuration + 90)
            else                       dayBegin + (halfDuration - 60)
          else
            dayEnd

        var begin2Minutes =
          if (durationMinutes > 300)
            if (turnoHasSix) end1Minutes + 60 else end1Minutes + 30
          else
            null

        var end2Minutes = if (durationMinutes > 300) dayEnd else null

        ---
        [{
          Employee_ID       : employeeId,
          Punch_Day         : punchDay,
          Punch_Begin_Hour1 : formatDayAndMinutes(punchDay, dayBegin),
          Punch_End_Hour1   : formatDayAndMinutes(punchDay, end1Minutes),
          Punch_Begin_Hour2 : formatDayAndMinutes(punchDay, begin2Minutes),
          Punch_End_Hour2   : formatDayAndMinutes(punchDay, end2Minutes)
        }]
      }
  }

// flatMap adapter
fun emitDailyRows(dayRows, index) = buildDailyOutputRow(dayRows)

// orderBy must return a single comparable; sort by "Employee_ID|Punch_Day"
fun sortByEmployeeThenDay(row, index) =
  ((row.Employee_ID default "") ++ "|" ++ (row.Punch_Day default ""))

// MAIN: group → aggregate → split → flatten → sort → CSV
---
orderBy(
  flatMap(
    valuesOf(
      groupBy((inputRows default []), groupByEmployeeDay)
    ),
    emitDailyRows
  ),
  sortByEmployeeThenDay
)