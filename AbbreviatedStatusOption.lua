---@diagnostic disable: ambiguity-1
local AbbreviatedStatus = LibStub("AceAddon-3.0"):NewAddon("AbbreviatedStatus", "AceConsole-3.0");
local AceDB = LibStub("AceDB-3.0");
local addon, ns = ...;
local version = GetAddOnMetadata(addon, "Version");
local PROFILES;
local DEFAULT_PROFILE = ns:GetDefaultProfile();

-- Required key/value pairs:
-- .optionName - String, name of option
-- .options - Array, array of possible options
-- Required strings:
-- ABBREVIATED_STATUS_OPTION_≤OPTION_NAME>

function AbbreviatedStatus:OnInitialize()
	self.db = AceDB:New("AbbreviatedStatusDB");
	PROFILES = self.db.global;

    if ( not ROMANSPECTOR_DISCORD ) then
        ROMANSPECTOR_DISCORD = true;
        DEFAULT_CHAT_FRAME:AddMessage("|cffbaf5aeAbbreviatedStatus|r: even more useful addons in my Discord group |cff44d3e3https://discord.gg/wXw6pTvxMQ|r");
    end

    AbbreviatedStatusOption_ValidateProfilesLoaded()
end

function AbbreviatedStatusOption_GenerationFrame(string, releaseFunc)
    return { manabar = string.."ManaBar", healthbar = string.."HealthBar", releaseFunc = releaseFunc };
end

function AbbreviatedStatusOption_OnLoad(self)
    self.name = "AbbreviatedStatus";
    self.version:SetText((ABBREVIATED_STATUS_OPTION_VERSION):format(version));

    local unitFrameReleaseFunc = function(self)
        local manabar = _G[self.manabar];
        local healthbar = _G[self.healthbar];
        if ( manabar ) then
            TextStatusBar_UpdateTextString(manabar);
        end
        if ( healthbar ) then
            TextStatusBar_UpdateTextString(healthbar);
        end
    end

    local unitFrames = {
        player = AbbreviatedStatusOption_GenerationFrame("PlayerFrame", unitFrameReleaseFunc),
        pet = AbbreviatedStatusOption_GenerationFrame("PetFrame", unitFrameReleaseFunc),
        target = AbbreviatedStatusOption_GenerationFrame("TargetFrame", unitFrameReleaseFunc),
        focus = AbbreviatedStatusOption_GenerationFrame("FocusFrame", unitFrameReleaseFunc),
    };
    unitFrames.party = { };
    unitFrames.arena = { };
    for i=1,4 do
        tinsert(unitFrames.party, AbbreviatedStatusOption_GenerationFrame("PartyMemberFrame"..i, unitFrameReleaseFunc));
    end
    for i=1,5 do
        tinsert(unitFrames.arena, AbbreviatedStatusOption_GenerationFrame("ArenaEnemyFrame"..i, unitFrameReleaseFunc));
    end

    self.GeneralFrame = unitFrames;
    InterfaceOptions_AddCategory(self);
end

function AbbreviatedStatusOption_DefaultCallback(self)
	AbbreviatedStatusOption_ResetToDefaults();
end

function AbbreviatedStatusOption_ResetToDefaults()
    table.remove(PROFILES, 1);
	table.insert(PROFILES, DEFAULT_PROFILE);
    AbbreviatedStatusOption_UpdateCurrentPanel();
end

function AbbreviatedStatusOptions_SetCVar(self, unit)
    self.cvar = "STATUS_TEXT_"..strupper(unit)
    self.unit = unit;
end

function AbbreviatedStatusOptions_SetUnit(self)
    local statusFrame, percentFrame = self:GetChildren();

    if ( self.unit == "partypet" ) then
        statusFrame.manaOptions:Hide();
        percentFrame.manaOptions:Hide();
    end

    AbbreviatedStatusOptions_SetCVar(statusFrame, self.unit);
    AbbreviatedStatusOptions_SetCVar(percentFrame, self.unit);
end

function AbbreviatedStatusOption_GetParent(self)
    return self:GetParent():GetParent():GetParent();
end

function AbbreviatedStatusSubOption_OnLoad(self)
    local text = _G[self:GetName().."Title"];
    local tag = format("ABBREVIATED_STATUS_OPTION_%s", strupper(self.unit));

    if ( text ) then
        text:SetText(_G[tag] or ("Need string: "..tag));
    end

    self.parent = AbbreviatedStatusOption.name;
    self.name = _G[tag] or ("Need string: "..tag);
    self.GeneralFrame = AbbreviatedStatusOption.GeneralFrame[self.unit];

    AbbreviatedStatusOptions_SetUnit(self);
    InterfaceOptions_AddCategory(self);
