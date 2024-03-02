local config = require 'configs.shared'
local clConfig = require 'configs.client'
local GetVehicleOilLevel = GetVehicleOilLevel
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetVehicleBodyHealth = GetVehicleBodyHealth

-- Vehicle Inspection Menu --
function openInspectionMenu(vehicle)
    local wheelsInfo = getVehicleWheels(vehicle)
    local temp, tempType = getVehicleTemp(vehicle)
    local fuelProgress

    if clConfig.Fuel == 'ox_fuel' then
        fuelProgress = Entity(vehicle)?.state and Entity(vehicle)?.state.fuel or GetVehicleFuelLevel(vehicle)
    else
        fuelProgress = exports[config.Fuel]:GetFuel(vehicle)
    end

    clConfig.Emote('tablet2')
    if lib.progressCircle({
        label = 'Scanning Vehicle...',
        duration = (clConfig.ScanVehicleLength * 1000),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true },
    }) then
        clConfig.Emote('tablet')
        lib.registerContext({
            id = 'vehicle_status',
            title = 'Vehicle Status',
            onExit = function() ClearPedTasks(cache.ped) end,
            options = {
                {
                    title = ('Engine Temp: %s %s'):format(temp, tempType),
                    progress = (temp / 3),
                    colorScheme = vehicleTempColor((temp / 3)),
                    icon = 'fas fa-temperature-three-quarters'
                },
                {
                    title = ('Oil Level: %sL'):format(tostring(GetVehicleOilLevel(vehicle))),
                    progress = (GetVehicleOilLevel(vehicle) * 20), -- Max oil seems to be 5 for all vehicles? Assuming its litres?
                    colorScheme = '#B45F04',
                    icon = 'fas fa-oil-can'
                },
                {
                    title = ('Fuel Level: %s'):format(tostring(math.ceil(fuelProgress))),
                    progress = math.ceil(fuelProgress),
                    colorScheme = '#FFFF00',
                    icon = 'fas fa-gas-pump'
                },
                {
                    title = ('Engine Health: %s'):format(tostring(math.ceil(GetVehicleEngineHealth(vehicle) / 10))),
                    progress = (GetVehicleEngineHealth(vehicle) / 10),
                    colorScheme = vehicleHealthColor(math.ceil(GetVehicleEngineHealth(vehicle) / 10)),
                    icon = 'fas fa-car-battery'
                },
                {
                    title = ('Body Health: %s'):format(tostring(math.ceil(GetVehicleBodyHealth(vehicle) / 10))),
                    progress = (GetVehicleBodyHealth(vehicle) / 10),
                    colorScheme = vehicleHealthColor(math.ceil(GetVehicleBodyHealth(vehicle) / 10)),
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
        ClearPedTasks(cache.ped)
    end
end