fx_version 'cerulean'
game 'gta5'

author 'AiReiKe'
description 'Eric QBCore Job Vehicle'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'locales/*.lua',
    'config.lua'
}

client_script 'client.lua'
server_scripts {
    'server/*.lua'
}

dependency 'qb-core'