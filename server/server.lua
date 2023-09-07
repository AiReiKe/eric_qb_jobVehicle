local societyVeh = {}
QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("eric_qb_jobVehicle:returnVehicle", function(netID, plate)
	local src = source
	local vehicle = NetworkGetEntityFromNetworkId(netID)
	local vehOwner = NetworkGetEntityOwner(vehicle)

	if vehOwner and vehOwner ~= 0 then
		TriggerClientEvent("eric_qb_jobVehicle:deleteVehicle", vehOwner, netID)
	else
		DeleteEntity(vehicle)
		Wait(100)
		if not DoesEntityExist(vehicle) then
			societyVeh[plate] = nil
		end
	end
end)

RegisterNetEvent("eric_qb_jobVehicle:removeJobVehicle", function(plate)
	societyVeh[plate] = nil
end)

QBCore.Functions.CreateCallback('eric_qb_jobVehicle:SpawnVehicle', function (source, cb, coords, model, plate)
    local veh = QBCore.Functions.SpawnVehicle(source, model, coords, true)
	local Player = QBCore.Functions.GetPlayer(source)
    SetEntityHeading(veh, coords.w)
    SetVehicleNumberPlateText(veh, plate)
    local netId = NetworkGetNetworkIdFromEntity(veh)
	societyVeh[plate] = Player.PlayerData.job.name
    cb(netId)
end)

QBCore.Functions.CreateCallback("eric_qb_jobVehicle:checkPlateStatus", function(source, cb, plate)
	cb(societyVeh[plate])
end)

print("This script created by AiReiKe\nThis script is for free")