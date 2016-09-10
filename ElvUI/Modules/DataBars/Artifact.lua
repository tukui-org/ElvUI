local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');

--Cache global variables
--Lua functions
local _G = _G
local format = format

--WoW API / Variables
local C_ArtifactUIGetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local HasArtifactEquipped = HasArtifactEquipped
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local ShowUIPanel = ShowUIPanel
local SocketInventoryItem = SocketInventoryItem
local ARTIFACT_POWER = ARTIFACT_POWER
local ARTIFACT_POWER_TOOLTIP_BODY = ARTIFACT_POWER_TOOLTIP_BODY

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, CreateFrame, ArtifactFrame

function mod:UpdateArtifact(event)
	if not mod.db.artifact.enable then return end

	local bar = self.artifactBar
	local showArtifact = HasArtifactEquipped();
	if not showArtifact or (event == "PLAYER_REGEN_DISABLED" and self.db.artifact.hideInCombat) then
		bar:Hide()
	elseif showArtifact and (not self.db.artifact.hideInCombat or not InCombatLockdown()) then
		bar:Show()

		if self.db.artifact.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local text = ''
		local _, _, _, _, totalXP, pointsSpent = C_ArtifactUIGetEquippedArtifactInfo();
		local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP);
		bar.statusBar:SetMinMaxValues(0, xpForNextPoint)
		bar.statusBar:SetValue(xp)

		local textFormat = self.db.artifact.textFormat
		if textFormat == 'PERCENT' then
			text = format('%d%%', xp / xpForNextPoint * 100)
		elseif textFormat == 'CURMAX' then
			text = format('%s - %s', E:ShortValue(xp), E:ShortValue(xpForNextPoint))
		elseif textFormat == 'CURPERC' then
			text = format('%s - %d%%', E:ShortValue(xp), xp / xpForNextPoint * 100)
		elseif textFormat == 'CUR' then
			text = format('%s', E:ShortValue(totalXP))
		elseif textFormat == 'REM' then
			text = format('%s', E:ShortValue(xpForNextPoint - xp))
		elseif textFormat == 'CURREM' then
			text = format('%s - %s', E:ShortValue(xp), E:ShortValue(xpForNextPoint - xp))
		end

		bar.text:SetText(text)
	end
end

function mod:ArtifactBar_OnEnter()
	if mod.db.artifact.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	GameTooltip:AddLine(ARTIFACT_POWER)
	GameTooltip:AddLine(' ')

	local _, _, _, _, totalXP, pointsSpent = C_ArtifactUIGetEquippedArtifactInfo();
	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP);

	GameTooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%d%%)', xp, xpForNextPoint, xp/xpForNextPoint * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d %s)', xpForNextPoint - xp, (xpForNextPoint - xp) / xpForNextPoint * 100, 20 * (xpForNextPoint - xp) / xpForNextPoint, L["Bars"]), 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(format(ARTIFACT_POWER_TOOLTIP_BODY, numPointsAvailableToSpend), nil, nil, nil, true)

	GameTooltip:Show()
end

function mod:ArtifactBar_OnClick()
	if not ArtifactFrame or not ArtifactFrame:IsShown() then
		ShowUIPanel(SocketInventoryItem(16))
	elseif ArtifactFrame and ArtifactFrame:IsShown() then
		HideUIPanel(ArtifactFrame)
	end
end

function mod:UpdateArtifactDimensions()
	self.artifactBar:Width(self.db.artifact.width)
	self.artifactBar:Height(self.db.artifact.height)
	self.artifactBar.statusBar:SetOrientation(self.db.artifact.orientation)
	self.artifactBar.statusBar:SetReverseFill(self.db.artifact.reverseFill)
	self.artifactBar.text:FontTemplate(nil, self.db.artifact.textSize)
	if self.db.artifact.mouseover then
		self.artifactBar:SetAlpha(0)
	else
		self.artifactBar:SetAlpha(1)
	end
end

function mod:EnableDisable_ArtifactBar()
	if self.db.artifact.enable then
		self:RegisterEvent('ARTIFACT_XP_UPDATE', 'UpdateArtifact')
		self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'UpdateArtifact')
		self:UpdateArtifact()
		E:EnableMover(self.artifactBar.mover:GetName())
	else
		self:UnregisterEvent('ARTIFACT_XP_UPDATE')
		self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
		self.artifactBar:Hide()
		E:DisableMover(self.artifactBar.mover:GetName())
	end
end

function mod:LoadArtifactBar()
	self.artifactBar = self:CreateBar('ElvUI_ArtifactBar', self.ArtifactBar_OnEnter, self.ArtifactBar_OnClick, 'RIGHT', self.honorBar, 'LEFT', E.Border - E.Spacing*3, 0)
	self.artifactBar.statusBar:SetStatusBarColor(.901, .8, .601)
	self.artifactBar.statusBar:SetMinMaxValues(0, 325)

	self.artifactBar.eventFrame = CreateFrame("Frame")
	self.artifactBar.eventFrame:Hide()
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.artifactBar.eventFrame:SetScript("OnEvent", function(self, event) mod:UpdateArtifact(event) end)

	self:UpdateArtifactDimensions()
	E:CreateMover(self.artifactBar, "ArtifactBarMover", L["Artifact Bar"])
	self:EnableDisable_ArtifactBar()
end