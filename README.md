# UAA docker & chart repo

UAA can support openid protocol,so we can use it in k8s with oidc.

## Mysql chart install

```
helm install -n database --namespace auth-system mysql
```

## Ingress install

The default domain is "\*.k8s.io", and the cert must be modify.

## UAA chart install

```
helm install -n auth --namespace auth-system uaa
```

## Configuration

| Parameter               | Description                            | Default                   |
| ----------------------- | -------------------------------------- | ------------------------- |
| `image.repository`|This is uaa images|wdxxsez/uaa-chart|
| `image.tag`|The image tag|4.10.0|
| `image.pullPolicy`|This is image pull policy|Always|
| `replicaCount`|The replicaCount set|1|
| `resources.limits.cpu`|Resource limit cpu set|200m|
| `resources.limits.memory`|Resource limit memory set|1024Mi|
| `resources.requests.cpu`|Resource request cpu|200m|
| `resources.requests.memory`|Resource request memory|1024Mi|
| `externalUrl`|External Url is expose the domain|k8s.io|
| `tomcat.catalinaOpts`|Tomcat catalina Ops set|-Xmx768m -XX:MaxPermSize=256m|
| `datasource.host`|Uaa mysql datasource host|database-mysql|
| `datasource.port`|Uaa mysql datasource port|3306|
| `datasource.dbname`|Uaa mysql datasource dbname|uaa|
| `datasource.username`|Uaa mysql database username|admin|
| `datasource.password`|Uaa mysql database password|changeme|
| `ingress.enabled`|Enabled the ingress|true|
| `ingress.tls`|TLS config,please see the value file|xxxxxx|
| `ingress.url`|Ingress url set|uaa.k8s.io|
| `uaa.ssl.enabled`|The uaa ssl enabled|true|
| `uaa.ssl.cacert`|The CA cert content|xxxxxx|
| `uaa.ssl.cakey`|The CA key content|xxxxxx|
| `uaa.ssl.tls.cert`|The uaa.k8s.io or login.k8s.io cert|xxxxxx|
| `uaa.ssl.tls.key`|The client key content|xxxxxx|
