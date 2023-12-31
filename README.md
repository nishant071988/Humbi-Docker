## Description

The command run.sh executes the 4icli command to download files for CCLF,Beneficiary and Reports. It then upload/copy the files to the respective Azure storage container which is mapped on to the Azure node.

## How it works:

#### Syntax: 

run.sh arg1 arg2

arg1: source path for the config.txt and 4icli binaries. This is uploaded to the storage container which is mapped to the Azure node created with Azure Batch account

arg2: Destination path where the files will be copied.Usually a mount folder path for the Azure storage

#### Example: 

run.sh /mnt/batch/tasks/fsmounts/impilos-config1/upperline/ /mnt/batch/tasks/fsmounts/impilos-config1/upperline-data/


