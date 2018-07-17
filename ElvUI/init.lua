--[[
~AddOn Engine~

To load the AddOn engine add this to the top of your file:

	local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

To load the AddOn engine inside another addon add this to the top of your file:

	local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

--Cache global variables
local _G = _G
local pairs = pairs
local format = string.format
local GameMenuFrame = GameMenuFrame
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuButtonAddons = GameMenuButtonAddons

BINDING_HEADER_ELVUI = GetAddOnMetadata(..., "Title");

local AddOnName, Engine = ...;
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", 'AceTimer-3.0', 'AceHook-3.0');
AddOn.callbacks = AddOn.callbacks or
  LibStub("CallbackHandler-1.0"):New(AddOn)
AddOn.DF = {}; AddOn.DF["profile"] = {}; AddOn.DF["global"] = {}; AddOn.privateVars = {}; AddOn.privateVars["profile"] = {}; -- Defaults
AddOn.Options = {
	type = "group",
	name = AddOnName,
	args = {},
}

local Locale = LibStub("AceLocale-3.0"):GetLocale(AddOnName, false);
Engine[1] = AddOn;
Engine[2] = Locale;
Engine[3] = AddOn.privateVars["profile"];
Engine[4] = AddOn.DF["profile"];
Engine[5] = AddOn.DF["global"];

_G[AddOnName] = Engine;
local tcopy = table.copy
function AddOn:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {};
	end

	ElvCharacterData = nil; --Depreciated
	ElvPrivateData = nil; --Depreciated
	ElvData = nil; --Depreciated

	self.db = tcopy(self.DF.profile, true);
	self.global = tcopy(self.DF.global, true);
	if ElvDB then
		if ElvDB.global then
			self:CopyTable(self.global, ElvDB.global)
		end

		local profileKey
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[self.myname..' - '..self.myrealm]
		end

		if profileKey and ElvDB.profiles and ElvDB.profiles[profileKey] then
			self:CopyTable(self.db, ElvDB.profiles[profileKey])
		end
	end

	self.private = tcopy(self.privateVars.profile, true);
	if ElvPrivateDB then
		local profileKey
		if ElvPrivateDB.profileKeys then
			profileKey = ElvPrivateDB.profileKeys[self.myname..' - '..self.myrealm]
		end

		if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
			self:CopyTable(self.private, ElvPrivateDB.profiles[profileKey])
		end
	end

	if self.private.general.pixelPerfect then
		self.Border = self.mult;
		self.Spacing = 0;
		self.PixelMode = true;
	end

	self:UIScale();
	self:UpdateMedia();

	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	-- self:RegisterEvent('PLAYER_LOGIN', 'Initialize')
	self:Contruct_StaticPopups()
	self:InitializeInitialModules()

	if IsAddOnLoaded("Tukui") then
		self:StaticPopup_Show("TUKUI_ELVUI_INCOMPATIBLE")
	end

	local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
	GameMenuButton:SetText(format("|cfffe7b2c%s|r", AddOnName))
	GameMenuButton:SetScript("OnClick", function()
		AddOn:ToggleConfig()
		HideUIPanel(GameMenuFrame)
	end)
	GameMenuFrame[AddOnName] = GameMenuButton

	if not IsAddOnLoaded("ConsolePortUI_Menu") then -- #390
		GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:Point("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
		hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', self.PositionGameMenuButton)
	end

	self.loadedtime = GetTime()
end

function AddOn:PositionGameMenuButton()
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)
	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= GameMenuFrame[AddOnName] then
		GameMenuFrame[AddOnName]:ClearAllPoints()
		GameMenuFrame[AddOnName]:Point("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:Point("TOPLEFT", GameMenuFrame[AddOnName], "BOTTOMLEFT", 0, offY)
	end
end

local loginFrame=CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self)
	AddOn:Initialize(self)
end)

function AddOn:PLAYER_REGEN_ENABLED()
	self:ToggleConfig()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED');
end

function AddOn:PLAYER_REGEN_DISABLED()
	local err = false;

	if IsAddOnLoaded("ElvUI_Config") then
		local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

		if ACD.OpenFrames[AddOnName] then
			self:RegisterEvent('PLAYER_REGEN_ENABLED');
			ACD:Close(AddOnName);
			err = true;
		end
	end

	if self.CreatedMovers then
		for name, _ in pairs(self.CreatedMovers) do
			if _G[name] and _G[name]:IsShown() then
				err = true;
				_G[name]:Hide();
			end
		end
	end

	if err == true then
		self:Print(ERR_NOT_IN_COMBAT);
	end
end

function AddOn:ResetProfile()
	local profileKey
	if ElvPrivateDB.profileKeys then
		profileKey = ElvPrivateDB.profileKeys[self.myname..' - '..self.myrealm]
	end

	if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
		ElvPrivateDB.profiles[profileKey] = nil;
	end

	ElvCharacterDB = nil;
	ReloadUI()
end

function AddOn:OnProfileReset()
	self:StaticPopup_Show("RESET_PROFILE_PROMPT")
end

function AddOn:ToggleConfig(msg)
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return;
	end

	if not IsAddOnLoaded("ElvUI_Config") then
		local _, _, _, _, reason = GetAddOnInfo("ElvUI_Config")
		if reason ~= "MISSING" and reason ~= "DISABLED" then
			self.GUIFrame = false
			LoadAddOn("ElvUI_Config")
			--For some reason, GetAddOnInfo reason is "DEMAND_LOADED" even if the addon is disabled.
			--Workaround: Try to load addon and check if it is loaded right after.
			if not IsAddOnLoaded("ElvUI_Config") then
				self:Print("|cffff0000Error -- Addon 'ElvUI_Config' not found or is disabled.|r")
				return
			end
			if GetAddOnMetadata("ElvUI_Config", "Version") ~= "1.05" then
				self:StaticPopup_Show("CLIENT_UPDATE_REQUEST")
			end
		else
			self:Print("|cffff0000Error -- Addon 'ElvUI_Config' not found or is disabled.|r")
			return
		end
	end

	local ACD = LibStub("AceConfigDialog-3.0-ElvUI")

	local pages
	if (msg and msg ~= "") then
		pages = {string.split(",", msg)}
	end
	local mode = 'Close'
	if not ACD.OpenFrames[AddOnName] or (pages ~= nil) then
		mode = 'Open'
	end
	ACD[mode](ACD, AddOnName)

	if pages then
		ACD:SelectGroup("ElvUI", unpack(pages))
	end

	GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end

--HonorFrameLoadTaint workaround
--credit: https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint
if (UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 2 then
	UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		if UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
			return
		end
		for i=1, UIDROPDOWNMENU_MAXLEVELS do
			for j=1, UIDROPDOWNMENU_MAXBUTTONS do
				local b = _G["DropDownList" .. i .. "Button" .. j]
				if not (issecurevariable(b, "value") or b:IsShown()) then
					b.value = nil
					repeat
						j, b["fx" .. j] = j+1
					until issecurevariable(b, "value")
				end
			end
		end
	end)
end

--DisplayModeCommunitiesTaint workaround
--credit https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeCommunitiesTaint
if (UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
	UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		if UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
			return
		end
		if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU ~= frame
		   and not issecurevariable(UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
			UIDROPDOWNMENU_OPEN_MENU = nil
			local t, f, prefix, i = _G, issecurevariable, " \0", 1
			repeat
				i, t[prefix .. i] = i + 1
			until f("UIDROPDOWNMENU_OPEN_MENU")
		end
	end)
end