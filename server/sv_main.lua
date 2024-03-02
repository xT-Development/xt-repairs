local config =      require 'configs.shared'
local svConfig =    require 'configs.server'
repairBays = {}

-- Toggle Busy State --
lib.callback.register('xt-repairs:server:setBusyState', function(source, id, state)
    local src = source
    local dist = distanceCheck(src, id)
    if not dist then return end

    local setState = state
    if state then
        setState = src
    end

    return setBusyState(id, setState)
end)

-- Gets Bay State --
lib.callback.register('xt-repairs:server:getRepairBayState', function(source, id)
    return repairBays[id]
end)

-- Get Couunt of Mechanics --
lib.callback.register('xt-repairs:server:getJobCount', function(source, id)
    local playerJob = getPlayerJob(tonumber(source))
    local locationInfo = config.Locations[id]
    local job = locationInfo.business.isOwned and locationInfo.business.job or config.DefaultMechJob
    local hasAllowedJob = (playerJob == job)

    if hasAllowedJob then -- Returns early if allowed
        return 1, hasAllowedJob
    end

    return getJobCount(job), hasAllowedJob
end)

-- Check if Source has Funds --
lib.callback.register('xt-repairs:server:takePayment', function(source, id, type, target)

    if (target ~= nil) then
        local dist = distanceCheckFromPlayer(source, target)
        if not dist then return end
    end

    local src = (target ~= nil) and target or source
    local money = getMoney(src, 'bank')
    local total = config.Locations[id].cost[type]
    local hasFunds = false
    local hasPaid = false

    if money >= total then
        local isOwned = config.Locations[id].business.isOwned
        local cost = calculateCost(id, type)

        hasFunds = true

        if isOwned then
            if removeMoney(src, cost, 'bank', 'vehicle-repair') then
                svConfig.addBusinessFunds(config.Locations[id].business.job, cost)
                hasPaid = true
            end
        else
            if removeMoney(src, cost, 'bank', 'vehicle-repair') then
                hasPaid = true
            end
        end
    else
        lib.notify(src, { title = 'You don\'t have enough funds for the repair!', type = 'error' })
    end

    return hasFunds, hasPaid
end)

-- Gets Repair Total --
lib.callback.register('xt-repairs:server:getRepairCost', function(source, id, type)
    return calculateCost(id, type)
end)

-- Handlers --
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    repairBays = {}
    for x = 1, #config.Locations do
        setBusyState(x, false)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for x = 1, #repairBays do
        if repairBays[x] == src then
            setBusyState(x, false)
            break
        end
    end
end)