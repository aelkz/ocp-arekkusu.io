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
