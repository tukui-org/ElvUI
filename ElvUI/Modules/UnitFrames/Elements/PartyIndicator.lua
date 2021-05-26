local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_PartyIndicator(frame)
	local PartyIndicator = CreateFrame('Frame', nil, frame.RaisedElementParent)

	local HomeIcon = PartyIndicator:CreateTexture(nil, 'OVERLAY', nil, 0)
	HomeIcon:Point('CENTER', 4, 4)
	HomeIcon:Size(26)

	local InstanceIcon = PartyIndicator:CreateTexture(nil, 'OVERLAY', nil, 1)
	InstanceIcon:Point('CENTER', 0, 0)
	InstanceIcon:Size(26)

	PartyIndicator.HomeIcon = HomeIcon
	PartyIndicator.InstanceIcon = InstanceIcon

	return PartyIndicator
end

function UF:Configure_PartyIndicator(frame)
	local db = frame and frame.db and frame.db.partyIndicator
	if not db then return end

	local PartyIndicator = frame.PartyIndicator
	PartyIndicator:ClearAllPoints()
	PartyIndicator:Point(db.anchorPoint, frame.Health, db.anchorPoint, db.xOffset, db.yOffset)
	PartyIndicator:Size(20 * (db.scale or 1))

	if frame.db.partyIndicator.enable and not frame:IsElementEnabled('PartyIndicator') then
		frame:EnableElement('PartyIndicator')
	elseif not frame.db.partyIndicator.enable and frame:IsElementEnabled('PartyIndicator') then
		frame:DisableElement('PartyIndicator')
	end
end
