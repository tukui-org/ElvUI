local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_PingIndicator(frame)
	local pingIndicator = CreateFrame('Frame', nil, frame.RaisedElementParent.TextureParent)
	pingIndicator:Size(30)
	pingIndicator:Hide()

	local background = pingIndicator:CreateTexture(nil, 'OVERLAY', nil, 6)
	background:SetAllPoints()
	pingIndicator.Background = background

	local icon = pingIndicator:CreateTexture(nil, 'OVERLAY', nil, 7)
	icon:SetAllPoints()
	pingIndicator.Icon = icon

	return pingIndicator
end

function UF:Configure_PingIndicator(frame)
	local pingIndicator = frame.PingIndicator
	local db = frame.db.pingIcon
	if not db then return end

	if db.enable then
		if not frame:IsElementEnabled('PingIndicator') then
			frame:EnableElement('PingIndicator')
		end

		local attachPoint = UF:GetObjectAnchorPoint(frame, db.attachToObject)
		pingIndicator:ClearAllPoints()
		pingIndicator:Point(db.attachTo, attachPoint, db.attachTo, db.xOffset, db.yOffset)
		pingIndicator:Size(db.size)
	else
		frame:DisableElement('PingIndicator')
		pingIndicator:Hide()
	end
end
