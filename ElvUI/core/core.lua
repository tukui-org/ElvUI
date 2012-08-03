local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local LSM = LibStub("LibSharedMedia-3.0")
local _, ns = ...
local ElvUF = ns.oUF

--Constants
_, E.myclass = UnitClass("player");
E.myname, _ = UnitName("player");
E.myguid = UnitGUID('player');
E.version = GetAddOnMetadata("ElvUI", "Version"); 
E.myrealm = GetRealmName();
_, E.wowbuild = GetBuildInfo(); E.wowbuild = tonumber(E.wowbuild);
E.resolution = GetCVar("gxResolution")
E.screenheight = tonumber(string.match(E.resolution, "%d+x(%d+)"))
E.screenwidth = tonumber(string.match(E.resolution, "(%d+)x+%d"))


--Tables
E["media"] = {};
E["frames"] = {};
E["texts"] = {};
E['snapBars'] = {}
E["RegisteredModules"] = {}
E['RegisteredInitialModules'] = {}
E['valueColorUpdateFuncs'] = {};
E.TexCoords = {.08, .92, .08, .92}
E.FrameLocks = {}

E.InversePoints = {
	TOP = 'BOTTOM',
	BOTTOM = 'TOP',
	TOPLEFT = 'BOTTOMLEFT',
	TOPRIGHT = 'BOTTOMRIGHT',
	LEFT = 'RIGHT',
	RIGHT = 'LEFT',
	BOTTOMLEFT = 'TOPLEFT',
	BOTTOMRIGHT = 'TOPRIGHT'
}

E.ClassRole = {
	PALADIN = {
		[1] = "Caster",
		[2] = "Tank",
		[3] = "Melee",
	},
	PRIEST = "Caster",
	WARLOCK = "Caster",
	WARRIOR = {
		[1] = "Melee",
		[2] = "Melee",
		[3] = "Tank",	
	},
	HUNTER = "Melee",
	SHAMAN = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Caster",	
	},
	ROGUE = "Melee",
	MAGE = "Caster",
	DEATHKNIGHT = {
		[1] = "Tank",
		[2] = "Melee",
		[3] = "Melee",	
	},
	DRUID = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Tank",	
		[4] = "Caster"
	},
	MONK = {
		[1] = "Tank",
		[2] = "Caster",
		[3] = "Melee",	
	},
}

E.noop = function() end;

function E:Print(msg)
	print(self["media"].hexvaluecolor..'ElvUI:|r', msg)
end

function E:UpdateMedia()	
	--Fonts
	self["media"].normFont = LSM:Fetch("font", self.db['general'].font)
	self["media"].combatFont = LSM:Fetch("font", self.db['general'].dmgfont)
	

	--Textures
	self["media"].blankTex = LSM:Fetch("background", "ElvUI Blank")
	self["media"].normTex = LSM:Fetch("statusbar", self.private['general'].normTex)
	self["media"].glossTex = LSM:Fetch("statusbar", self.private['general'].glossTex)

	--Border Color
	local border = E.db['general'].bordercolor
	if E.db.theme == 'class' then
		border = RAID_CLASS_COLORS[E.myclass]
	end
	self["media"].bordercolor = {border.r, border.g, border.b}

	--Backdrop Color
	local backdrop = self.db['general'].backdropcolor
	self["media"].backdropcolor = {backdrop.r, backdrop.g, backdrop.b}

	--Backdrop Fade Color
	backdrop = self.db['general'].backdropfadecolor
	self["media"].backdropfadecolor = {backdrop.r, backdrop.g, backdrop.b, backdrop.a}
	
	--Value Color
	local value = self.db['general'].valuecolor
	if E.db.theme == 'class' then
		value = RAID_CLASS_COLORS[E.myclass]
	end	
	self["media"].hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self["media"].rgbvaluecolor = {value.r, value.g, value.b}
	
	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
		LeftChatPanel.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.55 > 0 and E.db.general.backdropfadecolor.a - 0.55 or 0.5)		
		
		RightChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameRight)
		RightChatPanel.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.55 > 0 and E.db.general.backdropfadecolor.a - 0.55 or 0.5)		
	end

	self:ValueFuncCall()
	self:UpdateBlizzardFonts()
