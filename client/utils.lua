local config = require 'configs.shared'
local clConfig = require 'configs.client'

local Wheels = {
    ['4'] = {
        { id = 0, name = 'Driver Front'},
        { id = 4, name = 'Driver Rear'},
        { id = 1, name = 'Passenger Front'},
        { id = 5, name = 'Passenger Rear'}
    },
    ['6'] = {
        { id = 0, name = 'Driver Front'},
        { id = 2, name = 'Driver Middle'},
        { id = 4, name = 'Driver Rear'},
        { id = 1, name = 'Passenger Front'},
        { id = 3, name = 'Passenger Middle'},
        { id = 5, name = 'Passenger Rear'}
    }
}

-- Choose Customer or Personal Repair --
function handleChargeInput(total)
    local input = lib.inputDialog(('Repair Bill: $%s'):format(total), {
        { type = 'checkbox', label = 'Personal Repair' },
        {type = 'number', label = 'Citizen\'s Server ID', description = 'If another citizen is paying for the repair, enter their server ID'},
    }) if not input then return end

    return input
end

-- Confirm Repair Price --
function repairConfirmation(type, total)
    local alert = lib.alertDialog({
        header = ('**Confirm Repair Bill:** $%s'):format(total),
        size = 'xs',
        centered = true,
        cancel = true,
        labels = { cancel = 'Reject', confirm = 'Confirm' }
    }) if alert == 'cancel' then return end

    return alert
end

-- Check if Player is Driving a Allowed Vehicle --
function isPlayerDriving()
    local ped = cache.ped
	local vehicle = cache.vehicle
    local callback = false
	if vehicle then
		if GetPedInVehicleSeat(vehicle, -1) == ped then
			local class = GetVehicleClass(vehicle)
			if class ~= 15 and class ~= 16 and class ~= 21 and class ~= 13 then
				callback = true
			end
		end
	end
	return callback
end

-- Check if Vehicle is Allowed Class at Repair Bay --
function checkVehicle(id)
    local callback = false
    local vehicle = cache.vehicle
    for _, class in ipairs(config.Locations[id].allowedClasses) do
        if GetVehicleClass(vehicle) == class then
            callback = true
            break
        end
    end
    return callback
end

-- Repairs Body / Wheels --
function handleExternalRepairs(veh)
    local currentEngine = GetVehicleEngineHealth(veh)

    SetVehicleBodyHealth(veh, 1000.0)
    SetVehicleDirtLevel(veh)
    WashDecalsFromVehicle(veh, 1.0)
    SetVehicleFixed(veh)
    SetVehicleEngineHealth(veh, currentEngine)
    if clConfig.XTSlashTires then
        exports['xt-slashtires']:FixAllTires(veh)
    end
end

-- Repairs Entire Vehicle --
function repairAll(veh)
    if not isPlayerDriving() then return end

    handleExternalRepairs(veh)
    SetVehicleEngineHealth(veh, 1000.0)
    SetVehicleUndriveable(veh, false)
end

-- Create Repair Bay Blips --
function createRepairsBlip(text, coords, icon, scale, color)
    local blipID = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blipID, icon)
    SetBlipScale(blipID, scale)
    SetBlipDisplay(blipID, 4)
    SetBlipColour(blipID, color)
    SetBlipAsShortRange(blipID, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blipID)
    return blipID
end

-- Gets Vehicle Temps --
function getVehicleTemp(veh)
    local temp
    local type
    if config.Fahrenheit then
        temp = tostring(math.ceil(GetVehicleEngineTemperature(veh) * 1.8) + 32)
        type = '°F'
    else
        temp = tostring(math.ceil(GetVehicleEngineTemperature(veh)))
        type = '°C'
    end
    return temp, type
end

-- Get Vehicle Wheel Statuses --
function getVehicleWheels(veh)
    local wheelCount = GetVehicleNumberOfWheels(veh)
    local wheelsInfo = ''
    if wheelCount == 4 then
        for x = 1, #Wheels['4'] do
            local wHealth
            if IsVehicleTyreBurst(veh, Wheels['4'][x].id) then
                wHealth = '🔴'
            else
                wHealth = '🟢'
            end
            wheelsInfo = wheelsInfo..Wheels['4'][x].name..': '..wHealth..'  \n'
        end
    elseif wheelCount == 6 then
        for x = 1, #Wheels['6'] do
            local wHealth
            if IsVehicleTyreBurst(veh, Wheels['6'][x].id) then
                wHealth = '🔴'
            else
                wHealth = '🟢'
            end
            wheelsInfo = wheelsInfo..Wheels['6'][x].name..': '..wHealth..'  \n'
        end
    end
    return wheelsInfo
end

-- Global Vehicle Target --
function globalMechInfo()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'mechInfo',
            label = 'Vehicle Info',
            icon = 'fas fa-info',
            groups = config.MechanicJobs,
            onSelect = function(data)
                openInspectionMenu(data.entity)
            end
        }
    })
end

-- Returns Color for Vehicle Health Menu --
function vehicleHealthColor(progress)
    if progress >= 75 then
        return 'green'
    elseif progress < 75 and progress >= 50 then
        return 'yellow'
    elseif progress < 50 and progress >= 25 then
        return 'orange'
    elseif progress < 25 and progress >= 0 then
        return 'red'
    end
end

-- Returns Color for Vehicle Temperature Menu --
function vehicleTempColor(progress)
    if progress >= 90 then
        return 'red'
    elseif progress < 90 and progress >= 70 then
        return 'orange'
    elseif progress < 70 and progress >= 40 then
        return 'yellow'
    elseif progress < 40 and progress >= 0 then
        return 'green'
    end
end

-- Sets Vehicle Fuel Level --
function setFuel(veh, fuel)
    if clConfig.Fuel == 'ox_fuel' then
        Entity(veh).state.fuel = 100
    else
        exports[clConfig.Fuel]:SetFuel(veh, fuel)
    end
end

-- Repair Completed --
function repairCompleted(id, veh)
    local setBusy = lib.callback.await('xt-repairs:server:setBusyState', false, id, false)
    if setBusy then
        setFuel(veh, 100)
        FreezeEntityPosition(veh, false)
    end
end

-- Single Repair Type --
function handleRepair(id, type)
    local vehicle = cache.vehicle

    local setBusy = lib.callback.await('xt-repairs:server:setBusyState', false, id, true)
    if setBusy then
        FreezeEntityPosition(vehicle, true)
        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'airwrench', 0.05)
        if lib.progressCircle({
            label = 'Repairing Vehicle...',
            duration = (config.Locations[id].repairTimes[type] * 1000),
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = { car = true },
        }) then
            if type == 'externals' then
                handleExternalRepairs(vehicle)
            elseif type == 'internals' then
                SetVehicleEngineHealth(vehicle, 1000.0)
            elseif type == 'all' then
                repairAll(vehicle)
            end
            repairCompleted(id, vehicle)
        else
            FreezeEntityPosition(vehicle, false)
        end
    end
end