local scully = GetResourceState('scully_emotemenu')
local rpemotes = GetResourceState('rpemotes')
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

local xTc = {}

-- Play Emote --
function xTc.Emote(emote)
    if scully == 'started' then
        exports.scully_emotemenu:playEmoteByCommand(emote)
    end
    if rpemotes == 'started' then
        TriggerEvent('animations:client:EmoteCommandStart', {emote})
    end
end

-- End Emote --
function xTc.EndEmote()
    if scully == 'started' then
        exports.scully_emotemenu:cancelEmote()
    end
    if rpemotes == 'started' then
        TriggerEvent('animations:client:EmoteCommandStart', {'c'})
    end
end

function xTc.IsPedDriving()
    local ped = cache.ped
	local vehicle = GetVehiclePedIsIn(ped, false)
    local callback = false
	if IsPedInAnyVehicle(ped, false) then
		if GetPedInVehicleSeat(vehicle, -1) == ped then
			local class = GetVehicleClass(vehicle)
			if class ~= 15 and class ~= 16 and class ~= 21 and class ~= 13 then
				callback = true
			end
		end
	end
	return callback
end

function xTc.CheckVehicle(ID)
    local callback = false
    local vehicle = cache.vehicle
    for _, x in ipairs(Config.Locations[ID].allowedClasses) do
        if GetVehicleClass(vehicle) == x then
            callback = true
            break
        end
    end
    return callback
end

function xTc.RepairMenu(ID)
    local isBusy = lib.callback.await('xt-repairs:server:GetBusyState', false, ID)
    if isBusy then return QBCore.Functions.Notify('This repair bay is being used!', 'error') end

    local vehicleCheck = xTc.CheckVehicle(ID)
    if not vehicleCheck then return QBCore.Functions.Notify('You can\'t repair this vehicle class at this location!', 'error') end

    local vehicle = GetVehiclePedIsIn(cache.ped)
    local isOwned = Config.Locations[ID].business.isOwned
    local mechanicThreshold = Config.Locations[ID].maxMechanics
    local mechanics

    if isOwned then
        local business = Config.Locations[ID].business.job
        mechanics = lib.callback.await('xt-repairs:server:GetJobCount', false, business)
    else
        mechanics = lib.callback.await('xt-repairs:server:GetJobCount', false, Config.DefaultMechJob)
    end
    if mechanics >= mechanicThreshold then return QBCore.Functions.Notify('There is mechanics on duty at this location!', 'error') end

    lib.registerContext({
        id = 'repair_menu',
        title = 'Vehicle Repair',
        options = {
            {
                title = 'Repair Engine',
                icon = 'fas fa-gears',
                onSelect = function()
                    local hasFunds = lib.callback.await('xt-repairs:server:HasFunds', false, ID, 'internals')
                    local engine = GetVehicleEngineHealth(vehicle)
                    if engine >= 1000.0 then QBCore.Functions.Notify('Vehicle engine is not damaged!', 'error') return end
                    if hasFunds then xTc.Repair(ID, 'internals') end
                end
            },
            {
                title = 'Repair Body',
                icon = 'fas fa-gears',
                onSelect = function()
                    local hasFunds = lib.callback.await('xt-repairs:server:HasFunds', false, ID, 'externals')
                    local body = GetVehicleBodyHealth(vehicle)
                    if body >= 1000.0 then QBCore.Functions.Notify('Vehicle body is not damaged!', 'error') return end
                    if hasFunds then xTc.Repair(ID, 'externals') end
                end
            },
            {
                title = 'Repair All',
                icon = 'fas fa-gears',
                onSelect = function()
                    local hasFunds = lib.callback.await('xt-repairs:server:HasFunds', false, ID, 'all')
                    local body = GetVehicleBodyHealth(vehicle)
                    local engine = GetVehicleEngineHealth(vehicle)
                    if body >= 1000.0 then QBCore.Functions.Notify('Vehicle body is not damaged!', 'error') return end
                    if engine >= 1000.0 then QBCore.Functions.Notify('Vehicle engine is not damaged!', 'error') return end
                    if hasFunds then xTc.Repair(ID, 'all') end
                end
            },
        }
    })
    lib.showContext('repair_menu')
end

