local config = require 'configs.shared'
local clConfig = require 'configs.client'

-- Open Repair Bay Menu --
function openRepairMenu(ID)
    local bayState = lib.callback.await('xt-repairs:server:getRepairBayState', false, ID)
    if bayState and bayState > 0 then
        return lib.notify({ title = 'This repair bay is being used!', type = 'error' })
    end

    local vehicleCheck = checkVehicle(ID)
    if not vehicleCheck then return lib.notify({ title = 'You can\'t repair this vehicle class at this location!', type = 'error' }) end

    local vehicle = GetVehiclePedIsIn(cache.ped)
    local mechanicThreshold = config.Locations[ID].maxMechanics
    local mechanics, hasAllowedJob = lib.callback.await('xt-repairs:server:getJobCount', false, ID)

    if not hasAllowedJob then
        if mechanics > 0 and mechanics >= mechanicThreshold  then
            return lib.notify({ title = 'There is mechanics available at this location!', type = 'error' })
        end
    end

    lib.registerContext({
        id = 'repair_menu',
        title = 'Vehicle Repair',
        options = {
            {
                title = 'Repair Engine',
                icon = 'fas fa-gears',
                onSelect = function()
                    local engine = GetVehicleEngineHealth(vehicle)
                    if engine >= 1000.0 then lib.notify({ title = 'Vehicle engine is not damaged!', type = 'error' }) return end
                    local hasFunds, hasPaid, target

                    if hasAllowedJob then
                        local repairCost = config.Locations[ID].cost['internals']
                        local chargeInput = handleChargeInput(repairCost)
                        if not chargeInput then return end
                        if not chargeInput[1] and chargeInput[2] > 0 then
                            target = chargeInput[2]
                        end
                    else
                        local repairCost = lib.callback.await('xt-repairs:server:getRepairCost', false, ID, 'internals')
                        local chargeConfirmation = repairConfirmation('internals', repairCost)
                        if not chargeConfirmation then return end
                    end

                    hasFunds, hasPaid = lib.callback.await('xt-repairs:server:takePayment', false, ID, 'internals', target)

                    if hasFunds and hasPaid then
                        handleRepair(ID, 'internals')
                    else
                        lib.notify({ title = 'Not Enough Funds!', type = 'error' })
                    end
                end
            },
            {
                title = 'Repair Body',
                icon = 'fas fa-gears',
                onSelect = function()
                    local body = GetVehicleBodyHealth(vehicle)
                    if body >= 1000.0 then lib.notify({ title = 'Vehicle body is not damaged!', type = 'error' }) return end
                    local hasFunds, hasPaid, target

                    if hasAllowedJob then
                        local repairCost = config.Locations[ID].cost['externals']
                        local chargeInput = handleChargeInput(repairCost)
                        if not chargeInput then return end
                        if not chargeInput[1] and chargeInput[2] > 0 then
                            target = chargeInput[2]
                        end
                    else
                        local repairCost = lib.callback.await('xt-repairs:server:getRepairCost', false, ID, 'externals')
                        local chargeConfirmation = repairConfirmation('externals', repairCost)
                        if not chargeConfirmation then return end
                    end

                    hasFunds, hasPaid = lib.callback.await('xt-repairs:server:takePayment', false, ID, 'externals', target)

                    if hasFunds and hasPaid then
                        handleRepair(ID, 'externals')
                    else
                        lib.notify({ title = 'Not Enough Funds!', type = 'error' })
                    end
                end
            },
            {
                title = 'Repair All',
                icon = 'fas fa-gears',
                onSelect = function()
                    local body = GetVehicleBodyHealth(vehicle)
                    local engine = GetVehicleEngineHealth(vehicle)
                    if body >= 1000.0 then lib.notify({ title = 'Vehicle body is not damaged!', type = 'error' }) return end
                    if engine >= 1000.0 then lib.notify({ title = 'Vehicle engine is not damaged!', type = 'error' }) return end
                    local hasFunds, hasPaid, target

                    if hasAllowedJob then
                        local repairCost = config.Locations[ID].cost['all']
                        local chargeInput = handleChargeInput(repairCost)
                        if not chargeInput then return end
                        if not chargeInput[1] and chargeInput[2] > 0 then
                            target = chargeInput[2]
                        end
                    else
                        local repairCost = lib.callback.await('xt-repairs:server:getRepairCost', false, ID, 'all')
                        local chargeConfirmation = repairConfirmation('all', repairCost)
                        if not chargeConfirmation then return end
                    end

                    hasFunds, hasPaid = lib.callback.await('xt-repairs:server:takePayment', false, ID, 'all', target)

                    if hasFunds and hasPaid then
                        handleRepair(ID, 'all')
                    else
                        lib.notify({ title = 'Not Enough Funds!', type = 'error' })
                    end
                end
            },
        }
    })
    lib.showContext('repair_menu')
end