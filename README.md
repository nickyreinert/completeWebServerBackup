# completeWebServerBackup
Script to simple backup all existing databases and virtual hosts of an server running Apache and MySQL to any given location using duplicity.

# Installation

* copy the content from scripts/ to an location on your server
* make them executable
* edit conf-files and add your configuration
** MySql-User
** GnuPG-key information
** folder settings
* add cron call

# External references and thanks
- instructions in German on
-- https://www.nickyreinert.de/den-eigenen-web-server-sichern/
- initial duplicity tutorial, thanks to Justin Ellingwood:
-- https://www.digitalocean.com/community/tutorials/how-to-use-duplicity-with-gpg-to-securely-automate-backups-on-ubuntu
- thanks to Jean-Tiare Le Bigot for this simpel backup plan
-- https://blog.yadutaf.fr/2012/09/08/lazy-man-backup-strategy-with-duplicity-part-1/
- how to get current script's path
-- https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
- explode string to array
-- thanks to Dennis Williamson @ https://stackoverflow.com/a/31405855/2360229
