local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local strfind = strfind
local CreateFrame = CreateFrame

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame.RaisedElementParent)
	frame.LeaderIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.AssistantIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.MasterLooterIndicator = anchor:CreateTexture(nil, 'OVERLAY')

	anchor:Size(24, 12)
	anchor:SetFrameLevel(frame.RaisedElementParent.RaidRoleLevel)

	frame.LeaderIndicator:Size(12)
	frame.AssistantIndicator:Size(12)
	frame.MasterLooterIndicator:Size(12)

	frame.LeaderIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.AssistantIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.MasterLooterIndicator.PostUpdate = UF.RaidRoleUpdate

	return anchor
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

	if frame.db.raidRoleIcons.enable then
		raidRoleFrameAnchor:Show()
		if not frame:IsElementEnabled('LeaderIndicator') then
			frame:EnableElement('LeaderIndicator')
			frame:EnableElement('AssistantIndicator')
			frame:EnableElement('MasterLooterIndicator')
		end

		raidRoleFrameAnchor:ClearAllPoints()
		raidRoleFrameAnchor:Point(frame.db.raidRoleIcons.position, frame, frame.db.raidRoleIcons.xOffset, frame.db.raidRoleIcons.yOffset)
	elseif frame:IsElementEnabled('LeaderIndicator') then
		raidRoleFrameAnchor:Hide()
		frame:DisableElement('LeaderIndicator')
		frame:DisableElement('AssistantIndicator')
		frame:DisableElement('MasterLooterIndicator')
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local frame = anchor:GetParent():GetParent()
	local leader = frame.LeaderIndicator
	local assistant = frame.AssistantIndicator
	local masterlooter = frame.MasterLooterIndicator

	if not leader or not assistant or not masterlooter then return end

	local db = frame.db
	local isLeader = leader:IsShown()
	local isAssist = assistant:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()
	masterlooter:ClearAllPoints()

	if db and db.raidRoleIcons then
		local pos, x, y = db.raidRoleIcons.position, db.raidRoleIcons.xOffset, db.raidRoleIcons.yOffset

		local right = strfind(pos, 'RIGHT')
		local pos1 = right and 'RIGHT' or 'LEFT'
		local pos2 = right and 'LEFT' or 'RIGHT'

		if isLeader then
			leader:Point(pos, anchor, x, y)
			masterlooter:Point(pos1, leader, pos2)
		elseif isAssist then
			assistant:Point(pos, anchor, x, y)
			masterlooter:Point(pos1, assistant, pos2)
		else
			masterlooter:Point(pos, anchor, x, y)
		end
	end
end
