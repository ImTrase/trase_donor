fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Trase'
description 'A tebex to fivem api where customers can automatically claim packages.'
version '1.0.1'

shared_script 'configuration/config.lua'
client_scripts { 'frameworks/**/client.lua', 'client/*.lua' }
server_scripts { 
    'configuration/server.lua',
    'frameworks/**/server.lua', 
    'server/*.lua',
    '@mysql-async/lib/MySQL.lua' -- If you are not using vehicles, then you can disable this
}

escrow_ignore { 
    'configuration/**/*.lua',
    'frameworks/*.lua',
    'server/*.lua',
    'client/*.lua',
}