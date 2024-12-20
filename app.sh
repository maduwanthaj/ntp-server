#!/bin/sh

# define paths to the chrony configuration and drift files
CONFIG_FILE="/etc/chrony/chrony.conf"
DRIFT_FILE="/var/lib/chrony/chrony.drift"


# change ownership of the chrony.drift file
[ -f "${DRIFT_FILE}" ] && chown chrony:chrony "${DRIFT_FILE}"


# set the log level and corresponding message
case "${LOG_LEVEL}" in
	1)	log_message="warning" ;;
	2)	log_message="non-fatal error" ;;
	3)	log_message="fatal error" ;;
	*)	log_message="informational"; LOG_LEVEL=0 ;;
esac

# log the configured log level with a timestamp
echo "$(date -u "+%Y-%m-%dT%TZ") Log level set to value ${LOG_LEVEL} (${log_message})"


# populate the chrony.conf file with configuration settings
cat <<- EOF > "${CONFIG_FILE}"
	# chronyd configuration file

	# define the NTP source configuration based on available environment variables (NTP_POOL, NTP_SERVER, ENABLE_NTS)
	# if neither NTP_POOL nor NTP_SERVER is provided, fallback to the default pool "pool.ntp.org iburst"
	# if NTS (Network Time Security) is enabled, include the "nts" option with the server/pool configurations.
	$(if [ -z "${NTP_POOL}" ] && [ -z "${NTP_SERVER}" ]; then
		echo "pool pool.ntp.org iburst"
	elif [ "${ENABLE_NTS:-false}" = "true" ]; then
		[ -n "${NTP_POOL}" ] && echo "pool ${NTP_POOL} iburst nts"
		[ -n "${NTP_SERVER}" ] && echo "${NTP_SERVER}" | tr ',' '\n' | sed 's/^/server /;s/$/ iburst nts/'
	else
		[ -n "${NTP_POOL}" ] && echo "pool ${NTP_POOL} iburst"
		[ -n "${NTP_SERVER}" ] && echo "${NTP_SERVER}" | tr ',' '\n' | sed 's/^/server /;s/$/ iburst/'
	fi)

	# apply a clock correction if the offset exceeds 0.1 seconds, up to 3 times after startup
	makestep 0.1 3

	# specify the drift file to store system clock drift data
	driftfile /var/lib/chrony/chrony.drift
	
	# disable the command port as a security measure
	cmdport 0
	
	# specify NTP clients that are allowed to access the server
	$({ [ -n "${NTP_CLIENT_ALLOW}" ] && echo "${NTP_CLIENT_ALLOW}" | tr ',' '\n' | sed 's/^/allow /'; } || echo "allow all" )

	# specify NTP clients that are denied access to the server (optional)
	$({ [ -n "${NTP_CLIENT_DENY}" ] && echo "${NTP_CLIENT_DENY}" | tr ',' '\n' | sed 's/^/deny /'; } || echo "# deny none") 
EOF


# start chronyd in the foreground as the chrony user, using the specified log level
exec chronyd -u chrony -d -x -L "${LOG_LEVEL}"