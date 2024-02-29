if GetResourceState('ox_core') ~= 'started' then return end

local file = ('imports/%s.lua'):format(IsDuplicityVersion() and 'server' or 'client')
local import = LoadResourceFile('ox_core', file)
local chunk = assert(load(import, ('@@ox_core/%s'):format(file)))
chunk()

function getPlayer(id)
    return Ox.GetPlayer(id)
end

function getCharID(src)
    local player = getPlayer(src)
    return player.charId
end

function getPlayerJob(src)
    local player = getPlayer(src)
    return player.getGroup()
end

function getMoney(src, type)
    if type == 'cash' then
        return exports.ox_inventory:GetItemCount(src, 'money')
    else
        return
    end
end

function removeMoney(src, amount, type, reason)
    if type == 'cash' then
        return exports.ox_inventory:RemoveItem(src, 'money', amount)
    else
        return
    end
end