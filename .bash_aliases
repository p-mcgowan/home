## Common:

alias eali='sub ~/.bash_aliases &>/dev/null || vim ~/.bash_aliases'
alias sali='source ~/.bash_aliases'
alias bashrc='source ~/.bashrc'
alias ebashrc='sub ~/.bashrc &>/dev/null || vim ~/.bashrc'

# Pretty print json
pp() { python3 -m json.tool $*; }
# Cd and ls
cdl() { cd "$@" && ls --color=auto; }
# List octal permissions
lp() {
  ls -l --color=always "$@" |awk '{
    k = 0;
    for (i = 0; i <= 8; i++) {
      k += ((substr($1, i + 2, 1) ~/[rwx]/) * 2 ^ (8 - i));
    }
    if (k) {
      printf("%0o ", k);
    }
    print;
  }'
}
alias l1='ls -1'
alias lr='ls -R'


## Navigation:

alias docs='cd ~/Documents ;ls --color=auto'
alias dls='cd ~/Downloads ;ls --color=auto'
alias pics='cd ~/Pictures ;ls --color=auto'
alias ..='cd .. && ls --color=auto'
alias ...='cd ../.. && ls --color=auto'
alias ....='cd ../../.. && ls --color=auto'

declare -A GOTO_LOCATIONS=(
  [acr]=~/source/acrontum
  [aos]=~/source/acrontum/bmw/aos/aos2
  [bbox]=~/source/acrontum/blue-box
  [dsd]=~/source/acrontum/bmw/dsd
  [dsdc]=~/source/acrontum/bmw/dsd/config
  [ext]=~/.local/share/gnome-shell/extensions/
  [fst]=~/source/acrontum/open-source/filesystem-template
  [gen]=~/source/acrontum/open-source
  [os]=~/source/acrontum/open-source
  [moxy]=~/source/acrontum/open-source/moxy
  [googler]=~/source/googler/
  [hc]=~/source/hc
  [port]=~/source/p-mcgowan/portfolio/
  [pg]=~/source/p-mcgowan/playground/
)

goto() {
  if [ -z "$1" ]; then
    {
      for key in "${!GOTO_LOCATIONS[@]}"; do
        echo -e "$key => ${GOTO_LOCATIONS[$key]}"
      done
    } | sort -k3 |column -t
    return 0
  fi

  local quiet=
  local target=
  local check=
  local configured=

  while [ -n "$1" ]; do
    case $1 in
      -q) quiet=true ;;
      -c) check=true ;;
      -a) GOTO_LOCATIONS[$2]=$3; shift 2; configured=true; complete -W "$(goto |awk '{print $1}')" goto;;
      *) target="$1" ;;
    esac
    shift
  done

  if [ -z "$target" ]; then
    if [ -n "$configured" ]; then
      return 0
    fi
    echo >&2 "No target specified"
    return 1
  fi

  if [ -z "${GOTO_LOCATIONS[$target]}" ]; then
    [ -z "$quiet" ] && [ -z "$check" ] && echo >&2 "Could not find $target"
    return 1
  fi

  if [ -n "$check" ]; then
    echo ${GOTO_LOCATIONS[$target]}
    return 0
  fi

  eval cd ${GOTO_LOCATIONS[$target]}
  [ -z "$quiet" ] && ls
  return 0
}
complete -W "$(goto |awk '{print $1}')" goto

project-root() {
  targets=('package.json' 'build.gradle' 'requirements.txt' 'Dockerfile')

  initial="$PWD"
  here="$PWD"

  while [ "$prev" != "$here" ]; do
    for target in ${targets[@]}; do
      if [ -f $target ]; then
        return 0;
      fi
    done

    prev="$here"
    cd ..
    here="$PWD"
  done

  cd "$initial"

  echo >&2 "No project files above"
}

# goto -a something ${HOME}/source/p-mcgowan/something

## Programs

alias tmux='TERM=xterm-256color tmux'
calc() { echo "$@" |bc -l ; }
alias term='gnome-terminal'
alias conky='conky -c ~/.conkyrc &>/dev/null'
alias conkyconf="vim /etc/conky/conky.conf"
alias csgo='steam steam://rungameid/730'
alias days='steam steam://rungameid/251570'
alias fluxkeys='gedit ~/.fluxbox/keys &'
alias fluxstart='gedit ~/.fluxbox/startup &'
alias gopen='xdg-open'
open() {
  for file in "$@"; do
    xdg-open "$file" &>/tmp/open.log &
  done
}
alias recentinstalls='grep " install " /var/log/dpkg.log'
alias minecraft='java -jar ~/.minecraft/Minecraft.jar &>/dev/null &'
alias forge='cd .minecraft; java -jar ~/.minecraft/Minecraft.jar &>/dev/null &'
alias servercraft='java -jar -Xmx1024M -Xms1024M -jar minecraft_server.1.6.4.jar nogui'
alias brave='brave-browser &> /tmp/brave.log &'
#vlc() {
#  args="$*"
#  if [[ "$*" =~ \-t\ ?([0-9]{1,2}(:[0-9]{1,2})?(:[0-9]{1,2})?) ]]; then
#    seconds=$(echo ${BASH_REMATCH[1]} |awk '{n=split($1,A,":"); print A[n]+60*A[n-1]+60*60*A[n-2]}')
#    args="--start-time=$seconds ${args/${BASH_REMATCH[0]}/}"
#  fi
#
#  command vlc $args &>/dev/null &
#}

firefox() { command firefox "$@" &>/tmp/firefox.log & }
skype() { command skypeforlinux "$@" &>/tmp/skypeforlinux.log & }
spotify() { command spotify --show-console "$@" &>/tmp/spotify.log & }
vivaldi() { command vivaldi "$@" &>/tmp/vivaldi.log & }
pinta() { command pinta "$@" &>/tmp/pinta.log & }
slack() { SLACK_DEVELOPER_MENU=true command slack "$@" &>/tmp/slack.log & }
totem() { command totem "$@" &>/tmp/totem.log & }
signal() { command signal-desktop "$@" &>/tmp/signal.log & }
postman() { /home/pat/programs/postman/postman $@ &>/dev/postman & }
tor-browser() { /home/pat/programs/tor-browser_en-US/Browser/start-tor-browser --detatch $@ &>/tmp/tor.log & }
alias tweaks='gnome-tweak-tool 2>/tmp/tweaks.log &'
alias scli='spotifycli.py'
alias resub='killall -9 sublime_text && sub'
alias novim='HOME=/dev/null vim -u NONE -n'
alias watch='watch '

## Gaming

