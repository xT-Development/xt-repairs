fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

description 'Repair Bays | xT Development'

shared_scripts { '@ox_lib/init.lua', 'configs/shared.lua', 'shared/*.lua' }
client_scripts { 'configs/client.lua', 'client/*.lua' }
server_scripts { 'configs/server.lua', 'bridge/server/*.lua', 'server/*.lua' }