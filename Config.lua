local addon, ns = ...;
local version = GetAddOnMetadata(addon, "Version");

function AbbreviatedStatusOption_SetTtextProperties()
    return { enable = true, xOff = 0, yOff = 0 };
end

function AbbreviatedStatusOption_SetBarProperties()
    return {
        percent = AbbreviatedStatusOption_SetTtextProperties(),
        status = AbbreviatedStatusOption_SetTtextProperties(),
    };
end

function AbbreviatedStatusOption_SetDefaultSetting()
    return {
        ["healthbar"] = AbbreviatedStatusOption_SetBarProperties(),
        ["manabar"] = AbbreviatedStatusOption_SetBarProperties()
    };
end

function ns:GetDefaultProfile()
    return {
        version     = version,
        remainder   = 1,
        ["player"]  = AbbreviatedStatusOption_SetDefaultSetting(),
        ["pet"]     = {
                        ["healthbar"] = { enable = true, xOff = 0, yOff = 0 },
                        ["manabar"] = { enable = true, xOff = 0, yOff = -1.5 },
                    },
        ["target"]  = AbbreviatedStatusOption_SetDefaultSetting(),
        ["focus"]   = AbbreviatedStatusOption_SetDefaultSetting(),
        ["party"]   = AbbreviatedStatusOption_SetDefaultSetting(),
        ["arena"]   = {
                        ["healthbar"] = { enable = true, xOff = 0, yOff = 2 },
                        ["manabar"] = { enable = true, xOff = 0, yOff = 1 },
                    }
    };
end