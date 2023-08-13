local xTc = {}

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
    for x = 1, #Config.Locations[ID].allowedClasses do
        if GetVehicleClass(vehicle) == x then
            callback = true
            break
        end
    end
    return callback
end

function xTc.RepairMenu(ID)
    local isBusy = lib.callback.await('xt-repairs:server:GetBusyState', false, ID)
    if not isBusy then
        local vehicleCheck = xTc.CheckVehicle(ID)
        if vehicleCheck then
            local vehicle = GetVehiclePedIsIn(cache.ped)
            local isOwned = Config.Locations[ID].business.isOwned
            local mechanics

            if isOwned then
                local business = Config.Locations[ID].business.job
                mechanics = lib.callback.await('xt-repairs:server:GetJobCount', false, business)
            else
                mechanics = lib.callback.await('xt-repairs:server:GetJobCount', false, 'mechanic')
            end

            if mechanics <= Config.MinimumMechanics then
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
            else
                QBCore.Functions.Notify('There is mechanics on duty at this location!', 'error')
            end
        else
            QBCore.Functions.Notify('You can\'t repair this vehicle class at this location!', 'error')
        end
    else
        QBCore.Functions.Notify('This repair bay is being used!', 'error')
    end
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
        QBCore.Functions.Progressbar('repair_vehicle', 'Repairing Vehicle...', (Config.Locations[ID].repairTimes[TYPE] * 1000), false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            if TYPE == 'externals' then
                SetVehicleBodyHealth(vehicle, 1000.0)
                SetVehicleFixed(vehicle)
                SetVehicleEngineHealth(vehicle, currentEngine)
            elseif TYPE == 'internals' then
                SetVehicleEngineHealth(vehicle, 1000.0)
            elseif TYPE == 'all' then
                xTc.RepairAll()
            end
            TriggerServerEvent('xt-repairs:server:setBusyState', ID, false)
            exports[Config.Fuel]:SetFuel(vehicle, getFuel)
            FreezeEntityPosition(vehicle, false)
        end, function()
            FreezeEntityPosition(vehicle, false)
            QBCore.Functions.Notify('Canceled...', 'error', 3000)
        end)
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

return xTc