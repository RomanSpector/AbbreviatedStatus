local addon, ns = ...;
local version = GetAddOnMetadata(addon, "Version");

function AbbreviatedStatusOption_SetDefaultSetting()
    return {
        ["healthbar"] = {
            percent = { enable = true, xOff = 0, yOff = 0 },
            status = { enable = true, xOff = 0, yOff = 0 },
        },
        ["manabar"] = {
            percent = { enable = true, xOff = 0, yOff = 0 },
            status = { enable = true, xOff = 0, yOff = 0 },
        }
    }
end

function ns:GetDefaultProfile()
    return {
        version     = version,
        remainder   = 1,
        ["player"]  = AbbreviatedStatusOption_SetDefaultSetting(),
        ["pet"]     = AbbreviatedStatusOption_SetDefaultSetting(),
        ["target"]  = AbbreviatedStatusOption_SetDefaultSetting(),
        ["focus"]   = AbbreviatedStatusOption_SetDefaultSetting(),
        ["party"]   = AbbreviatedStatusOption_SetDefaultSetting(),
        ["arena"]   = AbbreviatedStatusOption_SetDefaultSetting(),
    };
end