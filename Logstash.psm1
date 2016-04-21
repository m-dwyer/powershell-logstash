function PushTo-Logstash {
    [CmdletBinding()]
    param (
    [Parameter(
        Mandatory=$true,
        ValueFromPipeline=$true)
    ]
    [Object]$InputObject,
    [String]$HostName,
    [String]$Port
    )

    begin {
        Write-Verbose "Initialising TCP stream.."
        $hostAddress = [System.Net.Dns]::GetHostAddresses($HostName) 
        $ipAddress = [System.Net.IPAddress]::Parse($hostAddress)
        $socket = New-Object System.Net.Sockets.TCPClient($ipAddress, $Port)
        $stream = $socket.GetStream() 
        $writer = New-Object System.IO.StreamWriter($stream)
    }

    process {
        Write-Verbose "Writing JSON object to TCP stream.."
        $jsonObject = ((ConvertTo-Json $InputObject) -replace "`r", ' ' -replace "`n", ' ')
        $writer.WriteLine($jsonObject)
    }

    end {
        Write-Verbose "Flushing and closing stream.."
        $writer.Flush()
        $stream.Close()
        $socket.Close()
    }
}