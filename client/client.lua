--------------- # --------------- # --------------- # --------------- # ---------------

local icons = { ["true"] = "check", ["false"] = "x" } -- To change the icons in the menus
local settings = {} -- Local storage for settings

local threadActive = false -- If the script is actually working
local toyAvailable = false -- If the toy is connected

-- Values for the main thread
local oldHealth

--------------- # --------------- # --------------- # --------------- # ---------------

local function mainThread()

    -- If the toy is not connected then tries to connect to it
    if not toyAvailable then
        return ConnectToToy()
    end
    threadActive = false
    Wait(1000)
    threadActive = true

    oldHealth = GetEntityHealth(PlayerPedId())
    local segment = (220.0 - settings.speed.thresholdSpeed) / 10

    CreateThread(function ()
        while threadActive do
            Wait(0)

            -- Checks for toy presence
            if not toyAvailable then
                threadActive = false
                return lib.notify({ type = "error", title = L("toy_disconnected")})
            end

            -- Resets some values
            local intensity = 0
            local duration = 0
            local playerPed = PlayerPedId()

            if settings.damage.enabled then -- Checks if the feature is enabled

                local currentHealth = GetEntityHealth(playerPed)
                if currentHealth < oldHealth then -- If the player took damage

                    -- Sets the intensity (if randomized or forced)
                    if settings.damage.vibration.intensity.randomize then
                        intensity = math.random(settings.damage.vibration.intensity.min, settings.damage.vibration.intensity.max)
                    else
                        intensity = settings.damage.vibration.intensity.min
                    end

                    -- Sets the duration (if randomized or forced)
                    if settings.damage.vibration.duration.randomize then
                        duration = math.random(settings.damage.vibration.duration.min, settings.damage.vibration.duration.max)
                    else
                        duration = settings.damage.vibration.duration.min
                    end

                    SendNUIMessage({
                        action = "vibrate",
                        intensity = intensity,
                        duration = duration
                    })

                end
                oldHealth = currentHealth -- Updates the old health
            end

--------------- # --------------- # --------------- # --------------- # --------------- # --------------- # ---------------

            if settings.speed.enabled then -- Checks if the feature is enabled
                
                local speed = GetEntitySpeed(playerPed) * 3.6
                if speed > settings.speed.thresholdSpeed then -- If the player is going faster
                    
                    -- This transforms km/h into a number between 1 and 20
                    for i = 0, 10 do
                        if speed > (settings.speed.thresholdSpeed + (segment * i)) then
                            intensity = settings.speed.vibration.intensity.min * i * 2
                        end
                    end
                    
                    -- Here in case the player has put a max intensity
                    if intensity > settings.speed.vibration.intensity.max then
                        intensity = settings.speed.vibration.intensity.max
                    end
                    
                    SendNUIMessage({
                        action = "speeding",
                        intensity = intensity
                    })
                end
                
            end

--------------- # --------------- # --------------- # --------------- # --------------- # --------------- # ---------------

            if settings.shooting.enabled then
                
                if IsPedShooting(playerPed) then
                    
                    if settings.shooting.vibration.intensity.randomize then
                        intensity = math.random(settings.shooting.vibration.intensity.min, settings.shooting.vibration.intensity.max)
                    else
                        intensity = settings.shooting.vibration.intensity.min
                    end

                    -- Sets the duration (if randomized or forced)
                    if settings.shooting.vibration.duration.randomize then
                        duration = math.random(settings.shooting.vibration.duration.min, settings.shooting.vibration.duration.max)
                    else
                        duration = settings.shooting.vibration.duration.min
                    end

                    SendNUIMessage({
                        action = "vibrate",
                        intensity = intensity,
                        duration = duration
                    })
                end
            end

--------------- # --------------- # --------------- # --------------- # --------------- # --------------- # ---------------

        end
    end)
end

