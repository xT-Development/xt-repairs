if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

local convertMoney = {
    ["cash"] = "money",
    ["bank"] = "bank"
}

function getPlayer(src)
    return ESX.GetPlayerFromId(src)
end

function getCharID(src)
    local Player = getPlayer(src)
    return Player.identifier
end

function getPlayerJob(src)
    local Player = getPlayer(src)
    return Player.job.name, Player.job.grade
end

function getMoney(src, mtype)
    local Player = getPlayer(src)
    if not Player then return end
    mtype = convertMoney[mtype] or mtype
    return Player.getAccount(mtype).money
end

function removeMoney(src, amount, mtype, reason)
    local mtype = convertMoney[mtype] or mtype

    local Player = getPlayer(src)
    if not Player then
        return false
    end

    if Player.getAccount(mtype).money < amount then
        return false
    end

    Player.removeAccountMoney(mtype, amount, reason)
    return true
end