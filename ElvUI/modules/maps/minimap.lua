local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('Minimap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
E.Minimap = M

local gsub = string.gsub
local upper = string.upper

local calendar_string = gsub(SLASH_CALENDAR1, "/", "")
calendar_string = gsub(calendar_string, "^%l", upper)


local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", E.UIParent)

local menuList = {
	{text = CHARACTER_BUTTON,
	func = function() ToggleCharacter("PaperDollFrame") end},
	{text = SPELLBOOK_ABILITIES_BUTTON,
	func = function() if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end end},
	{text = MOUNTS_AND_PETS,
	func = function()
		TogglePetJournal();
	end},
	{text = TALENTS_BUTTON,
	func = function()
		if not PlayerTalentFrame then
			TalentFrame_LoadUI()
		end

		if not GlyphFrame then
			GlyphFrame_LoadUI()
		end
		
		if not PlayerTalentFrame:IsShown() then
			ShowUIPanel(PlayerTalentFrame)
		else
			HideUIPanel(PlayerTalentFrame)
		end
	end},
	{text = TIMEMANAGER_TITLE,
	func = function() ToggleFrame(TimeManagerFrame) end},		
	{text = ACHIEVEMENT_BUTTON,
	func = function() ToggleAchievementFrame() end},
	{text = QUESTLOG_BUTTON,
	func = function() ToggleFrame(QuestLogFrame) end},
	{text = SOCIAL_BUTTON,
	func = function() ToggleFriendsFrame(1) end},
	{text = calendar_string,
	func = function() GameTimeFrame:Click() end},
	{text = PLAYER_V_PLAYER,
	func = function()
		if not PVPUIFrame then
			PVP_LoadUI()
		end	
		ToggleFrame(PVPUIFrame) 
	end},
	{text = ACHIEVEMENTS_GUILD_TAB,
	func = function()
		if IsInGuild() then
			if not GuildFrame then GuildFrame_LoadUI() end
			GuildFrame_Toggle()
		else
			if not LookingForGuildFrame then LookingForGuildFrame_LoadUI() end
			if not LookingForGuildFrame then return end
			LookingForGuildFrame_Toggle()
		end
	end},
	{text = LFG_TITLE,
	func = function() PVEFrame_ToggleFrame(); end},
	{text = ENCOUNTER_JOURNAL, 
	func = function() if not IsAddOnLoaded('Blizzard_EncounterJournal') then EncounterJournal_LoadUI(); end ToggleFrame(EncounterJournal) end},		
	{text = HELP_BUTTON,
	func = function() ToggleHelpFrame() end},
}

--Support for other mods
function GetMinimapShape() 
	return 'SQUARE' 
end

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then 
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.84, 0.03, 0.03
	end	
end

function M:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function M:Minimap_OnMouseUp(btn)
	local position = self:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if position:match("LEFT") then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end	
	elseif btn == "RightButton" then
		local xoff = -1

		if position:match("RIGHT") then xoff = E:Scale(-16) end
	
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, xoff, E:Scale(-3))
	else
		Minimap_OnClick(self)
	end
end

