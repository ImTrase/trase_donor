-- Add a custom notification system here.
RegisterNetEvent('trase_tebex:client:send_notification', function(message)
    SetNotificationTextEntry('STRING')
	AddTextComponentString(message)
	DrawNotification(0, 1)
end)

RegisterNetEvent('trase_donor:client:giveVehicle', SpawnVehicle)