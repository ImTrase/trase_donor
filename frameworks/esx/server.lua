if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()
Config.Framework = 0

GetPlayer = function(target)
    local xPlayer = ESX.GetPlayerFromId(target)
    if (xPlayer) then
        return xPlayer
    end
end

AddItem = function(target, item, amount)
    local player = GetPlayer(target)

    if (item == 'money') then
        player.addMoney(amount)
    elseif (item == 'black_money' or item == 'bank') then
        player.addAccountMoney(item, amount)
    else
        player.addInventoryItem(item, amount)
    end
end

GiveVehicle = function(target, vehicleProps, vehicleType)
    local player = GetPlayer(target)
    if (Config.SQL == 0) then -- oxmysql
        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (?, ?, ?, 1, ?)', { player.identifier, vehicleProps.plate, json.encode(vehicleProps), vehicleType }, function(id)
            
        end)
    else -- mysql-asnyc
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)',
        {
            ['@owner']   = player.identifier,
            ['@plate']   = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@stored']  = 1,
            ['type'] = vehicleType
        }, function ()
            
        end)
    end
end