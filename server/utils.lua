local config = require 'configs.shared'

-- Distance Check From Bay --
function distanceCheck(src, id)
    local callback = false
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    local repairCoords = config.Locations[id].point.coords
    local dist = #(repairCoords - pCoords)

    if dist <= config.Locations[id].point.radius then
        callback = true
    end

    return callback
end

-- Distance From Target Player --
function distanceCheckFromPlayer(src, target)
    local callback = false
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local dist = #(targetCoords - pCoords)

    if dist <= 10 then
        callback = true
    end

    return callback
end

-- Calculate Total Cost --
function calculateCost(id, type)
    local owned = config.Locations[id].business.isOwned
    local mechJob = config.DefaultMechJob
    local mechCount = 0
    local src = source

    if owned then
        mechJob = config.Locations[id].business.job
    end

    if getPlayerJob(src) ~= mechJob then
        mechCount = getJobCount(mechJob) -- Upcharges if "customer" does not have the job for the repair bay
    end

    local base = config.Locations[id].cost[type]
    local mechMult = (mechCount * config.Locations[id].costMultiplierPerMechanic)
    local totalMutli = base * mechMult
    local total = (base + totalMutli)

    return math.floor(total)
end

-- Sets Repair Bay State --
function setBusyState(id, state)
    if (repairBays[id] == state) then
        return
    end

    repairBays[id] = state

    return (repairBays[id] == state)
end

-- Gets Total Job Count --
function getJobCount(job)
    local count = 0
    for _, src in pairs(GetPlayers()) do
        if job == getPlayerJob(tonumber(src)) then
            count += 1
        end
    end
    return count
end