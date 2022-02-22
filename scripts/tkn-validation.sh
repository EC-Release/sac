#!/bin/bash
#
#  Copyright (c) 2019 General Electric Company. All rights reserved.
#
#  The copyright to the computer software herein is the property of
#  General Electric Company. The software may be used and/or copied only
#  with the written permission of General Electric Company or in accordance
#  with the terms and conditions stipulated in the agreement/contract
#  under which the software has been supplied.
#

#validate params
# $1: <EXEC_DAT>
function validate_params () {
  if [[ -z $EXEC_DAT ]]; then
    printf "%s" "{\"error\":\"empty request.\"}"
    return -1
  fi
  echo "EXEC_DAT"=$1
  region=$(echo $1 | jq -r .region)
  userPoolId=$(echo $1 | jq -r .userPoolId)
  svcId==$(echo $1 | jq -r .svcId)
  if [[ -z ${region} || -z ${userPoolId} || -z ${svcId} ]]; then
    printf "%s" "{\"error\":\"one or more required values are missing.\"}"
    return -1
  fi
  url = ${idp}.${region}.${domain}/${userPoolId}/.well-known/jwks.json
  return 0
}

# verify the Cognito token and validate service-id from the map
# $1: <EXEC_DAT>
# $2: <EXEC_MAP>
# $3: <EXEC_URL>
function int_a () {
  printf "{\"hello2\":\"world2\",\"dataFromrRequest\":%s,\"appParams\":%s}" "$1" "$2"
  exit 0
  if [[ "${validate_params}" = "0"} ]]; then
    
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" $3
    if [ $STATUS != "200"* ]; then
      printf "%s" "{\"error\":\"error from aws token verification.\"}"
      return -1
    else
      echo "check if Cognito-userpool key exists in the map"
      if [[ "$(key_exists $1 $2; echo $?)" = "0" ]]; then
          if printf '%s\n' "${_array_name[@]}" | grep -Fxq 'svc-id'; then
            printf "%s" "{\"decision\":\"PERMIT\"}"
          fi

      else
          printf "%s" "{\"error\":\"Cognito-userpool key does not exist in the map.\"}"
      fi

      return 0      
    fi
  fi
  
}

# Check if Cognito-userpool key exists
# Usage: array_key_exists $array_name $key
# Returns: 0 = key exists, 1 = key does NOT exist
function key_exists() {
    local _array_name="$1"
    local _key="$2"
    local _cmd='echo ${!'$_array_name'[@]}'
    local _array_keys=($(eval $_cmd))
    local _key_exists=$(echo " ${_array_keys[@]} " | grep " $_key " &>/dev/null; echo $?)
    [[ "$_key_exists" = "0" ]] && return 0 || return 1
}
