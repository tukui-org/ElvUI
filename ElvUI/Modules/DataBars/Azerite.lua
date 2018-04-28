local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions

--WoW API / Variables
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

function mod:UpdateAzerite()
	--if not mod.db.azerite.enable then return end

	local bar = self.azeriteBar
	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()

	if (not azeriteItemLocation) then
		return;
	end

	--XP
	xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)

	--Current Level
	currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

end

function mod:AzeriteBar_OnEnter()
	-- FILL ME
end

function mod:AzeriteBar_OnClick()
	-- FILL ME
end

function mod:UpdateaAzeriteDimensions()
	self.azeriteBar:Width(self.db.azerite.width)
	self.azeriteBar:Height(self.db.azerite.height)
	self.azeriteBar.statusBar:SetOrientation(self.db.azerite.orientation)
	self.azeriteBar.statusBar:SetReverseFill(self.db.azerite.reverseFill)

	if self.db.azerite.orientation == "HORIZONTAL" then
		self.azeriteBar.statusBar:SetRotatesTexture(false)
		self.azeriteBar.bagValue:SetRotatesTexture(false)
	else
		self.azeriteBar.statusBar:SetRotatesTexture(true)
		self.azeriteBar.bagValue:SetRotatesTexture(true)
	end

	self.azeriteBar.text:FontTemplate(LSM:Fetch("font", self.db.azerite.font), self.db.azerite.textSize, self.db.azerite.fontOutline)
	if self.db.azerite.mouseover then
		self.azeriteBar:SetAlpha(0)
	else
		self.azeriteBar:SetAlpha(1)
	end
end

function mod:EnableDisable_AzeriteBar()
	if self.db.azerite.enable then
		--Possible Events
		self:RegisterEvent("PLAYER_ENTERING_WORLD", _)
		self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", _)
		self:RegisterEvent("CVAR_UPDATE", _)

		self:UpdateAzerite()
		E:EnableMover(self.azeriteBar.mover:GetName())
	else
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
		self:UnregisterEvent("CVAR_UPDATE")

		self.azeriteBar:Hide()
		E:DisableMover(self.azeriteBar.mover:GetName())
	end
end

function mod:LoadAzeriteBar()
	self.azeriteBar = self:CreateBar('ElvUI_AzeriteBar', self.AzeriteBar_OnEnter, self.AzeriteBar_OnClick, 'RIGHT', self.honorBar, 'LEFT', E.Border - E.Spacing*3, 0)
	self.azeriteBar.statusBar:SetStatusBarColor(.901, .8, .601)
	self.azeriteBar.statusBar:SetMinMaxValues(0, 325)
	self.azeriteBar.statusBar:SetFrameLevel(self.azeriteBar:GetFrameLevel() + 2)

	self:UpdateArtifactDimensions()
	E:CreateMover(self.azeriteBar, "AzeriteBarMover", L["Azerite Bar"])
	self:EnableDisable_AzeriteBar()
end