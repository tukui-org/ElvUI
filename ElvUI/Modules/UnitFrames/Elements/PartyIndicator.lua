local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

function UF:Construct_PartyIndicator(frame)
	local PartyIndicatorFrame = CreateFrame('Frame', nil, frame.RaisedElementParent)
	
	local HomePartyIcon = PartyIndicatorFrame:CreateTexture(nil, 'OVERLAY', nil, 0)	
	local InstancePartyIcon = PartyIndicatorFrame:CreateTexture(nil, 'OVERLAY', nil, 1)
	
	
	HomePartyIcon:SetTexture([[Interface\FriendsFrame\UI-Toast-FriendOnlineIcon]])
	HomePartyIcon:Point('CENTER', 4, 4)
	HomePartyIcon:Size(26)
	
	InstancePartyIcon:SetTexture([[Interface\FriendsFrame\UI-Toast-FriendOnlineIcon]])
	InstancePartyIcon:Point('CENTER', 0, 0)
	InstancePartyIcon:Size(26)

	PartyIndicatorFrame.HomePartyIcon = HomePartyIcon
	PartyIndicatorFrame.InstancePartyIcon = InstancePartyIcon

	return PartyIndicatorFrame
end

function UF:Configure_PartyIndicator(frame)
	local PartyIndicatorFrame = frame.PartyIndicator
	PartyIndicatorFrame:ClearAllPoints()
	PartyIndicatorFrame:Point(frame.db.partyIndicator.anchorPoint, frame.Health, frame.db.partyIndicator.anchorPoint, frame.db.partyIndicator.xOffset, frame.db.partyIndicator.yOffset)

	local size = 20 * (frame.db.partyIndicator.scale or 1)
	PartyIndicatorFrame:Size(size)


	if frame.db.partyIndicator.enable and not frame:IsElementEnabled('PartyIndicator') then
		frame:EnableElement('PartyIndicator')
	elseif not frame.db.partyIndicator.enable and frame:IsElementEnabled('PartyIndicator') then
		frame:DisableElement('PartyIndicator')
	end

end
