# opencv-docker-rpi
Dockerfile for opencv applications and python3 on raspberry pi

## Building

Resources required:

* Building this image requires @ 2GB of RAM.
* For RPI3 or less, increase swap size to @ 2GB
* Image needs @ 7GB of disk space while building
* Image size is @ 2.3 GB (should work on shrinking it more sometime)
* Takes several hours to build

```
sudo docker build -t opencv:v2 .
```

To tag and push to a private (insecure) registry
```
sudo docker tag opencv:v2 <PRIVATEREGISTRY>:80/opencv/v2
sudo docker push <PRIVATEREGISTRY:80/opencv/v2
```
