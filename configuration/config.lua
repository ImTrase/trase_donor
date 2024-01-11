Config = {}

Config.Framework = 0 -- ESX = 0, QBCore = 1, Custom = 2 (For custom, setup in frameworks/custom.lua)
Config.ConsolePrints = true -- Print in console when a package is claimed (error prints will print regardless of this option)
Config.Notifications = 0 -- 0 = Default (customize and change in client/functions), 2 = okokNotify

Config.GiveVehicles = {
    Enabled = true,
    ESX = 'esx_vehicleshop' -- The resource that generates the license plate, QBCore uses a different system so if on QBCore, ignore this
}

Config.Strings = {
    ['no_tebex'] = 'No tebex transaction id specified!',
    ['no_key'] = 'The transaction key provided was invalid and was unable to be found.',
    ['awarded'] = 'You have redeemed and have been rewarded the {package_name}, thanks for your support!',
    ['already_claimed'] = 'This tebex transaction ID was already claimed!',
    ['no_packages'] = 'This tebex transaction ID has no available packages!',
    ['cooldown'] = 'You must wait before attempting to claim another package!',
    ['cooldown_global'] = 'There is currently a cooldown, please wait a minute!',
}