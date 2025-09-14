#!/usr/bin/env bash
set -ex
vercomp () {
	local op="$2"
	if [ "$op" == "-eq" ] && [ $1 == $3 ]
	then
		return 0
	fi
	local IFS=.
	local i ver1=($1) ver2=($3)
	# fill empty fields in ver1 with zeros
	for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
	do
		ver1[i]=0
	done
	for ((i=0; i<${#ver1[@]}; i++))
	do
	if (( 10#${ver1[i]:=0} == 10#${ver2[i]:=0} ));then
		if (( (i+1) == ${#ver1[@]} ));then
			return 1
		else
			continue
		fi
	elif test $((10#${ver1[i]:=0})) "$op" $((10#${ver2[i]:=0}))
	then
		break
	else
		return 1
	fi
	done
	return 0
}

REPO="${1:?Missing repo}"
BASH_VERSION="${2:?Missing bash version}"
DESTINATION="${3:?Missing destination}"
if vercomp "$BASH_VERSION" "-lt" "4.1.17"
then
	COMPLETION_VERSION="1.3"
else
	COMPLETION_VERSION="2.10"
fi

echo "Installing bash-completion version : ${COMPLETION_VERSION}"
git clone --depth 1 --single-branch --branch "${COMPLETION_VERSION}" "${REPO}" "${DESTINATION}"
