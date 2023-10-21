local xTs = {}

function xTs.CalcCost(ID, TYPE)
    local owned = Config.Locations[ID].business.isOwned
    local mechCount = 0

    if owned then
        mechCount = xTs.getJobCount(Config.Locations[ID].business.job)
    else
        mechCount = xTs.getJobCount('mechanic')
    end

    local base = Config.Locations[ID].cost[TYPE]
    local mechMult = (mechCount * Config.Locations[ID].costMultiplierPerMechanic)
    local totalMutli = base * mechMult
    local total = (base + totalMutli)

    return math.floor(total)
end

function xTs.BusyState(ID, BOOL)
    if Config.Locations[ID].isBusy == BOOL then return end
    local pCoords = GetEntityCoords(GetPlayerPed(source))
    local repairCoords = Config.Locations[ID].point.coords
    local dist = #(repairCoords - pCoords)
    if dist > Config.Locations[ID].point.radius then return end
    Config.Locations[ID].isBusy = BOOL
end

function xTs.getJobCount(JOB)
    local count = 0
    for _, source in pairs(GetPlayers()) do
        local hasGroup = Bridge.hasGroup(source, JOB)
        if hasGroup then
            count += 1
        end
    end
    return count
end

return xTs