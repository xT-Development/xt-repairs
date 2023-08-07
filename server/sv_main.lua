local Utils = require('modules.shared')
local xTs = require('modules.server')

-- Toggle Busy State --
RegisterNetEvent('xt-repairs:server:setBusyState', function(ID, BOOL) xTs.BusyState(ID, BOOL) end)

-- Get Couunt of Mechanics --
lib.callback.register('xt-repairs:server:GetJobCount', function(source, JOB) return QBCore.Functions.GetDutyCount(JOB) end)

-- Get Busy State --
lib.callback.register('xt-repairs:server:GetBusyState', function(source, ID) return Config.Locations[ID].isBusy end)

-- Check if Player has Funds --
lib.callback.register('xt-repairs:server:HasFunds', function(source, ID, TYPE)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local money = Player.Functions.GetMoney('bank')
    local callback = false

    if money >= Config.Locations[ID].cost[TYPE] then
        callback = true
    else
        QBCore.Functions.Notify(src, 'You don\'t have enough funds for the repair!', 'error')
    end
    return callback
end)

-- Check if Player has Paid --
lib.callback.register('xt-repairs:server:HasPaid', function(source, ID, TYPE)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local callback = false
    local isOwned = Config.Locations[ID].business.isOwned
    local cost = xTs.CalcCost(ID, TYPE)

    if isOwned then
        if Player.Functions.RemoveMoney('bank', cost) then
            if Config.RenewedBanking then
                exports['Renewed-Banking']:addAccountMoney(Config.Locations[ID].business.job, cost)
                callback = true
            else
                exports['qb-management']:AddMoney(Config.Locations[ID].business.job, cost)
                callback = true
            end
        end
    else
        if Player.Functions.RemoveMoney('bank', cost) then
            callback = true
        end
    end
    Utils.Debug('vehicle Repair', 'Paid: '..cost..' | Type: '..TYPE)
    return callback
end)