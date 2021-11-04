local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame.RaisedElementParent)
	frame.LeaderIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.AssistantIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	if not E.Retail then frame.MasterLooterIndicator = anchor:CreateTexture(nil, 'OVERLAY') end

	anchor:Size(24, 12)
	anchor:SetFrameLevel(frame.RaisedElementParent.RaidRoleLevel)

	frame.LeaderIndicator:Size(12)
	frame.AssistantIndicator:Size(12)
	if not E.Retail then frame.MasterLooterIndicator:Size(12) end

	frame.LeaderIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.AssistantIndicator.PostUpdate = UF.RaidRoleUpdate
	if not E.Retail then frame.MasterLooterIndicator.PostUpdate = UF.RaidRoleUpdate end

	return anchor
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

	if frame.db.raidRoleIcons.enable then
		raidRoleFrameAnchor:Show()
		if not frame:IsElementEnabled('LeaderIndicator') then
			frame:EnableElement('LeaderIndicator')
			frame:EnableElement('AssistantIndicator')
			if not E.Retail then frame:EnableElement('MasterLooterIndicator') end
		end

		raidRoleFrameAnchor:ClearAllPoints()
		raidRoleFrameAnchor:Point(frame.db.raidRoleIcons.position, frame, frame.db.raidRoleIcons.position, frame.db.raidRoleIcons.xOffset, frame.db.raidRoleIcons.yOffset)
	elseif frame:IsElementEnabled('LeaderIndicator') then
		raidRoleFrameAnchor:Hide()
		frame:DisableElement('LeaderIndicator')
		frame:DisableElement('AssistantIndicator')
		if not E.Retail then frame:DisableElement('MasterLooterIndicator') end
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local frame = anchor:GetParent():GetParent()
	local leader = frame.LeaderIndicator
	local assistant = frame.AssistantIndicator
	local masterlooter = not E.Retail and frame.MasterLooterIndicator

	if not leader or not assistant or not masterlooter then return end

	local db = frame.db
	local isLeader = leader:IsShown()
	local isAssist = assistant:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()

	if db and db.raidRoleIcons then
		if isLeader then
			leader:Point(db.raidRoleIcons.position, anchor, db.raidRoleIcons.position, db.raidRoleIcons.xOffset, db.raidRoleIcons.yOffset)
		elseif isAssist then
			assistant:Point(db.raidRoleIcons.position, anchor, db.raidRoleIcons.position, db.raidRoleIcons.xOffset, db.raidRoleIcons.yOffset)
		end
	end
end
