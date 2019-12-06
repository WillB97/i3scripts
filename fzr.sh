#!/bin/bash
# version: 1.2.1
PRINT_CMD=1
PRINT_OUT=1
CMD_OUT=''
QUERY=""
LEN=12

while getopts ":hqsc:Q:" flag; do
	case "$flag" in
		h) echo -e "\e[1mUsage:\e[0m $0 [-hqs] [-c <file>] [-Q <query>] <command ['{q}']>"
			echo "  <command>: The command that the query will be supplied to"
			echo "  '{q}': The placeholder where the query will be substituted"
			echo "         The query is appended to the command is this not supplied"
			echo "  -h: print this help message"
			echo "  -q: Suppress printing the produced command to standard error"
			echo "  -s: Suppress printing the produced output to standard out"
			echo "  -c <file>: File to print produced command to, stderr otherwise"
			echo "  -Q <query>: set the initial value of the query"
			echo
			echo -e "\e[1mExamples:\e[0m"
			echo "  Query string is automatically appended"
			echo "    cat any/data/here | $0 grep"
			echo "  Supplied query placeholder is used"
			echo "    cat any/data/here | $0 grep '{q}'"
			echo "  Can be used without piped input when command produces it's own output"
			echo "    $0 grep '{q}' any/file/here"
			exit 1;;
		q) PRINT_CMD=0;; # suppress printing command
		s) PRINT_OUT=0;; # suppress printing output
		c) CMD_OUT=$OPTARG;; # set command output
		Q) QUERY=$OPTARG;; # set the initial query
	esac
done
shift "$((OPTIND-1))"

TMP_FILE="$(mktemp)" # temporary file to store produced output
trap "rm -f $TMP_FILE" 0 2 3 15
while [[ "$(ps c -C fzf |grep "$(ps h -p $$ -o tty)"|wc -l)" != 0 ]]; do
	sleep 1; # if another fzf is running wait until it closes
done

preview_cmd="$* "
if [[ ! "$*" =~ "{q}" ]]; then
	# append query string if not already set
	preview_cmd+="{q} "
fi
preview_cmd+=">$TMP_FILE "
if [[ ! -t 0 ]]; then
	# only insert stdin if from a pipe
	input="$(mktemp)" # temporary file to store piped input
	trap "rm -f $input" 0 2 3 15
	cat - </dev/stdin > "$input" & # move stdin to temp file
	INPUT_TASK=$!
	preview_cmd+="< $input"
fi
preview_cmd+="; cat $TMP_FILE"

HINT="$*"
[[ ${#HINT} -gt $LEN ]] && HINT="${HINT:0:((LEN-2))}.."

output="$(fzf \
	--height=95% \
	--print-query \
	--prompt="$HINT > " \
	--preview="$preview_cmd" \
	--query="$QUERY" \
	--preview-window='up:99%:wrap' < /dev/null 2>/dev/tty)"

# don't output anything if fzf is cancelled
if [[ "x$output" != "x" ]]; then
	cmd="$* '$output'"
	# output produced command to stderr
	if [[ -z $CMD_OUT ]]; then
		if [[ $PRINT_CMD == 1 ]]; then
			([ -t 2 ] && echo -e "\e[34m$cmd\e[0m" || echo "$cmd") 1>&2
		fi
	else
		echo "$cmd" >> "$CMD_OUT"
	fi
	# print command output for following pipeline
	[[ $PRINT_OUT == 1 ]] && cat "$TMP_FILE"
	# remove temporary files
	[[ -f "$TMP_FILE" ]] && rm "$TMP_FILE"
	[[ -n "$INPUT_TASK" ]] && kill $INPUT_TASK 2>/dev/null
	[[ -f "$input" ]] && rm "$input"
	exit 0
fi

# remove temporary files on failure
[[ -f "$TMP_FILE" ]] && rm "$TMP_FILE"
[[ -n "$INPUT_TASK" ]] && kill $INPUT_TASK 2>/dev/null
[[ -f "$input" ]] && rm "$input"
