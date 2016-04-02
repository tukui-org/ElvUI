local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local pairs = pairs
local tinsert = table.insert
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local GetInstanceInfo = GetInstanceInfo
local UnregisterStateDriver = UnregisterStateDriver
local RegisterStateDriver = RegisterStateDriver

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UnitFrame_OnEnter, UnitFrame_OnLeave, ElvUF_Raid

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_RaidFrames(unitGroup)
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self.RaisedElementParent = CreateFrame('Frame', nil, self)
	self.RaisedElementParent:SetFrameStrata("MEDIUM")
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 10)

	self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')

	self.Power = UF:Construct_PowerBar(self, true, true, 'LEFT')
	self.Power.frequentUpdates = false;

	self.Portrait3D = UF:Construct_Portrait(self, 'model')
	self.Portrait2D = UF:Construct_Portrait(self, 'texture')

	self.Name = UF:Construct_NameText(self)
	self.Buffs = UF:Construct_Buffs(self)
	self.Debuffs = UF:Construct_Debuffs(self)
	self.AuraWatch = UF:Construct_AuraWatch(self)
	self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
	self.DebuffHighlight = UF:Construct_DebuffHighlight(self)
	self.ResurrectIcon = UF:Construct_ResurectionIcon(self)
	self.LFDRole = UF:Construct_RoleIcon(self)
	self.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)
	tinsert(self.__elements, UF.UpdateTargetGlow)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', UF.UpdateTargetGlow)
	self:RegisterEvent('PLAYER_ENTERING_WORLD', UF.UpdateTargetGlow)

	self.Threat = UF:Construct_Threat(self)
	self.RaidIcon = UF:Construct_RaidIcon(self)
	self.ReadyCheck = UF:Construct_ReadyCheckIcon(self)
	self.HealPrediction = UF:Construct_HealComm(self)
	self.GPS = UF:Construct_GPS(self)
	self.Range = UF:Construct_Range(self)
	self.customTexts = {}
	self.InfoPanel = UF:Construct_InfoPanel(self)

	UF:Update_StatusBars()
	UF:Update_FontStrings()

	self.unitframeType = "raid"

	return self
end

function UF:RaidSmartVisibility(event)
	if not self.db or (self.db and not self.db.enable) or (UF.db and not UF.db.smartRaidFilter) or self.isForced then
		self.blockVisibilityChanges = false
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end

	if not InCombatLockdown() then
		self.isInstanceForced = nil
		local inInstance, instanceType = IsInInstance()
		if(inInstance and (instanceType == 'raid' or instanceType == 'pvp')) then
			local _, _, _, _, maxPlayers, _, _, mapID, maxPlayersInstance = GetInstanceInfo()
			--[[if maxPlayersInstance > 0 then
				maxPlayers = maxPlayersInstance
			end]]

			if UF.mapIDs[mapID] then
				maxPlayers = UF.mapIDs[mapID]
			end

			UnregisterStateDriver(self, "visibility")

			if(maxPlayers < 40) then
				self:Show()
				self.isInstanceForced = true
				self.blockVisibilityChanges = false
				if(ElvUF_Raid.numGroups ~= E:Round(maxPlayers/5) and event) then
					UF:CreateAndUpdateHeaderGroup('raid')
				end
			else
				self:Hide()
				self.blockVisibilityChanges = true
			end
		elseif self.db.visibility then
			RegisterStateDriver(self, "visibility", self.db.visibility)
			self.blockVisibilityChanges = false
			if(ElvUF_Raid.numGroups ~= self.db.numGroups) then
				UF:CreateAndUpdateHeaderGroup('raid')
			end
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
end

function UF:Update_RaidHeader(header, db, isForced)
	header:GetParent().db = db

	local headerHolder = header:GetParent()
	headerHolder.db = db

	if not headerHolder.positioned then
		headerHolder:ClearAllPoints()
		headerHolder:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 195)

		E:CreateMover(headerHolder, headerHolder:GetName()..'Mover', L["Raid Frames"], nil, nil, nil, 'ALL,RAID')

		headerHolder:RegisterEvent("PLAYER_ENTERING_WORLD")
		headerHolder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		headerHolder:SetScript("OnEvent", UF['RaidSmartVisibility'])
		headerHolder.positioned = true;
	end

	UF.RaidSmartVisibility(headerHolder)
end

function UF:Update_RaidFrames(frame, db)
	frame.db = db

	frame.Portrait = frame.Portrait or (db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D)
	frame.colors = ElvUF.colors
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')

	do
		if(self.thinBorders) then
			frame.SPACING = 0
			frame.BORDER = E.mult
		else
			frame.BORDER = E.Border
			frame.SPACING = E.Spacing
		end
		frame.SHADOW_SPACING = 3

		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?

		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = (E.global.tukuiMode and not db.infoPanel.enable) and db.height + db.infoPanel.height or db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width

		frame.STAGGER_WIDTH = 0
		frame.CLASSBAR_WIDTH = 0
		frame.CLASSBAR_YOFFSET = 0
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and (db.infoPanel.enable or E.global.tukuiMode)
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

		frame.USE_TARGET_GLOW = db.targetGlow
	end

	if not InCombatLockdown() then
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	end

	UF:Configure_InfoPanel(frame)
	--Health
	UF:Configure_HealthBar(frame)

	--Name
	UF:UpdateNameSettings(frame)

	--Power
	UF:Configure_Power(frame)

	--Portrait
	UF:Configure_Portrait(frame)

	--Threat
	UF:Configure_Threat(frame)

	--Target Glow
	UF:Configure_TargetGlow(frame)

	--Auras
	UF:EnableDisable_Auras(frame)
	UF:Configure_Auras(frame, 'Buffs')
	UF:Configure_Auras(frame, 'Debuffs')

	--RaidDebuffs
	UF:Configure_RaidDebuffs(frame)

	--Raid Icon
	UF:Configure_RaidIcon(frame)

	--Debuff Highlight
	UF:Configure_DebuffHighlight(frame)

	--Role Icon
	UF:Configure_RoleIcon(frame)

	--OverHealing
	UF:Configure_HealComm(frame)

	--GPSArrow
	UF:Configure_GPS(frame)

	--Raid Roles
	UF:Configure_RaidRoleIcons(frame)

	--Range
	UF:Configure_Range(frame)

	--Buff Indicators
	UF:UpdateAuraWatch(frame)

	--ReadyCheck
	UF:Configure_ReadyCheckIcon(frame)

	--CustomTexts
	UF:Configure_CustomTexts(frame)

	frame:UpdateAllElements()
end

UF['headerstoload']['raid'] = true
