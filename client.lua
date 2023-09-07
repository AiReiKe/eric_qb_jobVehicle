local inZone, radialID = nil, nil
local targetPed, garageBlips = {}, {}
isJob = nil

QBCore = exports['qb-core']:GetCoreObject()
PlayerData = nil

local function DisableBlips()
    for k, v in pairs(garageBlips) do
        RemoveBlip(v)
        garageBlips[k] = nil
    end
end

local function EnableBlips()
    local blipData = Config.Zones[isJob].blip
    for k, v in pairs(Config.Zones[isJob].garages) do
        if v.blip then
            garageBlips[k] = AddBlipForCoord(v.pedPos.xyz)
            
            SetBlipSprite(garageBlips[k], blipData.sprite or 50)
            SetBlipColour(garageBlips[k], blipData.color or 3)
            SetBlipScale(garageBlips[k], blipData.scale or 0.8)
            SetBlipDisplay(garageBlips[k], 4)
            SetBlipAsShortRange(garageBlips[k], true)
    
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.label and Lang:t("label.garage"))
            EndTextCommandSetBlipName(garageBlips[k])
        end
    end
end

local function OpenGarageMenu(garage)
    if lib then
        lib.registerContext({
            id = 'job_garage_menu',
            title = Config.Zones[isJob].garages[garage].label or Lang:t("label.garage"),
            options = {
                {
                    title = Lang:t("header.get_vehicles"),
                    description = Lang:t("desc.get_vehicles_des"),
                    icon = 'fas fa-sign-out-alt',
                    arrow = true,
                    event = 'eric_qb_jobVehicle:VehicleList',
                    args = garage
                },
                {
                    title = Lang:t("header.put_vehicle"),
                    description = Lang:t("desc.put_vehicle_des"),
                    icon = 'fas fa-parking',
                    event = 'eric_qb_jobVehicle:ReturnVehicle',
                    args = garage
                }
            }
        })
        lib.showContext('job_garage_menu')
    else
        exports['qb-menu']:openMenu({
            {
                header = Lang:t("label.garage"),
                icon = 'fas fa-car',
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
            {
                header = Lang:t("header.get_vehicles"),
                txt = Lang:t("desc.get_vehicles_des"),
                icon = 'fas fa-sign-out-alt',
                params = {
                    event = 'eric_qb_jobVehicle:VehicleList',
                    args = garage
                }
            },  
            {
                header = Lang:t("header.put_vehicle"),
                txt = Lang:t("desc.put_vehicle_des"),
                icon = 'fas fa-parking',
                params = {
                    event = 'eric_qb_jobVehicle:ReturnVehicle',
                    args = garage
                }
            },
        })
    end
end

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    if isJob and PlayerData.job.onduty then
        DisableBlips()
    end
    isJob = nil
    if inZone then
        if lib then
            lib.hideContext()
        else
            TriggerEvent("qb-menu:client:closeMenu")
        end
        inZone = nil
    end
    PlayerData = nil
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    if PlayerData and (PlayerData.job.onduty ~= val.job.onduty or PlayerData.job.name ~= val.job.name) then
        if isJob and PlayerData.job.onduty then
            DisableBlips()
        end
        isJob = nil
        if inZone then
            exports['qb-core']:HideText()
            if lib then
                lib.hideContext()
                lib.removeRadialItem('jobVehicle_menu')
            else
                TriggerEvent("qb-menu:client:closeMenu")
                exports['qb-radialmenu']:RemoveOption(radialID)
            end
            inZone = nil
        end
        PlayerData = val
        for k, v in pairs(Config.Zones) do
            if k == PlayerData.job.name then
                isJob = k
                break
            end
        end
        if isJob and PlayerData.job.onduty then
            EnableBlips()
        end
    elseif not PlayerData then
        PlayerData = val
        for k, v in pairs(Config.Zones) do
            if k == PlayerData.job.name then
                isJob = k
                break
            end
        end
        if isJob and PlayerData.job.onduty then
            EnableBlips()
        end
    else
        PlayerData = val
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if isJob and PlayerData.job.onduty then
            DisableBlips()
        end
        for k, v in pairs(Config.Zones) do
            for key, value in pairs(v.garages) do
                if targetPed[k.."_"..key] and DoesEntityExist(targetPed[k.."_"..key]) then
                    if Config.UseTarget then
                        exports['qb-target']:RemoveTargetEntity(targetPed[k.."_"..key], value.label or Lang:t("label.garage"))
                    end
                    DeleteEntity(targetPed[k.."_"..key])
                    targetPed[k.."_"..key] = nil
                end
            end
        end
        if inZone then
            exports['qb-core']:HideText()
            if lib then
                lib.hideContext()
                lib.removeRadialItem('jobVehicle_menu')
            else
                exports['qb-radialmenu']:RemoveOption(radialID)
                TriggerEvent("qb-menu:client:closeMenu")
            end            
            inZone = nil
        end
    end
end)

