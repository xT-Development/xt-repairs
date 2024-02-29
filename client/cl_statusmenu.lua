local config = require 'configs.shared'
local clConfig = require 'configs.client'
local GetVehicleOilLevel = GetVehicleOilLevel
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetVehicleBodyHealth = GetVehicleBodyHealth

-- Vehicle Inspection Menu --
function openInspectionMenu(VEH)
    local wheelsInfo = getVehicleWheels(VEH)
    local temp, tempType = getVehicleTemp(VEH)
    local fuelProgress

    if clConfig.Fuel == 'ox_fuel' then
        fuelProgress = Entity(VEH)?.state and Entity(VEH)?.state.fuel or GetVehicleFuelLevel(VEH)
    else
        fuelProgress = exports[config.Fuel]:GetFuel(VEH)
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
                    title = ('Oil Level: %sL'):format(tostring(GetVehicleOilLevel(VEH))),
                    progress = (GetVehicleOilLevel(VEH) * 20), -- Max oil seems to be 5 for all vehicles? Assuming its litres?
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
                    title = ('Engine Health: %s'):format(tostring(math.ceil(GetVehicleEngineHealth(VEH) / 10))),
                    progress = (GetVehicleEngineHealth(VEH) / 10),
                    colorScheme = vehicleHealthColor(math.ceil(GetVehicleEngineHealth(VEH) / 10)),
                    icon = 'fas fa-car-battery'
                },
                {
                    title = ('Body Health: %s'):format(tostring(math.ceil(GetVehicleBodyHealth(VEH) / 10))),
                    progress = (GetVehicleBodyHealth(VEH) / 10),
                    colorScheme = vehicleHealthColor(math.ceil(GetVehicleBodyHealth(VEH) / 10)),
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