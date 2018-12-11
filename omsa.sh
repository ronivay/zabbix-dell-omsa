#!/bin/bash

OMSABIN="/opt/dell/srvadmin/bin/omreport"

function PhysicalDisksDiscovery {

for CONTROLLER in "$($OMSABIN storage controller | grep ^ID | awk '{print $3}')"
do

IFS=$'\n' read -r -d '' -a DISKS <<< "$($OMSABIN storage pdisk controller=$CONTROLLER | grep ^ID | awk '{print $3}')"

for DISK in "${DISKS[@]}"; do
  RESULT+=$(echo -e "\n{\n\"{#PDISK}\": \"$DISK\",\n\"{#CONTROLLER}\": \"$CONTROLLER\" \n},")
done

done
echo -e "{"
echo -e "\"data\":["

JSON=$(echo "$RESULT" | sed '$s/,$//')

echo "$JSON"
echo "]}"


}

function PhysicalDiskStatus {

PDISK="$1"
CONTROLLER="$2"

case "$3" in
	status)
	echo "$($OMSABIN storage pdisk controller=$CONTROLLER pdisk=$PDISK | grep ^State | awk '{print $3}')"
	;;
	pfailure)
	echo "$($OMSABIN storage pdisk controller=$CONTROLLER pdisk=$PDISK | grep "^Failure Predicted" | awk '{print $4}')"
	;;
esac

}

function VirtualDiskDiscovery {

for CONTROLLER in "$($OMSABIN storage controller | grep ^ID | awk '{print $3}')"
do

IFS=$'\n' read -r -d '' -a VDISKS <<< "$($OMSABIN storage vdisk controller=$CONTROLLER| grep '^ID' |  awk '{print $3}')"

for VDISK in "${VDISKS[@]}"
do
  RESULT+=$(echo -e "\n{\n\"{#VDISK}\": \"$VDISK\",\n\"{#CONTROLLER}\": \"$CONTROLLER\" \n},")
done

done

echo -e "{"
echo -e "\"data\":["

JSON=$(echo "$RESULT" | sed '$s/,$//')

echo "$JSON"
echo "]}"

}

function VirtualDiskStatus {

VDISK="$1"
CONTROLLER="$2"

case "$3" in 
	status)
	echo "$($OMSABIN storage vdisk controller=$CONTROLLER vdisk=$VDISK| grep ^Status | awk '{print $3}')"
	;;
	raid)
	echo "$($OMSABIN storage vdisk controller=$CONTROLLER vdisk=$VDISK | grep ^Layout | awk '{print $3}')"
	;;
	size)
	echo "$($OMSABIN storage vdisk controller=$CONTROLLER vdisk=$VDISK | grep ^Size | awk '{print $3}')"
	;;
	*)
	exit
	;;
esac

}


function FanDiscovery {

IFS=$'\n' read -r -d '' -a FANS <<< "$($OMSABIN chassis fans | grep ^Index | awk '{print $3}')"

for FAN in "${FANS[@]}"; do
  RESULT+=$(echo -e "\n{\n\"{#FAN}\": \"$FAN\"\n},")
done

echo -e "{"
echo -e "\"data\":["

JSON=$(echo "$RESULT" | sed '$s/,$//')

echo "$JSON"
echo "]}"

}

function FanStatus {

FAN="$1"
ITEM="$2"

[[ "$ITEM" == "rpm" ]] && REPLY="$($OMSABIN chassis fans index=$FAN | grep ^Reading | awk '{print $3}')"

[[ "$ITEM" == "status" ]] && REPLY="$($OMSABIN chassis fans index=$FAN | grep ^Status | awk '{print $3}')"

echo "$REPLY"

}

function PsuDiscovery {

IFS=$'\n' read -r -d '' -a PSUS <<< "$($OMSABIN chassis pwrsupplies | grep ^Index | awk '{print $3}')"

for PSU in "${PSUS[@]}"; do
  RESULT+=$(echo -e "\n{\n\"{#PSU}\": \"$PSU\"\n},")
done

echo -e "{"
echo -e "\"data\":["

JSON=$(echo "$RESULT" | sed '$s/,$//')

echo "$JSON"
echo "]}"

}

