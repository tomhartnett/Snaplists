hexBuildNumber=$(git rev-parse --short HEAD | tr "[:lower:]" "[:upper:]")
decBuildNumber=$(echo "ibase=16; $hexBuildNumber" | bc)
agvtool new-version -all $decBuildNumber
