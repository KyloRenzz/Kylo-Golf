games {'gta5'}

fx_version 'cerulean'

description 'Kylo Golf based on koil/Alberto golf for gameplay!'
version '0.0.1'
lua54 'yes'

shared_scripts {
	'@PolyZone/client.lua',
	'config.lua',
	'@ox_lib/init.lua'
}

client_script {
	'tools.lua',
	'client.lua'
}

export {
	'trace',
	'endGame',
	'displayHelpText',
	'blipsStartEndCurrentHole',
	'createBall',
	'idleShot',
	'lookingForBall',
	'addBallBlip',
	'addblipGC'
}

server_scripts {
	'server.lua'
}
