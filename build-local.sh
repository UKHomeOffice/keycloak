#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION=3.3.0.Final
DISTDIR="$DIR/../pontus-dist/opt/pontus/pontus-keycloak";
TARFILE=$DIR/distribution/server-dist/target/keycloak-${VERSION}.tar.gz

CURDIR=`pwd`
cd $DIR

echo DIR is $DIR
echo TARFILE is $TARFILE

if [[ ! -f $TARFILE ]]; then
  MAVEN_OPTS="-Xmx2g" mvn install -DskipTests -Pdistribution -e 
fi

if [[ ! -d $DISTDIR ]]; then
  mkdir -p $DISTDIR
fi

cd $DISTDIR
rm -rf *
tar xvfz $TARFILE
ln -s keycloak-$VERSION current

cd $CURDIR
