export ZSHRC_TESTS_DIR="$ZSHRC_DIR/_tests"

source "$ZSHRC_DIR"/_tests/__test_harness.zsh
source "$ZSHRC_DIR"/_tests/_run_all_test_cases.zsh
source "$ZSHRC_DIR"/_tests/_verify_test_invocations.zsh
source "$ZSHRC_DIR"/_tests/_verify_test_ordering.zsh

# Allow filtering test section by number (1-5)
ZSHRC_TESTS_SECTION_FILTER=$([[ $1 -ge 1 && $1 -le 5 ]] && echo "$1")

# Allow filtering test cases by substring match
# shellcheck disable=SC2030
ZSHRC_TESTS_NAME_FILTER=$([[ -z $ZSHRC_TESTS_SECTION_FILTER && -n $1 ]] && echo "$1")

# Source test subjects and general utils
ZSHRC_UNDER_TESTING=1 source ~/.zshrc

# shellcheck disable=SC2031
if [[ $ZSHRC_TESTS_SECTION_FILTER -eq 1 || -z $ZSHRC_TESTS_SECTION_FILTER ]]; then
	run_all_test_cases_section 1
fi

if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq 2 || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	verify_test_invocations_section 2
fi

if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq 3 || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	verify_test_ordering_section 3
fi

#
# 4: Verify key mapping functions in keymaps are alphabetized # TODO
#
