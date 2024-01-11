local cooldown_active, openedPackages = {}, {}

local debug_print = function(text)
    if (not Config.Debug) then return end
    print(('^4[trase_tebex] ^6[DEBUG]^0: %s'):format(text))
end

local valid_transaction = function(transaction_id)
    local api_key = Config.APIKey
    local url = ('https://plugin.tebex.io/payments/%s'):format(transaction_id)
    
    local p = promise.new()
    local headers = { ["X-Tebex-Secret"] = api_key }

    PerformHttpRequest(url, function(statusCode, responseBody, headers)
        local response = false

        debug_print(statusCode)

        if statusCode == 200 then
            response = responseBody
        elseif (statusCode) == 403 then
            cooldown = true
            SetTimeout(60000, function() cooldown = false end)
            print('^4[trase_tebex] ^1[ERROR]^0: You are getting rate limited, enabling a global 1 minute cooldown!')
        else
            response = false
        end

        p:resolve({ response })
    end, "GET", "", headers)

    return table?.unpack(Citizen.Await(p))
end

local load_json = function()
    local res = GetCurrentResourceName()
    local file = LoadResourceFile(res, 'server/cached_transactions.json')
    if file and file ~= '' and type(json.decode(file)) == 'table' then
        return file
    else
        return false
    end
end

local fix_json = function()
    CreateThread(function()
        print('^4[trase_tebex] ^1[ERROR]^0: The "cached_transactions.json" was unable to be found or is corrupted, automatically recreating in 5 seconds.')

        for i = 5, 1, -1 do
            Wait(1000)
            print(('^4[trase_tebex] ^3[INFORMATION]^0: Fixing "cached_transactions.json" in %s seconds!'):format(i))
        end

        Wait(1000)
        SaveResourceFile(GetCurrentResourceName(), 'server/cached_transactions.json', '[]')
        print('^4[trase_tebex] ^2[SUCCESS]^0: "cached_transactions.json" has been restored!')
    end)
end

local getIdentifiers = function(player)
    local t = {}

    if player then
        local identifiers = GetPlayerIdentifiers(player)

        for i=1, #identifiers do
            local prefix, identifier = string.strsplit(':', identifiers[i])
            t[prefix] = identifier
        end
    end

    return t
end

