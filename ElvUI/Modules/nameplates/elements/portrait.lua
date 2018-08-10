local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local SetPortraitTexture = SetPortraitTexture

function mod:UpdateElement_Portrait(frame, trigger)
	if not (self.db.units[frame.UnitType].portrait and (self.db.units[frame.UnitType].portrait.enable or trigger)) then
		return;
	end

	if(not UnitExists(frame.unit) or not UnitIsConnected(frame.unit) or not UnitIsVisible(frame.unit)) then
		--frame.Portrait:SetUnit("")
		--frame.Portrait.texture:SetTexture(nil) --this must be nil, "" will do nothing
		frame.Portrait:Hide()
	else
		--frame.Portrait:SetUnit(frame.unit)
		frame.Portrait:Show()
		SetPortraitTexture(frame.Portrait.texture, frame.unit)
	end

	mod:UpdateElement_HealerIcon(frame)
end

function mod:ConfigureElement_Portrait(frame, triggered)
	if not triggered then
		if not (self.db.units[frame.UnitType].portrait) then return end
		frame.Portrait:SetWidth(self.db.units[frame.UnitType].portrait.width)
		frame.Portrait:SetHeight(self.db.units[frame.UnitType].portrait.height)
	end

	frame.Portrait:ClearAllPoints()
	if frame.PowerBar:IsShown() then
		frame.Portrait:SetPoint("TOPRIGHT", frame.HealthBar, "TOPLEFT", -6, 2)
	elseif frame.HealthBar:IsShown() then
		frame.Portrait:SetPoint("RIGHT", frame.HealthBar, "LEFT", -6, 0)
	else
		frame.Portrait:SetPoint("BOTTOM", frame.Name, "TOP", 0, 3)
	end
end

function mod:ConstructElement_Portrait(frame)
	frame = CreateFrame("Frame", nil, frame)
	self:StyleFrame(frame)
	frame.texture = frame:CreateTexture(nil, "OVERLAY")
	frame.texture:SetAllPoints()
	frame.texture:SetTexCoord(.18, .82, .18, .82)

	frame:SetPoint("TOPRIGHT", frame.HealthBar, "TOPLEFT", -E.Border, 0)
	frame:Hide()

	return frame
end
