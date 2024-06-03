# -l, --local
# -c --command
#   [cmd]
# -t --test
# -r -k
#   [cmd]
#   [*.sql]
# -j
# *.sql

_get_sql_files() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[((COMP_CWORD - 1))]}

  if [ "$prev" == '-f' ] || [ "$prev" == '-l' ]; then
    COMPREPLY=($(compgen -o plusdirs -f -X '!*.sql' -- $cur))
  else
    COMPREPLY=($(compgen -o filenames -W "-c -d -D -f -h -j -q -r -s -t --command --database --debug --file --help --json --query --remote --silent --test" -- "$cur"))
  fi
}
complete -o filenames -F _get_sql_files psql
