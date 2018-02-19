#!/bin/sh

KEYPASS=Smile4now
STOREPASS=Smile4now

keytool -importkeystore -srckeystore testkeystore.p12 -srcstoretype pkcs12 -destkeystore tmac-keystore.jks -deststoretype JKS


echo "Generate server certificate and export it"
keytool -genkey -alias server-alias -keyalg RSA -keypass $KEYPASS -storepass $STOREPASS -keystore tmac-keystore.jks
keytool -export -alias server-alias -storepass $STOREPASS -file server.cer -keystore tmac-keystore.jks

echo "Create trust store"
${JAVA_HOME}/bin/keytool -import -v -trustcacerts -alias server-alias -file server.cer -keystore tmac-truststore.jks -keypass $KEYPASS -storepass $STOREPASS