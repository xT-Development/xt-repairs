return {
    DefaultMechJob = 'mechanic',                                    -- Default job check for locations that are not owned
    MechanicJobs = { 'mechanic' },                                  -- Used for vehicle status menu

    Locations = {
        { -- Bennys
            maxMechanics = 1,                                       -- If mechanic count is over this, required to contact mechanic
            point = { coords = vec3(-211.74, -1323.82, 30.89), radius = 8 },
            cost = {                                                -- Price of Repairs
                ['internals'] = 500,
                ['externals'] = 200,
                ['all'] = 700
            },
            repairTimes = {                                         -- Length of repairs
                ['internals'] = 10,
                ['externals'] = 10,
                ['all'] = 20
            },
            costMultiplierPerMechanic = 0.05,                       -- Cost Multiplier Per Mechanic
            blip = { enable = true, text = 'Repair Bay', sprite = 446, color = 3, scale = 0.5 },
            business = { isOwned = false, job = 'mechanic' },       -- If zone is owned by a business, enable and set job name (Business will receive funds)
            allowedClasses = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 12 },  -- Vehicle Classes Allowed to Repair Here
        },

        { -- Paleto
            maxMechanics = 0,
            point = { coords = vec3(108.16316986084, 6623.857421875, 31.787296295166), radius = 8 },
            cost = {
                ['internals'] = 500,
                ['externals'] = 200,
                ['all'] = 700
            },
            repairTimes = {
                ['internals'] = 10,
                ['externals'] = 10,
                ['all'] = 20
            },
            costMultiplierPerMechanic = 0.05,
            blip = { enable = true, text = 'Repair Bay', sprite = 446, color = 3, scale = 0.5 },
            business = { isOwned = false, job = 'mechanic' },
            allowedClasses = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 12 },
        },
    },
}