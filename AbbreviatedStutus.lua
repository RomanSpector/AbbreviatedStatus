local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsConnected = UnitIsConnected;
local GetCVarBool = GetCVarBool;
local PLAYER_OFFLINE =  PLAYER_OFFLINE;
local DEAD = DEAD;

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

local CONFIG = {
    remainder = 1,
};
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
    local number = (value / data.significandDivisor) % data.fractionDivisor;
    if ( number > 0.1 ) then
        return string.format("%."..remainder.."f", (value / data.significandDivisor) / data.fractionDivisor);
    else
        return string.format("%.f", (value / data.significandDivisor) / data.fractionDivisor);
    end
end

local function AbbreviateNumbers(value, remainder )
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

local function Abbreviated_UpdateTextString(self)
    local _, valueMax = self:GetMinMaxValues();
    local value = self:GetValue();
    local unit = self.unit;
    local statustext = self.TextString;
    local stringText = AbbreviateNumbers(value, CONFIG.remainder);
    local cvarPerc = GetCVarBool("statusTextPercentage");
    local statustextPercentage = self.TextPercent and self.TextPercent.text;

    if ( cvarPerc and value > 0 ) then
        local percentText = string.format("%.f%%", value/valueMax*100);

        if ( not statustextPercentage ) then
            self.TextPercent = CreateFrame("Frame", "$parentTextPercent", self, "TextStatusBarTextPercentTemplate")
            self.TextPercent:SetFrameLevel(self:GetFrameLevel() + 1)
            self.TextPercent:SetAllPoints();
            statustextPercentage = self.TextPercent.text;
        end

        if ( unit and UnitIsDeadOrGhost(unit) or ( unit and not UnitIsConnected(unit) ) ) then
            statustextPercentage:Hide();
        else
            statustextPercentage:Show();
            statustextPercentage:ClearAllPoints();
            statustextPercentage:SetText(percentText);

            if ( statustext and not statustext:IsShown() ) then
                statustextPercentage:SetPoint("CENTER");
            else
                statustextPercentage:SetPoint("LEFT", 10, 0);
            end
        end

    elseif ( statustextPercentage ) then
        statustextPercentage:Hide();
    end

    if ( ( not statustext ) or ( not statustext:IsShown() ) ) then
        return;
    end

    statustext:SetAlpha(1);
    statustext:ClearAllPoints();
    statustext:SetPoint("CENTER", self, "CENTER");

    if ( unit and not UnitIsConnected(unit) ) then
        statustext:SetText(PLAYER_OFFLINE);
    elseif ( unit and UnitIsDeadOrGhost(unit) ) then
            local health = (statustext:GetName() or ""):match("Health");
            if ( health ) then
                statustext:SetText(DEAD);
            else
                statustext:SetAlpha(0);
            end
    elseif ( value > 0 ) then
        if ( cvarPerc ) then
            statustext:ClearAllPoints();
            statustext:SetPoint("RIGHT", self, "RIGHT", -5, 0);
        end
        statustext:SetText(stringText);
    else
        statustext:SetAlpha(0);
    end

end

hooksecurefunc("TextStatusBar_UpdateTextString", Abbreviated_UpdateTextString);