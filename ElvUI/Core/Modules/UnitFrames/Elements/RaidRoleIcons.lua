local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local strfind = strfind
local CreateFrame = CreateFrame

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame.RaisedElementParent)
	frame.LeaderIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.AssistantIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.MasterLooterIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.RaidRoleIndicator = anchor:CreateTexture(nil, 'OVERLAY')

	anchor:Size(36, 12)
	anchor:SetFrameLevel(frame.RaisedElementParent.RaidRoleLevel)

	frame.LeaderIndicator:Size(12)
	frame.AssistantIndicator:Size(12)
	frame.MasterLooterIndicator:Size(12)
	frame.RaidRoleIndicator:Size(12)

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
			frame:EnableElement('RaidRoleIndicator')
		end

		raidRoleFrameAnchor:ClearAllPoints()
		raidRoleFrameAnchor:Point(frame.db.raidRoleIcons.position, frame, frame.db.raidRoleIcons.xOffset, frame.db.raidRoleIcons.yOffset)
	elseif frame:IsElementEnabled('LeaderIndicator') then
		raidRoleFrameAnchor:Hide()
		frame:DisableElement('LeaderIndicator')
		frame:DisableElement('AssistantIndicator')
		frame:DisableElement('MasterLooterIndicator')
		frame:DisableElement('RaidRoleIndicator')
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local frame = anchor and anchor:GetParent():GetParent()
	if not frame then return end

	local leader = frame.LeaderIndicator
	local assistant = frame.AssistantIndicator
	local masterlooter = frame.MasterLooterIndicator
	local mamt = frame.RaidRoleIndicator

	local isLeader = leader:IsShown()
	local isAssist = assistant:IsShown()
	local isMAMT = mamt:IsShown()
	local isML = masterlooter:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()
	masterlooter:ClearAllPoints()
	mamt:ClearAllPoints()

	local db = frame.db and frame.db.raidRoleIcons
	if db then
		local pos, x, y = db.position or 'TOPLEFT', db.xOffset or 0, db.yOffset or 4
		local size = 12 * (db.scale or 1)

		local right = strfind(pos, 'RIGHT')
		local pos1 = right and 'RIGHT' or 'LEFT'
		local pos2 = right and 'LEFT' or 'RIGHT'

		leader:Size(size)
		assistant:Size(size)
		masterlooter:Size(size)
		mamt:Size(size)

		if isLeader then
			leader:Point(pos, anchor, x, y)
		elseif isAssist then
			assistant:Point(pos, anchor, x, y)
		end

		if isMAMT then
			if isLeader then
				mamt:Point(pos1, leader, pos2)
			elseif isAssist then
				mamt:Point(pos1, assistant, pos2)
			else
				mamt:Point(pos, anchor, x, y)
			end
		end

		if isML then
			if isMAMT then
				masterlooter:Point(pos1, mamt, pos2)
			elseif isLeader then
				masterlooter:Point(pos1, leader, pos2)
			elseif isAssist then
				masterlooter:Point(pos1, assistant, pos2)
			else
				masterlooter:Point(pos, anchor, x, y)
			end
		end
	end
end
