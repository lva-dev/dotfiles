#
# ~/.bash_functions
#

# Usage: path
# Prints the paths in PATH, split by newlines.
function path() {
  echo "$PATH" | tr ':' '\n'
}

# Usage: newf <path>
# Creates a new file.
function newf() {
	for path in "$@"; do
		if [[ -f "$path" ]]; then
			echo -e "error: file '$path' already exists"
			return 1
		elif [[ -d "$path" ]]; then
			echo -e "error: '$path' is a directory"
			return 1
		elif [[ -e "$path" ]]; then
			echo -e "error: path '$path' already exists"
			return 1
		fi

		mkdir -p "$(dirname "$path")" && touch "$path"
	done
}

# Usage: colors
# Prints some basic terminal colors.
function colors() (
	function pcolor() {
		n="$1"
		fg=$((0 + n))
		bg=$((10 + n))
		echo -ne "\e[${fg}m${fg}\e[m "
		echo -ne "\e[${bg}m${bg}\e[m\n"
	}

	for n in {30..37}; do
		pcolor "$n"
	done

	for n in {90..97}; do
		pcolor "$n"
	done
)

# Usage: cd
#        cd <dir>
#        cd [(-|+)[N]]
#        cd --
# A better cd.
# Author:
#   Petar Marinov, http:/geocities.com/h2428, public domain
function cd() {
	local x2 the_new_dir adir index
	local -i cnt

	if [[ $1 == "--" ]]; then
		dirs -v
		return 0
	fi

	the_new_dir=$1
	[[ -z $1 ]] && the_new_dir=$HOME

	if [[ ${the_new_dir:0:1} == '-' ]]; then
		#
		# Extract dir N from dirs
		index=${the_new_dir:1}
		[[ -z $index ]] && index=1
		adir=$(dirs +$index)
		[[ -z $adir ]] && return 1
		the_new_dir=$adir
	fi
	# '~' has to be substituted by ${HOME}
	[[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"
	# Now change to the new dir and add to the top of the stack
	pushd "${the_new_dir}" >/dev/null || return 2
	[[ $? -ne 0 ]] && return 1
	the_new_dir=$(pwd)
	# Trim down everything beyond 11th entry
	popd -n +11 2>/dev/null 1>/dev/null
	# Remove any other occurence of this dir, skipping the top of the stack
	for ((cnt = 1; cnt <= 10; cnt++)); do
		x2=$(dirs +${cnt} 2>/dev/null)
		[[ $? -ne 0 ]] && return 0
		[[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
		if [[ "${x2}" == "${the_new_dir}" ]]; then
			popd -n +$cnt 2>/dev/null 1>/dev/null
			cnt=$((cnt - 1))
		fi
	done

	return 0
}
