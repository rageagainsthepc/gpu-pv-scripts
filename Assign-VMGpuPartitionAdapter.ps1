Param (
    [Parameter(Mandatory=$true)]
    [string] $VMName
)

function Assign-VMGPUPartitionAdapter {
    param(
        [string] $VMName,
        [string] $GPUName = AUTO,
        [decimal] $GPUResourceAllocationPercentage = 100
    )

    if ($GPUName -eq "AUTO") {
        Add-VMGpuPartitionAdapter -VMName $VMName
    }
    else {
        $PartitionableGPUList = Get-WmiObject -Class "Msvm_PartitionableGpu" -ComputerName $env:COMPUTERNAME -Namespace "ROOT\virtualization\v2" 
        $DeviceID = ((Get-WmiObject Win32_PNPSignedDriver | where {($_.Devicename -eq "$GPUNAME")}).hardwareid).split('\')[1]
        $DevicePathName = ($PartitionableGPUList | Where-Object name -like "*$DeviceID*").Name
        Add-VMGpuPartitionAdapter -VMName $VMName -InstancePath $DevicePathName
    }

    [float]$devider = [math]::round($(100 / $GPUResourceAllocationPercentage),2)

    Set-VMGpuPartitionAdapter -VMName $VMName -MinPartitionVRAM ([math]::round($(1000000000 / $devider))) -MaxPartitionVRAM ([math]::round($(1000000000 / $devider))) -OptimalPartitionVRAM ([math]::round($(1000000000 / $devider)))
    Set-VMGPUPartitionAdapter -VMName $VMName -MinPartitionEncode ([math]::round($(18446744073709551615 / $devider))) -MaxPartitionEncode ([math]::round($(18446744073709551615 / $devider))) -OptimalPartitionEncode ([math]::round($(18446744073709551615 / $devider)))
    Set-VMGpuPartitionAdapter -VMName $VMName -MinPartitionDecode ([math]::round($(1000000000 / $devider))) -MaxPartitionDecode ([math]::round($(1000000000 / $devider))) -OptimalPartitionDecode ([math]::round($(1000000000 / $devider)))
    Set-VMGpuPartitionAdapter -VMName $VMName -MinPartitionCompute ([math]::round($(1000000000 / $devider))) -MaxPartitionCompute ([math]::round($(1000000000 / $devider))) -OptimalPartitionCompute ([math]::round($(1000000000 / $devider)))
}

Set-VM -VMName $VMName -GuestControlledCacheTypes $true -LowMemoryMappedIoSpace 3Gb -HighMemoryMappedIoSpace 32Gb

$CPUManufacturer = Get-CimInstance -ClassName Win32_Processor | Foreach-Object Manufacturer
$BuildVer = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
if (($BuildVer.CurrentBuild -gt 22000) -and (-not ($CPUManufacturer -eq "AuthenticAMD"))) {
    Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
}

Assign-VMGPUPartitionAdapter -VMName $VMName