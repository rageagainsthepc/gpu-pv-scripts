# GPU-PV: GPU paravirtualization for Hyper-V VMs

This repository contains rearranged scripts from <https://github.com/jamesstringerparsec/Easy-GPU-PV> with the purpose of adding *GPU-PV*
to an existing VM instead of provisioning one from scratch.
Apparently *GPU-PV* is supposed to replace *RemoteFX* on Hyper-V VMs, but it's pretty much undocumented as of writing this readme.

## Prerequisites

- *Hyper-V* with *Powershell* support has to be installed

- Guest OS has to be *Windows*

- Host and guest OS versions have to match

- Windows Pro as the guest OS is recommended if one intents to use *Enhanced Session Mode*

## Usage

1. Open an admin powershell inside the scripts directory.

2. Execute driver update script:

    ```powershell
    PS> .\Update-VMGpuPartitionDriver.ps1 -VMName "My VM"
    ```

    This step has to be repeated each time the host GPU driver has been updated.

3. Execute script to add a `VMGpuPartitionAdapter`:

    ```powershell
    PS> .\Assign-VMGpuPartitionAdapter.ps1 -VMName "My VM"
    ```