local get_ids = function(target)
    local t = {}

    local identifiers = getIdentifiers(target)

    for k, v in pairs(identifiers) do
        if k == 'steam' then
            t[#t+1] = ('Steam: [%s](https://steamcommunity.com/profiles/%s)'):format(v, tonumber(v, 16))
        elseif k == 'discord' then
            t[#t+1] = ('Discord: <@%s>'):format(v)
        elseif k == 'license' then
            t[#t+1] = ('License: %s'):format(v)
        elseif k == 'license2' then
            t[#t+1] = ('License 2: %s'):format(v)
        elseif k == 'fivem' then
            t[#t+1] = ('FiveM: %s'):format(v)
        elseif k == 'xbl' then
            t[#t+1] = ('Xbox: %s'):format(v)
        elseif k == 'live' then
            t[#t+1] = ('Live: %s'):format(v)
        end
    end

    return table.concat(t, '\n')
end

local log_cache = function(id, src)
    if (Config.ConsolePrints) then
        print(('^4[Trase_Donor] ^3[INFORMATION]^0: Tebex ID "%s" was just claimed, it was cached successfully!'):format(id))
    end

    if (Config.Discord.Enabled) then
        local embed = {
            color = Config.Discord.Logs.EmbedColor,
            type = 'rich',
            title = 'Tebex Claimed',
            description = 'Someone claimed a tebex package!',
            footer = {
                text = '© Trase.Dev',
                icon_url = 'https://imgur.com/3igi3eC.png'
            }
        }

        if (Config.Discord.Logs.Timestamp) then
            embed.timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
        end

        local fields = {}
        fields[#fields +1] = { name = 'Player Name', value = GetPlayerName(src), inline = true }
        fields[#fields +1] = { name = 'Player Server ID', value = src, inline = true }
        fields[#fields +1] = { name = 'ID Claimed', value = ('```%s```'):format(id), inline = false }
        fields[#fields +1] = { name = 'Player Identifiers', value = get_ids(src), inline = false }

        embed.fields = fields

        PerformHttpRequest(Config.Discord.Webhook, function(err, text, headers) end, 'POST', json.encode({
            username = Config.Discord.Logs.Author.Username, 
            avatar_url = Config.Discord.Logs.Author.Avatar, 
            embeds = { embed } }), { ['Content-Type'] = 'application/json' 
        })
    end
end

local cache_transaction = function(id, src)
    local cached = load_json()
    if (not cached) then 
        fix_json()
        Wait(10000)
        local table = json.decode(cached)
        table[#table +1] = id
        SaveResourceFile(GetCurrentResourceName(), 'server/cached_transactions.json', json.encode(table))
        log_cache(id, src)
    else
        local table = json.decode(cached)
        table[#table +1] = id
        SaveResourceFile(GetCurrentResourceName(), 'server/cached_transactions.json', json.encode(table))
        log_cache(id, src)
    end
end

local check_cached = function(tebex_id)
    local cached = load_json()
    if (not cached) then
        return true
    else
        local table = json.decode(cached)
        for i = 1, #table do
            if (table[i]:lower() == tebex_id:lower()) then
                return true
            end
        end

        return false
    end
end

local notify_player = function(target, text, type)
    if (Config.Notifications == 0) then
        TriggerClientEvent('trase_tebex:client:send_notification', target, text)
    else
        TriggerClientEvent('okokNotify:Alert', target, 'Notification', text, 5000, type)
    end
end

RegisterCommand(Config.Command, function(source, args)
    local src = source
    local tebex_id = args[1]

    if (cooldown) then
        return notify_player(src, Config.Strings['cooldown_global'], 'error')
    end

    if (cooldown_active[src]) then
        return notify_player(src, Config.Strings['cooldown'], 'error')
    end

    if (not tebex_id) then
        return notify_player(src, Config.Strings['no_tebex'], 'error')
    end

    local already_claimed = check_cached(tebex_id)

    if (already_claimed) then
        return notify_player(src, Config.Strings['already_claimed'], 'error')
    end

    local valid_transaction = valid_transaction(tebex_id)
    cooldown_active[src] = true
    SetTimeout(60000, function()
        cooldown_active[src] = nil
    end)
 

    if (valid_transaction) then
        cache_transaction(tebex_id, src)
        local data = json.decode(valid_transaction)

        if #data.packages == 0 then
            return notify_player(src, Config.Strings['no_packages'], 'error')
        end

        openedPackages[src] = true
        SetTimeout(60000, function() openedPackages[src] = nil end)

        for k, v in pairs(data.packages) do
            if (Config.Packages[v.name]) then
                local package = Config.Packages[v.name]
                local text = Config.Strings['awarded']:gsub('{package_name}', v.name)
                notify_player(src, text, 'success')

                if (package.Rewards.Items) then
                    for k2, v2 in pairs(package.Rewards.Items) do
                        AddItem(src, k2, v2)
                    end
                end

                if (package.Rewards.Vehicles) then
                    if (not Config.GiveVehicles.Enabled) then
                        print(('^4[Trase_Donor] ^1[ERROR]^0: Package "%s" tried giving vehicles, but Config.GiveVehicles in the config is disabled, please go enable it.'):format(v.name))
                    else
                        for model, vehicleType in pairs(package.Rewards.Vehicles) do
                            TriggerClientEvent('trase_donor:client:giveVehicle', src, vehicleType, model)
                        end
                    end
                end
            else
                print(('^4[Trase_Donor] ^1[ERROR]^0: Someone just claimed package %s, but that package is not configured in the config!'):format(v.name))
            end
        end
    else
        notify_player(src, Config.Strings['no_key'], 'error')
    end
end)

RegisterNetEvent('trase_donor:server:getVehicle', function(vehicleProps, vehicleType, model)
    if (not openedPackages[source]) then
        return print('cheater')
    end

    GiveVehicle(source, vehicleProps, vehicleType, model)
end)