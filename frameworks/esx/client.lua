if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()
Config.Framework = 0

SpawnVehicle = function(vehicleType, model)
    if (not Config.GiveVehicles.Enabled) then return end
    local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

    ESX.Game.SpawnVehicle(model, coords, 0.0, function(vehicle)
		if DoesEntityExist(vehicle) then
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)
			
			local newPlate = exports[Config.GiveVehicles.ESX]:GeneratePlate()
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			vehicleProps.plate = newPlate

            TriggerServerEvent('trase_donor:server:getVehicle', vehicleProps, vehicleType)
			ESX.Game.DeleteVehicle(vehicle)		
		end
	end)
end