local function openMenu()

    if not Config.forceServerSettings then
        FetchSettings()

        lib.registerContext({
            id = "brr:main_menu",
            title = L("main_menu_title"),
            canClose = true,
            options = {
                {
                    title = L("dmg_title"),
                    description = L("dmg_desc"),
                    icon = icons[tostring(settings.damage.enabled)],
                    onSelect = function ()
                        DamageInput()
                    end
                },
                {
                    title = L("speed_title"),
                    description = L("speed_desc"),
                    icon = icons[tostring(settings.speed.enabled)],
                    onSelect = function ()
                        SpeedInput()
                    end
                },
                {
                    title = L("shooting_title"),
                    description = L("shooting_desc"),
                    icon = icons[tostring(settings.shooting.enabled)],
                    onSelect = function ()
                        ShootingInput()
                    end
                },
                {
                    title = L("server_title"),
                    description = L("server_desc"),
                    icon = icons[tostring(settings.server.enabled)],
                    onSelect = function ()
                        ServerInput()
                    end
                },
                {
                    title = L("activate_deactivate"),
                    icon = icons[tostring(threadActive)],
                    onSelect = function ()
                        if not threadActive then
                            mainThread()
                        else
                            threadActive = false
                            SendNUIMessage({
                                action = "disconnect"
                            })
                        end
                    end
                }
            }
        })

    else
        lib.registerContext({
            id = "brr:main_menu",
            title = L("main_menu_title"),
            canClose = true,
            options = {
                {
                    title = L("activate_deactivate"),
                    icon = icons[tostring(threadActive)],
                    onSelect = function ()
                        if not threadActive then
                            mainThread()
                        else
                            threadActive = false
                            SendNUIMessage({
                                action = "disconnect"
                            })
                        end
                    end
                }
            }
        })
    end

    lib.showContext("brr:main_menu")
end

--------------- # --------------- # --------------- # --------------- # ---------------

function DamageInput()
    local input = lib.inputDialog(L("dmg_title"), {
        { type = "checkbox", label = L("active"), checked = settings.damage.enabled },
        { type = "checkbox", label = L("randomize_intensity"), checked = settings.damage.vibration.intensity.randomize },
        { type = "number", label = L("min_intensity"), min = 0, max = 20, default = settings.damage.vibration.intensity.min, placeholder = settings.damage.vibration.intensity.min},
        { type = "number", label = L("max_intensity"), min = 0, max = 20, default = settings.damage.vibration.intensity.max, placeholder = settings.damage.vibration.intensity.max },
        { type = "checkbox", label = L("randomize_duration"), checked = settings.damage.vibration.duration.randomize },
        { type = "number", label = L("min_duration"), min = 0, max = 60, default = settings.damage.vibration.duration.min, placeholder = settings.damage.vibration.duration.min },
        { type = "number", label = L("max_duration"), min = 0, max = 60, default = settings.damage.vibration.duration.max, placeholder = settings.damage.vibration.duration.max },
    })

    if input == nil then
        return openMenu()
    end

    settings.damage.enabled = input[1]
    settings.damage.vibration.intensity.randomize = input[2]
    settings.damage.vibration.intensity.min = tonumber(input[3])
    settings.damage.vibration.intensity.max = tonumber(input[4])
    settings.damage.vibration.duration.randomize = input[5]
    settings.damage.vibration.duration.min = tonumber(input[6])
    settings.damage.vibration.duration.max = tonumber(input[7])

    SaveSettings()
    openMenu()
end

function SpeedInput()
    local input = lib.inputDialog(L("speed_title"), {
        { type = "checkbox", label = L("active"), checked = settings.speed.enabled },
        { type = "number", label = L("speed_treshold"), min = 0, max = 500, precision = 1, step = 1, default = settings.speed.thresholdSpeed, placeholder = settings.speed.thresholdSpeed },
        { type = "number", label = L("min_intensity"), min = 0, max = 20, default = settings.speed.vibration.intensity.min, placeholder = settings.speed.vibration.intensity.min },
        { type = "number", label = L("max_intensity"), min = 0, max = 20, default = settings.speed.vibration.intensity.max, placeholder = settings.speed.vibration.intensity.max },
    })

    if input == nil then
        return openMenu()
    end

    settings.speed.enabled = input[1]
    settings.speed.thresholdSpeed = tonumber(input[2]..".0")
    settings.speed.vibration.intensity.min = tonumber(input[3])
    settings.speed.vibration.intensity.max = tonumber(input[4])

    SaveSettings()
    openMenu()
end

