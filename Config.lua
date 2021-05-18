local addon, ns = ...;
local version = GetAddOnMetadata(addon, "Version");

function AbbreviatedStatusOption_SetTextProperties()
    return { enable = true, xOff = 0, yOff = 0 };
end

function AbbreviatedStatusOption_SetBarProperties()
    return {
        percent = AbbreviatedStatusOption_SetTextProperties(),
        status = AbbreviatedStatusOption_SetTextProperties()
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
        prefix      = 3,
        remainder   = 1,
        ["player"]  = AbbreviatedStatusOption_SetDefaultSetting(),
        ["pet"]     = AbbreviatedStatusOption_SetDefaultSetting(),
        ["target"]  = AbbreviatedStatusOption_SetDefaultSetting(),
        ["focus"]   = AbbreviatedStatusOption_SetDefaultSetting(),
        ["party"]   = AbbreviatedStatusOption_SetDefaultSetting(),
        ["arena"]   = AbbreviatedStatusOption_SetDefaultSetting()
    };
end

StaticPopupDialogs["DEFAULT_ABBREVIATED_STATUS"] = {
    text    = DEFAULT_ABBREVIATED_STATUS,
    button1 = CURRENT_SETTINGS,
    button3 = DEFAULT_ABBREVIATED_ALL_PROFILE,
	button2 = CANCEL,
	OnAccept = function()
		AbbreviatedStatusOption_SetCurrentToDefaults();
	end,
	OnAlt   = function()
	    AbbreviatedStatusOption_SetAllToDefaults();
	end,
    OnCancel = function() end,
    timeout = 0,
	hideOnEscape = 1,
};