---@diagnostic disable: ambiguity-1
local AbbreviatedStatus = LibStub("AceAddon-3.0"):NewAddon("AbbreviatedStatus", "AceConsole-3.0");
local AceDB = LibStub("AceDB-3.0");
local _, ns = ...;
local PROFILES;
local DEFAULT_PROFILE = ns:GetDefaultPofile();

-- Required key/value pairs:
-- .optionName - String, name of option
-- .options - Array, array of possible options
-- Required strings:
-- ABBREVIATED_STATUS_OPTION_≤OPTION_NAME>
function ns:GetProfileSetting()
    return PROFILES and PROFILES[1] or DEFAULT_PROFILE;
end

function AbbreviatedStatus:OnInitialize()
	self.db = AceDB:New("AbbreviatedStatusDB");
	PROFILES = self.db.global;

    if ( not ROMANSPECTOR_DISCORD ) then
        ROMANSPECTOR_DISCORD = true;
        DEFAULT_CHAT_FRAME:AddMessage("|cffbaf5aeAbbreviatedStatus|r: even more useful addons in my Discord group |cff44d3e3https://discord.gg/wXw6pTvxMQ|r");
    end
    InterfaceOptionsFrame:HookScript("OnShow", function()
        InterfaceOptionsFrame:SetSize(858, 660);
        InterfaceOptionsFrame:SetMinResize(858, 660);
    end)
    AbbreviatedStatusOption_OnEvent(AbbreviatedStatusOption, "ABBREVIATED_STATUS_OPTION_PROFILES_LOADED");
end

function AbbreviatedStatusOption_GenerationFrame(string)
    return { manabar = string.."ManaBar", healthbar = string.."HealthBar" };
end

function AbbreviatedStatusOption_OnLoad(self)
    self.name = "AbbreviatedStatus";
    self:RegisterEvent("PLAYER_LOGIN");

    local unitFrames = {
        player = AbbreviatedStatusOption_GenerationFrame("PlayerFrame"),
        pet = AbbreviatedStatusOption_GenerationFrame("PetFrame"),
        target = AbbreviatedStatusOption_GenerationFrame("TargetFrame"),
        focus = AbbreviatedStatusOption_GenerationFrame("FocusFrame"),
    };
    unitFrames.party = { };
    unitFrames.partypet = { };
    unitFrames.arena = { };
    for i=1,4 do
        tinsert(unitFrames.party, AbbreviatedStatusOption_GenerationFrame("PartyMemberFrame"..i));
    end
    for i=1,5 do
        tinsert(unitFrames.arena, AbbreviatedStatusOption_GenerationFrame("ArenaEnemyFrame"..i));
    end

    self.GeneralFrames = unitFrames;
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
    self.GeneralFrame = AbbreviatedStatusOption.GeneralFrames[self.unit];

    AbbreviatedStatusOptions_SetUnit(self);
    InterfaceOptions_AddCategory(self);
end

function AbbreviatedStatusOption_OnEvent(self, event, ...)
    if ( event == "ABBREVIATED_STATUS_OPTION_PROFILES_LOADED") then
        AbbreviatedStatusOption_ValidateProfilesLoaded();
    end
end

function AbbreviatedStatusOption_ValidateProfilesLoaded()
    if ( #PROFILES == 0 ) then
        local profile = CopyTable(DEFAULT_PROFILE);
        table.insert(PROFILES, profile);
        AbbreviatedStatusOption_UpdateCurrentPanel();
    elseif ( PROFILES[1].locale ~= GetLocale() ) then
        AbbreviatedStatusOption_ResetToDefaults();
    else
        AbbreviatedStatusOption_UpdateCurrentPanel();
    end
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
    AbbreviatedStatusOption_ApplySetting(AbbreviatedStatusOption_GetParent(self));
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
    if ( self.name == "remainder") then
        self.value:SetText(format("%.f", value));
        AbbreviatedStatusOptionSet_Remainer(value);
        return;
    end
    self.value:SetText(format("%.1f", value));
    local optionFrame = AbbreviatedStatusOption_GetOptionFrame(self);
    AbbreviatedStatusSetProfileOption(optionFrame.unit, self.prefix, optionFrame.type, self.optionName, value);
    AbbreviatedStatusOption_ApplySetting(AbbreviatedStatusOption_GetParent(self).GeneralFrame);
end

-------------------------------------------------------------
-----------------Applying of Options----------------------
-------------------------------------------------------------
local MANA = MANA;
local HEALTH = HEALTH;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsConnected = UnitIsConnected;

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
    AbbreviatedStatusOption_ApplySetting(AbbreviatedStatusOption.GeneralFrames);
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
    return PROFILES[1][unit]
end

function AbbreviatedStatusOption_GetRemainder()
    if ( not PROFILES ) then
        return 1;
    end

    return PROFILES[1].remainder or 1;
end

function AbbreviatedStatusOption_UpdateCurrentPanel()
	local panel = AbbreviatedStatusOption;
	for i=1, #panel.optionControls do
		panel.optionControls[i]:updateFunc();
	end
end

local function GroupFramesApplySetting(frames)
    for _, statusBar in pairs(frames) do
        if ( _G[statusBar] ) then
            TextStatusBar_UpdateTextString(_G[statusBar]);
        end
    end
end

function AbbreviatedStatusOption_ApplySetting(GeneralFrame)
    if ( not GeneralFrame ) then
        return;
    end

    for _, statusBar in pairs(GeneralFrame) do
        if ( type(statusBar)=="table" ) then
            GroupFramesApplySetting(statusBar);
        elseif ( _G[statusBar] ) then
            TextStatusBar_UpdateTextString(_G[statusBar]);
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

    return ((bar:GetName()):match("HealthBar")) and HEALTH or MANA;
end

function AbbreviatedStatusOption_SetShown(textFrame, enable)
    if ( enable ) then
        textFrame:Show();
    else
        textFrame:Hide();
    end
end

function AbbreviatedStatusOption_SetPosition(text, point, relativeTo, barType, status, unit)
    local xOff, yOff =  0, 0;
    if ( point ~= "CENTER" ) then
        xOff, yOff = AbbreviatedStatusOption_GetPoint(unit, barType, status);
    end
    text:ClearAllPoints();
    text:SetPoint(point, relativeTo, point, xOff, yOff);
end

function AbbreviatedStatusOption_SetText(frame, unit, text)
    if ( not UnitIsConnected(unit) ) then
        text = PLAYER_OFFLINE;
    elseif ( UnitIsDeadOrGhost(unit) ) then
        text = DEAD;
    end
    frame:SetText(text);
end