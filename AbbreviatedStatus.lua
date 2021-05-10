--######################################################################
--######                   AbbreviatedStatus                     #######
------------------------------------------------------------------------
--######################################################################
------------------------------------------------------------------------
--######       My Discord: https://discord.gg/Fm9kgfk            #######
------------------------------------------------------------------------
--######################################################################
local _, ns = ...;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsConnected = UnitIsConnected;
local GetCVarBool = GetCVarBool;
local PLAYER_OFFLINE =  PLAYER_OFFLINE;
local DEAD = DEAD;
local CONFIG = ns:GetConfig();

if ( GetLocale() == "ruRU" ) then
    FOURTH_NUMBER_CAP_NO_SPACE = "T";
    THIRD_NUMBER_CAP_NO_SPACE = "МЛРД";
    SECOND_NUMBER_CAP_NO_SPACE = "М";
    FIRST_NUMBER_CAP_NO_SPACE = "к";
else
    FOURTH_NUMBER_CAP_NO_SPACE = "T";
    THIRD_NUMBER_CAP_NO_SPACE = "B";
    SECOND_NUMBER_CAP_NO_SPACE = "M";
    FIRST_NUMBER_CAP_NO_SPACE = "K";
end


---------------------------------------------------------
local NUMBER_ABBREVIATION_DATA = {
    -- Order these from largest to smallest
    -- (significandDivisor and fractionDivisor should multiply to be equal to breakpoint)
    { breakpoint = 10000000000000,   abbreviation = FOURTH_NUMBER_CAP_NO_SPACE,       significandDivisor = 1000000000000,  fractionDivisor = 1  },
    { breakpoint = 1000000000000,    abbreviation = FOURTH_NUMBER_CAP_NO_SPACE,       significandDivisor = 100000000000,   fractionDivisor = 10 },
    { breakpoint = 10000000000,      abbreviation = THIRD_NUMBER_CAP_NO_SPACE,        significandDivisor = 1000000000,     fractionDivisor = 1  },
    { breakpoint = 1000000000,       abbreviation = THIRD_NUMBER_CAP_NO_SPACE,        significandDivisor = 100000000,      fractionDivisor = 10 },
    { breakpoint = 10000000,         abbreviation = SECOND_NUMBER_CAP_NO_SPACE,       significandDivisor = 1000000,        fractionDivisor = 1  },
    { breakpoint = 1000000,          abbreviation = SECOND_NUMBER_CAP_NO_SPACE,       significandDivisor = 100000,         fractionDivisor = 10 },
    { breakpoint = 10000,            abbreviation = FIRST_NUMBER_CAP_NO_SPACE,        significandDivisor = 1000,           fractionDivisor = 1  },
    { breakpoint = 1000,             abbreviation = FIRST_NUMBER_CAP_NO_SPACE,        significandDivisor = 100,            fractionDivisor = 10 },
};

local function FinalValueWithRemainder(remainder, value, data)
    return string.format("%."..remainder.."f", (value / data.significandDivisor) / data.fractionDivisor);
end

function AbbreviateNumbers(value, remainder )
    for i, data in ipairs(NUMBER_ABBREVIATION_DATA) do
        if ( value >= data.breakpoint ) then
            local finalValue;
            if ( remainder ) then
                finalValue = FinalValueWithRemainder(remainder, value, data);
            else
                finalValue = math.floor(value / data.significandDivisor) / data.fractionDivisor;
            end
            return finalValue .. data.abbreviation;
        end
    end
    return tostring(value);
end

local function GetFrameType(frame)
    local typeFrame = (frame:GetName()):match("(%u%l+Frame)");
    return typeFrame;
end

local function GetStatusBarType(bar)
    if not ( bar and bar.GetName ) then
        return;
    end

    return (bar:GetName()):match("HealthBar") or "ManaBar";
end

local function GetTextType(frame)
    return (frame:GetName()):match("Percent") or "Status";
end

local function SetPosition(frame, point, relativeTo, relativePoint, ofsx, ofsy)
    local barType = GetStatusBarType(frame);
    local frameType = GetFrameType(frame);
    local textType = GetTextType(frame);
    local setting = CONFIG.position

    if ( frameType ) then
        local xOff = setting[frameType][textType][barType].ofsx;
        local yOff = setting[frameType][textType][barType].ofsy;

        frame:SetPoint(point, relativeTo, relativePoint, ofsx or xOff, ofsy or yOff);
    end
end

local function Abbreviated_UpdateTextString(self)
    local _, valueMax = self:GetMinMaxValues();
    local value = self:GetValue();
    local unit = self.unit;
    local statustext = self.TextString;
    local stringText = AbbreviateNumbers(value, CONFIG.remainder);
    local cvarPerc = GetCVarBool("statusTextPercentage");
    local statustextPercentage = self.TextPercent and self.TextPercent.text;
    local cvarStatusText = GetCVarBool(self.cvar or "");

    if ( cvarPerc and value > 0 ) then
        local barType = GetStatusBarType(self);
        local percentText = string.format("%.f%%", value/valueMax*100);

        if ( not statustextPercentage ) then
            self.TextPercent = CreateFrame("Frame", "$parentTextPercent", self, "TextStatusBarTextPercentTemplate");
            self.TextPercent:SetFrameLevel(self:GetFrameLevel() + 1);
            self.TextPercent:SetAllPoints();
            statustextPercentage = self.TextPercent.text;
        end

        statustextPercentage:Show();
        statustextPercentage:ClearAllPoints();
        statustextPercentage:SetText(percentText);

        if ( statustext and not statustext:IsShown() ) then
            SetPosition(statustextPercentage, "CENTER", self, "CENTER");
        else
            SetPosition(statustextPercentage, "LEFT", self, "LEFT");
        end

        if ( CONFIG["show"..barType] or not cvarStatusText ) then
            if ( unit and ( UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) ) ) then
                statustextPercentage:Hide();
            else
                statustextPercentage:Show();
            end
        else
            statustextPercentage:Hide();
        end
    elseif ( statustextPercentage ) then
        statustextPercentage:Hide();
    end

    if ( ( not statustext ) or ( not statustext:IsShown() ) ) then
        return;
    end

    local health = (statustext:GetName() or ""):match("Health");
    statustext:SetAlpha(1);
    statustext:ClearAllPoints();
    SetPosition(statustext, "CENTER", self, "CENTER");

    if ( unit and not UnitIsConnected(unit) ) then
        statustext:SetText(PLAYER_OFFLINE);
    elseif ( unit and UnitIsDeadOrGhost(unit) ) then
            if ( health ) then
                statustext:SetText(DEAD);
            else
                statustext:SetAlpha(0);
            end
    elseif ( value > 0 ) then
        if ( cvarPerc ) then
            statustext:ClearAllPoints();
            SetPosition(statustext, "RIGHT", self, "RIGHT");
        end
        statustext:SetText(stringText);
    else
        statustext:SetAlpha(0);
    end

end

hooksecurefunc("TextStatusBar_UpdateTextString", Abbreviated_UpdateTextString);

