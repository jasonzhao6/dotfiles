export ZSHRC_TESTS_DIR="$ZSHRC_DIR/_tests"

source "$ZSHRC_DIR"/_tests/__test_harness.zsh
source "$ZSHRC_DIR"/_tests/_run_all_test_cases.zsh
source "$ZSHRC_DIR"/_tests/_verify_keymap_definitions.zsh
source "$ZSHRC_DIR"/_tests/_verify_keymap_ordering.zsh
source "$ZSHRC_DIR"/_tests/_verify_test_invocations.zsh
source "$ZSHRC_DIR"/_tests/_verify_test_ordering.zsh

# Allow filtering test section by number (1-5)
ZSHRC_TESTS_SECTION_FILTER=$([[ $1 -ge 1 && $1 -le 5 ]] && echo "$1")

# Allow filtering test cases by substring match
# shellcheck disable=SC2030
ZSHRC_TESTS_NAME_FILTER=$([[ -z $ZSHRC_TESTS_SECTION_FILTER && -n $1 ]] && echo "$1")

# Source test subjects and general utils
ZSHRC_UNDER_TESTING=1 source ~/.zshrc


ZSHRC_TESTS_SECTION_NUMBER=1
# shellcheck disable=SC2031
if [[ $ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER ]]; then
	run_all_test_cases_section $ZSHRC_TESTS_SECTION_NUMBER
fi

ZSHRC_TESTS_SECTION_NUMBER=2
if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	verify_test_invocations_section $ZSHRC_TESTS_SECTION_NUMBER
fi

ZSHRC_TESTS_SECTION_NUMBER=3
if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	verify_test_ordering_section $ZSHRC_TESTS_SECTION_NUMBER
fi

ZSHRC_TESTS_SECTION_NUMBER=4
if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	verify_keymap_definitions_section $ZSHRC_TESTS_SECTION_NUMBER
fi

ZSHRC_TESTS_SECTION_NUMBER=5
if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq $ZSHRC_TESTS_SECTION_NUMBER || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	verify_keymap_ordering_section $ZSHRC_TESTS_SECTION_NUMBER
fi
