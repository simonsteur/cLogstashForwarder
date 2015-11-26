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
* **Files**: A URL to the zip file containing your Logstash-Forwarder.exe file, certs, etc.
* **ConfigFile**: A URL to the config.json file. This is kept seperate from the other files so that you can specify different config files per node. A consistency check is done with this file.

## Versions
### 1.0.0.0 
* Initial release

## Examples



## Links of interest
* https://groups.google.com/forum/#!topic/logstash-users/Fn-u0HNegv0
* https://github.com/elastic/logstash-forwarder
* https://www.elastic.co/products/logstash
