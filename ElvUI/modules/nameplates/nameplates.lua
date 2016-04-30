local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

local NamePlateDriverMixin = NamePlateDriverMixin

local DefaultCompactUnitFrameOptions = {
	displayNameWhenSelected = false,
	displayNameByPlayerNameRules = true,
}

function NP:ApplySettings(plate)
	local statusBarTex = LSM:Fetch("statusbar", self.db.statusbar)
	plate.UnitFrame.healthBar:SetStatusBarTexture(statusBarTex)
	plate.UnitFrame.castBar:SetStatusBarTexture(statusBarTex)
	
	local font, fontSize, fontOutline = LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline
	plate.UnitFrame.name:SetFont(font, fontSize, fontOutline)
	plate.UnitFrame.level:SetFont(font, fontSize, fontOutline)
	
	plate.UnitFrame.name:SetWordWrap(self.db.wrapName)
end

function NP:NAME_PLATE_CREATED(event, plate)
	local healthBar = plate.UnitFrame.healthBar
	local border = plate.UnitFrame.healthBar.border
	border:StripTextures(true)
	self.mult = E.mult * UIParent:GetScale()
	
	plate.UnitFrame.name:ClearAllPoints()
	plate.UnitFrame.name:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", 0, 2)
	plate.UnitFrame.name:SetJustifyH("LEFT")
	
	plate.UnitFrame.level = plate.UnitFrame:CreateFontString(nil, 'OVERLAY')
	plate.UnitFrame.level:SetPoint("BOTTOMRIGHT", healthBar, "TOPRIGHT", 0, 2)
	
	plate.UnitFrame.name:SetPoint("BOTTOMRIGHT", plate.UnitFrame.level, "BOTTOMLEFT")
	
	if(not border.bordertop) then
		border.bordertop = border:CreateTexture(nil, "BORDER")
		border.bordertop:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -self.mult, self.mult)
		border.bordertop:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", self.mult, self.mult)
		border.bordertop:SetHeight(self.mult)
		border.bordertop:SetColorTexture(unpack(E["media"].bordercolor))
		border.bordertop:SetDrawLayer("BORDER", 1)

		border.borderbottom = border:CreateTexture(nil, "BORDER")
		border.borderbottom:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", -self.mult, -self.mult)
		border.borderbottom:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", self.mult, -self.mult)
		border.borderbottom:SetHeight(self.mult)
		border.borderbottom:SetColorTexture(unpack(E["media"].bordercolor))
		border.borderbottom:SetDrawLayer("BORDER", 1)

		border.borderleft = border:CreateTexture(nil, "BORDER")
		border.borderleft:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -self.mult, self.mult)
		border.borderleft:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", self.mult, -self.mult)
		border.borderleft:SetWidth(self.mult)
		border.borderleft:SetColorTexture(unpack(E["media"].bordercolor))
		border.borderleft:SetDrawLayer("BORDER", 1)

		border.borderright = border:CreateTexture(nil, "BORDER")
		border.borderright:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", self.mult, self.mult)
		border.borderright:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", -self.mult, -self.mult)
		border.borderright:SetWidth(self.mult)
		border.borderright:SetColorTexture(unpack(E["media"].bordercolor))
		border.borderright:SetDrawLayer("BORDER", 1)
	end
	
	self:ApplySettings(plate)
end

function NP:NAME_PLATE_REMOVED(even, plate)

end

function NP:NAME_PLATE_UNIT_ADDED(event, unit)
	--Name
	local plate = C_NamePlate.GetNamePlateForUnit(unit)
	if(plate.UnitFrame.optionTable.displayNameWhenSelected) then
		plate.UnitFrame.optionTable.displayNameWhenSelected = false
		plate.UnitFrame.optionTable.displayName = true
		plate.UnitFrame.optionTable.displayNameByPlayerNameRules = false
		CompactUnitFrame_UpdateName(plate.UnitFrame)
	end

	--Level
	local level = UnitLevel(unit)
	local color = GetQuestDifficultyColor(level)
	plate.UnitFrame.level:SetText(level)
	plate.UnitFrame.level:SetTextColor(color.r, color.g, color.b)
end

function NP:NAME_PLATE_UNIT_REMOVED(event, unit)

end

function NP:UpdateSettings()

end

function NP:Initialize()
	self.db = E.db["nameplate"]
	if E.private["nameplate"].enable ~= true then return end
	E.NamePlates = NP
	
	self:RegisterEvent("NAME_PLATE_CREATED")
	self:RegisterEvent("NAME_PLATE_REMOVED")
	
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end


E:RegisterModule(NP:GetName())