# Aegis Ink - Clean Version (No Host-Specific Paths)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class NativeMethods {
    [DllImport("ntdll.dll", SetLastError = true)]
    public static extern uint NtTerminateProcess(IntPtr ProcessHandle, uint ExitStatus);
}
"@

$inkRegistry = @{}
$threatLevel = 0
$stealthMode = $true
$seenProcesses = @{}
$udpMorphLog = @{}
$SOS_Domain = "alert.whistle-safe.org"

function Append-Log($text) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $text"
}

function Send-DNSBeacon {
    param ([string]$Payload)
    $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Payload)) -replace '=', ''
    $domain = $encoded.Substring(0, [Math]::Min(63, $encoded.Length)) + '.' + $SOS_Domain
    try { nslookup $domain | Out-Null } catch {}
}

function Kill-ProcessNative {
    param ([int]$pid)
    try {
        $proc = Get-Process -Id $pid -ErrorAction Stop
        [NativeMethods]::NtTerminateProcess($proc.Handle, 0) | Out-Null
    } catch {
        Append-Log \"[✖️ ERROR] Failed to kill PID $pid\"
    }
}

function Show-SOSBeacon {
    param ([int]$pid)
    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
    $info = \"HOST=$env:COMPUTERNAME;PID=$pid;PROC=$($proc.Name)\"
    $choice = Read-Host \"Threat level 100%. Send S.O.S. beacon? (yes/no)\"
    if ($choice -eq 'yes') {
        Send-DNSBeacon $info
        Append-Log \"[🆘 S.O.S.] Beacon sent for PID $pid\"
    }
}

function Update-ThreatLevel($amount) {
    $global:threatLevel += $amount
    if ($global:threatLevel -gt 100) { $global:threatLevel = 100 }
    Append-Log \"Threat Level: $global:threatLevel%\"

    if ($global:threatLevel -ge 100) {
        Append-Log \"AIRGAP SUGGESTED - PURGE UDP? [Y/N]\"
        $result = Read-Host \"Purge UDP exfil channels? (yes/no)\"
        if ($result -eq \"yes\") {
            Get-NetUDPEndpoint | ForEach-Object {
                try {
                    Stop-Process -Id $_.OwningProcess -Force -ErrorAction Stop
                    Append-Log \"[🔥 PURGED] UDP process $($_.OwningProcess) killed.\"
                } catch {
                    Append-Log \"[✖️ ERROR] Could not kill process $($_.OwningProcess)\"
                }
            }
        }
    }
}

function Ink-Entity($entry, $reason) {
    $msg = \"[🖋️ INKED] $reason :: PID $($entry.ProcessId) -> $($entry.RemoteIP):$($entry.RemotePort) [$($entry.Protocol)]\"
    Append-Log $msg
    Send-DNSBeacon $msg
    Update-ThreatLevel 10
}

function Get-NetworkSnapshot {
    $udpConns = Get-NetUDPEndpoint | ForEach-Object {
        [PSCustomObject]@{
            Protocol   = \"UDP\"
            LocalIP    = $_.LocalAddress
            LocalPort  = $_.LocalPort
            RemoteIP   = \"N/A\"
            RemotePort = \"N/A\"
            ProcessId  = $_.OwningProcess
            TimeStamp  = Get-Date
        }
    }
    return @($udpConns | Where-Object { $_ })
}

$prevConnections = @{}
while ($true) {
    $current = Get-NetworkSnapshot
    foreach ($conn in $current) {
        if ($conn.ProcessId -eq 0) { continue }
        $key = \"$($conn.Protocol):$($conn.RemoteIP):$($conn.RemotePort)\"

        if ($conn.Protocol -eq \"UDP\" -and $conn.ProcessId -eq 4) {
            if (-not $udpMorphLog.ContainsKey($key)) {
                Ink-Entity $conn \"UDP process morphing into SYSTEM (PID 4)\"
                $udpMorphLog[$key] = 1
            }
        }

        if ($prevConnections.ContainsKey($key)) {
            if ($prevConnections[$key].ProcessId -ne $conn.ProcessId) {
                Ink-Entity $conn \"PID Morph Detected for $key\"
            }
        }

        $prevConnections[$key] = $conn
    }
    Start-Sleep -Seconds 10
}
