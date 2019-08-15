# ViZix QA Automation - Continuous Testing On Amazon

### Configuration Functional Test CoreBridgeMt/KafkaCoreBridge and Services (Cucumber) :

Example complete setup environment and execution for functional test (services and corebridge)

in order to set the suites executed you have to update the file Suites on /path/vizix_repositories/vizix-qa-automation-ci/setupAmazon/src/Suites
(i.e. for three machines)

```
CBHappyPath
CBHappyPath1,@Suite2
CBHappyPath2,@Suite3,@Suite4,@Suite5
```

```
cd /path/vizix_repositories/vizix-qa-automation-ci/setupAmazon
gradle CreateVirtualMachinesAmazon -Pimage_id=${AWS_IMAGE_ID} -Pnew_vms_number=${AWS_NEW_VMS_NUMBER} -Pinstance_type=${AWS_INSTANCE_TYPE} -Pkey_name=${AWS_KEY_NAME} -Psecurity_groups=${AWS_SECURITY_GROUPS} -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pinstance_name=${AWS_INSTANCE_NAME}
gradle WaitVmAreReady -Pnew_vms_number=${AWS_NEW_VMS_NUMBER} -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pinstance_name=${AWS_INSTANCE_NAME}
gradle GetPublicIpFromVirtualMachine -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pip_path_tmp=${LOCAL_IP_PATH_TMP} -Pinstance_name=${AWS_INSTANCE_NAME}
gradle ExecuteAutomationTestRemotly -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pip_path_tmp=${LOCAL_IP_PATH_TMP} -Pdocker_branch=${DOCKER_BRANCH} -Psetup_script_name=${SETUP_SCRIPT_NAME} -Pip_path_tmp=${LOCAL_IP_PATH_TMP} -Pbranch_automation=${BRANCH_AUTOMATION} -Pnumber_threads_cb=${NUMBER_OF_THREAD_CB} -Pautomation_compose_folder_name=${AUTOMATION_COMPOSE_FOLDER_NAME}
gradle GetJsonReports -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Plocal_path_report_json=${LOCAL_PATH_REPORT_JSON} -Pip_path_tmp=${LOCAL_IP_PATH_TMP}
cd ${LOCAL_PATH_REPORT_JSON}
for a in $(ls -1 *.tar.gz); do tar -zxvf $a; done
cd /path/vizix_repositories/vizix-qa-automation-ci/setupAmazon
gradle RemoveInstancesCreated -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pinstance_name=${AWS_INSTANCE_NAME}
```
note:

```
setupScriptCorebridgemt/setup.sh ----------> script for corebridgemt environment
setupScriptKafkacorebridge/setupkafka.sh -----> script for kafka corebridge environment
```
### Configuration Functional  Test BlockChain (Cucumber):

```
Parameters:
AWS_IMAGE_ID = Name of AWS image. Example: AWS_IMAGE_ID=ami-7d1fbb07
AWS_NEW_VMS_NUMBER = Number of servers AWS to create. It always must be 3. Example: AWS_NEW_VMS_NUMBER=3
AWS_INSTANCE_TYPE = Type of instance server AWS. Example: AWS_INSTANCE_TYPE=t2.xlarge 
AWS_KEY_NAME = Name of file .pem. Example: AWS_KEY_NAME=awsqa
AWS_SECURITY_GROUPS = Example: AWS_SECURITY_GROUPS=sg-2cbc0f52,sg-e5d4679b,sg-31970c41
LOCAL_AWS_CLI_PATH = Path where is install AWS Cli. Example: LOCAL_AWS_CLI_PATH=/usr/bin
INSTANCE_NAME = Name of server AWS. Example: INSTANCE_NAME=blockchain 
INSTANCE_REGION = Example: INSTANCE_REGION==us-east-1
LOCAL_IP_PATH_TMP = Path where will save the ips of the instances. It is a json file. Example: LOCAL_IP_PATH_TMP=/tmp/ips.json 
LOCAL_KEY_PEM_PATH = Path where is the file .pem. Example: LOCAL_KEY_PEM_PATH= /path/folder/ 
SETUP_SCRIPT_NAME = Name of script to run environment blockchain. Example: SETUP_SCRIPT_NAME=setupBlockchain.sh 
LOCAL_PATH_SMART_CONTRACT = Path file where will be saved the smartContractAddress. Example: LOCAL_PATH_SMART_CONTRACT=/tmp/smartContractAddress.txt
LOCAL_PATH_REPORT_JSON = Path where will be saved the cucumber report. Example: LOCAL_PATH_REPORT_JSON=/path/automation/reports/
GIT_USER = Username giuhub
GIT_PASS = Password giuhub
DOCKER_BRANCH =  Name of brach for repositories: services, bridges, adapter, smed. Example: DOCKER_BRANCH=develop
AUTOMATION_BRANCH = Name of branch for repository: vizix-qa-automacion. Example: AUTOMATION_BRANCH=develop 
CMD_POPDB = Command to execute a popdb. Example: CMD_POPDB=docker-compose exec -T services bash /run.sh install AutomationKafka clean -f
```

