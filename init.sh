#!/bin/sh 
DEMO="JBoss BPM Suite & Signavio Mortgage Demo"
AUTHORS="Steven Lawandowski, Babak Mozaffari, Eric D. Schabell"
PROJECT="git@github.com:jbossdemocentral/bpms-signavio-integration-demo.git"
PRODUCT="JBoss BPM Suite"
JBOSS_HOME=./target/jboss-eap-6.4
SERVER_DIR=$JBOSS_HOME/standalone/deployments/
SERVER_CONF=$JBOSS_HOME/standalone/configuration/
SERVER_BIN=$JBOSS_HOME/bin
SRC_DIR=./installs
SUPPORT_DIR=./support
PRJ_DIR=./projects/mortgage-demo
WEBSERVICE=jboss-mortgage-demo-ws.war
BPMS=jboss-bpmsuite-6.1.0.GA-installer.jar
EAP=jboss-eap-6.4.0-installer.jar
VERSION=6.1

# wipe screen.
clear 

echo
echo "#############################################################################"
echo "##                                                                         ##"   
echo "##  Setting up the ${DEMO}                ##"
echo "##                                                                         ##"   
echo "##                                                                         ##"   
echo "##     ####  ####   #   #      ### #   # ##### ##### #####                 ##"
echo "##     #   # #   # # # # #    #    #   #   #     #   #                     ##"
echo "##     ####  ####  #  #  #     ##  #   #   #     #   ###                   ##"
echo "##     #   # #     #     #       # #   #   #     #   #                     ##"
echo "##     ####  #     #     #    ###  ##### #####   #   #####                 ##"
echo "##                                                                         ##"   
echo "##                                                                         ##"   
echo "##  brought to you by,                                                     ##"   
echo "##                                                                         ##"   
echo "##      ${AUTHORS}              ##"
echo "##                                                                         ##"   
echo "##  ${PROJECT}     ##"
echo "##                                                                         ##"   
echo "#############################################################################"
echo

command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
	echo Product sources are present...
	echo
else
	echo Need to download $EAP package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$BPMS ] || [ -L $SRC_DIR/$BPMS ]; then
	echo Product sources are present...
	echo
else
	echo Need to download $BPMS package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

# Remove the old JBoss instance, if it exists.
if [ -x $JBOSS_HOME ]; then
	echo "  - removing existing JBoss product..."
	echo
	rm -rf $JBOSS_HOME
fi

# Run installers.
echo "JBoss EAP installer running now..."
echo
java -jar $SRC_DIR/$EAP $SUPPORT_DIR/installation-eap -variablefile $SUPPORT_DIR/installation-eap.variables

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during JBoss EAP installation!
	exit
fi

echo "JBoss BPM Suite installer running now..."
echo
java -jar $SRC_DIR/$BPMS $SUPPORT_DIR/installation-bpms -variablefile $SUPPORT_DIR/installation-bpms.variables

if [ $? -ne 0 ]; then
	echo Error occurred during $PRODUCT installation
	exit
fi

echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
cp $SUPPORT_DIR/application-roles.properties $SERVER_CONF

echo "  - setting up demo projects..."
echo
cp -r $SUPPORT_DIR/bpm-suite-demo-niogit $SERVER_BIN/.niogit

echo "Deploying web service that pulls out credit report of customer based on SSN..."
echo
cp $SUPPORT_DIR/$WEBSERVICE $SERVER_DIR

echo "  - setting up standalone.xml configuration adjustments..."
echo
cp $SUPPORT_DIR/standalone.xml $SERVER_CONF

echo "  - setup email task notification users..."
echo
cp $SUPPORT_DIR/userinfo.properties $SERVER_DIR/business-central.war/WEB-INF/classes/

echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $JBOSS_HOME/bin/standalone.sh

# Optional: uncomment this to install mock data for BPM Suite.
#
#echo - setting up mock bpm dashboard data...
#cp $SUPPORT_DIR/1000_jbpm_demo_h2.sql $SERVER_DIR/dashbuilder.war/WEB-INF/etc/sql
#echo

echo "You can now start the $PRODUCT with $SERVER_BIN/standalone.sh"
echo
echo "Login into business central at:"
echo
echo "    http://localhost:8080/business-central  (u:erics / p:bpmsuite1!)"
echo
echo "PRE-LOAD DEMO"
echo "============="
echo "To load the BPM with a set of process instances, you can run the following command"
echo "after you start JBoss BPM Suite, build and deploy the mortgage project, then you can"
echo "use the helper jar file found in the support directory as follows:"
echo 
echo "   java -jar jboss-mortgage-demo-client.jar erics bpmsuite1!" 
echo
echo "$PRODUCT $VERSION $DEMO Setup Complete."
echo

