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

cat /proc/sys/crypto/fips_enabled 2>/dev/null || echo NOFIPS


ssh-keygen -t rsa -b 4096 -C "rsa-test" -f "$HOME/.ssh/rsa_test" -N ""

cat "$HOME/.ssh/rsa_test.pub" >> "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

ssh -i "$HOME/.ssh/rsa_test" -o IdentitiesOnly=yes -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new "$(whoami)@localhost" 'whoami'

grep -ri authorizedkeys /etc/ssh/sshd_config.d/ 2>/dev/null || echo NONE


ls /etc/ssh/sshd_config.d/ && cat /etc/ssh/sshd_config.d/* >/dev/null 2>&1 && echo READABLE || echo UNREADABLE
