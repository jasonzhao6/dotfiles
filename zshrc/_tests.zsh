# When profiling, set to 1; otherwise, set to <empty>
ZSHRC_TESTS_UNDER_PROFILING=

# Profile `.zshrc` testing time: Start here
[[ -n $ZSHRC_TESTS_UNDER_PROFILING ]] && zmodload zsh/zprof

# Track `.zshrc` testing time: Start here
ZSHRC_TESTS_START_TIME=$(gdate +%s.%2N)

#
# Test setup
#

# Allow filtering test sections by number (1-5)
ZSHRC_TESTS_SECTION_FILTER=$([[ $1 -ge 1 && $1 -le 5 ]] && echo "$1")

# Allow filtering test cases by substring match
# shellcheck disable=SC2030
ZSHRC_TESTS_NAME_FILTER=$([[ -z $ZSHRC_TESTS_SECTION_FILTER && -n $1 ]] && echo "$1")

# Source test subjects
ZSHRC_UNDER_TESTING=1 source ~/.zshrc

# Source test harness
source "$ZSHRC_DIR"/_tests/_test_harness.zsh

#
# Test sections: Start here
#

ZSHRC_TESTS_SECTION_NUMBER=1
# shellcheck disable=SC2031
if [[ $ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER ]]; then
	source "$ZSHRC_DIR"/_tests/_run_all_test_cases.zsh
	run_all_test_cases_section $ZSHRC_TESTS_SECTION_NUMBER
fi

ZSHRC_TESTS_SECTION_NUMBER=2
if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	source "$ZSHRC_DIR"/_tests/_verify_test_invocations.zsh
	verify_test_invocations_section $ZSHRC_TESTS_SECTION_NUMBER
fi

ZSHRC_TESTS_SECTION_NUMBER=3
if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	source "$ZSHRC_DIR"/_tests/_verify_test_ordering.zsh
	verify_test_ordering_section $ZSHRC_TESTS_SECTION_NUMBER
fi

ZSHRC_TESTS_SECTION_NUMBER=4
if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	source "$ZSHRC_DIR"/_tests/_verify_keymap_definitions.zsh
	verify_keymap_definitions_section $ZSHRC_TESTS_SECTION_NUMBER
fi

ZSHRC_TESTS_SECTION_NUMBER=5
if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	source "$ZSHRC_DIR"/_tests/_verify_keymap_ordering.zsh
	verify_keymap_ordering_section $ZSHRC_TESTS_SECTION_NUMBER
fi

#
# Test sections: Finish here
#

# Track `.zshrc` testing time: Finish here
gray_fg "\n\`.zshrc\` tests ran in $(echo "$(gdate +%s.%2N) - $ZSHRC_TESTS_START_TIME" | bc) seconds"

# Profile `.zshrc` testing time: Finish here
[[ -n $ZSHRC_TESTS_UNDER_PROFILING ]] && echo && zprof