end

function E:PLAYER_ENTERING_WORLD()
	self:UpdateMedia()
	self:UnregisterEvent('PLAYER_ENTERING_WORLD')
end

function E:ValueFuncCall()
	for func, _ in pairs(self['valueColorUpdateFuncs']) do
		func(self["media"].hexvaluecolor, unpack(self["media"].rgbvaluecolor))
	end
end

function E:UpdateFrameTemplates()
	for frame, _ in pairs(self["frames"]) do
		if frame and frame.template  then
			frame:SetTemplate(frame.template, frame.glossTex);
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBorderColors()
	for frame, _ in pairs(self["frames"]) do
		if frame then
			if frame.template == 'Default' or frame.template == 'Transparent' or frame.template == nil then
				frame:SetBackdropBorderColor(unpack(self['media'].bordercolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end	

function E:UpdateBackdropColors()
	for frame, _ in pairs(self["frames"]) do
		if frame then
			if frame.template == 'Default' or frame.template == nil then
				if frame.backdropTexture then
					frame.backdropTexture:SetVertexColor(unpack(self['media'].backdropcolor))
				else
					frame:SetBackdropColor(unpack(self['media'].backdropcolor))				
				end
			elseif frame.template == 'Transparent' then
				frame:SetBackdropColor(unpack(self['media'].backdropfadecolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end	

function E:UpdateFontTemplates()
	for text, _ in pairs(self["texts"]) do
		if text then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle);
		else
			self["texts"][text] = nil;
		end
	end
end

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame('Frame', 'ElvUIParent', UIParent);
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel());
E.UIParent:SetPoint('CENTER', UIParent, 'CENTER');
E.UIParent:SetSize(UIParent:GetSize());
tinsert(E['snapBars'], E.UIParent)

E.HiddenFrame = CreateFrame('Frame')
E.HiddenFrame:Hide()

--Check if PTR version of WoW is loaded
function E:IsPTRVersion()
	if self.wowbuild > 14545 then
		return true;
	else
		return false;
	end
	return false;
end

function E:CheckRole()
	local talentTree = GetSpecialization()
	local IsInPvPGear = false;
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() and UnitLevel('player') == MAX_PLAYER_LEVEL then
		IsInPvPGear = true;
	end
	
	self.role = nil;
	
	if type(self.ClassRole[self.myclass]) == "string" then
		self.role = self.ClassRole[self.myclass]
	elseif talentTree then
		self.role = self.ClassRole[self.myclass][talentTree]
	end
	
	if self.role == "Tank" and IsInPvPGear then
		self.role = "Melee"
	end
	
	if not self.role then
		local playerint = select(2, UnitStat("player", 4));
		local playeragi	= select(2, UnitStat("player", 2));
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (playerap > playerint) or (playeragi > playerint) then
			self.role = "Melee";
		else
			self.role = "Caster";
		end		
	end
end

function E:CheckIncompatible()
	if IsAddOnLoaded('Prat-3.0') and E.private.chat.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Prat', 'Chat'))
	elseif IsAddOnLoaded('Chatter') and E.private.chat.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Chatter', 'Chat'))
	end
	
	if IsAddOnLoaded('Bartender4') and E.private.actionbar.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Bartender', 'ActionBar'))
	elseif IsAddOnLoaded('Dominos') and E.private.actionbar.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Dominos', 'ActionBar'))
	end	
	
	if IsAddOnLoaded('TidyPlates') and E.private.nameplate.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'TidyPlates', 'NamePlate'))
	elseif IsAddOnLoaded('Aloft') and E.private.nameplate.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Aloft', 'NamePlate'))
	end	
	
	if IsAddOnLoaded('ArkInventory') and E.private.general.bags then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'ArkInventory', 'Bags'))
	elseif IsAddOnLoaded('Bagnon') and E.private.general.bags then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Bagnon', 'Bags'))
	elseif IsAddOnLoaded('OneBag3') and E.private.general.bags then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'OneBag3', 'Bags'))
	elseif IsAddOnLoaded('OneBank3') and E.private.general.bags then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'OneBank3', 'Bags'))
	end
