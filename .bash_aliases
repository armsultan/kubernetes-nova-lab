# kubectl pods
alias k='kubectl'
alias kg='kubectl get'
alias kgpod='kubectl get pod'
alias kgall='kubectl get --all-namespaces all'
alias kdp='kubectl describe pod'
# kubectl apply
alias kap='kubectl apply'
# kubectl delete
alias krm='kubectl delete'
alias krmf='kubectl delete -f'
# kubectl services
alias kgsvc='kubectl get service'
# kubectl deployments
alias kgdep='kubectl get deployments'
# kubectl misc
alias kl='kubectl logs'
alias kei='kubectl exec -it'

if [[ ! -o vi ]]; then
  # Required to refresh the prompt after fzf
  bind '"\er": redraw-current-line'
  bind '"\e^": history-expand-line'

  # CTRL-R - Paste the selected command from history into the command line
  bind '"\C-r": " \C-e\C-u\C-y\ey\C-u$(HISTTIMEFORMAT= history | fzf-history)\e\C-e\er\e^"'
fi