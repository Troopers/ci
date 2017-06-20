#!/usr/bin/env bash
echo "============================================="
echo "| BEHAT PARALLELISM TEST DISPATCHER SCRIPT |"
echo "============================================="
echo "by Leny Bernard (Troopers)                  |"
echo ""

if [ -z "$TEST_PARALLELISM_CONTAINER_TOTAL" ]; then
  echo "No parrallelism found, setting defaults to run all tests."
  TEST_PARALLELISM_CONTAINER_TOTAL=1
fi

if [ -z $1 ] || [ $1 -le 0 ]
then
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "TO MAKE PARRALELISM WORK, YOU NEED TO PASS THE CONTAINER ID (integer)"
    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    containerIndex=1
    TEST_PARALLELISM_CONTAINER_TOTAL=1
else
    containerIndex=$1
fi

echo "Container $containerIndex/$TEST_PARALLELISM_CONTAINER_TOTAL"

# Don't rely on default order
# http://serverfault.com/questions/181787/find-command-default-sorting-order/181815#181815
availableScenarios=($(cat var/scenarios))
let "scenarioCount = ${#availableScenarios[@]}"
echo "$scenarioCount features found"

let "scenariosToRunCount = scenarioCount / TEST_PARALLELISM_CONTAINER_TOTAL"
let "modulo = scenarioCount % TEST_PARALLELISM_CONTAINER_TOTAL"
if [ "$modulo" -ne 0 ]; then
    let "scenariosToRunCount += 1"
fi
fromScenarioIndex=1

let "toScenarioIndex = (scenariosToRunCount) * containerIndex - 1"
let "fromScenarioIndex = toScenarioIndex - scenariosToRunCount + 1"
echo "$scenariosToRunCount features to run here [$fromScenarioIndex-$toScenarioIndex]"

echo "scenarios:"

scenariosToRun=()
for ((i=0; i < ${#availableScenarios[@]}; i++)); do
    if [ "$i" -ge $fromScenarioIndex ] && [ "$i" -le $toScenarioIndex ]; then
        echo "- ${availableScenarios[$i]}"
        scenariosToRun+=(${availableScenarios[$i]})
    fi
done

# Calculate sum of return codes in order to detect errors
# http://stackoverflow.com/questions/6348902/how-can-i-add-numbers-in-a-bash-script/6348945#6348945
sum=0
if [ "${#scenariosToRun[@]}" -gt 0 ]; then
    for ((i=0; i < ${#scenariosToRun[@]}; i++)); do
        echo "bin/behat -vv ${scenariosToRun[$i]}"
        time bin/behat -vv ${scenariosToRun[$i]}
        return=$?
        echo "return code = ${return}"
        sum=$(( $sum + $return ))
    done
else
    echo "No test to run (issue related to modulo)"
fi

echo "sum of Behat return codes = ${sum}"

exit $sum
