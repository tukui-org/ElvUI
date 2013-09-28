local addonName, addon = ...
local module = addon:NewModule("DisableBlizzard", "AceEvent-3.0", "AceHook-3.0")
local L = addon:GetLocales()

function module:BlizzardOptionsPanel_OnEvent()
	InterfaceOptionsActionBarsPanelBottomRight.Text:SetText(format(L['Remove Bar %d Action Page'], 2))
	InterfaceOptionsActionBarsPanelBottomLeft.Text:SetText(format(L['Remove Bar %d Action Page'], 3))
	InterfaceOptionsActionBarsPanelRightTwo.Text:SetText(format(L['Remove Bar %d Action Page'], 4))
	InterfaceOptionsActionBarsPanelRight.Text:SetText(format(L['Remove Bar %d Action Page'], 5))
	
	InterfaceOptionsActionBarsPanelBottomRight:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelRightTwo:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelRight:SetScript('OnEnter', nil)
end


function module:HandleFrame(frame, notDeep)
	frame:UnregisterAllEvents()
	frame:SetParent(ElvUIHider)

	if(not notDeep) then
		for i=1, frame:GetNumChildren() do
			local element = select(i, frame:GetChildren())
			element:UnregisterAllEvents()
		end
	end
end

function module:DisableArenaFrames(event, addon)
	if(addon ~= "Blizzard_ArenaUI") then return end
	for i=1, 5 do
		self:HandleFrame(_G[('ArenaEnemyFrame%d'):format(i)])
		self:HandleFrame(_G[('ArenaPrepFrame%d'):format(i)])
		self:HandleFrame(_G[('ArenaEnemyFrame%dPetFrame'):format(i)])
	end	

	if(event == "ADDON_LOADED") then
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function module:DisableUnitFrames()
	if(self.db.playerFrame) then
		self:HandleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterUnitEvent('UNIT_ENTERING_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_EXITING_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_EXITED_VEHICLE', "player")
		PlayerFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
		
		-- User placed frames don't animate
		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
		RuneFrame:SetParent(PlayerFrame)	
		RuneFrame:UnregisterAllEvents()

		InterfaceOptionsStatusTextPanelPlayer:SetAlpha(0)
		InterfaceOptionsStatusTextPanelPlayer:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelPet:SetAlpha(0)
		InterfaceOptionsStatusTextPanelPet:SetScale(0.0001)
	end

	if(self.db.targetFrame) then
		self:HandleFrame(TargetFrame)
		self:HandleFrame(ComboFrame)	
		self:HandleFrame(TargetFrameToT)
		InterfaceOptionsStatusTextPanelTarget:SetScale(0.0001)	
		InterfaceOptionsStatusTextPanelTarget:SetAlpha(0)
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:SetAlpha(0)
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:EnableMouse(false)		

		InterfaceOptionsCombatPanelTargetOfTarget:SetScale(0.0001)
		InterfaceOptionsCombatPanelTargetOfTarget:SetAlpha(0)
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates:ClearAllPoints()
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates:SetPoint(InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:GetPoint())		
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetScale(0.0001)
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetAlpha(0)			
	end

	if(self.db.focusFrame) then
		self:HandleFrame(FocusFrame)
		--self:HandleFrame(TargetofFocusFrame)
		InterfaceOptionsUnitFramePanelFullSizeFocusFrame:SetScale(0.0001)
		InterfaceOptionsUnitFramePanelFullSizeFocusFrame:SetAlpha(0)
	end

	if(self.db.bossFrames) then
		for i=1, 4 do
			self:HandleFrame(_G[('Boss%dTargetFrame'):format(i)])
		end		
	end

	if(self.db.arenaFrames) then
		if(not IsAddOnLoaded('Blizzard_ArenaUI')) then
			self:RegisterEvent('ADDON_LOADED', "DisableArenaFrames")
		else
			self:DisableArenaFrames(nil, "Blizzard_ArenaUI")
		end

		InterfaceOptionsUnitFramePanelArenaEnemyFrames:SetScale(0.0001)
		InterfaceOptionsUnitFramePanelArenaEnemyFrames:SetAlpha(0)
		InterfaceOptionsUnitFramePanelArenaEnemyCastBar:SetScale(0.0001)
		InterfaceOptionsUnitFramePanelArenaEnemyCastBar:SetAlpha(0)
		InterfaceOptionsUnitFramePanelArenaEnemyPets:SetScale(0.0001)
		InterfaceOptionsUnitFramePanelArenaEnemyPets:SetAlpha(0)		
	end

	if(self.db.partyFrames) then
		for i=1, 4 do
			self:HandleFrame(_G[('PartyMemberFrame%d'):format(i)])
		end
		InterfaceOptionsStatusTextPanelParty:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelParty:SetAlpha(0)
		InterfaceOptionsUnitFramePanelPartyPets:SetScale(0.0001)
		InterfaceOptionsUnitFramePanelPartyPets:SetAlpha(0)
	end

	if(self.db.raidFrames) then
		InterfaceOptionsFrameCategoriesButton11:SetScale(0.0001)
	end

	if(self.db.partyFrames and self.db.arenaFrames and self.db.focusFrame) then
		InterfaceOptionsFrameCategoriesButton10:SetScale(0.0001)
	end
