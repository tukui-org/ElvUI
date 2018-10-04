local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitAura = UnitAura

--Cache detection buff names
local DETECTION_BUFFS = {
	[203761] = true, --Detector
	[213486] = true, --Demonic Vision
}

function mod:UpdateElement_Detection(frame)
	if not (self.db.units[frame.UnitType].detection and self.db.units[frame.UnitType].detection.enable and frame.displayedUnit) then return end

	local canDetect
	for i=1, BUFF_MAX_DISPLAY do
		local name, _, _, _, _, _, _, _, _, spellId = UnitAura(frame.displayedUnit, i, 'HELPFUL')
		if not name then break end
		if spellId and DETECTION_BUFFS[spellId] then
			canDetect = true
			break
		end
	end

	if canDetect then
		frame.DetectionModel:Show()
		frame.DetectionModel:SetModel("Spells\\Blackfuse_LaserTurret_GroundBurn_State_Base")
	end
end

function mod:ConfigureElement_Detection(frame)
	if not (self.db.units[frame.UnitType].detection and self.db.units[frame.UnitType].detection.enable) then
		return;
	end

	frame.DetectionModel:ClearAllPoints()
	frame.DetectionModel:Point("BOTTOM", frame.TopLevelFrame or frame.Name, "TOP", 0, 0)
end

function mod:ConstructElement_Detection(frame)
	local model = CreateFrame("PlayerModel", nil, frame)
	model:Size(75, 75)
	model:Point("BOTTOM", frame, "TOP", 0, 0)
	model:SetFrameStrata("LOW") --HealthBar is on BACKGROUND
	model:SetPosition(3, 0, 1.25) --Zoom in
	model:Hide()

	return model
end
