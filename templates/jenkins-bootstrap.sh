#!/bin/bash
sudo mkdir ${jenkins_home}init.groovy.d/
sudo chown bitnami:bitnami ${jenkins_home}init.groovy.d/
sudo tee ${jenkins_home}init.groovy.d/managePlugins.groovy <<EOF
${groovy_manage_plugins}
EOF
sudo chown tomcat:tomcat ${jenkins_home}init.groovy.d/
sudo service bitnami restart