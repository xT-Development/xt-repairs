if not lib.checkDependency('ND_Core', '2.0.0') then return end

NDCore = {}

lib.load('@ND_Core.init')

function getPlayer(src)
    return NDCore.getPlayer(src)
end

function getCharID(src)
    local Player = getPlayer(src)
    return Player.identifier
end

function getPlayerJob(src)
    local Player = getPlayer(src)
    return Player.getJob()
end

function getMoney(src, mtype)
    local Player = getPlayer(src)
    if not Player then return end
    return Player[mtype]
end

function removeMoney(src, amount, mtype, reason)
    local Player = getPlayer(src)
    if not Player then return end

    if Player[mtype] < amount then
        return
    end

    return Player.deductMoney(mtype, amount, reason or "unknown")
end