end

function E:IsFoolsDay()
	if string.find(date(), '04/01/') and not E.global.aprilFools then
		return true;
	else
		return false;
	end
end

function E:CopyTable(currentTable, defaultTable)
	if type(currentTable) ~= "table" then currentTable = {} end
	
	if type(defaultTable) == 'table' then
		for option, value in pairs(defaultTable) do
			if type(value) == "table" then
				value = self:CopyTable(currentTable[option], value)
			end
			
			currentTable[option] = value			
		end
	end
	
	return currentTable
end

function E:SendMessage()
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == 'pvp' or instanceType == 'arena' then
		SendAddonMessage("ElvUIVC", E.version, "BATTLEGROUND")	
	else
		if IsInRaid() then
			SendAddonMessage("ElvUIVC", E.version, "RAID")
		elseif IsInGroup() then
			SendAddonMessage("ElvUIVC", E.version, "PARTY")
		end
	end
	
	self:CancelAllTimers()
end

local function SendRecieve(self, event, prefix, message, channel, sender)
	if event == "CHAT_MSG_ADDON" then
		if sender == E.myname then return end

		if prefix == "ElvUIVC" and sender ~= 'Elvz' and not string.find(sender, 'Elvz%-') and not E.recievedOutOfDateMessage then
			if E.version ~= 'BETA' and tonumber(message) > tonumber(E.version) then
				E:Print(L["Your version of ElvUI is out of date. You can download the latest version from http://www.tukui.org"])
				E.recievedOutOfDateMessage = true
			end
		end
	else
		E:ScheduleTimer('SendMessage', 12)
	end
end

local f = CreateFrame('Frame')
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript('OnEvent', SendRecieve)

