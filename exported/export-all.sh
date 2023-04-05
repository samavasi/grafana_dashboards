#!/bin/bash
# https://gist.github.com/crisidev/bd52bdcc7f029be2f295

set -o errexit
set -o pipefail
# set -x

FULLURL="$1"
headers="$2"
# headers="Authorization: Bearer $2"
in_path=dashboards_raw
base_path=dashboards_all
set -o nounset

echo "Exporting Grafana dashboards from $FULLURL"
rm -rf $in_path
rm -rf $base_path

mkdir -p $in_path
mkdir -p $base_path
for dash in $(curl -H "$headers" -s "$FULLURL/api/search?query=&" | jq -r '.[] | select(.type == "dash-db") | .uid'); do
        curl -H "$headers" -s "$FULLURL/api/search?query=&" 1>/dev/null
        dash_path="$in_path/$dash.json"
        curl -H "$headers" -s "$FULLURL/api/dashboards/uid/$dash" | jq -r . > $dash_path
        jq -r .dashboard $dash_path > $in_path/dashboard.json
        title=$(jq -r .dashboard.title $dash_path | sed -r 's/[ \/]+/_/g')
        folder="$(jq -r '.meta.folderTitle' $dash_path)"
        mkdir -p "$base_path/$folder"
        mv -f $in_path/dashboard.json "$base_path/$folder/${title}.json"
       echo "exported $folder/${title}.json"

done
rm -r $in_path
