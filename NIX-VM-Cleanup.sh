find /var/log -type f -exec sh -c "cat /dev/null > {}" \;

rm -rf /root/.cache

rm -rf /tmp/*

rm -rf /root/.wget-hsts

cat /dev/null | tee /root/.bash_history /home/<USER>/.bash_history && history -c && init 0

find / -type f -name '.bash_history'

find /var/log -type f -name '*.gz' -delete
