# Name: registry-route
# Description: Create an edge terminated route for the OpenShift registry
# URL: https://docs.okd.io/latest/install_config/registry/securing_and_exposing_registry.html

# guest root user
user=root
# openshift registry route suffix
suffix=apps.arekkusu.io

echo  -- "Create secret directory"
mkdir -p /var/lib/origin/secrets
chown $user /var/lib/origin/secrets

echo  -- "Creating server cert"
/usr/bin/oc adm ca create-server-cert --signer-cert=/etc/origin/master/ca.crt --signer-key=/etc/origin/master/ca.key --signer-serial=/etc/origin/master/ca.serial.txt --hostnames='registry-default.${suffix},registry-default.${suffix}:443,registry.default.svc.cluster.local,172.30.1.1' --cert=/var/lib/origin/secrets/registry.crt --key=/var/lib/origin/secrets/registry.key

echo  -- "Creating the secret for the registry certificates"
/usr/bin/oc create secret generic registry-certificates --from-file=/var/lib/origin/secrets/registry.crt --from-file=/var/lib/origin/secrets/registry.key -n default

echo  -- "Adding the secret to the registry pod’s service accounts (including the default service account)"
/usr/bin/oc secrets link registry registry-certificates -n default --as system:admin
/usr/bin/oc secrets link default registry-certificates -n default --as system:admin

echo  -- "Pausing the docker-registry service"
/usr/bin/oc rollout pause dc/docker-registry -n default --as system:admin

echo  -- "Adding the secret volume to the registry deployment configuration"
/usr/bin/oc set volume dc/docker-registry --add --type=secret --secret-name=registry-certificates -m /etc/secrets -n default --as system:admin

echo  -- "Enabling TLS by adding the environment variables to the registry deployment configuration"
/usr/bin/oc set env dc/docker-registry REGISTRY_HTTP_TLS_CERTIFICATE=/etc/secrets/registry.crt REGISTRY_HTTP_TLS_KEY=/etc/secrets/registry.key -n default --as system:admin

echo  -- "Updating the scheme used for the registry’s liveness probe from HTTP to HTTPS"
/usr/bin/oc patch dc/docker-registry -p '{"spec": {"template": {"spec": {"containers":[{"name":"registry","livenessProbe":  {"httpGet": {"scheme":"HTTPS"}}}]}}}}' -n default --as system:admin

echo  -- "Updating the scheme used for the registry’s readiness probe from HTTP to HTTPS"
/usr/bin/oc patch dc/docker-registry -p '{"spec": {"template": {"spec": {"containers":[{"name":"registry","readinessProbe":  {"httpGet": {"scheme":"HTTPS"}}}]}}}}' -n default --as system:admin

echo  -- "Resuming the docker-registry service"
/usr/bin/oc rollout resume dc/docker-registry -n default --as system:admin

echo  -- "Creating passthrough route for docker-registry service"
/usr/bin/oc create route passthrough --service=docker-registry --hostname=registry-default.${suffix} -n default --as system:admin

echo  -- "Creating docker certs.d directory"
mkdir -p /etc/docker/certs.d/registry-default.${suffix}
chown $user /etc/docker/certs.d/registry-default.${suffix}

echo  -- "copying ca.crt from master into certs.d directory"
#docker cp origin:/etc/origin/master/ca.crt /etc/docker/certs.d/registry-default.${suffix}/ca.crt
cp /etc/origin/master/ca.crt /etc/docker/certs.d/registry-default.${suffix}/ca.crt

echo  -- Add-on registry-route created a new docker-registry route. Please run following commands to login to the OpenShift docker registry:
echo
echo  -- $ docker login -u developer -p `oc whoami -t` registry-default.${suffix}
echo