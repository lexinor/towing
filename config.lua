Config = {}

Config.actionsCategory = "towing"

Config.whitelist = { -- when adding add-on cars simply use their spawn name
    'FLATBED',
    'BENSON',
    'WASTLNDR', -- WASTELANDER
    'MULE',
    'MULE2',
    'MULE3',
    'MULE4',
    'TRAILER', -- TRFLAT
    'ARMYTRAILER',
    'BOATTRAILER',
}

Config.offsets = { -- when adding add-on cars simply use their spawn name
    {model = 'FLATBED', offset = {x = 0.0, y = -9.0, z = -1.25}}, -- x -> Left/Right adjustment | y -> Forward/Backward adjustment | z -> Height adjustment
    {model = 'BENSON', offset = {x = 0.0, y = 0.0, z = -1.25}},
    {model = 'WASTLNDR', offset = {x = 0.0, y = -7.2, z = -0.9}},
    {model = 'MULE', offset = {x = 0.0, y = -7.0, z = -1.75}},
    {model = 'MULE2', offset = {x = 0.0, y = -7.0, z = -1.75}},
    {model = 'MULE3', offset = {x = 0.0, y = -7.0, z = -1.75}},
    {model = 'MULE4', offset = {x = 0.0, y = -7.0, z = -1.75}},
    {model = 'TRAILER', offset = {x = 0.0, y = -9.0, z = -1.25}},
    {model = 'ARMYTRAILER', offset = {x = 0.0, y = -9.5, z = -3.0}},
}

RampHash = 'imp_prop_flatbed_ramp'


Config.QuickActions = {
    
    -- Actions sur les Véhicule
    vehicle = {
        deployramp = {
            isAuthorized = true,
            options = {
                {
                    -- an identifier used when removing options
                    name = ("%s_deployramp"):format(Config.actionsCategory),
                    -- an icon from font-awesome
                    icon = "fa-solid fa-truck-ramp-box",
                    iconColor = "violet",
                    -- display text
                    label = "Déployer la rampe",
                    -- range to display (default: 2, max: 7)
                    distance = 2.0,
                    -- custom check to hide or display the option
                    canInteract = function(entity, distance, coords, name, bone)                        
                        if distance < 2.0 then
                            local rampdeployed = Entity(entity).state.rampdeployed
                            if not rampdeployed then
                                local vName = GetDisplayNameFromVehicleModel(GetEntityModel(entity))
                                return Contains(vName, Config.whitelist)
                            end
                        end
                    end,
                    -- triggered on option selection (one only)
                    onSelect = function(data)
                        if data.distance < 2.0 and data.entity then
                            local vehicleCoords = GetEntityCoords(data.entity)
                            local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(data.entity))
                            for _, value in pairs(Config.offsets) do
                                if vehicleName == value.model then
                                    local ramp = CreateObject(RampHash, vector3(value.offset.x, value.offset.y, value.offset.z), true, false, false)
                                    AttachEntityToEntity(ramp, data.entity, GetEntityBoneIndexByName(data.entity, 'chassis'), value.offset.x, value.offset.y, value.offset.z , 180.0, 180.0, 0.0, 0, 0, 1, 0, 0, 1)
                                    exports.ox_target:addEntity(NetworkGetNetworkIdFromEntity(ramp), Config.EntityTargetOption)
                                    local netId = NetworkGetNetworkIdFromEntity(data.entity)
                                    Entity(ramp).state:set("parentNetId", netId, true)
                                end
                            end
                            drawNotification(locale("success.rampdeployed"))
                            Entity(data.entity).state:set("rampdeployed", true, true)
                        end
                    end,
                }
            }
        },
    },
}

Config.EntityTargetOption = {
    {
        -- an identifier used when removing options
        name = ("%s_rmramp"):format(Config.actionsCategory),
        -- an icon from font-awesome
        icon = "fa-solid fa-truck-ramp-box",
        iconColor = "violet",
        -- display text
        label = "Ranger rampe",
        -- range to display (default: 2, max: 7)
        distance = 2.0,
        -- triggered on option selection (one only)
        onSelect = function(data)
            if data.distance < 2.0 and data.entity then
                if not IsPedInAnyVehicle(cache.ped or PlayerPedId(), false) then
                    if GetHashKey(RampHash) == GetEntityModel(data.entity) then                        
                        TriggerServerEvent("towing:rmramp", NetworkGetNetworkIdFromEntity(data.entity), Entity(data.entity).state.parentNetId)
                        drawNotification(locale("success.rampremoved"))
                    end
                end
            end
        end,
    }
}