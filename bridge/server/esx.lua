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

function getMoney(src, type)
    local Player = getPlayer(src)
    if not Player then return end
    type = convertMoney[type] or type
    return Player.getAccount(type).money
end

function removeMoney(src, amount, type, reason)
    local type = convertMoney[type] or type

    local Player = getPlayer(src)
    if not Player then
        return false
    end

    if Player.getAccount(type).money < amount then
        return false
    end

    Player.removeAccountMoney(type, amount, reason)
    return true
end