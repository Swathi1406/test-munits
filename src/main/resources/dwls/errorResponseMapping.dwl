%dw 2.0
output application/json
---
{
	"resultCode": error.errorType.namespace ++ ":" ++ error.errorType.identifier,
	"resultDesc": error.detailedDescription replace("\n") with (", ")
}