AddEventHandler("eric_qb_jobVehicle:ReturnVehicle", function(garage)
    local garagePos = Config.Zones[isJob].garages[garage].spawnPos
    local vehicle, vehicleDist = QBCore.Functions.GetClosestVehicle(garagePos.xyz)

    if vehicle ~= -1 and vehicleDist <= 6.0 then
        QBCore.Functions.TriggerCallback('eric_qb_jobVehicle:checkPlateStatus', function(hasPlate)
            if hasPlate == isJob then
                TriggerServerEvent("eric_qb_jobVehicle:returnVehicle", VehToNet(vehicle), QBCore.Functions.GetPlate(vehicle))
            else
                QBCore.Functions.Notify(Lang:t("error.not_society_vehicle"), 'error', 5000)
            end
        end, QBCore.Functions.GetPlate(vehicle))
    else
        QBCore.Functions.Notify(Lang:t("error.no_vehicle_nearby"), 'error', 5000)
    end
end)

RegisterNetEvent("eric_qb_jobVehicle:deleteVehicle", function(netID)
    local vehEntity = NetToVeh(netID)
    local plate = QBCore.Functions.GetPlate(vehEntity)
    DeleteEntity(vehEntity)
    Wait(300)
    if not DoesEntityExist(vehEntity) then
        TriggerServerEvent("eric_qb_jobVehicle:removeJobVehicle", plate)
    end
end)

