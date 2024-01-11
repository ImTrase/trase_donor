if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()
Config.Framework = 1

GetPlayer = function(target)
    local player = QBCore.Functions.GetPlayer(target)
    if (player) then
        return player
    end
end

AddItem = function(target, item, amount)
    local player = QBCore.Functions.GetPlayer(target)

    if (item == 'cash' or item == 'crypto' or item == 'bank') then
        player.Functions.AddMoney(item, amount)
    else
        player.Functions.AddItem(item, amount)
    end
end

GeneratePlate = function()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end


GiveVehicle = function(target, vehicleProps, vehicleType, model)
    local player = GetPlayer(target)

    if (Config.SQL == 0) then -- oxmysql
        MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', { 
            player.PlayerData.license,
            player.PlayerData.citizenid,
            model,
            vehicleProps.model,
            '{}', 
            vehicleProps.plate, 
            'pillboxgarage',
            0 
        }, function(id)
            
        end)
    else -- mysql-asnyc
        MySQL.Async.execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (@owner, @plate, @vehicle, @stored, @type)',
        {
            ['@license']   = player.PlayerData.license,
            ['@citizenid']   = player.PlayerData.citizenid,
            ['@vehicle'] = model,
            ['@hash'] = vehicleProps.model,
            ['@mods'] = '{}',
            ['@plate'] = vehicleProps.plate,
            ['@garage'] = 'pillboxgarage',
            ['@state']  = 0
        }, function ()
            
        end)
    end
end

QBCore.Functions.CreateCallback('trase_donor:server:qbcore-generatePlate', function(source, cb)
    local plate = GeneratePlate()
    cb(plate)
end)