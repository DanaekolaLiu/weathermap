#!/bin/bash
##
# Copyright@2017 Huawei Technologies Co., Ltd. 
##

# check sk/sk
if [ -z "$AK" ]; then
    if [ -e "credentials" ]; then 
        AK=`awk -F= '/ak/{print $2}' credentials`
    else
	    echo "Cannot find ak/sk in credentials file or system environment variables"
		exit 1
    fi
fi

if [ -z "$SK" ]; then
    if [ -e "credentials" ]; then 
        SK=`awk -F= '/sk/{print $2}' credentials`
    else
        echo "Cannot find ak/sk in credentials file or system environment variables"
		exit 1
    fi
fi

# prepare microservice.yaml
echo "cse:" > microservice.yaml
echo "  credentials:" >> microservice.yaml
echo "    accessKey: $AK" >> microservice.yaml
echo "    secretKey: $SK" >> microservice.yaml
echo "    akskCustomCipher: default" >> microservice.yaml

if [ -e "httpproxy.properties" ]; then
    PROXY_ENABLED=`awk -F= '/proxy.enabled/{print $2}' httpproxy.properties`
	if [ "$PROXY_ENABLED" == "true" ]; then
        PROXY_HOST=`awk -F= '/proxy.host/{print $2}' httpproxy.properties`
        PROXY_PORT=`awk -F= '/proxy.port/{print $2}' httpproxy.properties`
        PROXY_USER=`awk -F= '/proxy.user/{print $2}' httpproxy.properties`
        PROXY_PASSWORD=`awk -F= '/proxy.password/{print $2}' httpproxy.properties`
        echo "  proxy:" >> microservice.yaml
        echo "    enable: $PROXY_ENABLED" >> microservice.yaml
        echo "    host: $PROXY_HOST" >> microservice.yaml
        echo "    port: $PROXY_PORT" >> microservice.yaml
        echo "    username: $PROXY_USER" >> microservice.yaml
        echo "    passwd: $PROXY_PASSWORD" >> m icroservice.yaml
    else
	    
    fi
fi

# cp microservice
cp microservice.yaml ./weather/
cp microservice.yaml ./weather-beta/
cp microservice.yaml ./forecast/
cp microservice.yaml ./fusionweather/
rm microservice.yaml

# ln lib with all service
if [ ! -d "./weather/lib" ]; then
   ln -s ../lib weather/lib
fi

if [ ! -d "./weather-beta/lib" ]; then
   ln -s ../lib weather-beta/lib
fi

if [ ! -d "./forecast/lib" ]; then
   ln -s ../lib forecast/lib
fi

if [ ! -d "./fusionweather/lib" ]; then
   ln -s ../lib fusionweather/lib
fi

# start all services
echo "start weather"
./weather/startup.sh

echo "start weather-beta"
./weather-beta/startup.sh

echo "start forecast"
./forecast/startup.sh

echo "start fusionweather"
./fusionweather/startup.sh

echo "start weathermapweb"
./weathermapweb/startup.sh