function E:UpdateAll(ignoreInstall)
	self.data = LibStub("AceDB-3.0"):New("ElvData", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	self.db = self.data.profile;
	self.global = self.data.global;
	
	self:SetMoversPositions()
	
	local CH = self:GetModule('Chat')
	CH.db = self.db.chat
	CH:PositionChat(true); 
	
	local AB = self:GetModule('ActionBars')
	AB.db = self.db.actionbar
	AB:UpdateButtonSettings()
	 
	local bags = E:GetModule('Bags'); 
	bags:Layout(); 
	bags:Layout(true); 
	bags:PositionBagFrames()
	bags:SizeAndPositionBagBar()

	self:GetModule('Layout'):ToggleChatPanels()
	
	local DT = self:GetModule('DataTexts')
	DT.db = self.db.datatexts
	DT:LoadDataTexts()
	
	local NP = self:GetModule('NamePlates')
	NP.db = self.db.nameplate
	NP:UpdateAllPlates()
	
	local UF = self:GetModule('UnitFrames')
	UF.db = self.db.unitframe
	UF:Update_AllFrames()
	
	local M = self:GetModule("Misc")
	M:UpdateExpRepDimensions()
	M:EnableDisable_ExperienceBar()
	M:EnableDisable_ReputationBar()	
	
	self:GetModule('Auras').db = self.db.auras
	self:GetModule('Tooltip').db = self.db.tooltip
	
	E:GetModule('Auras'):UpdateAllHeaders()
	
	if self.db.install_complete == nil or (self.db.install_complete and type(self.db.install_complete) == 'boolean') or (self.db.install_complete and type(tonumber(self.db.install_complete)) == 'number' and tonumber(self.db.install_complete) <= 3.83) then
		if not ignoreInstall then
			self:Install()
		end
	end
	
	self:GetModule('Minimap'):UpdateSettings()
	
	self:UpdateMedia()
	self:UpdateBorderColors()
	self:UpdateBackdropColors()
	self:UpdateFrameTemplates()
	
	collectgarbage('collect');
end

function E:RemoveNonPetBattleFrames()
	if InCombatLockdown() then return end
	for object, _ in pairs(E.FrameLocks) do
		_G[object]:SetParent(E.HiddenFrame)
	end
end

function E:AddNonPetBattleFrames()
	if InCombatLockdown() then return end
	for object, _ in pairs(E.FrameLocks) do
		_G[object]:SetParent(UIParent)
	end
end

function E:ResetAllUI()
	self:ResetMovers()

	if E.db.lowresolutionset then
		E:SetupResolution(true)
	end	

	if E.db.layoutSet then
		E:SetupLayout(E.db.layoutSet, true)
	end
end

function E:ResetUI(...)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
	
	if ... == '' or ... == ' ' or ... == nil then
		E:StaticPopup_Show('RESETUI_CHECK')
		return
	end
	
	self:ResetMovers(...)
end

function E:RegisterModule(name)
	if self.initialized then
		self:GetModule(name):Initialize()
		tinsert(self['RegisteredModules'], name)
	else
		tinsert(self['RegisteredModules'], name)
	end
end

function E:RegisterInitialModule(name)
	tinsert(self['RegisteredInitialModules'], name)
end

function E:InitializeInitialModules()
	for _, module in pairs(E['RegisteredInitialModules']) do
		local module = self:GetModule(module, true)
		if module and module.Initialize then
			module:Initialize()
		end
	end
end

function E:RefreshModulesDB()
	local UF = self:GetModule('UnitFrames')
	table.wipe(UF.db)
	UF.db = self.db.unitframe
end

function E:InitializeModules()	
	for _, module in pairs(E['RegisteredModules']) do
		if self:GetModule(module).Initialize then
			self:GetModule(module):Initialize()
		end
	end
end

function E:Initialize()
	table.wipe(self.db)
	table.wipe(self.global)
	table.wipe(self.private)
	
	self.data = LibStub("AceDB-3.0"):New("ElvData", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	
	self.charSettings = LibStub("AceDB-3.0"):New("ElvPrivateData", self.privateVars);	
	self.private = self.charSettings.profile
	self.db = self.data.profile;
	self.global = self.data.global;
	self:CheckIncompatible()

	self:CheckRole()
	self:UIScale('PLAYER_LOGIN');

	if self.db.general.loginmessage then
		print(format(L['LOGIN_MSG'], self["media"].hexvaluecolor, self["media"].hexvaluecolor, self.version))
	end

	self:LoadConfig(); --Load In-Game Config
	self:LoadCommands(); --Load Commands
	self:InitializeModules(); --Load Modules	
	self:LoadMovers(); --Load Movers

	self.initialized = true
	
	if self.db.install_complete == nil or (self.db.install_complete and type(self.db.install_complete) == 'boolean') or (self.db.install_complete and type(tonumber(self.db.install_complete)) == 'number' and tonumber(self.db.install_complete) <= 3.83) then
		self:Install()
	end
	
	if not string.find(date(), '04/01/') then	
		E.global.aprilFools = nil;
	end
	
	if E:IsFoolsDay() then
		function GetMoney()
			return 0;
		end
		E:Delay(45, function()
			E:StaticPopup_Show('APRIL_FOOLS')
		end)
	end
	
	RegisterAddonMessagePrefix('ElvUIVC')
	RegisterAddonMessagePrefix('ElvSays')
	
	self:UpdateMedia()
	self:UpdateFrameTemplates()
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckRole");
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CheckRole");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckRole");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CheckRole");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "CheckRole");	
	self:RegisterEvent('UI_SCALE_CHANGED', 'UIScale')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent("PET_BATTLE_CLOSE", 'AddNonPetBattleFrames')
	self:RegisterEvent('PET_BATTLE_OPENING_START', "RemoveNonPetBattleFrames")	

	self:Tutorials()
	self:GetModule('Minimap'):UpdateSettings()
	self:RefreshModulesDB()
	collectgarbage("collect");
end
