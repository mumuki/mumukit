#!/bin/bash
set -e

echo ""
echo ""
echo "   _____                       __   .__  __ __________               __            __                        "
echo "  /     \  __ __  _____  __ __|  | _|__|/  |\______   \ ____   _____/  |_  _______/  |_____________  ______  "
echo " /  \ /  \|  |  \/     \|  |  \  |/ /  \   __\    |  _//  _ \ /  _ \   __\/  ___/\   __\_  __ \__  \ \____ \ "
echo "/    Y    \  |  /  Y Y  \  |  /    <|  ||  | |    |   (  <_> |  <_> )  |  \___ \  |  |  |  | \// __ \|  |_> >"
echo "\____|__  /____/|__|_|  /____/|__|_ \__||__| |______  /\____/ \____/|__| /____  > |__|  |__|  (____  /   __/ "
echo "        \/            \/           \/               \/                        \/                   \/|__|    "
echo ""
echo ""

if [ $# -ne 4 ]; then
  echo "[Mumukit::Bootstrap] Hi! So you want to create a runner? This script will help you :D"
  echo "                     Please run this script again passing the following arguments:"
  echo ""
  echo "                     ./create.sh <GITHUB_USER> <RUNNER> <CONSTANT> <DOCKER_BASE_IMAGE>"
  echo ""
  echo "                     where..."
  echo ""
  echo "                     GITHUB_USER is the Github username of the creator;"
  echo "                     RUNNER is the runners name, in snake-case-lower-case;"
  echo "                     CONSTANT is the runners name as a Ruby constant, in CamelCaseUpperCase;"
  echo "                     DOCKER_BASE_IMAGE is the Docker base image used to run the code like foo/bar:0.2"
  echo ""
  echo ""
  echo "                     Then follow instructions"
  exit 1
fi


user=$1
runner=$2
constant=$3
image=$4

author=$user
year=$(date +%Y)

echo ""
echo "[Mumukit::Bootstrap] Good. It looks like you have passed all the required arguments!"
echo "                     So I will create your runner..."
echo ""


project_directory="../mumuki-$runner-runner"

if [ -d $project_directory ]; then
  echo ""
  echo "[Mumukit::Bootstrap] Oops. There already exists a runner project in $project_directory."
  echo "                     Please remove it before proceeding"
  echo ""
  exit 2
fi

cp template $project_directory -R
cd $project_directory


echo "[Mumukit::Bootstrap] Creating gemspec..."
sed -i "s/<RUNNER>/$runner/g"                    mumuki-sample-runner.gemspec
sed -i "s/<CONSTANT>/$constant/g"                mumuki-sample-runner.gemspec
sed -i "s/<USER>/$user/g"                        mumuki-sample-runner.gemspec
sed -i "s/<AUTHOR>/$author/g"                    mumuki-sample-runner.gemspec
mv  mumuki-sample-runner.gemspec                 mumuki-$runner-runner.gemspec

echo "[Mumukit::Bootstrap] Creating LICENSE..."
sed -i "s/<YEAR>/$year/g"                        LICENSE
sed -i "s/<AUTHOR>/$author/g"                    LICENSE

echo "[Mumukit::Bootstrap] Creating config.ru..."
sed -i "s/<RUNNER>/$runner/g"                    config.ru

echo "[Mumukit::Bootstrap] Creating README.md..."
sed -i "s/<RUNNER>/$runner/g"                    README.md
sed -i "s/<USER>/$user/g"                        README.md

echo "[Mumukit::Bootstrap] Creating .travis.yml..."
sed -i "s/<RUNNER>/$runner/g"                    .travis.yml

echo "[Mumukit::Bootstrap] Creating spec/spec_helper.rb..."
sed -i "s/<RUNNER>/$runner/g"                    spec/spec_helper.rb

echo "[Mumukit::Bootstrap] Creating lib/${runner}_runner.rb..."
sed -i "s/<RUNNER>/$runner/g"                    lib/sample_runner.rb
mv lib/sample_runner.rb                          lib/${runner}_runner.rb

echo "[Mumukit::Bootstrap] Creating worker/Dockerfile..."
sed -i "s/<AUTHOR>/$author/g"                    worker/Dockerfile
sed -i "s,<IMAGE>,$image,g"                      worker/Dockerfile

echo "[Mumukit::Bootstrap] Creating lib/metadata_hook.rb..."
sed -i "s/<CONSTANT>/$constant/g"                lib/metadata_hook.rb

echo "[Mumukit::Bootstrap] Creating lib/test_hook.rb..."
sed -i "s/<CONSTANT>/$constant/g"                lib/test_hook.rb

echo "[Mumukit::Bootstrap] Creating lib/version_hook.rb..."
sed -i "s/<CONSTANT>/$constant/g"                lib/version_hook.rb

echo "[Mumukit::Bootstrap] Running bundle install..."
bundle install

echo "[Mumukit::Bootstrap] Initializing git repository..."
git init .
git add -A
git commit -m "Inital commit"

echo "[Mumukit::Bootstrap] Done!"
echo "                     Now go to $project_directory and start editing it."
echo ""
echo "                     See https://github.com/mumuki/mumukit-bootstrap/blob/master/README.md#developing for more instructions"


