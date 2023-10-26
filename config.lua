Config = {}

Config.Target = 'ox_target'  --- [ox_target/qb-target/qtarget]
Config.Inventory = 'ox'    ---- ox = Ox-inventory / qb = qb-inventory
Config.MemberPrice = 1000       --- Cost of Membership
Config.MemberCarditem = 'lscm'   --- database name for the membership item

Config.Golfmap = true    --- add the golfmap when swinging (NOTE: not all huds work with the map)
Config.Blip = vec3(-1360.336, 160.0437, 57.4211)  -- Blip Location
Config.PayLoc = vec3(-1367.41, 56.54, 53.90)       -- Where you will Pay for the Membership
Config.GolfStartLoc = vec3(-1348.73, 142.36, 56.27)       -- Where the Location to start Golfing
Config.CartSpawnLoc = {x = -1351.36, y = 134.05, z = 56.26}  -- where the cart will spawn


function alertCops()
 -- Add Police Alert 
end    
