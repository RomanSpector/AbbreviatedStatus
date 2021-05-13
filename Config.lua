local _, ns = ...;
local HEALTH = HEALTH;
local MANA = MANA;
function ns:GetDefaultPofile()
    return {
        locale = GetLocale(),
        remainder = 1,
        ["player"] = {
            [HEALTH] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            },
            [MANA] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            }
        },
        ["pet"] = {
            [HEALTH] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            },
            [MANA] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            }
        },
        ["target"] = {
            [HEALTH] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            },
            [MANA] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            }
        },
        ["focus"] = {
            [HEALTH] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            },
            [MANA] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            }
        },
        ["party"] = {
            [HEALTH] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            },
            [MANA] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            }
        },
        ["arena"] = {
            [HEALTH] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            },
            [MANA] = {
                percent = { enable = true, xOff = 0, yOff = 0 },
                status = { enable = true, xOff = 0, yOff = 0 },
            }
        }
    }
end