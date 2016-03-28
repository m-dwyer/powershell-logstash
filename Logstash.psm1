function PushTo-Logstash {
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
        Write-Output "Initialising TCP stream.."
        $hostAddress = [System.Net.Dns]::GetHostAddresses($HostName) 
        $ipAddress = [System.Net.IPAddress]::Parse($hostAddress)
        $socket = New-Object System.Net.Sockets.TCPClient($ipAddress, $Port)
        $stream = $socket.GetStream() 
        $writer = New-Object System.IO.StreamWriter($stream)
    }

    process {
        Write-Output "Writing JSON object to TCP stream.."
        $jsonObject = ((ConvertTo-Json $InputObject) -replace "`r", ' ' -replace "`n", ' ')
        $writer.WriteLine($jsonObject)
    }

    end {
        Write-Output "Flushing and closing stream.."
        $writer.Flush()
        $stream.Close()
        $socket.Close()
    }
}