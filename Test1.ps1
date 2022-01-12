# Run script
# Return the status in CustomProps  
# Steen Pedersen, 2022 - Version 004
#
# ------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------
#
# Preapare some environmental variables
$g_results =''
$g_temp_status_file = $env:temp+'\EEDK_PS1_Debug.log'
# Working directory
$g_working_dir = $PSScriptRoot
$g_ISO_Date_with_time = Get-Date -format "yyyy-MM-dd HH:mm:ss"

# Parameter help description
[Parameter(AttributeValues)]
[string]$PropNo
# ------------------------------------------------------------------------------------------------

function get_path_to_agent_tools()
    {
    # Find path to McAfee Agent
    # Read information from 64 bit
    if ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -like "64*")
    {
        #64bit code here
        #Write-Output "64-bit OS"
        Add-Content  $g_temp_status_file "64-bit OS"
        $Global:g_path_to_agent = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Network Associates\ePolicy Orchestrator\Agent" -Name "Installed Path")."Installed Path"
        $Global:g_Command_maconfig = $Global:g_path_to_agent+'\..\MACONFIG.exe'
        $Global:g_Command_cmdagent = $Global:g_path_to_agent+'\..\CMDAGENT.exe'
    }
    else
    {
        #32bit code here
        #Write-Output "32-bit OS"
        Add-Content  $g_temp_status_file "32-bit OS"
        $Global:g_path_to_agent = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Network Associates\ePolicy Orchestrator\Agent" -Name "Installed Path")."Installed Path"
        $Global:g_Command_maconfig = $Global:g_path_to_agent+'\MACONFIG.exe'
        $Global:g_Command_cmdagent = $Global:g_path_to_agent+'\CMDAGENT.exe'
    }
}

function write_customprops()
    {
           param(
            [string]$Value,
            [string]$PropsNo
        )
    
    $Parms = ' -custom -prop'+$PropsNo+' "'+$Value+'"'
    
    Add-Content $g_temp_status_file "Run $Global:g_Command_maconfig $Parms"

    try {
        $process_status = Start-Process  $Global:g_Command_maconfig -ArgumentList $Parms -NoNewWindow -PassThru -Wait        
    }
    catch {
        "Error running $Global:g_Command_maconfig"
        Add-Content $g_temp_status_file "Error running $Global:g_Command_maconfig $Parms"
    }
   
    # Perform CMDAGENT.EXE -p = Collect and Send Props
    #%comspec% /c "%agent_path%\cmdagent.exe" -p
    #& $Command_cmdagent @('-p')
    Add-Content $g_temp_status_file "Run $Global:g_Command_cmdagent -p"
    try {
        $process_status = Start-Process  $Global:g_Command_cmdagent -ArgumentList '-p' -NoNewWindow -PassThru -Wait
    }
    catch {
        "Error running $Global:g_Command_cmdagent"
        Add-Content $g_temp_status_file "Error running $Global:g_Command_cmdagent -p"
    }
    
    }

function return_results_to_ePO {
    param(
        [string]$PropsNo
    )

    write_customprops -PropsNo $PropsNo -Value $Global:g_results 
    
    "Status added to "+$g_temp_status_file
    Add-Content $g_temp_status_file "$Global:g_results"

    'Results: '+$Global:g_results
    
}

function place_your_code_here_function {
    #
    # Place your code here
    # 

    # Set the value to be returned to ePO - max 255 char
    $Global:g_results = "First test"
    # Write the results to the Custom Props
    $Global:g_results = $Global:g_results +", AT: "+$g_ISO_Date_with_time

}


################
# Main section #
################
function main()
{

    # Write start time 
    Add-Content  $g_temp_status_file ($g_ISO_Date_with_time+'  Start :'+$PSCommandPath+$args)
    
    get_path_to_agent_tools

    place_your_code_here_function

    return_results_to_ePO -PropsNo 8

    #"Completed : "
    #Get-Date -format "yyyyMMdd_HHmmss"
    
}

main
