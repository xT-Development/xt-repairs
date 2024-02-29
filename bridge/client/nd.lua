if not lib.checkDependency('ND_Core', '2.0.0') then return end

AddEventHandler('ND:characterLoaded', function()
    TriggerEvent('xt-repairs:client:onLoad')
end)

AddEventHandler('ND:characterUnloaded', function()
    TriggerEvent('xt-repairs:client:onUnload')
end)