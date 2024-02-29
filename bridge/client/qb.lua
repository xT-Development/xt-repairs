if GetResourceState('qb-core') ~= 'started' then return end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('xt-repairs:client:onLoad')
end)

AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('xt-repairs:client:onUnload')
end)