function ShootingInput()
    local input = lib.inputDialog(L("shooting_title"), {
        { type = "checkbox", label = L("active"), checked = settings.shooting.enabled },
        { type = "checkbox", label = L("randomize_intensity"), checked = settings.shooting.vibration.randomize },
        { type = "number", label = L("min_intensity"), min = 0, max = 20, default = settings.shooting.vibration.intensity.min, placeholder = settings.shooting.vibration.intensity.min },
        { type = "number", label = L("max_intensity"), min = 0, max = 20, default = settings.shooting.vibration.intensity.max, placeholder = settings.shooting.vibration.intensity.max },

        { type = "checkbox", label = L("randomize_duration"), checked = settings.shooting.vibration.duration.randomize },
        { type = "number", label = L("min_duration"), min = 0, max = 60, default = settings.shooting.vibration.duration.min, placeholder = settings.shooting.vibration.duration.min },
        { type = "number", label = L("max_duration"), min = 0, max = 60, default = settings.shooting.vibration.duration.max, placeholder = settings.shooting.vibration.duration.max },
    })

    if input == nil then
        return openMenu()
    end

    settings.shooting.enabled = input[1]
    settings.shooting.vibration.intensity.randomize = input[2]
    settings.shooting.vibration.intensity.min = tonumber(input[3])
    settings.shooting.vibration.intensity.max = tonumber(input[4])
    settings.shooting.vibration.duration.randomize = input[5]
    settings.shooting.vibration.duration.min = tonumber(input[6])
    settings.shooting.vibration.duration.max = tonumber(input[7])

    SaveSettings()
    openMenu()
end

function ServerInput()
    local input = lib.inputDialog(L("server_title"), {
        { type = "checkbox", label = L("active"), checked = settings.server.enabled },
        { type = "number", label = L("max_intensity"), min = 0, max = 20, default = settings.server.vibration.intensity.max, placeholder = settings.server.vibration.intensity.max },
        { type = "number", label = L("max_duration"), min = 0, max = 60, default = settings.server.vibration.duration.max, placeholder = settings.server.vibration.duration.max },
    })

    if input == nil then
        return openMenu()
    end

    settings.server.enabled = input[1]
    settings.server.vibration.intensity.max = tonumber(input[2])
    settings.server.vibration.duration.max = tonumber(input[3])

    SaveSettings()
    openMenu()
end

--------------- # --------------- # --------------- # --------------- # ---------------

RegisterNUICallback("connectionError", function ()
    lib.notify({ type = "error", title = L("toy_connection_error") })
end)

RegisterNUICallback("connectionSuccess", function ()
    toyAvailable = true
    lib.notify({ type = "success", title = L("toy_connection_success") })
    mainThread()
end)

RegisterNUICallback("deviceDisconnected", function ()
    toyAvailable = false
end)

RegisterNUICallback("disconnectSuccessful", function ()
    lib.notify({ type = "error", title = L("toy_disconnected") })
end)

--------------- # --------------- # --------------- # --------------- # ---------------

local dict = { ["true"] = true, ["false"] = false }
function StrToBool(string)
    return dict[string]
end

function FetchSettings() -- This returns all the settings saved in the client

    settings = Config.settings
    if GetResourceKvpString("damage_enabled") ~= nil then
        settings.damage.enabled = StrToBool(GetResourceKvpString("damage_enabled"))
        settings.damage.vibration.intensity.randomize = StrToBool(GetResourceKvpString("damage_int_rand"))
        settings.damage.vibration.intensity.min = GetResourceKvpInt("damage_int_min")
        settings.damage.vibration.intensity.max = GetResourceKvpInt("damage_int_max")
        settings.damage.vibration.duration.randomize = StrToBool(GetResourceKvpString("damage_dur_rand"))
        settings.damage.vibration.duration.min = GetResourceKvpInt("damage_dur_min")
        settings.damage.vibration.duration.max = GetResourceKvpInt("damage_dur_max")

        settings.speed.enabled = StrToBool(GetResourceKvpString("speed_enabled"))
        settings.speed.thresholdSpeed = GetResourceKvpFloat("speed_threshold")
        settings.speed.vibration.intensity.min = GetResourceKvpInt("speed_dur_min")
        settings.speed.vibration.intensity.max = GetResourceKvpInt("speed_dur_max")

        settings.shooting.enabled = StrToBool(GetResourceKvpString("shooting_enabled"))
        settings.shooting.vibration.intensity.randomize = StrToBool(GetResourceKvpString("shooting_int_rand"))
        settings.shooting.vibration.intensity.min = GetResourceKvpInt("shooting_int_min")
        settings.shooting.vibration.intensity.max = GetResourceKvpInt("shooting_int_max")
        settings.shooting.vibration.duration.randomize = StrToBool(GetResourceKvpString("shooting_dur_rand"))
        settings.shooting.vibration.duration.min = GetResourceKvpInt("shooting_dur_min")
        settings.shooting.vibration.duration.max = GetResourceKvpInt("shooting_dur_max")

        settings.server.enabled = StrToBool(GetResourceKvpString("server_enabled"))
        settings.server.vibration.intensity.max = GetResourceKvpInt("server_int_max")
        settings.server.vibration.duration.max = GetResourceKvpInt("server_dur_max")
    end
