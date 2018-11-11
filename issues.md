:: jenkins

During installation of jenkins-persistent template, in a pipeline execution, the maven POD wasn't able 
to pull the jenkins-slave-maven-rhel7 image.  For this reason, you'll need to do the following configuration:

To fix, access the `host` at 192.168.0.10 and execute:

```
$ xclip -sel c < /etc/rhsm/ca/redhat-uep.pem

$ ssh 192.168.50.10
sudo vi /etc/docker/certs.d/registry.access.redhat.com/redhat-ca.crt

# paste clipboard contents
# save and quit, images will now pull OK on openshift
```

Error message:
related to pull "registry.access.redhat.com/openshift3/jenkins-slave-maven-rhel7" at POD creation.

Source:
https://github.com/minishift/minishift-centos-iso/issues/251

:: jenkins - image builder

Error from server (Forbidden): buildconfigs "gmapseta-api" is forbidden: User "system:serviceaccount:cicd-devtools:jenkins" cannot get buildconfigs in the namespace "proj-gmapseta-dev": no RBAC policy matched

ERROR: Unable to retrieve object names: selector([name=null],[labels=null],[namelist=[buildconfig/gmapseta-api]],[projectlist=null]); action failed: {reference={}, err=Error from server (Forbidden): buildconfigs "gmapseta-api" is forbidden: User "system:serviceaccount:cicd-devtools:jenkins" cannot get buildconfigs in the namespace "proj-gmapseta-dev": no RBAC policy matched
, verb=get, cmd=oc --server=https://172.30.0.1:443 --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt --namespace=proj-gmapseta-dev --token=XXXXX get buildconfig/gmapseta-api -o=name --ignore-not-found , out=, status=1}

```
oc policy add-role-to-group edit system:serviceaccounts:cicd-devtools -n proj-gmapseta-dev
oc policy add-role-to-group edit system:serviceaccounts:cicd-devtools:jenkins -n proj-gmapseta-dev
```