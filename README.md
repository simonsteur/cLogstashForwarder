# cLogstashForwarder
Powershell DSC module for configuring Logstashforwarder. 

This DSC Resource can be used to configure the logstash forwarder agent on windows servers/clients to send logs to logstash.
Note that this resource should only be used to distribute your compiled logstashforwarder.exe + related files to your servers. It does not do the complete setup for you.

have a look at the links under the "Links of Interest" header to get some more information about how to compile, etc. 

## Resources
* cLogstashForwarder

## Dependencies
This resource requires you to use nssm. https://nssm.cc/

## CLogStashForwarder
* **Ensure**: If the LogStashForwarder service should be Present or Absent.
* **State**: The state of the service, Running or Stopped.
* **StartupType**: How the service should start at boot: Automatic, Disabled or Manual.
* **NSSMDIR**: Point this to the directory where you either already have nssm.exe or where you want to place it. 
* **NSSMURL**: Specify a URL where to download the nssm.exe file from if not present on the server.
* **Files**: A UwaRL to the zip file containing your Logstash-Forrder.exe file, certs, etc. This has to be a .zip file!
* **ConfigFile**: A URL to the config.json file. This is kept seperate from the other files so that you can specify different config files per node. A consistency check is done with this file.

## Versions
### 1.0.0.0 
* Initial release

## Examples
This configuration example will place all the required files on the server, install the logstash forwarder as a service using nssm. It will also make sure that the service is always running and starts up automaticly. The configfile specified will be checked for consistency. 

```powershell
Configuration LogstashForwarderDeploy
{

Import-DSCResource -ModuleName CLogStashForwarder

Node 'NodeName'
  {
 	Ensure = "Present"
	State = "Running"
	StartupType = "Automatic"
	NSSMDir = "C:\apps\nssm\"
	NSSMURL = "https://url-to-nssm.exe"
	Files = "https://url-to-logstashforwarder-files.zip"
	ConfigFile = "https://url-to-config.json"
  }

}
```
## Links of interest
* https://groups.google.com/forum/#!topic/logstash-users/Fn-u0HNegv0
* https://github.com/elastic/logstash-forwarder
* https://www.elastic.co/products/logstash
