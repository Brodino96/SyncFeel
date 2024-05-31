fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Brodino"
descritpion "Sync what happens inside the game with your sex toys"
version "1.0"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua",
    "locale/*",
}

server_scripts {
    "server/*",
}

client_scripts {
    "client/*",
}

ui_page "web/index.html"
files { "web/*" }

dependency "ox_lib"

escrow_ignore {
    "config.lua"
}