setup() {
  set -eux -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/ddev-drupal-storybook
  mkdir -p $TESTDIR
  export PROJNAME=ddev-drupal-storybook
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  # Configure and start drupal project.
  ddev config --project-name=${PROJNAME} --project-type=drupal10 --docroot=web --create-docroot
  ddev composer create drupal/recommended-project
  ddev composer require drush/drush
  ddev composer config minimum-stability dev
  ddev drush site:install --account-name=admin --account-pass=admin -y
}

health_checks() {
  # Test Storybook installation.
  ddev storybook init
  # Test starting Storybook.
  ddev storybook start
  # Check that Storybook is accessible on port 6006.
  curl -s https://${PROJNAME}.ddev.site:6006 | grep "Storybook"
  # Test stopping Storybook.
  ddev storybook stop
}

teardown() {
  set -eux -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eux -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  health_checks
}

@test "install from release" {
  set -eux -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get wotnak/ddev-drupal-storybook with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get wotnak/ddev-drupal-storybook
  ddev restart
  health_checks
}