function M:Minimap_OnMouseWheel(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == 'HIDE' or not E.private.general.minimap.enable then return; end
	Minimap.location:SetText(strsub(GetMinimapZoneText(),1,25))
	Minimap.location:SetTextColor(M:GetLocTextColor())
end

function M:UpdateLFG()
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:Point("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, 1)
	MiniMapLFGFrameBorder:Hide()
end

function M:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:UpdateSettings()
end

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	end
	E.MinimapSize = E.private.general.minimap.enable and E.db.general.minimap.size or Minimap:GetWidth() + 10
	
	if E.db.auras.consolidatedBuffs.enable then
		E.ConsolidatedBuffsWidth = ((E.MinimapSize - (E.db.auras.consolidatedBuffs.filter and 6 or 8)) / (E.db.auras.consolidatedBuffs.filter and 6 or 8)) + (E.PixelMode and 3 or 4)-- 4 needs to be 3
	else
		E.ConsolidatedBuffsWidth = 0;
	end
	
	E.MinimapWidth = E.MinimapSize	
	E.MinimapHeight = E.MinimapSize + 5
	
	if E.private.general.minimap.enable then
		Minimap:Size(E.MinimapSize, E.MinimapSize)
	end
	
	if LeftMiniPanel and RightMiniPanel then
		if E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			LeftMiniPanel:Show()
			RightMiniPanel:Show()
		else
			LeftMiniPanel:Hide()
			RightMiniPanel:Hide()
		end
	end	
	
	if MMHolder then
		MMHolder:Width((Minimap:GetWidth() + (E.PixelMode and 3 or 4)) + E.ConsolidatedBuffsWidth)
		
		if E.db.datatexts.minimapPanels then
			MMHolder:Height(Minimap:GetHeight() + (E.PixelMode and 22 or 27))
		else
			MMHolder:Height(Minimap:GetHeight() + (E.PixelMode and 2 or 5))	
		end
	end
	
	if Minimap.location then
		Minimap.location:Width(E.MinimapSize)
		
		if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
			Minimap.location:Hide()
		else
			Minimap.location:Show()
		end		
	end
	
	if MinimapMover then
		MinimapMover:Size(MMHolder:GetSize())
	end

	if AurasHolder then
		AurasHolder:Height(E.MinimapHeight)
		if AurasMover and not E:HasMoverBeenMoved('AurasMover') and not E:HasMoverBeenMoved('MinimapMover') then
			AurasMover:ClearAllPoints()
			AurasMover:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -(E.PixelMode and 4 or 8), 2)
			E:SaveMoverDefaultPosition('AurasMover')
		end
		
		if AurasMover then
			AurasMover:Height(E.MinimapHeight)
		end
	end
			
	if ElvConfigToggle then
		if E.db.auras.consolidatedBuffs.enable and E.db.datatexts.minimapPanels and E.private.general.minimap.enable then
			ElvConfigToggle:Show()
			ElvConfigToggle:Width(E.ConsolidatedBuffsWidth)
		else
			ElvConfigToggle:Hide()
		end
	end
	
	if ElvUI_ConsolidatedBuffs then
		E:GetModule('Auras'):Update_ConsolidatedBuffsSettings()
	end
end

function M:Initialize()	
	menuFrame:SetTemplate("Transparent", true)
	self:UpdateSettings()
	if not E.private.general.minimap.enable then 
		Minimap:SetMaskTexture('Textures\\MinimapMask')
		return; 
	end	
	
	local mmholder = CreateFrame('Frame', 'MMHolder', Minimap)
	mmholder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -10, -10)
	mmholder:Width((Minimap:GetWidth() + 29) + E.ConsolidatedBuffsWidth)
	mmholder:Height(Minimap:GetHeight() + 53)
	
	Minimap:ClearAllPoints()
	Minimap:Point("TOPLEFT", mmholder, "TOPLEFT", 2, -2)
	Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
	Minimap:SetQuestBlobRingAlpha(0) 
	Minimap:SetArchBlobRingAlpha(0)	
	Minimap:CreateBackdrop('Default')
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:HookScript('OnEnter', function(self)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return; end
		self.location:Show()
	end)
	
	Minimap:HookScript('OnLeave', function(self)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return; end
		self.location:Hide()
	end)	
	
	--Fix spellbook taint
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)	
	
	Minimap.location = Minimap:CreateFontString(nil, 'OVERLAY')
	Minimap.location:FontTemplate(nil, nil, 'OUTLINE')
	Minimap.location:Point('TOP', Minimap, 'TOP', 0, -2)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")	
	if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	end
	
	MinimapBorder:Hide()
	MinimapBorderTop:Hide()

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()

	MiniMapVoiceChatFrame:Hide()

	MinimapNorthTag:Kill()

	GameTimeFrame:Hide()

	MinimapZoneTextButton:Hide()

	MiniMapTracking:Hide()

	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:Point("TOPRIGHT", Minimap, 3, 4)
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\mail")

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:Point("BOTTOMRIGHT", Minimap, 3, 0)
	QueueStatusMinimapButtonBorder:Hide()
	QueueStatusFrame:SetClampedToScreen(true)

	MiniMapWorldMapButton:Hide()

	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetParent(Minimap)
	MiniMapInstanceDifficulty:Point("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

	GuildInstanceDifficulty:ClearAllPoints()
	GuildInstanceDifficulty:SetParent(Minimap)
	GuildInstanceDifficulty:Point("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	
	MiniMapChallengeMode:ClearAllPoints()
	MiniMapChallengeMode:SetParent(Minimap)
	MiniMapChallengeMode:Point("TOPLEFT", Minimap, "TOPLEFT", 8, -8)
	
	if TimeManagerClockButton then
		TimeManagerClockButton:Kill()
	end
	
	if FeedbackUIButton then
		FeedbackUIButton:Kill()
	end
	
	E:CreateMover(MMHolder, 'MinimapMover', L['Minimap'])

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)	
	Minimap:SetScript("OnMouseUp", M.Minimap_OnMouseUp)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")		
	self:RegisterEvent('ADDON_LOADED')
	self:UpdateSettings()
	
	--Create Farmmode Minimap
	local fm = CreateFrame('Minimap', 'FarmModeMap', E.UIParent)
	fm:Size(E.db.farmSize)
	fm:Point('TOP', E.UIParent, 'TOP', 0, -120)
	fm:SetClampedToScreen(true)
	fm:CreateBackdrop('Default')
	fm:EnableMouseWheel(true)
	fm:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)	
	fm:SetScript("OnMouseUp", M.Minimap_OnMouseUp)	
	fm:RegisterForDrag("LeftButton", "RightButton")
	fm:SetMovable(true)
	fm:SetScript("OnDragStart", function(self) self:StartMoving() end)
	fm:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	fm:Hide()
	E.FrameLocks['FarmModeMap'] = true;
	
	FarmModeMap:SetScript('OnShow', function() 	
		if not E:HasMoverBeenMoved('AurasMover') then
			AurasMover:ClearAllPoints()
			AurasMover:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
		end
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(FarmModeMap)
		if IsAddOnLoaded('Routes') then
			LibStub("AceAddon-3.0"):GetAddon('Routes'):ReparentMinimap(FarmModeMap)
		end

		if IsAddOnLoaded('GatherMate2') then
			LibStub('AceAddon-3.0'):GetAddon('GatherMate2'):GetModule('Display'):ReparentMinimapPins(FarmModeMap)
		end		
	end)
	
	FarmModeMap:SetScript('OnHide', function() 
		if not E:HasMoverBeenMoved('AurasMover') then
			E:ResetMovers('Auras Frame')
		end	
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetAllPoints(Minimap)	
		if IsAddOnLoaded('Routes') then
			LibStub("AceAddon-3.0"):GetAddon('Routes'):ReparentMinimap(Minimap)
		end

		if IsAddOnLoaded('GatherMate2') then
			LibStub('AceAddon-3.0'):GetAddon('GatherMate2'):GetModule('Display'):ReparentMinimapPins(Minimap)
		end	
	end)

	
	UIParent:HookScript('OnShow', function()
		if not FarmModeMap.enabled then
			FarmModeMap:Hide()
		end
	end)
	
	--PET JOURNAL TAINT FIX AS OF 5.1
	local info = UIPanelWindows['PetJournalParent'];
	for name, value in pairs(info) do
		PetJournalParent:SetAttribute("UIPanelLayout-"..name, value);
	end	

	PetJournalParent:SetAttribute("UIPanelLayout-defined", true);	
end

E:RegisterInitialModule(M:GetName())