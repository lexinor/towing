lib.locale()

RegisterCommand('deployramp', function ()
    local player = cache.ped or PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local radius = 5.0

    local vehicle = nil

    if IsAnyVehicleNearPoint(playerCoords, radius) then
        vehicle = getClosestVehicle(playerCoords)
        local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

        drawNotification("Trying to deploy a ramp for: " .. vehicleName)

        if Contains(vehicleName, Config.whitelist) then
            local vehicleCoords = GetEntityCoords(vehicle)

            for _, value in pairs(Config.offsets) do
                if vehicleName == value.model then
                    local ramp = CreateObject(RampHash, vector3(value.offset.x, value.offset.y, value.offset.z), true, false, false)
                    AttachEntityToEntity(ramp, vehicle, GetEntityBoneIndexByName(vehicle, 'chassis'), value.offset.x, value.offset.y, value.offset.z , 180.0, 180.0, 0.0, 0, 0, 1, 0, 0, 1)
                end
            end

            drawNotification(locale("success.rampdeployed"))
            return
        end
        drawNotification(locale("error.cantdeployramp"))
        return
    end
end)

RegisterCommand('ramprm', function()
    local player = cache.ped or PlayerPedId()
    local playerCoords = GetEntityCoords(player)

    local object = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, RampHash, false, 0, 0)

    if not IsPedInAnyVehicle(player, false) then
        if GetHashKey(RampHash) == GetEntityModel(object) then
            DeleteObject(object)
            drawNotification(locale("success.rampremoved"))
            return
        end
    end

    drawNotification(locale("error.rampremove"))
end)

RegisterCommand('attach', function()
    local player = cache.ped or PlayerPedId()
    local vehicle = nil

    if IsPedInAnyVehicle(player, false) then
        vehicle = GetVehiclePedIsIn(player, false)
        if GetPedInVehicleSeat(vehicle, -1) == player then
            local vehicleCoords = GetEntityCoords(vehicle)
            local vehicleOffset = GetOffsetFromEntityInWorldCoords(vehicle, 1.0, 0.0, -1.5)
            local vehicleRotation = GetEntityRotation(vehicle, 2)
            local belowEntity = GetVehicleBelowMe(vehicleCoords, vehicleOffset)
            local vehicleBelowRotation = GetEntityRotation(belowEntity, 2)
            local vehicleBelowName = GetDisplayNameFromVehicleModel(GetEntityModel(belowEntity))

            local vehiclesOffset = GetOffsetFromEntityGivenWorldCoords(belowEntity, vehicleCoords)

            local vehiclePitch = vehicleRotation.x - vehicleBelowRotation.x
            local vehicleYaw = vehicleRotation.z - vehicleBelowRotation.z

            if Contains(vehicleBelowName, Config.whitelist) then
                if not IsEntityAttached(vehicle) then
                    AttachEntityToEntity(vehicle, belowEntity, GetEntityBoneIndexByName(belowEntity, 'chassis'), vehiclesOffset, vehiclePitch, 0.0, vehicleYaw, false, false, true, false, 0, true)
                    return drawNotification(locale('success.vehicleattched'))
                end
                return drawNotification(locale('error.alreadyattached'))
            end
            return drawNotification('Can\'t attach to this entity: ' .. vehicleBelowName)
        end
        return drawNotification(locale('error.notdriver'))
    end
    drawNotification(locale('error.notinvehicle'))
end)

RegisterCommand('detach', function()
    local player = cache.ped or PlayerPedId()
    local vehicle = nil

    if IsPedInAnyVehicle(player, false) then
        vehicle = GetVehiclePedIsIn(player, false)
        if GetPedInVehicleSeat(vehicle, -1) == player then
            if IsEntityAttached(vehicle) then
                DetachEntity(vehicle, false, true)
                return drawNotification(locale('success.vehicledetched'))
            else
                return drawNotification(locale("error.notattached"))
            end
        else
            return drawNotification(locale('error.notdriver'))
        end
    else
        return drawNotification(locale('error.notinvehicle'))
    end
end)

function getClosestVehicle(coords)
    local ped = cache.ped or PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

function GetVehicleBelowMe(cFrom, cTo) -- Function to get the vehicle under me
    local rayHandle = CastRayPointToPoint(cFrom.x, cFrom.y, cFrom.z, cTo.x, cTo.y, cTo.z, 10, cache.ped or PlayerPedId(), 0) -- Sends raycast under me
    local _, _, _, _, vehicle = GetRaycastResult(rayHandle) -- Stores the vehicle under me
    return vehicle -- Returns the vehicle under me
end

function Contains(item, list)
    for _, value in ipairs(list) do
        if value == item then return true end
    end
    return false
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(true, false)
end

CreateThread(function ()
    for k, action in pairs(Config.QuickActions.vehicle) do
        if action.isAuthorized then
            exports.ox_target:removeGlobalVehicle(action.options[1].name)
            exports.ox_target:addGlobalVehicle(action.options)
        end
    end
end)