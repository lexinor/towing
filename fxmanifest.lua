fx_version 'cerulean'
game 'gta5'

description 'Towing script'
version '1.0.2'

lua54 "true"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
}

client_scripts {
    "config.lua",
    "client.lua"
}