while (not Config) do Wait(100) end

Config.Debug = false
Config.Command = 'tebexclaim' -- Name of command to type.
Config.APIKey = '' -- API Key (visit docs for more information)

Config.SQL = 0 -- oxmysql = 0, mysql-async = 1 [oxmysql is HIGHLY reccommended]

Config.Discord = {
    Enabled = true,
    Webhook = '',
    Logs = {
        Author = { Username = 'Tebex Logs', Avatar = 'https://imgur.com/3igi3eC.png' },
        EmbedColor = '0',
        Timestamp = true
    }
}

-- For money treat it the same:
-- ESX Money Types: (money, bank, black_money)
-- QBCore Money Types: (cash, bank, crypto)
-- ESX Vehicle Types: (car, boat, airplane, helicopter) [airplane & helicopter may be renamed to "aircraft" in some garage systems (e.g. loaf_garage)]

Config.Packages = {
    ['Trase_Lootboxes'] = {
        Rewards = {
            Items = {
                -- ['cash'] = 5000, -- Add money QBCore
                -- ['money'] = 5000, -- Add money ESX
                ['water'] = 2 -- Add 2x water bottles
            },
            Vehicles = { -- [model] = type (The type is used in ESX, allows to give thinks like helicopters, boats, and cars)
                ['zentorno'] = 'car' -- Give a zentorno
            }
        }
    }
}