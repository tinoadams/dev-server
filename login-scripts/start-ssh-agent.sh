function startAgent() {
    echo "Starting new SSH-AGENT instance..."
    killall ssh-agent
    ssh-agent -s > ~/.ssh/agent-env
}
ps -ef | grep "ssh-agent -s$" > /dev/null || startAgent
[ -s ~/.ssh/agent-env ] || startAgent

source ~/.ssh/agent-env
# register all pub keys with agent
ls ~/.ssh/*.pub | while read f; do ssh-add $(dirname ${f})/$(basename $f .pub); done