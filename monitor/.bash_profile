# .bash_profile
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs
export K2_HOME=/opt/apps/monitor
PATH=$PATH:$HOME/.local/bin:$HOME/bin:$K2_HOME/grafana/bin


cd $K2_HOME/
## k2view extra settings ###
LTGREEN="\[\033[40;1;32m\]"
LTBLUE="\[\033[40;1;34m\]"
CLEAR="\[\033[0m\]"
LIGHT_GRAY="\[\033[40;1;33m\]"
export PS1="$LTGREEN\u$LTBLUE@\h:$LIGHT_GRAY\w$CLEAR . "

## ALIASES ## (Works with monitor_manager.sh)
alias status='sh ~/scripts/monitor_manager.sh all status'
alias grafana-status='sh ~/scripts/monitor_manager.sh grafana status'
alias prometheus-status='sh ~/scripts/monitor_manager.sh prometheus status'
alias loki-status='sh ~/scripts/monitor_manager.sh loki status'
alias grafana-start='sh ~/scripts/monitor_manager.sh grafana start'
alias prometheus-start='sh ~/scripts/monitor_manager.sh prometheus start'
alias loki-start='sh ~/scripts/monitor_manager.sh loki start'
alias grafana-stop='sh ~/scripts/monitor_manager.sh grafana stop'
alias prometheus-stop='sh ~/scripts/monitor_manager.sh prometheus stop'
alias loki-stop='sh ~/scripts/monitor_manager.sh loki stop'
