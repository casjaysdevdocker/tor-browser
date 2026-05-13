## 👋 Welcome to tor-browser 🚀  

tor-browser README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update tor-browser
```
  
## Install and run container
  
```shell
dockerHome="/var/lib/srv/$USER/docker/casjaysdevdocker/tor-browser/tor-browser/latest/rootfs"
mkdir -p "/var/lib/srv/$USER/docker/tor-browser/rootfs"
git clone "https://github.com/dockermgr/tor-browser" "$HOME/.local/share/CasjaysDev/dockermgr/tor-browser"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/tor-browser/rootfs/." "$dockerHome/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-tor-browser-latest \
--hostname tor-browser \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 80:80 \
casjaysdevdocker/tor-browser:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/tor-browser
    container_name: casjaysdevdocker-tor-browser
    environment:
      - TZ=America/New_York
      - HOSTNAME=tor-browser
    volumes:
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/tor-browser/tor-browser/latest/rootfs/data:/data:z"
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/tor-browser/tor-browser/latest/rootfs/config:/config:z"
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/tor-browser
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/tor-browser" "$HOME/Projects/github/casjaysdevdocker/tor-browser"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/tor-browser"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
