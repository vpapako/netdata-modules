# shellcheck shell=bash
# no need for shebang - this file is loaded from charts.d.plugin
# SPDX-License-Identifier: GPL-3.0-or-later

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
#

# if this chart is called X.chart.sh, then all functions and global variables
# must start with X_

# _update_every is a special variable - it holds the number of seconds
# between the calls of the _update() function
dcmon_update_every=1

# the priority is used to sort the charts on the dashboard
# 1 = the first chart
dcmon_priority=1

# global variables to store our collected data
# remember: they need to start with the module name

# HVAC Board (watts)
dcmon_RphaseWatts=
dcmon_SphaseWatts=
dcmon_TphaseWatts=
dcmon_RphaseKiloWattHours=
dcmon_SphaseKiloWattHours=
dcmon_TphaseKiloWattHours=

# HVAC Board (amps)
dcmon_RphaseIrms=
dcmon_SphaseIrms=
dcmon_TphaseIrms=

# Board "A" Board (watts)
dcmon_RphaseWattsA=
dcmon_SphaseWattsA=
dcmon_TphaseWattsA=
dcmon_RphaseKiloWattHoursA=
dcmon_SphaseKiloWattHoursA=
dcmon_TphaseKiloWattHoursA=

# Board "A" (amps)
dcmon_RphaseIrmsA=
dcmon_SphaseIrmsA=
dcmon_TphaseIrmsA=

# Board "B" Board (watts)
dcmon_RphaseWattsB=
dcmon_SphaseWattsB=
dcmon_TphaseWattsB=
dcmon_RphaseKiloWattHoursB=
dcmon_SphaseKiloWattHoursB=
dcmon_TphaseKiloWattHoursB=

# Board "B" (amps)
dcmon_RphaseIrmsB=
dcmon_SphaseIrmsb=
dcmon_TphaseIrmsB=


dcmon_get() {
        # do all the work to collect / calculate the values
        # for each dimension
        #
        # Remember:
        # 1. KEEP IT SIMPLE AND SHORT
        # 2. AVOID FORKS (avoid piping commands)
        # 3. AVOID CALLING TOO MANY EXTERNAL PROGRAMS
        # 4. USE LOCAL VARIABLES (global variables may overlap with other modules)

	dcmon_RphaseWatts=$(printf '%.2f' $(curl -s "http://dcmon.datacenter.uoc.gr/feed/list.json?userid=1" | jq '. [0] .value' | sed -e 's/"//g') | sed -e 's/\.//g')
        dcmon_SphaseWatts=$(printf '%.2f' $(curl -s "http://dcmon.datacenter.uoc.gr/feed/list.json?userid=1" | jq '. [1] .value' | sed -e 's/"//g') | sed -e 's/\.//g')
        dcmon_TphaseWatts=$(printf '%.2f' $(curl -s "http://dcmon.datacenter.uoc.gr/feed/list.json?userid=1" | jq '. [2] .value' | sed -e 's/"//g') | sed -e 's/\.//g')

        dcmon_RphaseIrms=$(printf '%.2f' $(curl -s "http://dcmon.datacenter.uoc.gr/feed/list.json?userid=1" | jq '. [3] .value' | sed -e 's/"//g') | sed -e 's/\.//g')
        dcmon_SphaseIrms=$(printf '%.2f' $(curl -s "http://dcmon.datacenter.uoc.gr/feed/list.json?userid=1" | jq '. [4] .value' | sed -e 's/"//g') | sed -e 's/\.//g')
        dcmon_TphaseIrms=$(printf '%.2f' $(curl -s "http://dcmon.datacenter.uoc.gr/feed/list.json?userid=1" | jq '. [5] .value' | sed -e 's/"//g') | sed -e 's/\.//g')

        # this should return:
        #  - 0 to send the data to netdata
        #  - 1 to report a failure to collect the data

        return 0
}

# _check is called once, to find out if this chart should be enabled or not
dcmon_check() {
	# this should return:
	#  - 0 to enable the chart
	#  - 1 to disable the chart

	# check if jq for accessing json data is available
        require_cmd jq || return 1
        return 0
}

# _create is called once, to create the charts
dcmon_create() {
	# create the HVAC Board (watts) chart with 3 dimensions
	cat <<EOF
CHART dcmon.hvac_board_watts '' "Energy consumption of HVAC Board" "watts" "HVAC Board" $dcmon_priority $dcmon_update_every
DIMENSION Rphase '' absolute 1 100
DIMENSION Sphase '' absolute 1 100
DIMENSION Tphase '' absolute 1 100
CHART dcmon.hvac_board_irms '' "Energy consumption of HVAC Board" "amps" "HVAC Board" $dcmon_priority $dcmon_update_every
DIMENSION Rphase '' absolute 1 100
DIMENSION Sphase '' absolute 1 100
DIMENSION Tphase '' absolute 1 100
EOF

	return 0
}

# _update is called continuously, to collect the values
dcmon_update() {
	# the first argument to this function is the microseconds since last update
	# pass this parameter to the BEGIN statement (see bellow).

	dcmon_get || return 1

	# write the result of the work.
        cat <<VALUESEOF
BEGIN dcmon.hvac_board_watts $1
SET Rphase = $dcmon_RphaseWatts
SET Sphase = $dcmon_SphaseWatts
SET Tphase = $dcmon_TphaseWatts
END
BEGIN dcmon.hvac_board_irms $1
SET Rphase = $dcmon_RphaseIrms
SET Sphase = $dcmon_SphaseIrms
SET Tphase = $dcmon_TphaseIrms
END
VALUESEOF
	return 0
}
