#!/bin/bash

DIR="$( cd "$(dirname "$0")" ; pwd -P )"
VERSION=3.4.3.Final
DISTDIR="$DIR/../pontus-dist/opt/pontus/pontus-keycloak";
TARFILE=$DIR/distribution/server-dist/target/keycloak-${VERSION}.tar.gz

CURDIR=`pwd`
cd $DIR

echo DIR is $DIR
echo TARFILE is $TARFILE

if [[ ! -f "${TARFILE}" ]]; then
  echo REBUILDING $TARFILE
  env MAVEN_OPTS="-Xmx2g" mvn install -DskipTests -Pdistribution -e 
fi

if [[ ! -d $DISTDIR ]]; then
  mkdir -p $DISTDIR
fi

cd $DISTDIR
rm -rf *
tar xvfz $TARFILE
ln -s keycloak-$VERSION current
sed -i 's/jboss.http.port:8080/jboss.http.port:8081/g'  current/standalone/configuration/standalone.xml
sed -i 's/jboss.https.port:8443/jboss.https.port:15005/g'  current/standalone/configuration/standalone.xml
sed -i 's|keystore.*|keystore path="/etc/pki/java/localhost.jks"  keystore-password="pa55word" alias="localhost" key-password="pa55word"/>|g' current/standalone/configuration/standalone.xml
current/bin/standalone.sh -Dkeycloak.migration.action=import -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=${DIR}/keycloak.export.json -Dkeycloak.migration.strategy=OVERWRITE_EXISTING&
KCPID=$!
sleep 40
pkill -15 -P $KCPID
wait 
sed -i 's/jboss.https.port:15005/jboss.https.port:5005/g'  current/standalone/configuration/standalone.xml
cd $CURDIR
