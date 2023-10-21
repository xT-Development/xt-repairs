local Utils = require('modules.shared')
local xTs = require('modules.server')

-- Toggle Busy State --
RegisterNetEvent('xt-repairs:server:setBusyState', function(ID, BOOL) xTs.BusyState(ID, BOOL) end)

-- Get Couunt of Mechanics --
lib.callback.register('xt-repairs:server:GetJobCount', function(source, JOB) return xTs.getJobCount(JOB) end)

-- Get Busy State --
lib.callback.register('xt-repairs:server:GetBusyState', function(source, ID) return Config.Locations[ID].isBusy end)

-- Check if Player has Funds --
lib.callback.register('xt-repairs:server:HasFunds', function(source, ID, TYPE)
    local src = source
    local money = Bridge.getMoney(src, 'bank')
    local callback = false
    local total = Config.Locations[ID].cost[TYPE]

    if money >= total then
        callback = true
    else
        lib.notify({ title = 'You don\'t have enough funds for the repair!', type = 'error' })
    end
    return callback
end)

-- Check if Player has Paid --
lib.callback.register('xt-repairs:server:HasPaid', function(source, ID, TYPE)
    local src = source
    local callback = false
    local isOwned = Config.Locations[ID].business.isOwned
    local cost = xTs.CalcCost(ID, TYPE)

    if isOwned then
        if Bridge.removeMoney(src, cost, 'bank', 'vehicle-repair') then
            exports['Renewed-Banking']:addAccountMoney(Config.Locations[ID].business.job, cost)
            callback = true
        end
    else
        if Bridge.removeMoney(src, cost, 'bank', 'vehicle-repair') then
            callback = true
        end
    end
    Utils.Debug('vehicle Repair', 'Paid: '..cost..' | Type: '..TYPE)
    return callback
end)