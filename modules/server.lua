local xTs = {}

function xTs.CalcCost(ID, TYPE)
    local owned = Config.Locations[ID].business.isOwned
    local mechCount = 0

    if owned then
        mechCount = QBCore.Functions.GetDutyCount(Config.Locations[ID].business.job)
    else
        mechCount = QBCore.Functions.GetDutyCount('mechanic')
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

return xTs