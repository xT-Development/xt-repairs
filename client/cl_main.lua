local config =      require 'configs.shared'
local clConfig =    require 'configs.client'
local repairPoints = {}
local shown = false
local repairBlips = {}

local lib = lib
local IsControlJustReleased = IsControlJustReleased

local function setupRepairs()
    for x = 1, #config.Locations do
        local Info = config.Locations[x]
        if not DoesBlipExist(repairBlips[x]) and config.Locations[x].blip.enable then
            local blipInfo = config.Locations[x].blip
            repairBlips[x] = createRepairsBlip(blipInfo.text, Info.point.coords, blipInfo.sprite, blipInfo.scale, blipInfo.color)
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
            if not isPlayerDriving() then
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

                if IsControlJustReleased(0, 38) then
                    openRepairMenu(x)
                end
            else
                if shown then
                    lib.hideTextUI()
                    shown = false
                end
            end
        end
        repairPoints[#repairPoints+1] = RepairZone
    end
    globalMechInfo()
end

local function cleanupRepairs()
    for x = 1, #config.Locations do
        if DoesBlipExist(repairBlips[x]) and config.Locations[x].blip.enable then
            RemoveBlip(repairBlips[x])
        end
    end
    for x = 1, #repairPoints do
        repairPoints[x]:remove()
    end
    exports.ox_target:removeGlobalVehicle('mechInfo')
end

-- Handlers --
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        setupRepairs()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        cleanupRepairs()
    end
end)

AddEventHandler('xt-repairs:client:onLoad', function()
    setupRepairs()
end)

AddEventHandler('xt-repairs:client:onUnload', function()
    cleanupRepairs()
end)