AddEventHandler("eric_qb_jobVehicle:VehicleList", function(garage)
    if lib then
        local elements = {}
        local garageVehs = Config.Zones[isJob].vehicles
        for i = 1, #garageVehs, 1 do
            table.insert(elements, {
                title = garageVehs[i].label,
                description = Lang:t("desc.get_vehicles_des"),
                event = 'eric_qb_jobVehicle:getOutVehicles',
                args = {
                    model = garageVehs[i].name,
                    garage = garage,
                    extras = garageVehs[i].extras,
                    livery = garageVehs[i].livery,
                }
            })
        end
        lib.registerContext({
            id = 'job_garage:VehiclesList',
            title = Lang:t("header.get_vehicles"),
            menu = 'job_garage_menu',
            options = elements
        })
        lib.showContext('job_garage:VehiclesList')
    else
        local elements = {
            {
                header = Lang:t("header.get_vehicles"),
                icon = 'fas fa-car',
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
        }
        local garageVehs = Config.Zones[isJob].vehicles
        for i = 1, #garageVehs, 1 do
            table.insert(elements, {
                header = garageVehs[i].label,
                txt = Lang:t("desc.get_vehicles_des"),
                params = {
                    event = 'eric_qb_jobVehicle:getOutVehicles',
                    args = {
                        model = garageVehs[i].name,
                        garage = garage,
                        extras = garageVehs[i].extras,
                        livery = garageVehs[i].livery,
                    }
                }
            })
        end
        exports['qb-menu']:openMenu(elements)
    end
end)

RegisterNetEvent("eric_qb_jobVehicle:getOutVehicles", function(data)
    local garagePos = Config.Zones[isJob].garages[data.garage].spawnPos
    local closestVehicle, vehicleDist = QBCore.Functions.GetClosestVehicle(garagePos.xyz)

    if closestVehicle ~= -1 and vehicleDist <= 6.0 then
        QBCore.Functions.Notify(Lang:t("error.not_empty_pos"), 'error', 5000)
    else
        local plate = Config.Zones[isJob].plate or "WORK"
        local plateNum = 8 - string.len(plate)

        for i = 1, plateNum, 1 do
            plate = plate..math.random(0, 9)
        end

        QBCore.Functions.TriggerCallback('eric_qb_jobVehicle:checkPlateStatus', function(hasPlate)
            if hasPlate then
                TriggerEvent("eric_qb_jobVehicle:getOutVehicles", data)
            else
                QBCore.Functions.TriggerCallback("eric_qb_jobVehicle:SpawnVehicle", function(netID)
                    local vehicle = NetToVeh(netID)
                    if data.extras then
                        QBCore.Shared.SetDefaultVehicleExtras(vehicle, data.extras)
                    end
                    if data.livery then
                        SetVehicleLivery(vehicle, data.livery)
                    end
                    SetFuel(vehicle, 100)
                    TriggerEvent("vehiclekeys:client:SetOwner", plate)
                    SetVehicleEngineOn(vehicle, true, true)
                    SetVehRadioStation(vehicle, 'OFF')
                end, garagePos, data.model, plate)
            end
        end, plate)
    end
end)

AddEventHandler("eric_qb_jobVehicle:OpenGarageMenu", function(data)
    OpenGarageMenu(data)
end)

Citizen.CreateThread(function()
    if LocalPlayer.state.isLoggedIn then
        PlayerData = QBCore.Functions.GetPlayerData()
        for k, v in pairs(Config.Zones) do
            if k == PlayerData.job.name then
                isJob = k
                break
            end
        end
        if isJob then
            EnableBlips()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local pedCoords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.Zones) do
            for key, value in pairs(v.garages) do
                local dist = Vdist(pedCoords, value.pedPos.xyz)
                if dist <= 80 then
                    if not targetPed[k.."_"..key] or not DoesEntityExist(targetPed[k.."_"..key]) then
                        RequestModel(Config.PedModel)

                        while not HasModelLoaded(Config.PedModel) do
                            Citizen.Wait(0)
                        end

                        targetPed[k.."_"..key] = CreatePed(0, Config.PedModel, value.pedPos.xyz, value.pedPos.w, false, true)
                        SetEntityAlpha(targetPed[k.."_"..key], 0, false)
                        Wait(50)
                        SetEntityAlpha(targetPed[k.."_"..key], 255, false)
            
                        SetPedFleeAttributes(targetPed[k.."_"..key], 2)
                        SetBlockingOfNonTemporaryEvents(targetPed[k.."_"..key], true)
                        SetPedCanRagdollFromPlayerImpact(targetPed[k.."_"..key], false)
                        SetPedDiesWhenInjured(targetPed[k.."_"..key], false)
                        FreezeEntityPosition(targetPed[k.."_"..key], true)
                        SetEntityInvincible(targetPed[k.."_"..key], true)
                        SetPedCanPlayAmbientAnims(targetPed[k.."_"..key], false)
                        SetModelAsNoLongerNeeded(Config.PedModel)

                        if Config.UseTarget then
                            exports['qb-target']:AddTargetEntity(targetPed[k.."_"..key], {
                                options = {
                                    {
                                        action = function()
                                            OpenGarageMenu(key)
                                        end,
                                        canInteract = function()
                                            return PlayerData.job.onduty
                                        end,
                                        icon = value.icon or 'fas fa-car',
                                        label = value.label or Lang:t("label.garage"),
                                        job = k,
                                    }
                                },
                                distance = 1.2
                            })
                        end
                    end
                    if not Config.UseTarget then
                        if isJob == k then
                            if dist <= 1.5 then
                                if not inZone then
                                    inZone = k.."_"..key
                                    exports['qb-core']:DrawText(value.label or Lang:t("label.garage"))
                                    if lib then
                                        lib.addRadialItem({
                                            {
                                                id = 'jobVehicle_menu',
                                                icon = value.icon or 'fas fa-car',
                                                label = value.label or Lang:t("label.garage"),
                                                onSelect = function() OpenGarageMenu(key) end
                                            }
                                        })
                                    else
                                        local radialID = exports['qb-radialmenu']:AddOption({
                                            id = 'jobVehicle_menu',
                                            title = value.label or Lang:t("label.garage"),
                                            icon = value.icon or 'fas fa-car',
                                            type = 'client',
                                            event = 'eric_qb_jobVehicle:OpenGarageMenu',
                                            args = key,
                                            shouldClose = true
                                        }, radialID)
                                    end
                                end
                            else
                                if inZone == k.."_"..key then
                                    inZone = nil
                                    exports['qb-core']:HideText()
                                    if lib then
                                        lib.removeRadialItem('jobVehicle_menu')
                                    else
                                        exports['qb-radialmenu']:RemoveOption(radialID)
                                    end
                                end
                            end
                        elseif inZone == k.."_"..key then
                            inZone = nil
                            exports['qb-core']:HideText()
                            if lib then
                                lib.removeRadialItem('jobVehicle_menu')
                            else
                                exports['qb-radialmenu']:RemoveOption(radialID)
                            end
                        end
                    end
                else
                    if targetPed[k.."_"..key] and DoesEntityExist(targetPed[k.."_"..key]) then
                        if Config.UseTarget then
                            exports['qb-target']:RemoveTargetEntity(targetPed[k.."_"..key], value.label or Lang:t("label.garage"))
                        end
                        DeleteEntity(targetPed[k.."_"..key])
                        targetPed[k.."_"..key] = nil
                    end
                end
            end
        end
        Wait(500)
    end
end)