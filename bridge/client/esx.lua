if GetResourceState('es_extended') ~= 'started' then return end

AddEventHandler('esx:playerLoaded', function()
    TriggerEvent('xt-repairs:client:onLoad')
end)

AddEventHandler('esx:onPlayerLogout', function()
    TriggerEvent('xt-repairs:client:onUnload')
end)