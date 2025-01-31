find /var/log -type f -exec sh -c "cat /dev/null > {}" \;
rm -rf /root/.cache
rm -rf /tmp/*
rm -rf /root/.wget-hsts
find / -type f -name '.bash_history'
find /var/log -type f -name '*.gz' -delete

# Clear out history. Works with bash, but not with zsh.
cat /dev/null | tee /root/.bash_history /home/simspace/.bash_history

# Just remove the history session
exec rm "$HISTFILE" 
