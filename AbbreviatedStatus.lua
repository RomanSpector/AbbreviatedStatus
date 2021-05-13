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
local MANA = MANA;
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

local function Abbreviated_UpdateTextString(self)
    if not ( self.unit and AbbreviatedStatusGetUnitOption(string.gsub(self.unit, "[%d]", ""))) then
        return;
    end

    local _, valueMax = self:GetMinMaxValues();
    local unit = self.unit;
    local unitType = string.gsub(unit, "[%d]", "");
    local value = self:GetValue();
    local remainder = AbbreviatedStatusOption_GetRemainder();
    local statusText = self.TextString;
    local stringText = AbbreviateNumbers(value, remainder);
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

    if ( cvarStatus) then
        AbbreviatedStatusOption_SetText(statusText, unit, stringText);
        if ( barType == MANA and ( not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) ) ) then
            statusText:Hide();
        elseif ( value == 0 and barType == MANA ) then
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