fx_version 'adamant'

game 'gta5'

description 'Tracking System using Phone Number'

client_script 'client.lua'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
	'server.lua'
}