end

function AbbreviatedStatusOption_ValidateProfilesLoaded()
    if ( #PROFILES == 0 ) then
        local profile = CopyTable(DEFAULT_PROFILE);
        table.insert(PROFILES, profile);
    end
    AbbreviatedStatusOption_UpdateCurrentPanel();
end
--------------------------------------------------------------
-----------------UI Option Templates---------------------
--------------------------------------------------------------
function AbbreviatedStatusProfileOption_OnLoad(self)
    local parent = AbbreviatedStatusOption;
	if ( not parent.optionControls ) then
		parent.optionControls = {};
	end

	tinsert(parent.optionControls, self);
end
-------------------------------
-------Check Button---------
-------------------------------
function AbbreviatedStatusOptionCheckButton_InitializeWidget(self, optionName, array)
	self.optionName = array;
	local tag = format("ABBREVIATED_STATUS_OPTION_%s", strupper(optionName));
	self.label:SetText(_G[tag] or "Need string: "..tag);
	self.updateFunc = AbbreviatedStatusOptionCheckButton_Update;

    self:RegisterEvent("CVAR_UPDATE");
    AbbreviatedStatusProfileOption_OnLoad(self);
end

function AbbreviatedStatusOptionCheckButton_OnEven(self, event, name, value)
    local optionFrame = AbbreviatedStatusOption_GetOptionFrame(self);
    if ( event == "CVAR_UPDATE" and name == optionFrame.cvar ) then
        AbbreviatedStatusOptionCheckButton_OnClick(self, "LeftButton", value);
    end
end

function AbbreviatedStatusOptionCheckButton_Update(self)
    local optionFrame = AbbreviatedStatusOption_GetOptionFrame(self);
	local currentValue = AbbreviatedStatusGetProfileOption(optionFrame.unit, self.prefix, optionFrame.type, self.optionName);
	self:SetChecked(currentValue);
    AbbreviatedStatusOptionChekButton_SetStatus(self);
    AbbreviatedStatusOption_ApplySetting(AbbreviatedStatusOption_GetParent(self).GeneralFrame);
end

function AbbreviatedStatusOptionChekButton_SetStatus(self)
    if ( self:GetChecked() ) then
        AbbreviatedStatusOptionChekButton_SetEnable(self);
    else
        AbbreviatedStatusOptionChekButton_SetDisable(self);
    end
end

function AbbreviatedStatusOptionChekButton_SetEnable(self)
    self:GetParent().xOffSet:Enable();
    self:GetParent().yOffSet:Enable();
    self.label:SetFontObject(GameFontHighlightLeft);
end

function AbbreviatedStatusOptionChekButton_SetDisable(self)
    self:GetParent().xOffSet:Disable();
    self:GetParent().yOffSet:Disable();
    self.label:SetFontObject(GameFontNormalLeftRed);
end

function AbbreviatedStatusOption_GetOptionFrame(self)
    return self:GetParent():GetParent();
end

function AbbreviatedStatusOptionCheckButton_OnClick(self, button, currentValue)
    if ( currentValue ) then
        self:SetChecked(currentValue);
    end
    local optionFrame = AbbreviatedStatusOption_GetOptionFrame(self);
    AbbreviatedStatusOptionChekButton_SetStatus(self);
	AbbreviatedStatusSetProfileOption(optionFrame.unit, self.prefix, optionFrame.type, self.optionName, self:GetChecked() or false);
    AbbreviatedStatusOption_ApplySetting(AbbreviatedStatusOption_GetParent(self).GeneralFrame);
end
-------------------------------
------- Slider ----------------
-------------------------------
function AbbreviatedStatusOptionSlider_InitializeWidget(self, optionName, minText, maxText, updateFunc)
	self.optionName = optionName;
	local tag = format("ABBREVIATED_STATUS_OPTION_%s", strupper(optionName));
	self.lable:SetText(_G[tag] or "Need string: "..tag);
    if ( minText ) then
		self.lowLable:SetText(minText);
	end
	if ( maxText ) then
		self.maxLable:SetText(maxText);
	end

	self.updateFunc = updateFunc or AbbreviatedStatusOptionSlider_Update;
    AbbreviatedStatusProfileOption_OnLoad(self);
end

function AbbreviatedStatusOptionSlider_Update(self)
    local optionFrame = AbbreviatedStatusOption_GetOptionFrame(self);
	local currentValue = AbbreviatedStatusGetProfileOption(optionFrame.unit, self.prefix, optionFrame.type, self.optionName);
    self.value:SetText(format("%.1f", currentValue));
    self:SetValue(currentValue);
    AbbreviatedStatusOption_ApplySetting(AbbreviatedStatusOption_GetParent(self).GeneralFrame);
end

function AbbreviatedStatusOptionSlider_OnValueChanged(self, value)
    if ( self.optionName == "remainder" ) then
        self.value:SetText(format("%.f", value));
        AbbreviatedStatusOptionSet_Remainer(value);
    else
        local optionFrame = AbbreviatedStatusOption_GetOptionFrame(self);
        self.value:SetText(format("%.1f", value));
        AbbreviatedStatusSetProfileOption(optionFrame.unit, self.prefix, optionFrame.type, self.optionName, value);
        AbbreviatedStatusOption_ApplySetting(AbbreviatedStatusOption_GetParent(self).GeneralFrame);
    end
end

-------------------------------------------------------------
-----------------Applying of Options----------------------
-------------------------------------------------------------
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsConnected = UnitIsConnected;
local PLAYER_OFFLINE = PLAYER_OFFLINE;
local DEAD = DEAD;

function AbbreviatedStatusSetProfileOption(unit, prefix, type, optionName, value)
    if not ( PROFILES and unit) then
        return;
    end

    local option = PROFILES[1][unit];
    for barType, subOption in pairs(option) do
        if ( barType == prefix ) then
            subOption[type][optionName] = value;
        end
    end

end

function AbbreviatedStatusOptionSet_Remainer(value)
    if ( not PROFILES ) then
        return;
    end
    PROFILES[1].remainder = value;
    AbbreviatedStatusOption_UpdateUnits(AbbreviatedStatusOption);
end

function AbbreviatedStatusGetProfileOption(unit, prefix, type, optionName)
    if ( not PROFILES ) then
        return 0;
    end
    local option = PROFILES[1][unit];
    for barType, subOption in pairs(option) do
        if ( barType == prefix ) then
            return subOption[type][optionName];
        end
    end

end

function AbbreviatedStatusGetUnitOption(unit)
    if ( not PROFILES ) then
        return;
    end
    return PROFILES[1][unit];
end

function AbbreviatedStatusOption_GetRemainder()
    if ( not PROFILES ) then
        return 1;
    end

    return PROFILES[1].remainder;
end

function AbbreviatedStatusOption_UpdateCurrentPanel()
	local panel = AbbreviatedStatusOption;
	for i=1, #panel.optionControls do
		panel.optionControls[i]:updateFunc();
	end
end

function AbbreviatedStatusOption_UpdateUnits(self)
    for unit, frame in pairs(self.GeneralFrame) do
        AbbreviatedStatusOption_ApplySetting(frame);
    end
end

function AbbreviatedStatusOption_ApplySetting(GeneralFrame)
    if ( not GeneralFrame ) then
        return;
    end

     for key in pairs(GeneralFrame) do
        if ( type(key) ~= "number" ) then
            GeneralFrame:releaseFunc();
        else
            GeneralFrame[key]:releaseFunc();
        end
    end
end

function AbbreviatedStatus_GetCVarBool(unit, barType)
    if ( not PROFILES) then
        return;
    end
    local options = PROFILES[1][unit];
    local cvarStatus, cvarPecernt;
    for key,value in pairs(options) do
        if ( key == barType ) then
            cvarStatus= value.status.enable;
            cvarPecernt = value.percent.enable;
            break;
        end
    end
    return cvarStatus, cvarPecernt;
end

function AbbreviatedStatusOption_GetPoint(unit, barType, status)
    if ( not PROFILES) then
        return;
    end

    local options = PROFILES[1][unit];
    local xOff, yOff;
    for key, value in pairs(options) do
        if ( key == barType ) then
            xOff = value[status].xOff;
            yOff = value[status].yOff;
            break;
        end
    end
    return xOff or 0, yOff or 0;
end

function AbbreviatedStatusOption_GetStatusBarType(bar)
    if not ( bar and bar.GetName ) then
        return;
    end
    local barType = ((bar:GetName()):match("HealthBar")) or "manabar";
    return strlower(barType);
end

function AbbreviatedStatusOption_SetShown(textFrame, enable)
    if ( enable ) then
        textFrame:Show();
    else
        textFrame:Hide();
    end
end

function AbbreviatedStatusOption_SetPosition(text, point, relativeTo, barType, status, unit)
    local xOff, yOff = AbbreviatedStatusOption_GetPoint(unit, barType, status);
    text:ClearAllPoints();
    text:SetPoint(point, relativeTo, point, point == "CENTER" and 0 or xOff, yOff);
end

function AbbreviatedStatusOption_SetText(frame, unit, text)
    if ( not UnitIsConnected(unit) ) then
        text = PLAYER_OFFLINE;
    elseif ( UnitIsDeadOrGhost(unit) ) then
        text = DEAD;
    end
    frame:SetText(text);
end