function xTc.Repair(ID, TYPE)
    local hasPaid = lib.callback.await('xt-repairs:server:HasPaid', false, ID, TYPE)
    if hasPaid then
        local vehicle = GetVehiclePedIsIn(cache.ped)
        local getFuel = GetVehicleFuelLevel(vehicle)
        local currentEngine = GetVehicleEngineHealth(vehicle)

        TriggerServerEvent('xt-repairs:server:setBusyState', ID, true)
        FreezeEntityPosition(vehicle, true)
        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'airwrench', 0.05)
        if lib.progressCircle({
            label = 'Repairing Vehicle...',
            duration = (Config.Locations[ID].repairTimes[TYPE] * 1000),
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = { car = true },
        }) then
            if TYPE == 'externals' then
                SetVehicleBodyHealth(vehicle, 1000.0)
                SetVehicleFixed(vehicle)
                SetVehicleEngineHealth(vehicle, currentEngine)
                if Config.XTSlashTires then
                    exports['xt-slashtires']:FixAllTires(vehicle)
                end
            elseif TYPE == 'internals' then
                SetVehicleEngineHealth(vehicle, 1000.0)
            elseif TYPE == 'all' then
                xTc.RepairAll()
            end
            TriggerServerEvent('xt-repairs:server:setBusyState', ID, false)
            exports[Config.Fuel]:SetFuel(vehicle, getFuel)
            FreezeEntityPosition(vehicle, false)
        else
            FreezeEntityPosition(vehicle, false)
        end
    end
end

function xTc.RepairAll()
    if xTc.IsPedDriving() then
        local ped = cache.ped
        local vehicle = GetVehiclePedIsIn(ped, false)
        SetVehicleDirtLevel(vehicle)
        SetVehicleUndriveable(vehicle, false)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleFixed(vehicle)
        if Config.XTSlashTires then
            exports['xt-slashtires']:FixAllTires(vehicle)
        end
    end
end

function xTc.Blip(text, coords, icon, scale, color)
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

function xTc.GetVehTemp(VEH)
    local temp
    local type
    if Config.Fahrenheit then
        temp = tostring(math.ceil(GetVehicleEngineTemperature(VEH) * 1.8) + 32)
        type = '°F'
    else
        temp = tostring(math.ceil(GetVehicleEngineTemperature(VEH)))
        type = '°C'
    end
    return temp, type
end

function xTc.GetVehicleWheels(VEH)
    local wheelCount = GetVehicleNumberOfWheels(VEH)
    local wheelsInfo = ''
    if wheelCount == 4 then
        for x = 1, #Wheels['4'] do
            local wHealth
            if IsVehicleTyreBurst(VEH, Wheels['4'][x].id) then wHealth = '🔴' else wHealth = '🟢' end
            wheelsInfo = wheelsInfo..Wheels['4'][x].name..': '..wHealth..'  \n'
        end
    elseif wheelCount == 6 then
        for x = 1, #Wheels['6'] do
            local wHealth
            if IsVehicleTyreBurst(VEH, Wheels['6'][x].id) then wHealth = '🔴' else wHealth = '🟢' end
            wheelsInfo = wheelsInfo..Wheels['6'][x].name..': '..wHealth..'  \n'
        end
    end
    return wheelsInfo
end

function xTc.GlobalMechInfo()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'mechInfo',
            label = 'Vehicle Info',
            icon = 'fas fa-info',
            groups = Config.MechanicJobs,
            onSelect = function(data)
                TriggerEvent('xt-mechinfo:client:Menu', data.entity)
            end
        }
    })
end

function xTc.RemoveGlobalMechInfo()
    exports.ox_target:removeGlobalVehicle('mechInfo')
end

function xTc.VehicleHealthColor(PROGRESS)
    if PROGRESS >= 75 then
        return 'green'
    elseif PROGRESS < 75 and PROGRESS >= 50 then
        return 'yellow'
    elseif PROGRESS < 50 and PROGRESS >= 25 then
        return 'orange'
    elseif PROGRESS < 25 and PROGRESS >= 0 then
        return 'red'
    end
end

function xTc.VehicleTempColor(PROGRESS)
    if PROGRESS >= 90 then
        return 'red'
    elseif PROGRESS < 90 and PROGRESS >= 70 then
        return 'orange'
    elseif PROGRESS < 70 and PROGRESS >= 40 then
        return 'yellow'
    elseif PROGRESS < 40 and PROGRESS >= 0 then
        return 'green'
    end
end

return xTc