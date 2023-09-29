local GetVehicleOilLevel = GetVehicleOilLevel
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetVehicleBodyHealth = GetVehicleBodyHealth

local xTc = require('modules.client')

RegisterNetEvent('xt-mechinfo:client:Menu', function(VEH)
    local wheelsInfo = xTc.GetVehicleWheels(VEH)
    local temp, tempType = xTc.GetVehTemp(VEH)

    xTc.Emote('tablet2')
    if lib.progressCircle({
        label = 'Scanning Vehicle...',
        duration = (Config.ScanVehicleLength * 1000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true },
    }) then
        xTc.Emote('tablet')
        lib.registerContext({
            id = 'vehicle_status',
            title = 'Vehicle Status',
            onExit = function() xTc.EndEmote() end,
            options = {
                {
                    title = 'Engine Temp: '..temp..tempType,
                    progress = (temp / 3),
                    colorScheme = xTc.VehicleTempColor((temp / 3)),
                    icon = 'fas fa-temperature-three-quarters'
                },
                {
                    title = 'Oil Level: '..tostring(GetVehicleOilLevel(VEH))..'L',
                    progress = (GetVehicleOilLevel(VEH) * 20), -- Max oil seems to be 5 for all vehicles? Assuming its litres?
                    colorScheme = '#B45F04',
                    icon = 'fas fa-oil-can'
                },
                {
                    title = 'Fuel Level: '..tostring(math.ceil(exports[Config.Fuel]:GetFuel(VEH)))..'%',
                    progress = math.ceil(exports[Config.Fuel]:GetFuel(VEH)),
                    colorScheme = '#FFFF00',
                    icon = 'fas fa-gas-pump'
                },
                {
                    title = 'Engine Health: '..tostring(math.ceil(GetVehicleEngineHealth(VEH) / 10))..'%',
                    progress = (GetVehicleEngineHealth(VEH) / 10),
                    colorScheme = xTc.VehicleHealthColor(math.ceil(GetVehicleEngineHealth(VEH) / 10)),
                    icon = 'fas fa-car-battery'
                },
                {
                    title = 'Body Health: '..tostring(math.ceil(GetVehicleBodyHealth(VEH) / 10))..'%',
                    progress = (GetVehicleBodyHealth(VEH) / 10),
                    colorScheme = xTc.VehicleHealthColor(math.ceil(GetVehicleBodyHealth(VEH) / 10)),
                    icon = 'fas fa-car-burst'
                },
                {
                    title = 'Tires Health:',
                    description = wheelsInfo
                },
            }
        })
        lib.showContext('vehicle_status')
    else
        xTc.EndEmote()
    end
end)