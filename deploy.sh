ssh deploy@one.sigfigs.io 'mkdir -p ~/house_to_trello'
rsync -vzcrSLhp --exclude=".git" ./ deploy@one.sigfigs.io:house_to_trello
ssh deploy@one.sigfigs.io 'cd house_to_trello && ./install_crontab.sh'
