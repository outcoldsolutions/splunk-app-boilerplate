SPLUNK_IMAGE=splunk/splunk:7.1.2
APPINSPECT_IMAGE=outcoldsolutions/splunk-appinspect:1.6.0

SPLUNK_PASSWORD=splunkdev

APP=appboilerplate

.PHONY: splunk-up splunk-down splunk-logs-follow splunk-bash splunk-web splunk-refresh app-clean app-pack app-inspect

splunk-up:
	docker run \
		-d \
		--name ${APP}-splunk \
		--hostname ${APP}-splunk \
		--publish 8000:8000 \
		--publish 8088:8088 \
		--publish 8089:8089 \
		--env "SPLUNK_USER=root" \
		--env "SPLUNK_START_ARGS=--accept-license --answer-yes --seed-passwd ${SPLUNK_PASSWORD}" \
		--volume ${APP}-splunk-etc:/opt/splunk/etc \
		--volume ${APP}-splunk-var:/opt/splunk/var \
		--volume $(shell pwd)/${APP}:/${APP} \
		--volume $(shell pwd)/hack/splunk:/hack/splunk \
		--env "SPLUNK_BEFORE_START_CMD=version \$${SPLUNK_START_ARGS}" \
		--env "SPLUNK_BEFORE_START_CMD_1=cmd python -c \"import subprocess; subprocess.check_call('ln -s /${APP} /opt/splunk/etc/apps/${APP}', shell=True);\"" \
		--env "SPLUNK_BEFORE_START_CMD_2=cmd python -c \"import subprocess; subprocess.check_call('cp -fR /hack/splunk/etc /opt/splunk/', shell=True);\"" \
		--env "SPLUNK_CMD=add licenses -auth admin:${SPLUNK_PASSWORD} /hack/splunk/licenses/*.lic || true" \
		--env "SPLUNK_CMD_1=restart" \
		${SPLUNK_IMAGE}

splunk-down:
	-docker kill ${APP}-splunk
	-docker rm -v ${APP}-splunk
	-docker volume rm ${APP}-splunk-etc ${APP}-splunk-var

splunk-logs-follow:
	docker logs -f ${APP}-splunk

splunk-bash:
	docker exec -it ${APP}-splunk bash

splunk-web:
	open 'http://localhost:8000/en-US/account/insecurelogin?loginType=splunk&username=admin&password=${SPLUNK_PASSWORD}'

splunk-refresh:
	open 'http://localhost:8000/en-US/account/insecurelogin?loginType=splunk&username=admin&password=${SPLUNK_PASSWORD}&return_to=%2Fen-US%2Fdebug%2Frefresh'

app-clean:
	rm -fR "$(shell pwd)/${APP}/local/"
	rm -fR "$(shell pwd)/${APP}/metadata/local.meta"

app-pack:
	mkdir -p "$(shell pwd)/out"
	docker run \
		--volume $(shell pwd):/src \
		--workdir /src \
		--rm ${SPLUNK_IMAGE} \
		tar -cvzf out/${APP}.tar.gz ${APP}

app-inspect:
	docker run --volume $(shell pwd)/${APP}:/src/${APP} --rm ${APPINSPECT_IMAGE}


