Param (
    [Parameter(Mandatory=$true)]
    [string] $VMName,
    [string] $GPUName = "AUTO",
    [string] $Hostname = $ENV:Computername
)

Import-Module $PSSCriptRoot\Add-VMGpuPartitionAdapterFiles.psm1

$VM = Get-VM -VMName $VMName
$VHD = Get-VHD -VMId $VM.VMId

If ($VM.state -eq "Running") {
    [bool]$state_was_running = $true
    }

if ($VM.state -ne "Off"){
    "Attemping to shutdown VM..."
    Stop-VM -Name $VMName -Force
    } 

While ($VM.State -ne "Off") {
    Start-Sleep -s 3
    "Waiting for VM to shutdown - make sure there are no unsaved documents..."
    }

"Mounting Drive..."
$WinPartition = (Mount-VHD -Path $VHD.Path -PassThru | Get-Disk | Get-Partition | Where-Object { $_.Type -eq "Basic" } | Select-Object -First 1)

if(!$WinPartition) {
    Write-Error "Unable to find a basic partition on drive"
    Dismount-VHD -Path $VHD.Path
    Exit
}

$DriveLetter = $WinPartition.DriveLetter
if (!$DriveLetter) {
    $UsedDriveLetters = (Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter }).DriveLetter.ToUpper().TrimEnd(':')

    # 68-90 = D-Z
    for ($i = 68; $i -le 90; $i++) {
        $DriveLetter = [char]$i

        if ($UsedDriveLetters -notcontains $DriveLetter) {
            "Assigning ${DriveLetter}: to basic partition..."
            Set-Partition -InputObject $WinPartition -NewDriveLetter $DriveLetter
            break
        }
    }
}

if (Test-Path -Path ${DriveLetter}:\\Windows) {
    "Copying GPU Files - this could take a while..."
    Add-VMGPUPartitionAdapterFiles -hostname $Hostname -DriveLetter $DriveLetter -GPUName $GPUName
} else {
    Write-Error "Mounted partition does not look like the Windows system partition"
}

"Dismounting Drive..."
Dismount-VHD -Path $VHD.Path

If ($state_was_running){
    "Previous State was running so starting VM..."
    Start-VM $VMName
    }

"Done..."