fx_version 'cerulean'
game 'gta5'


ui_page "nui/index.html"

client_scripts {
	"config.lua",
	"client.lua"
} 

shared_script '@es_extended/imports.lua'

server_script {
	'@mysql-async/lib/MySQL.lua',
	"config.lua",
	"server.lua"
}

files {
	"nui/index.html",
	"nui/script.js",
	"nui/css.css"
}