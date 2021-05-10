local _, ns = ...
function ns:GetConfig()
    return {
        remainder = 1, -- digits after the decimal point
        showManaBar = true, -- display % text on manabar when the text status is enabled
        showHealthBar = true, -- display % text on healthbar when the text status is enabled

        position = { -- fix ArenaFrame and PetFrame position on the Y axis
            ["PetFrame"] = {
                Status = {
                    ["HealthBar"] = { ofsy = 0, ofsx = 0 },
                    ["ManaBar"]   = { ofsy = -1.5, ofsx = 0 },
                },
                Percent = {
                    ["HealthBar"] = { ofsy = 0, ofsx = 0 },
                    ["ManaBar"]   = { ofsy = -1.5, ofsx = 0 },
                }
            },
            ["EnemyFrame"] = { -- ArenaFrame
                Status = {
                    ["HealthBar"] = { ofsy = 2, ofsx = 0 },
                    ["ManaBar"]   = { ofsy = -1.5, ofsx = 0 },
                },
                Percent = {
                    ["HealthBar"] = { ofsy = 2, ofsx = 0 },
                    ["ManaBar"]   = { ofsy = -1.5, ofsx = 0 },
                }
            },
            ["TargetFrame"] = {
                Status = {
                    ["HealthBar"] = { ofsy = 0, ofsx = -5 },
                    ["ManaBar"]   = { ofsy = 0, ofsx = -5 },
                },
                Percent = {
                    ["HealthBar"] = { ofsy = 0, ofsx = 0 },
                    ["ManaBar"]   = { ofsy = 0, ofsx = 0 },
                }
            },
            ["FocusFrame"] = {
                Status = {
                    ["HealthBar"] = { ofsy = 0, ofsx = -5 },
                    ["ManaBar"]   = { ofsy = 0, ofsx = -5 },
                },
                Percent = {
                    ["HealthBar"] = { ofsy = 0, ofsx = 0 },
                    ["ManaBar"]   = { ofsy = 0, ofsx = 0 },
                }
            },
            ["MemberFrame"] = { -- PartyFrame
                Status = {
                    ["HealthBar"] = { ofsy = 0, ofsx = 0 },
                    ["ManaBar"]   = { ofsy = 0, ofsx = 0 },
                },
                Percent = {
                    ["HealthBar"] = { ofsy = 0, ofsx = 5 },
                    ["ManaBar"]   = { ofsy = 0, ofsx = 5 },
                }
            },
            ["PlayerFrame"] = {
                Status = {
                    ["HealthBar"] = { ofsy = 0, ofsx = 0 },
                    ["ManaBar"]   = { ofsy = 0, ofsx = 0 },
                },
                Percent = {
                    ["HealthBar"] = { ofsy = 0, ofsx = 5 },
                    ["ManaBar"]   = { ofsy = 0, ofsx = 5 },
                }
            },
        }
    };
end