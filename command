grep -Ei '^[[:space:]]*(AuthorizedKeysFile|AuthorizedKeysCommand|PubkeyAuthentication|AllowUsers|AllowGroups|DenyUsers|DenyGroups|StrictModes)' /etc/ssh/sshd_config 2>/dev/null || echo NO-ACCESS
