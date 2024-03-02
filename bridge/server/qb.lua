if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function getPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

function getCharID(src)
    local player = getPlayer(src)
    return player.PlayerData.citizenid
end

function getPlayerJob(src)
    local player = getPlayer(src)
    return player.PlayerData.job.name, player.PlayerData.job.grade.level
end

function getMoney(src, mtype)
    local player = getPlayer(src)
    if not player then return end
    return player.PlayerData.money[mtype]
end

function removeMoney(src, amount, mtype, reason)
    local player = getPlayer(src)
    if not player then return end

    if player.PlayerData.money[mtype] < amount then
        return
    end

    return player.Functions.RemoveMoney(mtype, amount, reason or "unknown")
end