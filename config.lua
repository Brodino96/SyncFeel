Config = {
    locale = "en",
    aceCommandsPermissions = { "admin" }, -- Aces that have permission to use the command /forcebrr

    forceServerSettings = false,
    -- [false] = Players will be able to change their own settings using the command /brr (prefered option)
    -- [true] = Players won't be able to change their own settings and this would be enforced for everyone

    settings = {

        damage = {
            enabled = true,
            vibration = {
                intensity = {
                    randomize = true,
                    min = 1,
                    max = 20
                },
                duration = {
                    randomize = true,
                    min = 1,
                    max = 5
                }
            }
        },
        speed = {
            enabled = true,
            thresholdSpeed = 100,
            vibration = {
                intensity = {
                    min = 1,
                    max = 20
                },
            }
        },
        shooting = {
            enabled = true,
            vibration = {
                intensity = {
                    randomize = true,
                    min = 1,
                    max = 20
                },
                duration = {
                    randomize = true,
                    min = 1,
                    max = 6
                }
            }
        },
        server = {
            enabled = true,
            vibration = {
                intensity = {
                    max = 10
                },
                duration = {
                    max = 30
                }
            }
        }
    }
}

Locale = {}