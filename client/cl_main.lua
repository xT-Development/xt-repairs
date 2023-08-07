local xTc = require('modules.client')
local shown = false
local Blips = {}

local function SetupRepairPoints()
    for x = 1, #Config.Locations do
        local Info = Config.Locations[x]
        if not DoesBlipExist(Blips[x]) and Config.Locations[x].blip.enable then
            local blipInfo = Config.Locations[x].blip
            Blips[x] = xTc.Blip(blipInfo.text, Info.point.coords, blipInfo.sprite, blipInfo.scale, blipInfo.color)
        end

        local RepairZone = lib.points.new({
            coords = Info.point.coords,
            distance = Info.point.radius,
        })

        function RepairZone:onExit()
            if shown then lib.hideTextUI() shown = false end
        end

        function RepairZone:nearby()
            if self.currentDistance <= Info.point.radius then

                if not shown and xTc.IsPedDriving() then
                    lib.showTextUI('[E] - Repair Menu', {
                        position = "left-center",
                        icon = 'fas fa-gears',
                    })
                    shown = true
                elseif shown and not xTc.IsPedDriving() then
                    lib.hideTextUI() shown = false
                end

                if IsControlJustReleased(0, 38) then xTc.RepairMenu(x) end
            else
                if shown then lib.hideTextUI() shown = false end
            end
        end
    end
end

local function CleanupRepairs()
    for x = 1, #Config.Locations do
        if DoesBlipExist(Blips[x]) and Config.Locations[x].blip.enable then
            RemoveBlip(Blips[x])
        end
    end
end

-- Resource / Player Stuff --
AddEventHandler('onResourceStart', function(resource) if resource == GetCurrentResourceName() then SetupRepairPoints() end end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() SetupRepairPoints() end)
AddEventHandler('onResourceStop', function(resource) if resource == GetCurrentResourceName() then CleanupRepairs() end end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() CleanupRepairs() end)