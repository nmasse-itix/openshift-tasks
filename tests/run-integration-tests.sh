# Exit immediately if command returns non-zero status code
set -e

if [ -z "$1" ]; then
  echo "No given instance of JBoss EAP ! Exiting..."
  exit 1
fi

appurl="$1"

function runtest() {
  url="$1"
  expected="$2"
  while ret="$(curl -s -o /dev/null -b cookies.txt -c cookies.txt -w "%{http_code}" "$url")" && [ "$ret" == "503" ]; do
    echo "Got a 503. An OpenShift deployment may be pending ? Sleeping for a while and retrying..."
    sleep 2
  done
  if [ "$ret" != "$expected" ]; then
    echo "$url: Got HTTP Status code '$ret' instead of a '$expected' Status code."
    exit 1
  fi
}

runtest "$appurl/" 200
runtest "$appurl/ws/demo/name" 200
runtest "$appurl/ws/demo/log/info" 200
runtest "$appurl/blabla" 404

echo "Successfully passed integration tests"
