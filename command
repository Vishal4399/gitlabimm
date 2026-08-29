grep -Ei '^[[:space:]]*(AuthorizedKeysFile|AuthorizedKeysCommand|PubkeyAuthentication|AllowUsers|AllowGroups|DenyUsers|DenyGroups|StrictModes)' /etc/ssh/sshd_config 2>/dev/null || echo NO-ACCESS


K="$HOME/.ssh/gitlab_batch_deploy_dev"    # adjust if your filename differs

ssh -vvv -i "$K" -o IdentitiesOnly=yes -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    "$(whoami)@localhost" true 2>&1 \
  | grep -Ei 'offering|send_pubkey|server accepts|authentications that can|no more auth|denied|invalid format|Trying private'

wc -c < "$HOME/.ssh/authorized_keys"
ssh-keygen -lf "$HOME/.ssh/authorized_keys" 2>&1 | cut -c1-30

ssh -i "$HOME/.ssh/gitlab_batch_deploy" -o IdentitiesOnly=yes -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new "$(whoami)@localhost" 'whoami; hostname'


[ "$(ssh-keygen -y -f "$HOME/.ssh/gitlab_batch_deploy" | awk '{print $1,$2}')" = "$(awk '{print $1,$2}' "$HOME/.ssh/authorized_keys")" ] && echo MATCH || echo MISMATCH

awk '{print $3}' "$HOME/.ssh/authorized_keys"

[ "$(getent passwd "$(whoami)" | cut -d: -f6)" = "$HOME" ] && echo SAME || echo DIFFERENT
