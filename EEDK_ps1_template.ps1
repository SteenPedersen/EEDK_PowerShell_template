# Run script
# Return the status in CustomProps  
# Steen Pedersen, 2022 - Version 004
#
# ------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------
#
# Preapare some environmental variables
$g_results =''
$g_temp_status_file = $env:temp+'\scriptflow.log'
$g_working_dir = $PSScriptRoot
$g_ISO_Date_with_time = Get-Date -format "yyyyMMdd_HHmmss"
# ------------------------------------------------------------------------------------------------