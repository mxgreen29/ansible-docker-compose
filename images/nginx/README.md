# NGINX in Docker

* [Dependencies](#dependencies)
* [Example of run](#example-of-run)

## Dependencies
- Config templates - each contains service description (e.g. upstream and server directives)

## Example of run
```bash
docker run --rm -it \
-p 80:8080 -p 443:8443 \
-v <path_to_ssl_crt>:/etc/ssl/nginx.crt:rw \
-v <path_to_ssl_key>:/etc/ssl/nginx.key:rw \
-v <the_first_config>:/etc/nginx/templates/<the_first_service_name>.conf.conf:rw \
#...another configs...
-v <the_last_config>:/etc/nginx/templates/<the_last_service_name>.conf.conf:rw  \
--name nginx \
<path_to_docker_image>
```