local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');
local LSM = LibStub("LibSharedMedia-3.0")
local LAP = LibStub("LibArtifactPower-1.0-ElvUI")

--Cache global variables
--Lua functions
local _G = _G
local floor = floor
local tonumber, select = tonumber, select
local format, split = string.format, string.split
--WoW API / Variables
local C_ArtifactUI_GetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerNumSlots = GetContainerNumSlots
local HasArtifactEquipped = HasArtifactEquipped
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local ShowUIPanel = ShowUIPanel
local SocketInventoryItem = SocketInventoryItem
local ARTIFACT_POWER = ARTIFACT_POWER
local ARTIFACT_POWER_TOOLTIP_BODY = ARTIFACT_POWER_TOOLTIP_BODY

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, CreateFrame, ArtifactFrame, UIParent

function mod:UpdateArtifact(event, unit)
	if not mod.db.artifact.enable then return end
	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		--We only need to scan bags once on this event, not on every load screen
		self.artifactBar.eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

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
		local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo();
		local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier);

		--Damn fishing artifacts and its inconsistent returns
		if xpForNextPoint <= 0 then
			xpForNextPoint = xp
		end

		bar.statusBar:SetMinMaxValues(0, xpForNextPoint)
		bar.statusBar:SetValue(xp)

		local BagValue = self:GetArtifactPowerInBags()
		if(BagValue and BagValue > 0) then
			self.artifactBar.bagValue:SetMinMaxValues(0, xpForNextPoint)
			self.artifactBar.bagValue:SetValue(xp + BagValue)
		else
			self.artifactBar.bagValue:SetMinMaxValues(0, 1)
			self.artifactBar.bagValue:SetValue(0)
		end

		local textFormat = self.db.artifact.textFormat
		if textFormat == 'PERCENT' then
			text = format('%s%%', floor(xp / xpForNextPoint * 100))
		elseif textFormat == 'CURMAX' then
			text = format('%s - %s', E:ShortValue(xp), E:ShortValue(xpForNextPoint))
		elseif textFormat == 'CURPERC' then
			text = format('%s - %s%%', E:ShortValue(xp), floor(xp / xpForNextPoint * 100))
		elseif textFormat == 'CUR' then
			text = format('%s', E:ShortValue(totalXP))
		elseif textFormat == 'REM' then
			text = format('%s', E:ShortValue(xpForNextPoint - xp))
		elseif textFormat == 'CURREM' then
			text = format('%s - %s', E:ShortValue(xp), E:ShortValue(xpForNextPoint - xp))
		elseif textFormat == 'CURPERCREM' then
			text = format('%s - %s%% (%s)', E:ShortValue(xp), floor(xp / xpForNextPoint * 100), E:ShortValue(xpForNextPoint - xp))
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

	local _, _, artifactName, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo();
	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier);

	GameTooltip:AddDoubleLine(ARTIFACT_POWER, artifactName, nil, nil, nil, 0.90, 0.80, 0.50)
	GameTooltip:AddLine(' ')

	--Damn fishing artifacts and its inconsistent returns
	if xpForNextPoint <= 0 then
		xpForNextPoint = xp
	end

	local remaining = xpForNextPoint - xp
	local apInBags = self.BagArtifactPower

	GameTooltip:AddDoubleLine(L["AP:"], format(' %s / %s (%s%%)', E:ShortValue(xp), E:ShortValue(xpForNextPoint), floor(xp / xpForNextPoint * 100)), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Remaining:"], format(' %s (%s%% - %s %s)', E:ShortValue(xpForNextPoint - xp), floor(remaining / xpForNextPoint * 100), floor(20 * remaining / xpForNextPoint), L["Bars"]), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["In Bags:"], format(' %s (%s%% - %s %s)', E:ShortValue(apInBags), floor(apInBags / xpForNextPoint * 100), floor(20 * apInBags / xpForNextPoint), L["Bars"]), 1, 1, 1)
	if (numPointsAvailableToSpend > 0) then
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(format(ARTIFACT_POWER_TOOLTIP_BODY, numPointsAvailableToSpend), nil, nil, nil, true)
	end

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
	self.artifactBar.bagValue:SetOrientation(self.db.artifact.orientation)
	self.artifactBar.bagValue:SetReverseFill(self.db.artifact.reverseFill)

	if self.db.artifact.orientation == "HORIZONTAL" then
		self.artifactBar.statusBar:SetRotatesTexture(false)
		self.artifactBar.bagValue:SetRotatesTexture(false)
	else
		self.artifactBar.statusBar:SetRotatesTexture(true)
		self.artifactBar.bagValue:SetRotatesTexture(true)
	end

	self.artifactBar.text:FontTemplate(LSM:Fetch("font", self.db.artifact.font), self.db.artifact.textSize, self.db.artifact.fontOutline)
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
		self:RegisterEvent("BAG_UPDATE_DELAYED", 'UpdateArtifact')

		self:UpdateArtifact()
		E:EnableMover(self.artifactBar.mover:GetName())
	else
		self:UnregisterEvent('ARTIFACT_XP_UPDATE')
		self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
		self:UnregisterEvent("BAG_UPDATE_DELAYED")

		self.artifactBar:Hide()
		E:DisableMover(self.artifactBar.mover:GetName())
	end
end

function mod:GetKnowledgeLevelFromItemLink(itemLink)
	local upgradeID = select(15, split(":", itemLink))
	local knowledgeLevel = tonumber(upgradeID) - 1 --Don't ask why, that's just how it is.

	return knowledgeLevel
end

local apItemCache = {}

function mod:GetAPForItem(itemLink)

	--Return cached item if possible
	if (apItemCache[itemLink] ~= nil) then
		return apItemCache[itemLink]
	end

	if (LAP:DoesItemGrantArtifactPower(itemLink)) then
		local knowledgeLevel = self:GetKnowledgeLevelFromItemLink(itemLink)
		local apValue = LAP:GetArtifactPowerGrantedByItem(itemLink, knowledgeLevel)

		--Cache item
		apItemCache[itemLink] = apValue

		return apValue
	end

	return 0
end

function mod:GetArtifactPowerInBags()
	self.artifactBar.BagArtifactPower = 0
	local itemLink, AP
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			itemLink = select(7, GetContainerItemInfo(bag, slot))

			if (itemLink) then
				AP = self:GetAPForItem(itemLink)
				self.artifactBar.BagArtifactPower = self.artifactBar.BagArtifactPower + AP
			end
		end
	end

	return self.artifactBar.BagArtifactPower
end

function mod:LoadArtifactBar()
	self.artifactBar = self:CreateBar('ElvUI_ArtifactBar', self.ArtifactBar_OnEnter, self.ArtifactBar_OnClick, 'RIGHT', self.honorBar, 'LEFT', E.Border - E.Spacing*3, 0)
	self.artifactBar.statusBar:SetStatusBarColor(.901, .8, .601)
	self.artifactBar.statusBar:SetMinMaxValues(0, 325)
	self.artifactBar.statusBar:SetFrameLevel(self.artifactBar:GetFrameLevel() + 2)

	self.artifactBar.eventFrame = CreateFrame("Frame")
	self.artifactBar.eventFrame:Hide()
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.artifactBar.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.artifactBar.eventFrame:SetScript("OnEvent", function(self, event) mod:UpdateArtifact(event) end)

	self.artifactBar.bagValue = CreateFrame("StatusBar", nil, self.artifactBar)
	self.artifactBar.bagValue:SetAllPoints(self.artifactBar.statusBar)
	self.artifactBar.bagValue:SetStatusBarTexture(E['media'].normTex)
	self.artifactBar.bagValue:SetStatusBarColor(0, 0.43, 0.95)
	self.artifactBar.bagValue:SetFrameStrata("LOW")
	self.artifactBar.bagValue:SetMinMaxValues(0, 1)
	self.artifactBar.bagValue:SetValue(0)
	self.artifactBar.bagValue:SetFrameLevel(self.artifactBar:GetFrameLevel() + 1)
	self.artifactBar.BagArtifactPower = 0

	self.artifactBar.tooltip = CreateFrame("GameTooltip", "BagArtifactPowerTooltip", UIParent, "GameTooltipTemplate")
	self.artifactBar.tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	self.artifactBar.tooltipLines = {}
	for i = 1, 5 do
		self.artifactBar.tooltipLines[i] = _G[format("BagArtifactPowerTooltipTextLeft%d", i)]
	end

	self:UpdateArtifactDimensions()
	E:CreateMover(self.artifactBar, "ArtifactBarMover", L["Artifact Bar"])
	self:EnableDisable_ArtifactBar()
end