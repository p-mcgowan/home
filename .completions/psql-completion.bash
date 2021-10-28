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
  local target=$2
  COMPREPLY+=($2*.sql)
}
complete -W "-h --help -l --local -c --command -t --test -r -k -j" -F _get_sql_files psql
