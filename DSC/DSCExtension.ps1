Configuration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName xPSDesiredStateConfiguration
Import-DscResource -ModuleName xSystemSecurity

Node $nodeName
  {
	  #Install the IIS Role 
    WindowsFeature IIS 
    { 
      Ensure = “Present” 
      Name = “Web-Server” 
    } 
	  #Install ASP.NET 4.5 
    WindowsFeature ASP 
    { 
      Ensure = “Present” 
      Name = “Web-Asp-Net45” 
    } 
	#Enable IIS Basic Auth
	  WindowsFeature BasicAuthentication
    {
      Name = "Web-Basic-Auth"
      Ensure = "Present"
    }
    #Install IIS Management Tools
	  WindowsFeature IISManagementTools
	  {
		  Name = "Web-Mgmt-Tools"
		  Ensure = "Present"
		  IncludeAllSubFeature = $True
	  }

	  #Create home page
        File CreateFile 
	  {
            DestinationPath = 'C:\inetpub\wwwroot\index.html'
            Ensure = "Present"
            Contents = '<html><h1>Please Give Me A Job Offer Steve! :)</h1></html>'
			DependsOn = "[WindowsFeature]IIS"
        }
		#Delete iisstart
        File DeleteIISstart.htm
	  {
            DestinationPath = 'C:\inetpub\wwwroot\iisstart.htm'
            Ensure = "Absent"
  			DependsOn = "[WindowsFeature]IIS"
        }
		File DeleteIISstart.png
	  {
            DestinationPath = 'C:\inetpub\wwwroot\iisstart.png'
            Ensure = "Absent"
  			DependsOn = "[WindowsFeature]IIS"
        }
	 xIEEsc DisableIEEscAdmin
	 {
		IsEnabled = $false
		UserRole = 	"Administrators"
	 }
	 xIEEsc DisableIEEscUsers
	 {
		 IsEnabled = $false
		 UserRole = "Users"
	 }
	# Dependency AGent install
	# Download and install the Dependency Agent
    xRemoteFile DAPackage 
    {
        Uri = "https://aka.ms/dependencyagentwindows"
        DestinationPath = "C:\InstallDependencyAgent-Windows.exe"
    }

    xPackage DA
    {
        Ensure="Present"
        Name = "Dependency Agent"
        Path = "C:\InstallDependencyAgent-Windows.exe"
        Arguments = '/S'
        ProductId = ""
        InstalledCheckRegKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DependencyAgent"
        InstalledCheckRegValueName = "DisplayName"
        InstalledCheckRegValueData = "Dependency Agent"
    } 
}
}