end

function SaveSettings() -- This saves all the settings into the client
    SetResourceKvp("damage_enabled", tostring(settings.damage.enabled))
    SetResourceKvp("damage_int_rand", tostring(settings.damage.vibration.intensity.randomize))
    SetResourceKvpInt("damage_int_min", settings.damage.vibration.intensity.min)
    SetResourceKvpInt("damage_int_max", settings.damage.vibration.intensity.max)
    SetResourceKvp("damage_dur_rand", tostring(settings.damage.vibration.duration.randomize))
    SetResourceKvpInt("damage_dur_min", settings.damage.vibration.duration.min)
    SetResourceKvpInt("damage_dur_max", settings.damage.vibration.duration.max)

    SetResourceKvp("speed_enabled", tostring(settings.speed.enabled))
    SetResourceKvpFloat("speed_threshold", settings.speed.thresholdSpeed)
    SetResourceKvpInt("speed_dur_min", settings.speed.vibration.intensity.min)
    SetResourceKvpInt("speed_dur_max", settings.speed.vibration.intensity.max)

    SetResourceKvp("shooting_enabled", tostring(settings.shooting.enabled))
    SetResourceKvp("shooting_int_rand", tostring(settings.shooting.vibration.intensity.randomize))
    SetResourceKvpInt("shooting_int_min", settings.shooting.vibration.intensity.min)
    SetResourceKvpInt("shooting_int_max", settings.shooting.vibration.intensity.max)
    SetResourceKvp("shooting_dur_rand", tostring(settings.shooting.vibration.duration.randomize))
    SetResourceKvpInt("shooting_dur_min", settings.shooting.vibration.duration.min)
    SetResourceKvpInt("shooting_dur_max", settings.shooting.vibration.duration.max)

    SetResourceKvp("server_enabled", tostring(settings.server.enabled))
    SetResourceKvpInt("server_int_max", settings.server.vibration.intensity.max)
    SetResourceKvpInt("server_dur_max", settings.server.vibration.duration.max)
end

function ConnectToToy()
    SendNUIMessage({
        action = "connect"
    })
end

--------------- # --------------- # --------------- # --------------- # ---------------

RegisterCommand("brr", function ()
    if Config.forceServerSettings then
        settings = Config.settings
        lib.notify({ type = "info", title = L("force_server_settings")})
    end

    openMenu()
end, false)

RegisterNetEvent("brbrr:forcebrr")
AddEventHandler("brbrr:forcebrr", function (intensity, duration, range, coords)

    if not settings.server.enabled then
        return
    end

    if range ~= nil then
        if #(GetEntityCoords(PlayerPedId()) - coords) > range then
            return
        end
    end

    if intensity > settings.server.vibration.intensity.max then
        intensity = settings.server.vibration.intensity.max
    end
    if duration > settings.server.vibration.duration.max then
        duration = settings.server.vibration.duration.max
    end

    SendNUIMessage({
        action = "vibrate",
        intensity = intensity,
        duration = duration
    })
end)

CreateThread(function ()
    TriggerEvent("chat:addSuggestion", "/forcebrr", L("command_desc"), {
        { name = L("command_mode"), help = L("command_mode_desc") },
        { name = L("command_intensity"), help = L("command_intensity_desc") },
        { name = L("command_duration"), help = L("command_duration_desc") },
        { name = L("command_range"), help = L("command_range_desc") }
    })
    TriggerEvent("chat:addSuggestion", "/brr", L("settings_command_desc"))
end)

--------------- # --------------- # --------------- # --------------- # ---------------

function L(line)
    return Locale[Config.locale][line]
end

--------------- # --------------- # --------------- # --------------- # ---------------
--[[
RegisterCommand("brrtest", function ()
    CreateThread(function ()
        while true do
            Wait(0)

            print(IsPedShooting(PlayerPedId()))
        end
    end)
end, false)
]]