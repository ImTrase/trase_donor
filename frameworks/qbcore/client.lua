if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()
Config.Framework = 1

SpawnVehicle = function(vehicleType, model)
    if (not Config.GiveVehicles.Enabled) then return end
    local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

    QBCore.Functions.SpawnVehicle(model, function(vehicle)
        if DoesEntityExist(vehicle) then
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)

            QBCore.Functions.TriggerCallback('trase_donor:server:qbcore-generatePlate', function(plate)
                local newPlate = plate
                local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
                vehicleProps.plate = newPlate
                TriggerServerEvent('trase_donor:server:getVehicle', vehicleProps, vehicleType, model)
                DeleteVehicle(vehicle)
            end)
		end
    end, coords, false)
end