```
cd /path/git/vizix-qa-automation-ci/setupAmazon
gradle launchInstanceByTagName -Pimage_id=${AWS_IMAGE_ID} -Pnew_vms_number=${AWS_NEW_VMS_NUMBER} -Pinstance_type=${AWS_INSTANCE_TYPE} -Pkey_name=${AWS_KEY_NAME} -Psecurity_groups=${AWS_SECURITY_GROUPS} -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pinstance_name=${INSTANCE_NAME} -Pinstance_region=${INSTANCE_REGION}
gradle WaitVmAreReady -Pnew_vms_number=${AWS_NEW_VMS_NUMBER} -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pinstance_name=${INSTANCE_NAME}
gradle getIpsFromByTagName -Pinstance_name=${INSTANCE_NAME} -Pips_path_tmp=${LOCAL_IP_PATH_TMP} -Pkey_pem_path=${LOCAL_KEY_PEM_PATH}
gradle executeScriptBlockchain -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pkey_name=${AWS_KEY_NAME} -Pips_path_tmp=${LOCAL_IP_PATH_TMP} -Psetup_script_name=${SETUP_SCRIPT_NAME} -Ppath_file_smartContract=${LOCAL_PATH_SMART_CONTRACT} -Pdocker_branch=${DOCKER_BRANCH} -Pgit_user=${GIT_USER} -Pgit_password=${GIT_PASS} -Pbranch_automation=${AUTOMATION_BRANCH} -Pcmd_popdb="${CMD_POPDB}"
gradle executeTestBlockchain -Pips_path_tmp=${LOCAL_IP_PATH_TMP} -Pkey_pem_path=${LOCAL_KEY_PEM_PATH}
gradle getJsonReportBlockchain -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pip_path_tmp=${LOCAL_IP_PATH_TMP} -Plocal_path_report_json=${LOCAL_PATH_REPORT_JSON}
cd  ${LOCAL_PATH_REPORT_JSON}
for a in $(ls -1 *.tar.gz); do tar -zxvf $a; done
pwd
cd /path/git/vizix-qa-automation-ci/setupAmazon
gradle RemoveInstancesCreated -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pinstance_name=${INSTANCE_NAME}
```
### Configuration Performance Test Services (Jmeter):
```
to do
```
### Configuration Performance Test Bridges (Simulator - Java Cucumber - python):
We have to update the file Suite in order to set the category to execute (the * will be replace for space into the script)
i.e
```
BigDataVerification*-PwaitTimeSimulator=60*-PcleanThingAfteSimulator=false*-PminValue=10*-PmaxValue=10*-PincreaseAmoung=1*-PprobabilityChangeLocation=50*-PpercentageOlders=0*-PpercentageNews=100*-PnumberOfRounds=1*-PfrequencySimulation=1*-PnumberThingsSimulation=50*-PblinksPerSecond=1
```


The gradle task action on jenkins job
```
cd /path/vizix_repositories/vizix-qa-automation-ci/setupAmazon
gradle CreateVirtualMachinesAmazon -Pimage_id=${AWS_IMAGE_ID} -Pnew_vms_number=${AWS_NEW_VMS_NUMBER} -Pinstance_type=${AWS_INSTANCE_TYPE} -Pkey_name=${AWS_KEY_NAME} -Psecurity_groups=${AWS_SECURITY_GROUPS} -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pinstance_name=${AWS_INSTANCE_NAME}
gradle WaitVmAreReady -Pnew_vms_number=${AWS_NEW_VMS_NUMBER} -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pinstance_name=${AWS_INSTANCE_NAME}
gradle GetPublicIpFromVirtualMachine -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pip_path_tmp=${LOCAL_IP_PATH_TMP} -Pinstance_name=${AWS_INSTANCE_NAME}
gradle ExecuteAutomationTestRemotly -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pip_path_tmp=${LOCAL_IP_PATH_TMP} -Pdocker_branch=${DOCKER_BRANCH} -Psetup_script_name=${SETUP_SCRIPT_NAME} -Pip_path_tmp=${LOCAL_IP_PATH_TMP} -Pbranch_automation=${BRANCH_AUTOMATION} -Pnumber_threads_cb=${NUMBER_OF_THREAD_CB}
gradle GetJsonReports -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Plocal_path_report_json=${LOCAL_PATH_REPORT_JSON} -Pip_path_tmp=${LOCAL_IP_PATH_TMP}
cd ${LOCAL_PATH_REPORT_JSON}
for a in $(ls -1 *.tar.gz); do tar -zxvf $a; done
cd /path/vizix_repositories/vizix-qa-automation-ci/setupAmazon
gradle RemoveInstancesCreated -Paws_cli_path=${LOCAL_AWS_CLI_PATH} -Pkey_pem_path=${LOCAL_KEY_PEM_PATH} -Pinstance_name=${AWS_INSTANCE_NAME}
```

note:

```
performanceBridges/setupPerfomance.sh ----------> script for performance corebridge
```

The report.tar.gz contains the performance html report generated with python and the json file generated by cucumber

### Configuration Performance Test Web Ui Reports (Cucumber Selenium):
```
to do
```
### Documentation:

[Documentation Continuous Testing On Amazon (In Progress .....)](link)

### Note
Single tenant version before 6.15 use the file SuiteKafka_6.15 and the branch canary/6.15.x
Multitenancy version from 6.16 to 6.23 use the file SuiteKafka_6.16_to_6.23.txt and the branch canary/6.23.x