end

function module:DisableActionBars()
	if(not self.db.actionBars) then return end

	MultiBarBottomLeft:SetParent(ElvUIHider)
	MultiBarBottomRight:SetParent(ElvUIHider)
	MultiBarLeft:SetParent(ElvUIHider)
	MultiBarRight:SetParent(ElvUIHider)

	-- Hide MultiBar Buttons, but keep the bars alive
	for i=1, 12 do
		_G["ActionButton" .. i]:Hide()
		_G["ActionButton" .. i]:UnregisterAllEvents()
		_G["ActionButton" .. i]:SetAttribute("statehidden", true)
	
		_G["MultiBarBottomLeftButton" .. i]:Hide()
		_G["MultiBarBottomLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton" .. i]:Hide()
		_G["MultiBarBottomRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton" .. i]:SetAttribute("statehidden", true)
		
		_G["MultiBarRightButton" .. i]:Hide()
		_G["MultiBarRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarRightButton" .. i]:SetAttribute("statehidden", true)
		
		_G["MultiBarLeftButton" .. i]:Hide()
		_G["MultiBarLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarLeftButton" .. i]:SetAttribute("statehidden", true)
		
		if _G["VehicleMenuBarActionButton" .. i] then
			_G["VehicleMenuBarActionButton" .. i]:Hide()
			_G["VehicleMenuBarActionButton" .. i]:UnregisterAllEvents()
			_G["VehicleMenuBarActionButton" .. i]:SetAttribute("statehidden", true)
		end
		
		if _G['OverrideActionBarButton'..i] then
			_G['OverrideActionBarButton'..i]:Hide()
			_G['OverrideActionBarButton'..i]:UnregisterAllEvents()
			_G['OverrideActionBarButton'..i]:SetAttribute("statehidden", true)
		end
		
		_G['MultiCastActionButton'..i]:Hide()
		_G['MultiCastActionButton'..i]:UnregisterAllEvents()
		_G['MultiCastActionButton'..i]:SetAttribute("statehidden", true)
	end

	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	
	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:SetParent(ElvUIHider)
	
	for i=1, MainMenuBar:GetNumChildren() do
		local child = select(i, MainMenuBar:GetChildren())
		if child then
			child:UnregisterAllEvents()
			child:SetParent(ElvUIHider)
		end
	end

	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:SetParent(ElvUIHider)	

	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:SetParent(ElvUIHider)
	
	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:SetParent(ElvUIHider)

	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:SetParent(ElvUIHider)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:SetParent(ElvUIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:SetParent(ElvUIHider)
	
	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:SetParent(ElvUIHider)

	IconIntroTracker:UnregisterAllEvents()
	IconIntroTracker:SetParent(ElvUIHider)

	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetScale(0.0001)
	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
	InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.00001)
	InterfaceOptionsStatusTextPanelXP:SetAlpha(0)
	InterfaceOptionsStatusTextPanelXP:SetScale(0.00001)
	InterfaceOptionsDisplayPanelShowFreeBagSpace:EnableMouse(false)
	InterfaceOptionsDisplayPanelShowFreeBagSpace:SetAlpha(0)
	self:SecureHook('BlizzardOptionsPanel_OnEvent')

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		self:SecureHook("TalentFrame_LoadUI")
	end	
end

function module:TalentFrame_LoadUI()
	PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
end

function module:DisableAuras()
	if(not self.db.auras) then return end
	InterfaceOptionsFrameCategoriesButton12:SetScale(0.0001)
	InterfaceOptionsFrameCategoriesButton12:SetAlpha(0)

	self:HandleFrame(BuffFrame, true)
	self:HandleFrame(ConsolidatedBuffs, true)
	self:HandleFrame(TemporaryEnchantFrame, true)
end

function module:OnInitialize()
	self.db = addon.private.disableBlizzard

	self:DisableActionBars()
	self:DisableUnitFrames()
	self:DisableAuras()
end