discord() { command discord "$@" &>/tmp/discord.log & }
steam() { command steam "$@" &>/tmp/steam.log & }
factorio() {
  if [ $# == 0 ]; then
    ~/.factorio/bin/x64/factorio -c ~/.factorio/config/config.ini &>/tmp/factorio.log &
  else
    ~/.factorio/bin/x64/factorio $*
  fi
}
dayserv() {
  ( cmdpid=$BASHPID;
    ( sleep 3; kill $cmdpid ) \
    & exec telnet 50.92.25.165 26900 2>&1 |grep -o "CurrentPlayers:[0-9]"
  )
}
cscfg() {
  case $1 in
    -v) vim ~/.steam/steam/steamapps/common/Counter-Strike\ Global\ Offensive/csgo/cfg/autoexec.cfg;;
    *)  sub ~/.steam/steam/steamapps/common/Counter-Strike\ Global\ Offensive/csgo/cfg/autoexec.cfg;;
  esac
}
# send mouse clicks to window
spam() {
  echo sleeping for 3s
  sleep 3;
  window=$(xdotool getwindowfocus);
  while [ "$(xdotool getactivewindow)" == $window ]; do
    xdotool mousedown 3 mouseup 3;
    xdotool mousedown 2 mouseup 2;
    sleep 0.01;
  done
  xdotool mouseup 3; xdotool mouseup 2;
}
epic() {
  data=$(curl -s https://patmcgowan.ca/v1/epic)

  node -e "$(
cat <<SCRIPT
let data = ${data};
console.table(
  data
    .reduce(
      (a, g) =>
        a.concat({
          title: g.title,
          price: g.price.totalPrice.discountPrice,
          link: \`https://www.epicgames.com/store/en-US/p/\${g.productSlug?.replace(/\/.*/g,'')}\`,
        }),
      []
    )
    .sort((a, b) => a.price - b.price)
);
SCRIPT
)"
}

## Computer Control:

alias shutdown='sudo shutdown -h now'
alias restart='sudo shutdown -r now'
alias update="sudo -- sh -c 'apt-get update; apt-get upgrade -y; apt-get autoremove -y'"
alias updatedown="sudo -- sh -c 'apt-get update; apt-get upgrade -y; apt-get autoremove -y; shutdown -h now'"
alias updatedownup="sudo -- sh -c 'apt-get update; apt-get upgrade -y; apt-get autoremove -y; shutdown -r now'"


## Hardware

# alias hardware="xset -dpms && xmodmap -e 'add mod3 = Scroll_Lock'"
alias hardware="xmodmap -e 'add mod3 = Scroll_Lock'"
alias kleds='echo hardware; hardware'
setzoom() {
  [[ -z "$1" ]] && gsettings get org.gnome.desktop.interface text-scaling-factor \
    || gsettings set org.gnome.desktop.interface text-scaling-factor "$@";
}
# Right monitor does not respond to mouse clicks...
alias fuckyounumlock="xmodmap -e keycode 77 = ISO_Level3_Shift Num_Lock"
alias mouseFucked='echo Fixing the damn thing, do not cancel this...; compiz --replace &'
alias monitorFucked='xset dpms force off'
alias trackpadFucked='sudo sh -c "rmmod psmouse && modprobe psmouse proto=imps"'
volume() {
  pactl -- set-sink-volume $(pactl list short sinks |awk '{printf($1); exit;}') $(echo $1/100 |bc -l)
}
# alias specs='inxi -Fxzd'
alias specs='inxi -Fdflmopuxz' # -m (mem) requires root
alias fixdisplays='xrandr --output HDMI-0 --left-of DVI-I-0 --auto'
sound() {
  case "$1" in
    -t | --test)
      paplay $(find /usr/share/sounds/ -name '*.ogg' |head -n1)
    ;;
    -s | --set-default)
      pactl set-default-sink $(pactl list short sinks |awk '{printf($2); exit;}')
    ;;
    -v | --set-volume)
      shift
      pactl -- set-sink-volume $(pactl list short sinks |awk '{printf($1); exit;}') "$@"
    ;;
    tv)
      amixer set "Headphone" mute
      amixer set "Speaker" unmute
      # pacmd set-card-profile 1 output:hdmi-stereo-extra1+input:analog-stereo
      # pacmd set-default-sink alsa_output.pci-0000_00_1f.3.hdmi-stereo-extra1
      # pacmd set-card-profile 1 output:hdmi-stereo+input:analog-stereo
      # pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1 ||
      # pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo
    ;;
    # tv2)
    #   pacmd set-card-profile 1 output:hdmi-stereo+input:analog-stereo
    #   pacmd set-default-sink alsa_output.pci-0000_00_1f.3.hdmi-stereo
    # ;;
    hp)
      amixer set "Speaker" mute
      amixer set "Headphone" unmute
      # pacmd set-card-profile 1 output:analog-stereo+input:analog-stereo
      # pacmd set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
    ;;
    *)
      gnome-control-center sound &
    ;;
  esac
}

## Network

records() {
  if [ $# == 0 ] || [[ "$1" =~ -h|--help ]]; then
    echo "Usage: records DOMAIN [TYPE=any]"
    return
  fi
  dig +nocmd $1 ${2-any} +multiline +noall +answer
}
alias tranny='transmission-remote -n "transmission:transmission"'
debbie() {
  if [ "$(mip)" == "$HOMEIP" ]; then
    ssh $DEBBIEL
  else
    ssh $DEBBIE
  fi
}
alias lip='hostname -I |awk "{ print(\$NF); }"'
alias mip='curl -s whatismyip.io |grep -o "\([[:digit:]]\+\.\?\)\{3\}[[:digit:]]\+"'
alias netscan='sudo nmap -snP 192.168.0.1/24'
hotspot() {
  local CONNECTION=$(nmcli connection show --active |grep -o 'Hotspot-[0-9]\+')
  if [ -n "$CONNECTION" ]; then
    read -p 'Detected running connection "'$CONNECTION'", kill it? [y/N]' ans
    case $ans in
      y|Y|yes|YES) nmcli connection down $CONNECTION;;
      *) return;;
    esac
  else
    nmcli device wifi hotspot ssid lappy password NdQ8Z8rZ
  fi
}
alias localip=$'ifconfig wlp59s0 |awk -F\' +\' \'$2 ~ /inet$/ {print $3}\''
getOffMyWlan() {
  sudo unbuffer iwlist wlp6s0 scan | grep \ Channel |awk -F ':' '{count[$2]++} END {for (word in count) print count[word], word}' |sort
}
killthese() {
  name="$(getxname)"
  killall -9 $name
}
alias ports='sudo netstat -tulpn'
pidport() {
  if [ -z "$1" ]; then
    echo "Usage: pidport PID [-k]"
    return 1
  fi

  PIDAT="$(lsof -i:$1 -t)"
  if ! [ -z $PIDAT ] && ([ "$2" == "k" ] || [ "$2" == "-k" ]); then
    kill -9 $PIDAT
  elif [ -z $PIDAT ]; then
    echo "No processes found"
  else
    echo $PIDAT
  fi
}
ipinfo() {
  curl ipinfo.io/$1
  echo
}
alias restart-nginx='sudo sh -c "nginx -t && service nginx restart"'

## Git

alias gitroot='cd $(git rev-parse --show-toplevel)'

alias gitdefault="git remote show origin 2>/dev/null |awk -F': ' '\$1 ~ /HEAD/ {print(\$2);}'"
alias gitsetdefault="git remote set-head origin --auto || git remote set-head origin \$(git remote show origin 2>/dev/null |awk -F': ' '\$1 ~ /HEAD/ {print(\$2);}')"
alias tags='git fetch --tags && git tag --list --sort=creatordate --format="%(refname:short) [%(creatordate:iso)] %(objectname)"'
gdiff() {
  args=
  files=
  for arg in $@; do
    if [ ${arg:0:1} == '-' ]; then
      args="${args} ${arg}"
    else
      files="${files} ${arg}"
    fi
  done

  # --word-diff=color
  git diff $args -- ':(exclude)**/package-lock.json' ':(exclude)package-lock.json' ':(exclude)build/' ':(exclude).openapi-nodegen/' $files
}
alias gst='git status'
alias ghist='git log --follow -p --'
alias ghistall='git log --follow --all -p --'
alias gfetch='git fetch --all --prune --tags --prune-tags --keep'
prune-local() {
  branches
  local branches=$(branches -l)
  local del
  if [ -z "$branches" ]; then
    echo no branches to delete
    return 0
  fi
  echo "Found local branches: $branches"
  read -p 'Delete local branches [y/N]? ' del
  if [ "${del,,}" == 'y' ] || [ "${del,,}" == 'yes' ]; then
    git branch -D $branches
  fi
}
gbranchprune() {
  local force=-d
  case $1 in
    -f | --force | f | force) force=-D ;;
    -p | p | prune | --prune)
      prune-local
      return 0
    ;;
    '') git fetch --all --prune --tags --prune-tags --keep ;;
  esac

  local toDelete=$(git branch -vv | grep -o ' [^ ]\+ [a-f0-9]\+ \[.*: gone]' | awk '{print $1}')

  if [ -n "$toDelete" ]; then
    echo "Found branches which were deleted on the remote:"
    echo "$toDelete"
    read -p "Delete these branches [y/N]?" ans
    if [ "${ans,,}" == 'y' ] || [ "${ans,,}" == 'yes' ]; then
      git branch $force $toDelete
    fi
  fi

  # master=$(gitdefault)
  # git checkout $master
  # git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do
  #   mergeBase=$(git merge-base $master $branch) && \
  #   [[ $(git cherry $master $(git commit-tree $(git rev-parse $branch\^{tree}) -p $mergeBase -m _)) == "-"* ]] && \
  #   git branch -d $branch;
  # done
}
alias amend='git add -A && git commit --amend '
alias gmerge='git merge $(git remote)/$(git rev-parse --abbrev-ref HEAD)'
# alias stash='echo "git stash --include-untracked"'
showstash() {
  local line=${1:-0}
  ((line++))
  git rev-list -g stash | git rev-list --stdin --max-parents=0 | awk -v "line=$line" 'NR == line { printf($0); }' | xargs git show -p
}
stash() {
  # stash staged, unstaged, untracked
  # --keep-index, --no-keep-index
  if [ $# == 0 ]; then
    echo "stash all with 'stash --'"
    echo "stash files 'stash file [...file]'"
    return
  fi

  branch=$(git rev-parse --abbrev-ref HEAD)
  commit=$(git log --oneline -n1 --decorate)

  if [ $1 == '--' ]; then
    echo "stashing all"
    git stash push -m "$commit" --include-untracked
    return
  fi
  echo "stashing $# files"


  git stash push -m "$commit -- [$*]" --include-untracked $*
}

alias local-branch-compare='git branch -l |sed "s/\*\?\ \+//g" |while read branch; do echo $branch; git rev-list --left-right --count $branch...remotes/origin/$branch 2>/dev/null || echo; done'

git-clone-folders() {
  if [ $# -lt 3 ]; then
    echo "usage: git-clone-folders <output> <repo> <paths> [...paths]"
    return 1
  fi

  local outdir="$1"
  shift
  local origin="$1"
  shift
  local files=($@)

  mkdir -p "$outdir"
  cd "$outdir"
  git init
  git remote add origin "$origin"
  git config core.sparseCheckout true
  printf '%s\n' "${files[@]}" >.git/info/sparse-checkout

  main=$(git remote show $origin | sed -n '/HEAD branch/s/.*: //p')
  git fetch origin $main
  git merge origin/$main
}

glog() {
  local arg1="$1"
  shift
  case $arg1 in
    -n | --network | n)
      git log --all --decorate --oneline --graph --date=format:"%Y-%m-%d %H:%M" --pretty=format:"%C(auto)%h %C(dim)%ad | %C(auto)[%an] %s %d" "$@" ;;
    -s | --short | s)
      git log --date=format:"%Y-%m-%d %H:%M" --pretty=format:"%C(auto)%h %C(dim)%ad | %C(auto)[%an] %s %d" --color --graph "$@" ;;
    --simple)
      git log --format="%Cgreen%h%Creset [%an] %s%C(dim)%+b%Creset" $* ;;
    -d | --diff | d)
      git log -p "$@" ;;
    -f | --files | f)
      git log --oneline --stat "$@" ;;
    --from)
      shaOrDate="$2"
      if [[ "$shaOrDate" =~ ^[[:alnum:]]{40}$ ]] || [[ $shaOrDate =~ ^[[:alnum:]]{6}$ ]]; then
        cmd="$shaOrDate^..$(git rev-parse HEAD)"
        # Could add --to=$3
        # cmd="$shaOrDate^..${3-$(git rev-parse HEAD)}"
      elif [[ "$shaOrDate" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        cmd="--since $shaOrDate"
      else
        echo "Unsupported bound: '$2'"
        echo "Expecting SHA hash (6 or 40 chars) or date YYYY-MM-DD"
        return 1
      fi
      git log $cmd --date=short --pretty=format:'%h %ad %an | %s%d' "$@"
    ;;
    # -m | --medium | m)
    #   git log -n1 --color --pretty=format:"%C(auto)%h %C(dim)%ad %C(auto)%s%d" --date=format:"%Y-%m-%d %H:%M"
    # ;;
    -h | --help | h)
      echo "glog [-s,--short | -d,--diff | -n,--network | -h,--help] [-f,--from [SHA or date]]";;
    *)
      git log --stat --graph $arg1 "$@";;
  esac
}

gpull() {
  branch=${1-$(git branch |grep '\*' |sed 's/\*\ //g')}
  if [ $# == 2 ]; then
    remote="$branch"
    branch="$2"
  # elif [ $# == 1 ]; then
  #   remote="$1"
  #   branch=$(git branch |grep '\*' |sed 's/\*\ //g')
  else
    remote="${2-$(echo $(git remote))}"
  fi
  if [[ "$remote" =~ \  ]]; then
    echo Ambiguous remote - aborting
    return 1
  fi
  echo Pulling from $remote $branch
  git pull $remote $branch
}

gpush() {
  branch=${1-$(git branch |grep '\*' |sed 's/\*\ //g')}
  if [ $# == 2 ]; then
    remote="$branch"
    branch="$2"
  # elif [ $# == 1 ]; then
  #   remote="$1"
  #   branch=$(git branch |grep '\*' |sed 's/\*\ //g')
  else
    remote="${2-$(echo $(git remote))}"
  fi
  if [[ "$remote" =~ \  ]]; then
    echo Ambiguous remote - aborting
    return 1
  fi
  echo Pushing to $remote $branch
  git push $remote $branch
}

alias gshove='git push -f --no-verify'

gcam() {
  git add -A && \
  git commit -am "$*"
}

gcpush() {
  git add -A && \
  git commit -am "$*" && \
  gpush
}

geditmerge() {
  if [ -n "$(which sub)" ]; then
    editor=sub
  elif [ -n "$(which code)" ]; then
    editor=code
  else
    editor=vim
  fi
  local editor=${1-$editor}
  local root=$(git rev-parse --show-toplevel)
  local toedit=$(git diff --name-only --diff-filter=U)
  cd $root
  OIFS=$IFS
  IFS=$'\n'
  # $editor "$toedit"
  for file in $toedit; do
    $editor "$file"
  done
  IFS=$OIFS
  cd - &>/dev/null
}

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
  # Add git completion to aliases
  __git_complete gmerge _git_merge
  __git_complete gpull _git_pull
  __git_complete gpush _git_push
  __git_complete gcam _git_commit
  __git_complete gcpush _git_push
fi

new-repo() {
  # eg: new-repo '{"name":"test-repo","private":true}'
  local JSON="$1"
  if [ ! -f ~/.ssh/github_repo_key ]; then
    echo 'no git key'
    exit 1
  fi
  curl https://api.github.com/user/repos -H 'Content-Type: application/json' -H "Authorization: token $(cat ~/.ssh/github_repo_key)" -d $JSON
}
ismerged() {
  branches -r |sed 's/\ /\n/g' |while read branch; do
    [[ $branch =~ stage|master|develop ]] && continue
    branch=$(echo $branch |sed -e 's|remotes/origin/||g')
    echo -e "\n$branch"
    glog -n --color=always | grep --color=never "$branch"
  done
}

## Misc

# some_command |colour
alias nocolour="sed -e 's/\x1b\[[0-9;]*m//g'"
# some_command |logfile /tmp/log.txt
alias logfile="tee /dev/tty |nocolour >"
alias clip='xsel --input --clipboard'
one-liner() {
  while read line; do
    echo -ne "\033[2K\r$line"
  done
}

pedit() {
  img=/tmp/$(date +%s).png
  echo "trying to write and edit $img"
  pasteimage $img && pinta $img
}
screenshot() {
  local launch=xdg-open
  if [ -n "$1" ]; then
    launch=$1
  fi
  if [ -z $(command -v $launch) ]; then
    echo "command not found '$launch'"
    echo "usage: screenshot [program]"
    return 1
  fi
  output=/tmp/$(date +%s).png
  /usr/bin/import $output && $launch $output &>/dev/null && echo $output
}
randomWord() { shuf -n ${1:-1} /usr/share/dict/words ; }
random-secret() { LC_ALL=C tr -dc '[:alnum:]!@#$%^&*' < /dev/urandom | head -c${1-128}; }
random-hex() { LC_ALL=C tr -dc '0-9a-f' < /dev/urandom | head -c${1-128}; }
xxdiff() { diff <(xxd $1) <(xxd $2); }
alias getxname='basename $(ll /proc/$(xprop _NET_WM_PID | awk "{print \$NF}")/exe | awk "{print \$NF}")'
alias finance='google -b credit; google -b fcu'
alias resudo='sudo !!'
alias top='top -d2'
alias chromelog='tail -f ~/.config/google-chrome/chrome_debug.log'
alias pirate_search='node ~/source/programming/node/pirateSearch/pirate.js'
alias streams='google -w patmcgowan.ca/apps/stream'
alias vantime='TZ=America/Vancouver date +"%y.%m.%d %H:%M"'
alias own='sudo chown $(id -u):$(id -g)'
alias cdtemp='cd $(mktemp -d)'
crlfToLf() {
  sed -i -e 's/\r$//' "$@"
}
alias xlcsv='libreoffice --headless --convert-to csv'
asciitree() { tree "$*" | sed 's/├/\+/g; s/─/-/g; s/└/\\/g'; }

## Quickterm shortcut
alias bt='bf gnome-terminal'
# Resize term
ts() {
  resize -s ${1:-25} ${2:-80} >/dev/null
}
# Random crap
imout() {
  echo '~   _o
~  //\_
~ _/\
~   /'
}
alias zoidberg='echo "(V) (°,,,,°) (V)" |tee /dev/tty |xsel --input'
alias throwit='echo "(╯°□°）╯︵ ┻━┻" |tee /dev/tty |xsel --input'
alias shrug='echo "¯\_(ツ)_/¯" |tee /dev/tty |xsel --input'
ducksay() {
  echo '
 ._(`)<   "'$*'"
  \___)'
}
function fire! { echo -n '0-118-999-881-999-119-725'; sleep 2; echo 3; }
instant-server() {
  local port=${1:-${PORT:-8080}}
  local spa=${2-true}
  node -e "$(cat <<EOF
const http = require('http');
const fs = require('fs');
const path = require('path');
const index = path.resolve(process.cwd(), 'index.html');
const conType = s => ({
  '.html': 'text/html',
  '.css': 'text/css',
  '.xml': 'text/xml',
  '.gif': 'image/gif',
  '.jpeg': 'image/jpeg',
  '.jpg': 'image/jpeg',
  '.js': 'application/x-javascript',
  '.txt': 'text/plain',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.bmp': 'image/x-ms-bmp' }[path.extname(s)] || 'application/octet-stream');

http.createServer(async (i, o, n) => {
  o.on('finish', () => {
    let ip = i.headers['x-forwarded-for'] || i.connection.remoteAddress;
    console.log(\`\${ip} \${i.method} \${i.url} => \${o.statusCode}\`);
  });
  const target = (i.url || '').replace(/^\//, '').replace(/[?#].*/, '');
  const file = path.resolve(process.cwd(), target);
  const fExists = await fs.promises.access(file)
    .then(() => fs.promises.stat(file).then(s => !s.isDirectory()))
    .catch(() => false);

  if (fExists && fs.statSync(file).isFile()) {
    o.setHeader('Content-Type', conType(file));
    o.setHeader('Access-Control-Allow-Origin', '*');
    o.writeHead(200);
    fs.createReadStream(file).pipe(o);
  } else {
    if ($spa) {
      if ((target === '/' || target === '')) {
        const indexExists = await fs.promises
          .stat(index)
          .then((s) => s.isFile())
          .catch(() => false);

        o.setHeader('Content-Type', 'text/html');
        o.setHeader('Access-Control-Allow-Origin', '*');
        o.writeHead(200);
        fs.createReadStream(index).pipe(o);
        return;
      }

      const fileWithHtml = path.resolve(process.cwd(), target + '.html');
      const htmlFileExists = await fs.promises.access(fileWithHtml)
        .then(() => fs.promises.stat(fileWithHtml).then(s => !s.isDirectory()))
        .catch(() => false);

      if (htmlFileExists) {
        o.setHeader('Content-Type', 'text/html');
        o.setHeader('Access-Control-Allow-Origin', '*');
        o.writeHead(200);
        fs.createReadStream(fileWithHtml).pipe(o);
        return;
      }
    }

    o.writeHead(404, { headers: corsHeaders });
    o.end();
  }
}).listen($port, () => console.log('up on $port'));
EOF
)"
}
unicode() {
  read -p 'enter char(s): ' char;
  echo -n $char |             # -n ignore trailing newline
  iconv -f utf8 -t utf32be |  # UTF-32 big-endian happens to be the code point
  xxd -p |                    # -p just give me the plain hex
  sed -r 's/^0+/0x/' |        # remove leading 0's, replace with 0x
  xargs printf 'U+%04X\n'     # pretty print the code point
}
watchdo() {
  FILE=$1
  shift
  CMD=$*
  if [ -z "$FILE" ] || [ -z "$CMD" ]; then
    echo "usage: watch-do FILE CMD"
    return 1
  fi

  LTIME=$(stat -c %Z "$FILE")

  echo "will run '$CMD' on changes to '$FILE'"

  while true; do
    ATIME=$(stat -c %Z "$FILE")

    if [[ "$ATIME" != "$LTIME" ]]; then
      echo "$CMD"
      eval $CMD
      LTIME=$ATIME
    fi

    sleep 0.5
  done
}

## Work

gsts()  {
  sub $(git status --short "$@" |awk '{ print($2); }')
}
sprt() {
  tmux at -t 'spotify' 2>/dev/null || \
  tmux new-session -t 'spotify' \; \
    send-keys "spirate" C-m \;
}
acrvpn() {
  tmux at -t 'acrvpn' 2>/dev/null || \
  tmux new-session -t 'acrvpn' \; send-keys "sudo ~/work/vpn" C-m \;
}
recompose() {
  if [ ! -f docker-compose.yml ]; then
    echo no compose here
    return 1
  fi

  docker compose up -d --build --force-recreate $@
}
compose-logs() {
  local composeFile=${1:-apps.compose.yml}
  if [ -n "$TMUX" ]; then
    goto dsdc && docker compose -f $composeFile logs -f --tail=200 | grep -v 'admin/health\|OPTIONS'
  else
    tmux at -t 'compose-logs' 2>/dev/null || {
      tmux new-session -t 'compose-logs' \; \
        send-keys "goto dsdc && docker compose -f $composeFile logs -f --tail=200 | grep -v 'admin/health\|OPTIONS'" C-m \;
    }
  fi
}
alias wh='watcherHelper'

kcc() {
  [ ! -t 1 ]
  isTTY=$?

  [[ -z "$1" ]] && kubectl config get-contexts | awk -v isTTY=$isTTY -F '  +' '{
    if ($1 == "*" && isTTY) {
      printf("\033[0;1m%s  %s  %s\033[0;0m\n", $2, $3, $NF);
    } else {
      printf("%s  %s  %s\n", $2, $3, $NF);
    }
  }' |column -t || {
    if [[ "$1" == -p ]]; then
      kubectl config get-contexts |awk '$1 == "*" { print($2); }'
    elif [[ "$1" == -l ]]; then
       kubectl config get-contexts |awk 'NR > 1 { if ($1 == "*") { print($2); } else { print($1); } }'
    else
      if [ -n "$2" ]; then
        local namespace="--namespace $2"
      fi
      kubectl config use-context "$1" $2 1>&2
    fi
  }
}
fast-mocha() {
  local splits=4
  if [ -n "$1" ]; then
    splits=$1
  fi
  # 0-54
  (
    # local files=$(ls **/*.spec.js |grep -v '/dist/')
    # local perpage=$((${#files[@]} / $splits))
    tmux new-session \; \
      split-window -h \; \
      split-window -h \; \
      split-window -h \; \
      send-keys -t0 'echo "0-13" |mocha -i' C-m \; \
      send-keys -t1 'sleep 1; echo "14-26" |NOSTARTUP=true mocha -i' C-m \; \
      send-keys -t2 'sleep 1; echo "27-39" |NOSTARTUP=true mocha -i' C-m \; \
      send-keys -t3 'sleep 1; echo "40-54" |NOSTARTUP=true mocha -i' C-m \; \
      select-layout even-vertical
  )
}
alias npm-update="npm i \$(npm outdated |awk 'NR > 1 { printf(\"%s@latest\n\", \$1); }')"
# JSON.stringify([].map.call(document.querySelectorAll('.opblock-summary'), e => e.innerText))
alias routes="curl http://api.test/swagger/swagger-ui-init.js 2>/dev/null |grep '^\ \ \ \ \ \ \{1,9\}\"\/.*'"

hours-from() {
  if [ -z "$1" ]; then
    echo "usage: hours-from [[[yyyy]mm]dd]"
    return 1
  fi
  local tmp=$(date +%Y%m%d)
  local theDate=${tmp:0:8-${#1}}${1}
  local YEAR=${theDate:0:4}
  local MON=${theDate:4:2}
  local DAY=${theDate:6:2}
  local FROM_DATE="$YEAR-$MON-$DAY"

  # read YEAR MON DAY <<<$(date -I |sed 's/-/ /g')
  # local TO_DATE=$(date -I |sed 's/-/ /g')
  local TO_DATE=$(date -I -d tomorrow)

  while [ "$FROM_DATE" != "$TO_DATE" ]; do
    HOURS_DATE="$(echo $FROM_DATE |sed 's/-//g')"
    hours ${HOURS_DATE:2}
    FROM_DATE=$(date -I -d "$FROM_DATE +1 days")
    echo -e '\033[1;31m--------------------------------------------\033[0;0m'
  done
}
hours() {
  if [ -z "$1" ]; then
    echo "usage: hours [[[yyyy]mm]dd]"
    return 1
  fi
  local indate=$1

  local log=
  local args=
  if [ "$2" == "-v" ]; then
    args='-p . :(exclude)**/package-lock.json'
  else
    args=$2
  fi

  local here=$(pwd)

  local timedata=$(timesheet -d "$indate")
  if [[ $timedata =~ ^No ]]; then
    echo -ne "\033[0;33m"
  else
    echo -ne "\033[1;33m"
  fi
  echo -ne "${timedata}\033[0;0m\n"

  # for projectsDir in dsd gen bbox aos; do
  for projectsDir in aos ii ia; do
    goto $projectsDir -q || continue
    for project in $(find $PWD -maxdepth 4 -type d -name .git 2>/dev/null); do
      if [ -f $(dirname $project)/../.gitmodules ] && grep -q $(basename $(dirname $project)) $(dirname $project)/../.gitmodules; then
        continue
      fi
      # skip scripts
      if [ $(basename $(dirname $project)) == "config" ]; then
        continue
      fi

      cd $(dirname $project)
      log=$(gdaycom $indate $args)
      if [ -n "$log" ]; then
        echo -e "\n\033[1;36m${projectsDir}@$(basename $(pwd))\033[0;0m"
        echo -e "$log"
      fi
    done
  done

  cd $here &>/dev/null
}

gdaycom() {
  git config --global grep.extendedRegexp true
  if ! [ -z "$1" ]; then
    local today=$(date +"%Y%m%d")
    local when="${today:0:-${#1}}$1"
    shift
    local year=${when:0:4}
    local month=0${when:4:2}
    local day=0${when:6:2}
    local fmtDate=$year-${month: -2}-${day: -2}
    # %h %ad | %s%d [%an]
    git log --color --after="$fmtDate 00:00" --before="$fmtDate 23:59" --all --author="p-mcgowan|Patrick McGowan" --pretty=format:"%C(auto)%h %C(dim)%ad %C(auto)%s%d" --date=format:"%Y-%m-%d %H:%M" $@
    # cd $here
  else
    echo 'usage: gdaycom [[YYYY]MM]DD'
    echo 'replaces current date from right to left (day first, mo, ...)'
    echo 'git log --after="<DATE> 00:00" --before="<DATE> 23:59"'
  fi
}

alias tsi='timesheet -i'
alias tso='timesheet -o'
alias tsu='(cd ~/source/work && gcam wip; gpull; gpush)'

s3get() {
  if [ -z "$1" ]; then
    echo 'usage: s3get hash [pij] [bucket]'
    echo 'default bucket is "dev"'
    return 1
  fi

  hash=$1
  option=${2-j}
  bucket=${3-dev}
  case $option in
    p | -p) path="${hash}/output.pdf";;
    j | -j) path="${hash}/output.json";;
    i | -i) path="${hash}/output.json";;
    '') path="${hash}/output.json";;
    *)
      echo "unknown option \"$option\""
      echo "must be [pij]"
      return 1
    ;;
  esac

  if [ "$option" == "i" ] || [ "$option" == "-i" ]; then
    res="$(api get -w "http://nest.test/api/ocr/${hash}/nojson")"
    echo "$res"
    regex='"imageKey":\ ?"([^"]+)"'
    [[ "$res" =~ $regex ]]
    path=${BASH_REMATCH[1]}
  fi

  wget "s3.test/${bucket}/${path}"
}

alias backflag='echo "background-image: url("https://upload.wikimedia.org/wikipedia/en/thumb/c/cf/Flag_of_Canada.svg/1280px-Flag_of_Canada.svg.png");
background-size: contain;
background-repeat: no-repeat;
background-position: center;"'

alias flint='npm run lint -- --fix && npm run format -- --l'
alias vtstest='VTESTTS=true vtest'

vtsc() {
  local files
  if [ -z "$*" ]; then
    if [ -f './tsc-errors.log' ]; then
      files=$(cat './tsc-errors.log')
    else
      compiler=tsc
      if npm list -depth=0 ttypescript &>/dev/null; then
        compiler=ttsc
      fi
      files=$(npx $compiler --noEmit)
    fi
  else
    files="$*"
  fi
  while read line; do [[ $line =~ ^([^\(]+)\(([0-9]+) ]] && echo $line && sub "${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"; done <<<$files
}

# alias vtsc='sub $(npx tsc |awk -F'"'"'[: ]'"'"' '"'"'{ if ($2 ~ /^[[:digit:]]+$/ && $3 ~ /^[[:digit:]]+$/) { printf("%s:%s\\n", $1, $2) } }'"'"')'

# alias v2c='LOG_LEVELS="default:all;debug:all;" NODE_ENV=${NODE_ENV:-mock} bash ~/bin/watcherHelper -wr v2c'
# alias plant='NODE_ENV=${NODE_ENV:-mock} bash ~/bin/watcherHelper -vvvwr plant'
client() {
  if ! [ -f './package.json' ]; then
    echo "Prolly wrong dir"
    return 1;
  fi
  sed -i "s/process.env.NODE_ENV = 'development';/process.env.NODE_ENV = process.env.NODE_ENV || 'development';process.env.REACT_APP_ENV = process.env.NODE_ENV;/" node_modules/react-scripts/scripts/start.js
  sed -i "s/require.resolve('react-dev-utils\/webpackHotDevClient'),/null,/" node_modules/react-scripts/config/webpack.config.js
  sed -i "s/.*'%cDownload the React DevTools '/\/\//" node_modules/react-dom/**/*.js
  # sed -i "s/process.env.BABEL_ENV = 'development';/process.edsdBABEL_ENV = process.env.BABEL_ENV || 'development';/" node_modules/react-scripts/scripts/start.js
  # line=$(sed -n '/socket.installHandlers(this.listenidsdpp, {/=' node_modules/webpack-dev-server/lib/Server.js)
  # sed -i -e "$((line++))s|^\ \ |//|" -e "$((line++))s|^\ \ |//|" -e "$((line++))s|^\ \ |//|" node_modules/webpack-dev-server/lib/Server.js
  NODE_ENV=${NODE_ENV:-development} npm start
}
alias teams="~/tmp/teams-unpacked/start.sh"

morning() {
  case $1 in
    lbsi)
      google -b outlook -b "bmw mail" -b ghme -b "lbsi hub" -b "lbsi automize github"
      psub acr
      teams
      pmux ia
    ;;
    aos)
      google -b outlook -b "bmw mail" -b "jira sprint progress board view" -b ghme -b "AOS HUB" -b "aos bitbucket"
      psub acr
      teams
      pmux aos
    ;;
    dsd)
      teams
      google -b outlook -b "bmw mail" -b "jira sprint board DSD" -b ghme -b "dsd hub"
      psub acr
      pmux dsd
    ;;
    gen)
      psub gen
      pmux gen
    ;;
    hc)
      slack
      google -b hcgh
      psub hc
      pmux hc
    ;;
    -d | --dir)
      shift
      cd ${1:-./}
      if [ ! -f *.sublime-project ]; then
        echo could not find project $1/*.sublime-project
        return 1
      fi
      sub *.sublime-project
      ptmux
    ;;
    *)
      echo "[-d dir] [dsd|gen|hc]"
    ;;
  esac
}
psub() {
  case $1 in
    '') [ -f *.sublime-project ] && sub *.sublime-project || echo 'no sublime-project here' ;;
    *)
      local target=$(goto -c $1)
      if [ -n "$target" ] && [ -f $target/*.sublime-project ]; then
        sub $target/*.sublime-project
      elif [ -f $1/*.sublime-project ]; then
        sub $1/*.sublime-project
      else
        echo "no sublime-project: $1/"
      fi
    ;;
  esac
}
pmux() {
  # vpnRunning=$(tmux list-session |grep -q acrvpn && echo 'yes')

  case $1 in
    '') [ -f *.sublime-project ] && sub *.sublime-project || echo 'no sublime-project here' ;;
    dsd)
      goto dsd;
      tmux new-session \; \
        split-window -v \; \
        send-keys -t0 'docks -u config' C-m \; \
        select-pane -t0 \;
        # select-pane -t1 \; \
        # send-keys -t1 "pew pew" C-m \;
    ;;
    ia | lbsi)
      goto ia;

      tmux new-session \; \
        split-window -v \; \
        send-keys -t0 'goto id' C-m "docker compose up -d --build --force-recreate $compose_apps" C-m 'docker compose logs -f' C-m \; \
        send-keys -t1 'goto id' C-m  'gst' C-m \; \
        select-pane -t1 \;
    ;;
    aos)
      goto aos;

      compose_apps=""
      # if [ -f docker/docker compose.yml ]; then
      #   compose_apps="$(awk -F '[ :]+' '
      #     /^services/ {
      #       reading_services = 1;
      #       next;
      #     }
      #     /^[a-z\-_0-9]/ {
      #       reading_services = 0;
      #     }
      #     /^  [a-z\-_0-9]+:/ {
      #       if (reading_services && $2 != "aos2-vehicle-backend") {
      #         printf("%s ", $2);
      #       }
      #     }' docker/docker compose.yml)"
      # fi
      # if [ -z "$vpnRunning" ]; then
      #   cmd=

      tmux new-session \; \
        split-window -v \; \
        send-keys -t0 'goto ad' C-m "docker compose up -d --build --force-recreate $compose_apps" C-m 'docker compose logs -f' C-m \; \
        send-keys -t1 'goto ad' C-m 'gst' C-m \;
    ;;
    *)
      local target=$(goto -c $1)
      if [ -n "$target" ]; then
        goto $1;
        tmux new-session \; \
          split-window -v \; \
          send-keys -t0 'docks -u' C-m \; \
          select-pane -t0 \;
      fi
    ;;
  esac
}
ptmux() {
  if [ -n "$1" ]; then
    cd $1
  fi
  tmux new-session \; \
  split-window -v \; \
  split-window -t 1 -h \; \
  select-layout tiled \; \
  select-pane -t2 \;
}
vctmux() {
  tmux new-session \; \
  split-window -h \; \
  split-window -t 0 -v \; \
  send-keys -t0 'cd docker/dev/ && docker compose -f docker compose-local-fs.yml -p v2c up -d --build --remove-orphans && cd ../../' C-m \; \
  send-keys -t1 'cd backend/' C-m \; \
  select-pane -t2 \;
}
pstmux() {
  tmux new-session \; \
  split-window -h \; \
  split-window -t 0 -v \; \
  send-keys -t0 'cd client/; cd ../../docker/dev/ && docker compose -f docker compose-local-fs.yml -p ps up -d --build --remove-orphans && cd -' C-m \; \
  send-keys -t0 'nvm use lts/dubnium ; client' C-m \; \
  send-keys -t1 'cd backend/' C-m \; \
  send-keys -t1 'nvm use lts/dubnium ; backend' C-m \; \
  select-pane -t2 \;
}
gstmux() {
  tmux new-session \; \
  split-window -h \; \
  send-keys -t0 'cd infrastructure/docker/ && docker compose up -d --build --remove-orphans && cd ../../' C-m \; \
  send-keys -t1 'cd backend/' C-m \;
}
gtmux() {
  tmux new-session \; \
  split-window -h \; \
  send-keys -t0 "gst" C-m \; \
  send-keys -t1 "gdiff $@" C-m \;
}
mtmux() {
  zs b
  tmux new-session \; \
  split-window -h \; \
  send-keys -t0 'zw npm start' C-m \; \
  send-keys -t1 'gst' C-m \;
}

perty() {
  local usage="\
Usage: perty [options] file_glob
options:
  --write     Write changes to file
  -d, --diff  Show changes in diff format
  -h, --help  Show this menu\
"

  if [[ $# -lt 1 ]]; then
    echo "$usage"
    return 1
  fi

  local write=
  local files=
  local diffMode=false

  while ! [ -z "$1" ]; do
    case $1 in
      --write) write='--write';;
      -d|--diff) diffMode=true;;
      -h|--help) echo "$usage"; return 0;;
      *) files="$files $1";;
    esac
    shift
  done

  if $diffMode; then
    for file in $files; do
      echo $file
      diff $file <(npx prettier --config ~/.prettierrc $file)
    done
  else
    if [ -z $write ]; then
      echo "Dry run - use '--write' to replace in place"
    fi
    prettier --config ~/.prettierrc $write $files
  fi
}

rereg() {
  email="test@example.com"
  password="password"
  case $# in
    0);;
    1)
      [[ "$1" =~ (.*):(.*) ]] && email=${BASH_REMATCH[1]} && password=${BASH_REMATCH[2]} || (echo huh? && return 1)
    ;;
    2)
      email=$1
      password=$1
    ;;
    *) echo "rereg [username[:password]]\nrereg [username [password]]"; return 1;;
  esac
  api post auth/register -d '{"email":"'$email'","password":"'$password'"}'
  echo -n 'Enter registration hash: '
  read hash
  api get "auth/verify-email?hash=$hash"
}

pmon() {
  cmd='pm2 monit'
  container=live
  usage="
run docker exec -ti ps_v2c_\${container}_1 \$cmd
defaults: container=$container, cmd=$cmd
  l, -l  cmd=\"bash -l\"
  L, -L  cmd=\"bash -c 'tail -f /opt/log/*/*.log'\"
  t, -t  cmd=\"htop\"
  c, -c  container=mock
  h, -h  show this
  "
  while ! [ -z $1 ]; do
    case $1 in
      l|-l) cmd='bash -l';;
      L|-L) cmd='bash -c "tail -f /opt/log/*/*.log"';;
      t|-t) cmd='htop';;
      c|-c) container=mock;;
      h|-h) echo "$usage"; return 0;;
      *) echo 'huh?'; echo "$usage"; return 1;;
    esac
    shift
  done
  echo docker exec -ti ps_v2c-${container}_1 $cmd
  eval "docker exec -ti ps_v2c-${container}_1 $cmd"
}

lint() {
  (
    project-root
    if [ ! -f package.json ]; then
      echo >&2 "no package json here"

      return 1
    fi

    if grep -q '"lint:fix"' package.json; then
      npm run lint:fix
    elif grep -q '"lint"' package.json; then
      npm run lint -- --fix
    elif grep -q '"fmt"' package.json; then
      npm run fmt
    elif grep -q '"format"' package.json; then
      npm run format
    else
      echo 'not sure what to run'
      npm run

      return 1
    fi

    return $?
  )
}

spindex() {
  TMUX=
  tmux at -t 'spindex' 2>/dev/null || {
    goto ps -q
    cd backend
    tmux new-session -t 'spindex' \; \
      split-window -h \; \
      select-pane -t 0 \; \
      send-keys "nvm use 10 && watcherHelper -vvvr cli -- -i" C-m \; \
      select-pane -t 1 \; \
      send-keys "nvm use 10 && watcherHelper -vvvr ramrod" C-m \; \
      select-layout even-vertical
  }
}

zs() {
  local usage="zs [b | f | s]
swap folders
"

  if [ ! -d "$(git rev-parse --show-toplevel)/.git" ]; then
    echo "not a git folder"
    return 1
  fi

  local calledFrom=$(git rev-parse --show-toplevel)
  local projectRoot=$(realpath "$calledFrom/..")

  if [ -d $projectRoot/*swagger ]; then
    local swaggerProject=$(basename $(find $projectRoot -maxdepth 1 -name *swagger))
    local backendProject=${swaggerProject/[-_]swagger/}
    local frontendProject=$projectRoot/$(ls $projectRoot |grep -v "$swaggerProject\|$backendProject")
    local swaggerProject="$projectRoot/$swaggerProject"
    local backendProject="$projectRoot/$backendProject"
  fi

  local target=
  case "$1" in
    s | -s | --swagger) target=$swaggerProject ;;
    b | -b | --backend) target=$backendProject ;;
    f | -f | --frontend) target=$frontendProject ;;
    '')
      case $calledFrom in
        $frontendProject | $swaggerProject) target=$backendProject ;;
        $backendProject) target=$swaggerProject ;;
        *) echo "couldn't figure out where we are" && return 1 ;;
      esac
    ;;
    *) echo "$usage" && return 1 ;;
  esac

  if [ -z "$target" ]; then
    echo "couldn't figure out what to do"
    return 1
  fi

  cd $target
}
vbump() {
  gitroot
  INITIAL_VERSION=$(awk -F'"' '$2 ~ /version/ { printf($4); }' package.json)

  localVersionNotGreater() {
    CURRENT_VERSION=$(awk -F'"' '$2 ~ /version/ { printf($4); }' package.json)
    if [ -z "$DEV_LATEST" ]; then
      echo "package json does not appear to be on dev"
      return 1
    fi

    if [ "$DEV_LATEST" = "$CURRENT_VERSION" ]; then
      return 0
    fi

    SEMVER_SORTED=$(echo -ne "$CURRENT_VERSION\n$DEV_LATEST" |sort -rV | tr -s '\n' ' ')
    SEMVER_SORTED=${SEMVER_SORTED:0:-1}

    if [ "$SEMVER_SORTED" != "$CURRENT_VERSION $DEV_LATEST" ]; then
      return 0
    fi

    return 1
  }

  git fetch --all --prune --tags --prune-tags
  DEV_LATEST=${TARGET_VERSION:-$(git show origin/develop:package.json |awk -F'"' '$2 ~ /version/ { printf($4); }')}
  while localVersionNotGreater; do
    BUMPED=$(npm --no-git-tag-version version patch)
  done

  if [ -n "$BUMPED" ]; then
    VERSION=$(awk -F'"' '$2 ~ /version/ { printf($4); }' package.json)
    echo -e "\nupdated \033[0;33m$INITIAL_VERSION -> $VERSION\033[0;0m\n"
    sed -ri "s/^(\s*)(version\s*:\s*.*$)/\1version: ${VERSION}/" helm/dsd*/Chart.yaml
    git add package.json package-lock.json helm/dsd*/Chart.yaml
    git commit package.json package-lock.json helm/dsd*/Chart.yaml -m "v$VERSION"
  else
    echo -e "\nlatest version [v$CURRENT_VERSION] ahead of origin/develop [v$DEV_LATEST] - \033[0;32mskipping version bump\033[0;0m\n"
  fi
}

jest() {
  if [ ! -f package.json ]; then
    gitroot
  fi
  if [ "$1" == "-s" ]; then
    args="--setupFilesAfterEnv=$HOME/work/unmangle-jest-console.js"
    shift
  fi
  NODE_ENV=test npx jest --collectCoverage false --verbose --runInBand --passWithNoTests $args $*
}

b64() {
  local decode=
  case $1 in
    e | -e | encode | --encode) shift ;;
    d | -d | decode | --decode) decode="-d"; shift ; ;;
    h |-h | help | --help) echo "b64 [-d] ...args"; return 0; ;;
  esac

  for i in "$@"; do
    echo -en "$i\n$(echo -n "$i" |base64 -w0 $decode)\n"
  done
}

gen() {
  npm run generate:nodegen --yes "$@"
}
difftool() {
  git mergetool --tool=vimdiff
}
