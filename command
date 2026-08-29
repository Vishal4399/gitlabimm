grep -Ei '^[[:space:]]*(AuthorizedKeysFile|AuthorizedKeysCommand|PubkeyAuthentication|AllowUsers|AllowGroups|DenyUsers|DenyGroups|StrictModes)' /etc/ssh/sshd_config 2>/dev/null || echo NO-ACCESS


K="$HOME/.ssh/gitlab_batch_deploy_dev"    # adjust if your filename differs

ssh -vvv -i "$K" -o IdentitiesOnly=yes -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    "$(whoami)@localhost" true 2>&1 \
  | grep -Ei 'offering|send_pubkey|server accepts|authentications that can|no more auth|denied|invalid format|Trying private'
