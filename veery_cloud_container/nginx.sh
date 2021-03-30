# Install Nginx-Proxy

cd /usr/src/;
if [ $REPOSITORY = "local" ]; then
 docker pull $REPOSITORY_IPURL":5000"/"nginx-proxy:latest";
 docker tag $REPOSITORY_IPURL":5000"/"nginx-proxy:latest" "nginx-proxy:latest";
 docker rmi -f $REPOSITORY_IPURL":5000"/"nginx-proxy:latest";
elif [ $REPOSITORY = "github" ]; then
if [ ! -d "DVP-ReverseProxy" ]; then
	git clone https://github.com/DuoSoftware/DVP-ReverseProxy.git;
fi
cd DVP-ReverseProxy;
docker build -t "nginx-proxy:latest" .
fi
cd /usr/src/;
docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro -v /etc/localtime:/etc/localtime:ro --log-opt max-size=10m --restart=always --log-opt max-file=10 --name nginx nginx-proxy
