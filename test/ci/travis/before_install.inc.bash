# Common / useful `set` commands
# set -Ee # Exit on error
# set -o pipefail # Check status of piped commands

echo "STARTING before_install.inc.bash"

NRSER_RB_TRAVIS_DIR="./test/ci/travis"

# Path to OS-specific "before install" script
# 
# Like `//test/ci/travis/bash/before_install/os/osx.inc.bash`
# 
NRSER_RB_OS_SCRIPT_PATH="${NRSER_RB_TRAVIS_DIR}/before_install/os/${TRAVIS_OS_NAME}.inc.bash"

# HACK  Change Git submodule SSH -> HTTPS paths so that Travis can pull them.
#       
#       This is a temp solution since it won't work recursively, prob need to
#       switch to HTTPS for public repos... though I've never liked HTTPS as
#       much, the SSH auth just always seemed to simple and consistent.
#       
#       Adapted from https://gist.github.com/iedemam/9830045
#       
./test/bin/git-submod-ssh-to-https.rb

# Then pull the submodules in. The recursive part probably won't work unless
# they are HTTPS URLs.
git submodule update --init --recursive

# Include OS-specific commands (if script exists)
if [ -f "${NRSER_RB_OS_SCRIPT_PATH}" ]; then
  echo "Including OS-specific script '${NRSER_RB_OS_SCRIPT_PATH}'..."
  source "${NRSER_RB_OS_SCRIPT_PATH}"
  echo "DONE: OS-specific script '${NRSER_RB_OS_SCRIPT_PATH}'"
else
  echo "No os-specific script found at '${NRSER_RB_OS_SCRIPT_PATH}'."
fi

# Install gem
gem update --system
gem install bundler

echo "DONE before_install.sh"
