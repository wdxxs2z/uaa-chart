# UAA docker & chart repo

UAA can support openid protocol,so we can use it in k8s with oidc.

* [1.Config mysql and install mysql](#Mysql chart install)

## Mysql chart install

```
helm install -n database --namespace auth-system mysql
```

## Ingress core tls generate

The default domain is "\*.k8s.io", and the cert must be modify.

```
cat >openssl.cnf <<EOL
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.k8s.io
DNS.2 = localhost
EOL

    echo "Generating ingress key ..."
    openssl genrsa -out ingress.key 2048
    echo "Generating ingress csr ..."
    openssl req -new -key ingress.key -out ingress.csr -subj "/CN=*.k8s.io" -config openssl.cnf
    echo "Generating ingress crt ..."
    openssl x509 -req -in ingress.csr -CA $ca_crt -CAkey $ca_key -CAcreateserial -out ingress.crt -days 3650 -extensions v3_req -extfile openssl.cnf
```

## UAA and saml tls generate
```
cat >openssl.cnf <<EOL
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = uaa.k8s.io
DNS.2 = login.k8s.io
EOL

    echo "Generating uaa tls key ..."
    openssl genrsa -out tls.key 2048
    echo "Generating uaa tls csr ..."
    openssl req -new -key ingress.key -out tls.csr -subj "/CN=uaa.k8s.io,login.k8s.io" -config openssl.cnf
    echo "Generating uaa tls crt ..."
    openssl x509 -req -in tls.csr -CA $ca_crt -CAkey $ca_key -CAcreateserial -out tls.crt -days 3650 -extensions v3_req -extfile openssl.cnf
```

## Config your ingress and uaa values.

**Values:**
```
tls:
  cert: |
    xxxxxxxx
  key: |
    xxxxxxxx
```
**Treafik ingress core secret: in ingress director.**</br>
```
tls.key: xxxxxxx
cat ingress-key.pem | base64 -w0

tls.crt: xxxxxxx
cat ingress-crt.pem | base64 -w0
```

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

## Get the id_token

Notice that: always we can get access and refresh token,not inclue id_token, so first step is: get the correct id_token.Please notice the **response_type=id_token+token**

```
curl -k 'https://uaa.k8s.io/oauth/token' -i -X POST \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -u 'kubernetes:{k8s_client_secret}' \
  -d 'username=admin' \
  -d 'password={admin_password}' \
  -d 'grant_type=password' \
  -d 'token_format=opaque' \ # if you want get all token fomart, remove the line.
  -d 'response_type=id_token+token'
```

## UAA refresh not contants id_token issue.

The uaa does not support refresh toke with id_token, and even if the response_type=id_token is configured.kubectl does not have the response_type parameter when requesting refresh_token, so I have a patch.

https://github.com/cloudfoundry/uaa/blob/4.11.0/server/src/main/java/org/cloudfoundry/identity/uaa/oauth/UaaTokenServices.java#L311
```
//response_type
String response_type = request.getRequestParameters().get("response_type");
Set<String> responseType = new HashSet<>();
if (response_type != null) {
    responseType = new HashSet<String>(Arrays.asList(response_type.split(" ")));
}else if (response_type == null && client.getScope().contains("openid")) {
    responseType.add("id_token");
}

CompositeAccessToken accessToken =
            createAccessToken(
                accessTokenId,
                user.getId(),
                user,
                (claims.get(AUTH_TIME) != null) ? new Date(((Long) claims.get(AUTH_TIME)) * 1000l) : null,
                null,
                requestedScopes,
                clientId,
                audience /*request.createOAuth2Request(client).getResourceIds()*/,
                grantType,
                refreshTokenValue,
                nonce,
                additionalAuthorizationInfo,
                additionalRootClaims,
                responseType, # this is response type set.
                revocableHashSignature,
                false,
                null,  //TODO populate response types
                null,
                revocable,
                null,
                null);
```

## Config the kubeconfig

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://192.168.213.131:6443
  name: admin
- cluster:
    certificate-authority-data: xxxxx
    server: https://192.168.213.131:6443
  name: kubernetes
contexts:
- context:
    cluster: admin
    user: admin
  name: admin
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: admin
kind: Config
preferences: {}
users:
- name: admin
  user:
    as-user-extra: {}
    auth-provider:
      config:
        client-id: kubernetes
        client-secret: Y2hhbmdlbWU=
        idp-certificate-authority: /etc/kubernetes/pki/ca.crt
        idp-issuer-url: https://uaa.k8s.io/oauth/token
        id-token: xxxxx 
        refresh-token: xxxxxx
      name: oidc
```

## Access the admin-cluster role to admin

Use the kubeadm defalut operator

```
kubectl create -f user_role_bind
```

## Test the result

```
k8s@192:~$ kubectl -n kube-system get pod
NAME                                      READY     STATUS    RESTARTS   AGE
etcd-192.168.213.131                      1/1       Running   19         19d
heapster-5c448886d-hcllj                  1/1       Running   11         13d
kube-apiserver-192.168.213.131            1/1       Running   0          29m
kube-controller-manager-192.168.213.131   1/1       Running   20         19d
kube-dns-6f4fd4bdf-k8z82                  3/3       Running   54         19d
kube-flannel-ds-2jv72                     1/1       Running   20         19d
kube-flannel-ds-swrmd                     1/1       Running   21         19d
kube-flannel-ds-x6g7c                     1/1       Running   21         19d
kube-proxy-cmsfl                          1/1       Running   17         19d
kube-proxy-nn4sd                          1/1       Running   17         19d
kube-proxy-wfwgz                          1/1       Running   18         19d
kube-scheduler-192.168.213.131            1/1       Running   20         19d
kubernetes-dashboard-f596b976d-9mbv7      1/1       Running   16         19d
monitoring-grafana-65757b9656-9mh94       1/1       Running   11         13d
monitoring-influxdb-66946c9f58-42lhz      1/1       Running   11         13d
tiller-deploy-5b48764ff7-48vt5            1/1       Running   11         13d
traefik-ingress-controller-65pff          1/1       Running   0          5h
traefik-ingress-controller-f655k          1/1       Running   0          5h
```

## keycloak-proxy to dashboard

Kubernetes Dashboard is a UI to manage our Kubernetes clusters. we can use a reverse proxy with OpenID Connect to protect the dashboard.

* CloudFoundry UAA (OpenID Connect identity provider)
* keycloak-proxy (OpenID Connect reverse proxy)
* kube-apiserver (Kubernetes API server)
* Kubernetes Dashboard

### Install keycloak-proxy with helm chart

1. Please config the dashboard-proxy values

2. helm install --namespace auth-system -n proxy dashboard-proxy

### Before install the proxy,we must know that: 

1. If you want login dashboard with uaa,you should deploy the keycloak-proxy,but the keycloak-proxy has some problem: uaa has muti or array aud claim -> [clientid,...],the keycloak-proxy is string,so we must skip it.

```
https://github.com/gambol99/keycloak-proxy/blob/master/user_context.go#L43

audiences, found, err := claims.StringsClaim(claimAudience)
if err != nil || !found {
        return nil, ErrNoTokenAudience
}
audience := audiences[0]
```
2. Before,if we set --oidc-username-claim=email,email_verified claim must be in our token.but recently,email_verified claim is not required for JWT validation(https://github.com/kubernetes/kubernetes/pull/61508),if it merage to next k8s release,we can use it with uaa.Now we only use **--oidc-username-claim=user_name**

```
 - --oidc-issuer-url=https://uaa.k8s.io/oauth/token
 - --oidc-username-claim=user_name
 - --oidc-username-prefix=https://uaa.k8s.io/oauth/token#
 - --oidc-client-id=kubernetes
 - --oidc-ca-file=/etc/kubernetes/pki/ca.crt
```
3. UAA set,we must define a client,and the authorized-grant-types must have password,refresh_token,client_credentials,authorization_code.The redirect uri such as: https://kubernetes-dashboard.k8s.io

```
oauth:
  clients:
    kubernetes:
      access-token-validity: 14400
      authorities: uaa.resource
      authorized-grant-types: password,refresh_token,client_credentials,authorization_code
      id: kubernetes
      override: true
      refresh-token-validity: 1209600
      scope: openid,password.write,scim.read,scim.write,uaa.user,email,profile
      redirect-uri: https://kubernetes-dashboard.k8s.io
      secret: k8s-changeme
```
4. Config the keycloak-proxy

```
args:
  - --listen=0.0.0.0:3000
  - --discovery-url=https://uaa.k8s.io/oauth/token
  - --client-id=kubernetes
  - --client-secret=k8s-changeme
  - --redirection-url=https://kubernetes-dashboard.k8s.io
  - --enable-refresh-tokens=true
  - --encryption-key=MsVRjD36bfAxfBvHUKUjXOTPXaItDThn
  - --upstream-url=https://kubernetes-dashboard.kube-system.svc.cluster.local
  - --resources=uri=/*
  - --skip-openid-provider-tls-verify
  - --cookie-domain=kubernetes-dashboard.k8s.io
```
5. Create a test user with uaac

```
uaac token client get admin -s Y2hhbmdlbWU=

uaac user add tony@k8s.io --emails tony@k8s.io
```
6. Bind a user with role

```
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-init-tony
subjects:
- kind: User
  name: https://uaa.k8s.io/oauth/token#tony@k8s.io
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```
7 Login with uaa and verify the header token,you can view the kc-access in your cookie.

Tap the https://kubernetes-dashboard.k8s.io and redirect to the uaa login page.

![login](https://github.com/wdxxs2z/uaa-chart/blob/master/images/login.JPG)

Input your username and password,jump to the dashboard with kc-access&kc-state token.

![dashboard](https://github.com/wdxxs2z/uaa-chart/blob/master/images/dashboard.JPG)

View the token,and decode it.

![cookies](https://github.com/wdxxs2z/uaa-chart/blob/master/images/cookies.JPG)
