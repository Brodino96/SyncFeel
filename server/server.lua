local function hasPermission(id)
    local perm = false
    for _, i in ipairs(Config.aceCommandsPermissions) do
        if IsPlayerAceAllowed(id, i) then
            perm = true
        end
    end
    return perm
end

RegisterCommand("forcebrr", function (source, args)
    if hasPermission(source) then

        local intensity
        local duration

        if args[2] ~= nil then
            intensity = tonumber(args[2])
        else
            intensity = Config.settings.server.vibration.intensity.max
        end

        if args[3] ~= nil then
            duration = tonumber(args[3])
        else
            duration = Config.settings.server.vibration.duration.max
        end
        
        if args[1] == "all" then
            TriggerClientEvent("brbrr:forcebrr", -1, intensity, duration)
        elseif tonumber(args[1]) ~= nil then
            TriggerClientEvent("brbrr:forcebrr", args[1], intensity, duration)
        elseif args[1] == "range" then
            TriggerClientEvent("brbrr:forcebrr", -1, intensity, duration, tonumber(args[4]), GetEntityCoords(GetPlayerPed(source)))
        end

    else
        TriggerClientEvent("ox_lib:notify", source, { type = "error", title = L("not_enough_permissions")})
    end
end, false)

function L(line)
    return Locale[Config.locale][line]
end