return {
    Fuel = 'ox_fuel',                                   -- Fuel resource, if 'ox_fuel', statebag is used
    XTSlashTires = false,                               -- Enable if using xt-slashtires (Requires exports to sync the tires properly)
    Fahrenheit = true,                                  -- Use farenheit for engine temp
    ScanVehicleLength = 5,                              -- Seconds it takes to scan the vehicle

    Emote = function(emote)                             -- Add your own event/export for emotes
        return exports.scully_emotemenu:playEmoteByCommand(emote)
    end,
}