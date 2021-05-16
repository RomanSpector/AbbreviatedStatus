--######################################################################
--######                   AbbreviatedStatus                     #######
------------------------------------------------------------------------
--######################################################################
------------------------------------------------------------------------
--######       My Discord: https://discord.gg/Fm9kgfk            #######
------------------------------------------------------------------------
--######################################################################
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsConnected = UnitIsConnected;
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

do

    local NUMBER_ABBREVIATION = { 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };
    local GetAbbreviationNumber = function(value)
        return NUMBER_ABBREVIATION[value];
    end

    function AbbreviatedStatusNumbers(value)
        local remainder = AbbreviatedStatusOption_GetGeneralValue("remainder");
        local prefix = AbbreviatedStatusOption_GetGeneralValue("prefix");
        for i, data in ipairs(NUMBER_ABBREVIATION_DATA) do
            if ( value >= data.breakpoint ) then
                local finalValue;
                local currentValue = GetAbbreviationNumber(prefix)
                finalValue = string.format("%."..remainder.."f", (value / data.significandDivisor) / data.fractionDivisor);
                return ( prefix > 1 and currentValue <= data.breakpoint ) and finalValue .. data.abbreviation or finalValue;
            end
        end
        return tostring(value)
    end

end

function AbbreviateNumbers(value)
    for i, data in ipairs(NUMBER_ABBREVIATION_DATA) do
        if ( value >= data.breakpoint ) then
            local finalValue;
            finalValue = math.floor(value / data.significandDivisor) / data.fractionDivisor;
            return finalValue .. data.abbreviation;
        end
    end
    return tostring(value);
end

local function Abbreviated_UpdateTextString(self)
    if not ( self.unit and AbbreviatedStatusGetUnitOption(string.gsub(self.unit, "[%d]", ""))) then
        return;
    end

    local _, valueMax = self:GetMinMaxValues();
    local unit = self.unit;
    local unitType = string.gsub(unit, "[%d]", "");
    local value = self:GetValue();
    local statusText = self.TextString;
    local stringText = AbbreviatedStatusNumbers(value);
    local percText = string.format("%.f%%", value/valueMax*100);
    local precentText = self.TextPercent and self.TextPercent.text;

    local barType = AbbreviatedStatusOption_GetStatusBarType(self);
    local cvarStatus, cvarPecernt = AbbreviatedStatus_GetCVarBool(unitType, barType);

    if ( not statusText ) then
        return;
    end

    if ( not precentText ) then
        self.TextPercent = CreateFrame("Frame", "$parentPecent", self, "TextPercentBarTemplate");
        self.TextPercent:SetFrameLevel(self:GetFrameLevel() + 1);
        self.TextPercent:SetAllPoints();
        precentText = self.TextPercent.text;
    end

    if ( cvarPecernt and value > 0 ) then
        precentText:SetText(percText);
        if ( not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) ) then
            precentText:Hide();
            self.updatePoint = true;
        else
            precentText:Show();
            self.updatePoint = true;
        end
    else
        precentText:Hide();
        self.updatePoint = true;
    end

    if ( cvarStatus ) then
        AbbreviatedStatusOption_SetText(statusText, unit, stringText);
        if ( barType == "manabar" and ( not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) ) ) then
            statusText:Hide();
        elseif ( value == 0 and barType == "manabar" ) then
            statusText:Hide();
            self.updatePoint = true;
        else
            statusText:Show();
            self.updatePoint = true;
        end
    else
        statusText:Hide();
        self.updatePoint = true;
    end


    if ( self.updatePoint ) then
        if ( cvarPecernt and cvarStatus ) then
            AbbreviatedStatusOption_SetPosition(precentText, "LEFT", self, barType, "percent", unitType);
            AbbreviatedStatusOption_SetPosition(statusText, "RIGHT", self, barType, "status", unitType);
            if ( precentText and not precentText:IsShown() ) then
                AbbreviatedStatusOption_SetPosition(statusText, "CENTER", self, barType, "status", unitType);
            end
        else
            AbbreviatedStatusOption_SetPosition(precentText, "CENTER", self, barType, "percent", unitType);
            AbbreviatedStatusOption_SetPosition(statusText, "CENTER", self, barType, "status", unitType);
        end
        self.updatePoint = false;
    end

end

hooksecurefunc("TextStatusBar_UpdateTextString", Abbreviated_UpdateTextString);