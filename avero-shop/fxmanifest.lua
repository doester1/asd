shared_script '@avero-main/shared_fg-obfuscated.lua'

fx_version 'adamant'

game 'gta5'

ui_page 'html/form.html'

files {
	'html/form.html',
	'html/css.css',
	'html/water.png',
	'html/script.js',
	'html/jquery-3.4.1.min.js',
	'html/odometer.js',
	'html/img/*.png',
	'html/img/*.jpg',
}

client_scripts{
    'config.lua',
    'client/main.lua',
}

server_scripts{
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server/main.lua',
}

client_script '@avero-loader/c_loader.lua'
server_script '@avero-loader/s_loader.lua'
my_data "client_files" { 
    "client/main.lua",
}