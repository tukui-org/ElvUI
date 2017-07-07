local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

--Cache global variables
--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit

local function HighlightUpdate(self)
	if not UnitExists("mouseover") or not self.unit or not UnitIsUnit("mouseover", self.unit) then
		self.Name.NameOnlyGlow:Hide()
		self.Highlight:Hide()
		self.Highlight.handler:SetScript("OnUpdate", nil)
	end
end

function mod:UpdateElement_Highlight(frame)
	if UnitIsUnit("mouseover", frame.unit) and not self.db.units[frame.UnitType].healthbar.enable and self.db.units[frame.UnitType].showName and not frame.isTarget then
		frame.Name.NameOnlyGlow:Show()
		frame.Highlight.handler:SetScript("OnUpdate", function() HighlightUpdate(frame) end)
	elseif UnitIsUnit("mouseover", frame.unit) and self.db.units[frame.UnitType].healthbar.enable and not frame.isTarget then
		frame.Highlight:ClearAllPoints()
		frame.Highlight:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT")
		frame.Highlight:SetPoint("BOTTOMRIGHT", frame.HealthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
		frame.Highlight:Show()
		frame.Highlight.handler:SetScript("OnUpdate", function() HighlightUpdate(frame) end)
	else
		frame.Name.NameOnlyGlow:Hide()
		frame.Highlight:Hide()
		frame.Highlight.handler:SetScript("OnUpdate", nil)
	end
end

function mod:ConstructElement_Highlight(frame)
	local f = frame.HealthBar:CreateTexture(nil, "ARTWORK", nil, 1)
	f.handler = CreateFrame("Frame")
	f:SetTexture(E["media"].normTex)
	f:SetVertexColor(1, 1, 1, .3)
	f:Hide()
	return f
end