# rsyncd

⚠️ This container is used for the TrueNAS SCALE app `rsyncd`. ⚠️

⚠️ While it should work, it's not intended to be used as a standalone container. ⚠️

`GitHub` - truenas/containers - https://github.com/truenas/containers/tree/master/apps/rsyncd

## Docker run

```shell
docker run -d \
    --name rsyncd \
    -v /path/of/some/files:/rsync \
    -v /path/of/some/config:/etc/rsyncd.conf \
    -p 873:873 \
    truenas/rsyncd:latest
```

Note that port 873 is the default port (Unless changed in the mounted config file) for rsyncd.
If you want to use a different port, you can change the port mapping to something like `-p 1234:873`.
(Change `873` to the port you defined in your config file)
