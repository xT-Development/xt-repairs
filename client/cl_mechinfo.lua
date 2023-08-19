local GetVehicleOilLevel = GetVehicleOilLevel
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetVehicleBodyHealth = GetVehicleBodyHealth

local xTc = require('modules.client')

RegisterNetEvent('xt-mechinfo:client:Menu', function(VEH)
    local wheelsInfo = xTc.GetVehicleWheels(VEH)
    local temp = xTc.GetVehTemp(VEH)

    xTc.Emote('tablet2')
    QBCore.Functions.Progressbar('scan_vehicle', 'Scanning Vehicle...', (Config.ScanVehicleLength * 1000), false, true, { -- Name | Label | Time | useWhileDead | canCancel
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        xTc.Emote('tablet')
        lib.registerContext({
            id = 'vehicle_status',
            title = 'Vehicle Status',
            onExit = function() xTc.EndEmote() end,
            options = {
                { title = 'Engine Temp: '..temp, },
                { title = 'Oil Level: '..tostring(GetVehicleOilLevel(VEH))..'L' },
                { title = 'Fuel Level: '..tostring(math.ceil(exports[Config.Fuel]:GetFuel(VEH)))..'%' },
                {
                    title = 'Engine Health:',
                    description = tostring(math.ceil(GetVehicleEngineHealth(VEH) / 10))..'%',
                    progress = (GetVehicleEngineHealth(VEH) / 10),
                    colorScheme = xTc.ProgressColor(math.ceil(GetVehicleEngineHealth(VEH) / 10))
                },
                {
                    title = 'Body Health:',
                    description = tostring(math.ceil(GetVehicleBodyHealth(VEH) / 10))..'%',
                    progress = (GetVehicleBodyHealth(VEH) / 10),
                    colorScheme = xTc.ProgressColor(math.ceil(GetVehicleBodyHealth(VEH) / 10))
                },
                {
                    title = 'Tires Health:',
                    description = wheelsInfo
                },
            }
        })
        lib.showContext('vehicle_status')
    end, function()
        xTc.EndEmote()
        QBCore.Functions.Notify('Canceled...', 'error')
    end)
end)