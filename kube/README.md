# kubectl
## Interactive Bash Shell
Lauth CLI
```shell
$ kubectl --namespace=lauth-testing exec --stdin --tty deployment.apps/cli -- /bin/bash
lauth@cli-6b56c9569b-b8d6h:~/cli$ pwd
/lauth/cli

lauth@cli-6b56c9569b-b8d6h:~/cli$ env | grep LAUTH
LAUTH_API_ROOT_PASSWORD=!none
LAUTH_API_ROOT_USER=root

lauth@cli-6b56c9569b-b8d6h:~/cli$ ./bin/lauth --user=$LAUTH_API_ROOT_USER --password=$LAUTH_API_ROOT_PASSWORD --route=http://api:9292 initconfig
create:client
create:institution
create:network
create:user
delete:client
delete:institution
delete:network
delete:user
list:clients
list:institutions
list:networks
list:users
read:client
read:institution
read:network
read:user
update:client
update:institution
update:network
update:user
Configuration file '/lauth/.lauth.rc' written.

lauth@cli-6b56c9569b-b8d6h:~/cli$ ./bin/lauth list users
root,User
```
## Port Mapping
Lauth API
```shell
$ kubectl --namespace=lauth-testing port-forward service/api 9292
Forwarding from 127.0.0.1:9292 -> 9292
Forwarding from [::1]:9292 -> 9292
```
Prometheus
```shell
$ kubectl --namespace=lauth-monitor port-forward service/prometheus-server 9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
```
## Deployment
Configure kubectl to use the deployment namespace.
```shell
$ kubectl config use lauth-testing        
Switched to context "lauth-testing".
```
Create a directory using the deployment namespace (if it doesn't already exist).
```shell
$ pwd
 /Users/foo/.../bar/mlibrary/lauth/kube
 
$ mkdir lauth-testing
```
Change directory to the deployment namespace directory making it your present working directory.
```shell
$ cd lauth-testing

$ pwd
 /Users/foo/.../bar/mlibrary/lauth/kube/lauth-testing
```
Create the database setup configuration map by executing create-db-setup-configmap script.
```shell
$ cat ../bin/create-db-setup-configmap 
#!/bin/sh

kubectl create configmap db-setup --from-file=../../db

$ ../bin/create-db-setup-configmap
```
Execute the yml-envsubst script.
```shell
$ ../bin/yml-envsubst
pwd: /Users/foo/.../bar/mlibrary/lauth/kube/lauth-example
script: ../bin/yml-envsubst
script dirname: ../bin
namespace: lauth-testing
envsubst < ../templates/lauth-secret.yml > lauth-secret.yml
envsubst < ../templates/cli-deploy.yml > cli-deploy.yml
envsubst < ../templates/db-pvc.yml > db-pvc.yml
envsubst < ../templates/db-deploy.yml > db-deploy.yml
envsubst < ../templates/db-svc.yml > db-svc.yml
envsubst < ../templates/db-migrate-job.yml > db-migrate-job.yml
envsubst < ../templates/api-deploy.yml > api-deploy.yml
envsubst < ../templates/db-setup-job.yml > db-setup-job.yml
envsubst < ../templates/api-svc.yml > api-svc.yml

$ ls -1
api-deploy.yml
api-svc.yml
cli-deploy.yml
db-deploy.yml
db-migrate-job.yml
db-pvc.yml
db-setup-job.yml
db-svc.yml
lauth-secret.yml
```
Edit the lauth-secret.yml file and fill in the stringData fields.
```shell
$ cat lauth-secret.yml
apiVersion: v1
kind: Secret
metadata:
  labels:
    app: lauth
  name: lauth-secret
  namespace: lauth-example
type: Opaque
stringData:
  api_root_user: ""
  api_root_password: ""
  db_root_password: ""
  db_database: ""
  db_user: ""
  db_password: ""

$ vi lauth-secret.yml

$ cat lauth-secret.yml
apiVersion: v1
kind: Secret
metadata:
  labels:
    app: lauth
  name: lauth-secret
  namespace: lauth-example
type: Opaque
stringData:
  api_root_user: "root"
  api_root_password: "!none"
  db_root_password: "lqsym"
  db_database: "lauth"
  db_user: "lauth"
  db_password: "htual"
```
Apply the yaml files in the following order.
```shell
$ kubectl apply --filename lauth-secret.yml
$ kubectl apply --filename db-pvc.yml
$ kubectl apply --filename db-svc.yml
$ kubectl apply --filename db-deploy.yml
```
Pause here to allow the database some time to come up.
```shell
$ kubectl apply --filename db-setup-job.yml
$ kubectl apply --filename db-migrate-job.yml
$ kubectl apply --filename api-svc.yml
$ kubectl apply --filename api-deploy.yml
$ kubectl apply --filename cli-deploy.yml
```
Execute an interactive shell session in the cli pod.
```shell
$ kubectl get all
NAME                       READY   STATUS      RESTARTS   AGE
pod/api-5c76698746-bmg4k   1/1     Running     0          8m45s
pod/cli-6b56c9569b-b8d6h   1/1     Running     0          8m31s
pod/db-66794ff8f6-rx5d6    1/1     Running     0          14m
pod/db-migrate-4czkm       0/1     Completed   0          8m57s
pod/db-setup-7flwq         0/1     Completed   0          9m16s

NAME          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/api   ClusterIP   None         <none>        9292/TCP   8m39s
service/db    ClusterIP   None         <none>        3306/TCP   10m

NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/api   1/1     1            1           8m45s
deployment.apps/cli   1/1     1            1           8m31s
deployment.apps/db    1/1     1            1           14m

NAME                             DESIRED   CURRENT   READY   AGE
replicaset.apps/api-5c76698746   1         1         1       8m45s
replicaset.apps/cli-6b56c9569b   1         1         1       8m31s
replicaset.apps/db-66794ff8f6    1         1         1       14m

NAME                   COMPLETIONS   DURATION   AGE
job.batch/db-migrate   1/1           5s         8m57s
job.batch/db-setup     1/1           5s         9m16s

$ kubectl --namespace=lauth-testing exec --stdin --tty deployment.apps/cli -- /bin/bash
lauth@cli-6b56c9569b-b8d6h:~/cli$ pwd
/lauth/cli
```
Run the lauth initconfig command.
```shell
lauth@cli-6b56c9569b-b8d6h:~/cli$ env | grep LAUTH
LAUTH_API_ROOT_PASSWORD=!none
LAUTH_API_ROOT_USER=root

lauth@cli-6b56c9569b-b8d6h:~/cli$ ./bin/lauth --user=$LAUTH_API_ROOT_USER --password=$LAUTH_API_ROOT_PASSWORD --route=http://api:9292 initconfig
create:client
create:institution
create:network
create:user
delete:client
delete:institution
delete:network
delete:user
list:clients
list:institutions
list:networks
list:users
read:client
read:institution
read:network
read:user
update:client
update:institution
update:network
update:user
Configuration file '/lauth/.lauth.rc' written.

lauth@cli-6b56c9569b-b8d6h:~/cli$ cat ~/.lauth.rc 
---
:v: false
:h: false
:help: false
:r: http://api:9292
:s: comma
:u: root
:p: "!none"
commands:
  :_doc: {}
  :create:
    commands:
      :client: {}
      :institution: {}
      :network: {}
      :user: {}
  :delete:
    commands:
      :client: {}
      :institution: {}
      :network: {}
      :user: {}
  :list:
    commands:
      :clients: {}
      :institutions: {}
      :networks: {}
      :users: {}
  :read:
    commands:
      :client: {}
      :institution: {}
      :network: {}
      :user: {}
  :update:
    commands:
      :client: {}
      :institution: {}
      :network: {}
      :user: {}
```
List the users.      
```shell
lauth@cli-6b56c9569b-b8d6h:~/cli$ ./bin/lauth list users
root,User
```
