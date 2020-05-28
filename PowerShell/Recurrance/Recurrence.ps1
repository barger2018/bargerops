
# Slow O(N squared)

function RecurrenceByNesting {
    param (
            [string]$inputString
        )
      
        for($i = 0; $i -lt $inputString.Length; $i++) {

            for($j = $i + 1; $j -lt $inputString.Length; $j++) {

                if($inputString[$i] -ceq $inputString[$j]) {
                    return $inputString[$i]
                }
            }
        }

        return "no match found"
}

#Fast O(N) on average
function RecurrenceByHash {
    param (
            [string]$inputString
        )

        $hash = @{}

        for($i = 0; $i -lt $inputString.Length; $i++) {
            if($hash.Contains($inputString[$i])) {
                return $inputString[$i]
            }
            $hash.Add($inputString[$i],$inputString[$i])
        }

        return "no match found"
}


$nesting = Measure-Command {Write-Host (RecurrenceByNesting -inputString "abcdefghijklmnopqrstuvxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")}

$hashing = Measure-Command {Write-Host (RecurrenceByHash -inputString "abcdefghijklmnopqrstuvxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")}

Write-Host "Nesting: " $nesting.Milliseconds
Write-Host "Hashing: " $hashing.Milliseconds