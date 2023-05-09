RegisterNetEvent("towing:rmramp", function (rampNetId, parentNetId)
    if not rampNetId and not parentNetId then return end

    local parent = NetworkGetEntityFromNetworkId(parentNetId)
    local ramp = NetworkGetEntityFromNetworkId(rampNetId)
    if GetHashKey(RampHash) == GetEntityModel(ramp) then
        Entity(parent).state:set("rampdeployed", false, true)
        DeleteEntity(ramp)
    end
end)