function PsuStatus {

PSU="$1"

echo "$($OMSABIN chassis pwrsupplies | grep -A1 "^Index.*$PSU" | tail -1 |  awk '{print $3}')"

}

function NicDiscovery {

IFS=$'\n' read -r -d '' -a NICS <<< "$($OMSABIN chassis nics | sed -n "/Physical NIC Interface/, /Team Interface/ p" | grep "^Interface Name" | awk '{print $4}')"

for NIC in "${NICS[@]}"; do
  RESULT+=$(echo -e "\n{\n\"{#NIC}\": \"$NIC\"\n},")
done

echo -e "{"
echo -e "\"data\":["

JSON=$(echo "$RESULT" | sed '$s/,$//')

echo "$JSON"
echo "]}"

}

function NicStatus {

NIC="$1"

STATUS="$($OMSABIN chassis nics | grep -A4 "^Interface Name.*$NIC" | grep "^Connection Status" | awk '{print $4}')"

echo "$STATUS"

}

function TempDiscovery {

IFS=$'\n' read -r -d '' -a TEMPS <<< "$($OMSABIN chassis temps | grep "^Index\|^Probe Name" | cut -d':' -f2 | sed 's/^ //' | paste - -)"

for TEMP in "${TEMPS[@]}"
do
  read -a TEMP_SPLIT <<< "$TEMP"

  INDEX=${TEMP_SPLIT[0]}
  TEMP=${TEMP_SPLIT[@]:1}

RESULT+=$(echo -e "\n{\n\"{#TEMP}\": \"$TEMP\",\n\"{#TEMPINDEX}\": \"$INDEX\" \n},")
done

echo -e "{"
echo -e "\"data\":["

JSON=$(echo "$RESULT" | sed '$s/,$//')

echo "$JSON"
echo "]}"

}

function TempStatus {

INDEX="$1"

STATUS="$($OMSABIN chassis temps index=$INDEX | grep ^Reading | awk '{print $3}')"

echo "$STATUS"

}

function SystemModel {

STATUS="$($OMSABIN chassis info | grep "^Chassis Model" | cut -d':' -f2 | sed 's/^ //')"
echo "$STATUS"

}

function SystemServiceTag {

STATUS="$($OMSABIN chassis info | grep "^Chassis Service Tag" | cut -d':' -f2 | sed 's/^ //')"
echo "$STATUS"

}

function SystemStatus {

if [[ -z "$($OMSABIN chassis | grep ":" | grep -v SEVERITY | cut -d':' -f1 | grep -v Ok)" ]]; then
	echo "Ok"
else
	echo "Failure"
fi

}

function SystemBiosVersion {

echo "$($OMSABIN chassis bios | grep '^Version' | awk '{print $3}')"

}

function SystemIdracVersion {

IDRACVERSION="$($OMSABIN chassis info | grep -i ^idrac | awk '{print $1,$4}')"

if [[ -z "$IDRACVERSION" ]]; then
	IDRACVERSION="none"
else
	IDRACVERSION="$IDRACVERSION"
fi

echo "$IDRACVERSION"

}

function HandleArgs {

	case "$1" in
		pddiscovery)
			PhysicalDisksDiscovery
			;;
		pdstatus)
			PhysicalDiskStatus $2 $3 $4
			;;
		vddiscovery)
			VirtualDiskDiscovery
			;;
		vdstatus)
			VirtualDiskStatus $2 $3 $4
			;;
		fandiscovery)
			FanDiscovery
			;;
		fanstatus)
			FanStatus $2 $3
			;;
		psudiscovery)
			PsuDiscovery
			;;
		psustatus)
			PsuStatus $2
			;;
		nicdiscovery)
			NicDiscovery
			;;
		nicstatus)
			NicStatus $2
			;;
		tempdiscovery)
			TempDiscovery
			;;
		tempstatus)
			TempStatus $2
			;;
		model)
			SystemModel
			;;
		stag)
			SystemServiceTag
			;;
		bios)
			SystemBiosVersion
			;;
		idrac)
			SystemIdracVersion
			;;
		status)
			SystemStatus
			;;												
		esac

}

HandleArgs $@
