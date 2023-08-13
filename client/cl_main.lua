local xTc = require('modules.client')
local RepairPoints = {}
local shown = false
local Blips = {}

local lib = lib
local IsControlJustReleased = IsControlJustReleased

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
            if shown then 
                lib.hideTextUI() 
                shown = false 
            end
        end

        function RepairZone:nearby()
            if not xTc.IsPedDriving() then
                if shown then
                    lib.hideTextUI() 
                    shown = false
                end
                return
            end

            if self.currentDistance <= Info.point.radius then
                if not shown then
                    lib.showTextUI('[E] - Repair Menu', {
                        position = "left-center",
                        icon = 'fas fa-gears',
                    })
                    shown = true
                end

                if IsControlJustReleased(0, 38) then xTc.RepairMenu(x) end
            else
                if shown then 
                    lib.hideTextUI() 
                    shown = false 
                end
            end
        end
        RepairPoints[#RepairPoints+1] = RepairZone
    end
end

local function CleanupRepairs()
    for x = 1, #Config.Locations do
        if DoesBlipExist(Blips[x]) and Config.Locations[x].blip.enable then
            RemoveBlip(Blips[x])
        end
    end
    for x = 1, #RepairPoints do
        RepairPoints[x]:remove()
    end
end

-- Resource / Player Stuff --
AddEventHandler('onResourceStart', function(resource) if resource == GetCurrentResourceName() then SetupRepairPoints() end end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() SetupRepairPoints() end)
AddEventHandler('onResourceStop', function(resource) if resource == GetCurrentResourceName() then CleanupRepairs() end end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() CleanupRepairs() end)