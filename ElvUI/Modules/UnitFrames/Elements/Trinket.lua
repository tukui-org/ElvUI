local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local CreateFrame = CreateFrame

function UF:Construct_Trinket(frame)
	local trinket = CreateFrame('Frame', nil, frame)
	trinket.bg = CreateFrame('Frame', nil, trinket)
	trinket.bg:SetTemplate(nil, nil, nil, self.thinBorders, true)
	trinket.bg:SetFrameLevel(trinket:GetFrameLevel() - 1)
	trinket:SetInside(trinket.bg)

	return trinket
end

function UF:Configure_Trinket(frame)
	local db = frame.db
	local trinket = frame.Trinket

	trinket.bg:SetSize(db.pvpTrinket.size, db.pvpTrinket.size)
	trinket.bg:ClearAllPoints()
	if db.pvpTrinket.position == 'RIGHT' then
		trinket.bg:SetPoint('LEFT', frame, 'RIGHT', db.pvpTrinket.xOffset, db.pvpTrinket.yOffset)
	else
		trinket.bg:SetPoint('RIGHT', frame, 'LEFT', db.pvpTrinket.xOffset, db.pvpTrinket.yOffset)
	end

	if db.pvpTrinket.enable and not frame:IsElementEnabled('Trinket') then
		frame:EnableElement('Trinket')
	elseif not db.pvpTrinket.enable and frame:IsElementEnabled('Trinket') then
		frame:DisableElement('Trinket')
	end
end
