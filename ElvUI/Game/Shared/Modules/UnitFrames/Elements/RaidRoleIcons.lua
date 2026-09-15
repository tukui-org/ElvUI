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
	frame.RaidRoleIndicator.PostUpdate = UF.RaidRoleUpdate

	return anchor
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

	local db = frame.db and frame.db.raidRoleIcons
	if db and db.enable then
		raidRoleFrameAnchor:Show()

		frame.LeaderIndicator.combatHide = db.combatHide
		frame.AssistantIndicator.combatHide = db.combatHide
		frame.MasterLooterIndicator.combatHide = db.combatHide
		frame.RaidRoleIndicator.combatHide = db.combatHide

		if not frame:IsElementEnabled('LeaderIndicator') then frame:EnableElement('LeaderIndicator') end
		if not frame:IsElementEnabled('AssistantIndicator') then frame:EnableElement('AssistantIndicator') end
		if not frame:IsElementEnabled('MasterLooterIndicator') then frame:EnableElement('MasterLooterIndicator') end
		if not frame:IsElementEnabled('RaidRoleIndicator') then frame:EnableElement('RaidRoleIndicator') end

		raidRoleFrameAnchor:ClearAllPoints()
		raidRoleFrameAnchor:Point(db.position, frame, db.xOffset, db.yOffset)
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

	local db = frame.db and frame.db.raidRoleIcons
	if db then
		local leader = frame.LeaderIndicator
		local assistant = frame.AssistantIndicator
		local masterLooter = frame.MasterLooterIndicator
		local raidRole = frame.RaidRoleIndicator

		local pos, x, y = db.position or 'TOPLEFT', db.xOffset or 0, db.yOffset or 4
		local size = 12 * (db.scale or 1)

		local right = strfind(pos, 'RIGHT')
		local pos1 = right and 'RIGHT' or 'LEFT'
		local pos2 = right and 'LEFT' or 'RIGHT'

		leader:Size(size)
		leader:ClearAllPoints()
		leader:Point(pos, anchor, x, y)

		assistant:Size(size)
		assistant:ClearAllPoints()
		assistant:Point(pos, anchor, x, y)

		local isMAMT = raidRole:IsShown()
		if isMAMT then -- assist / tank
			raidRole:Size(size)
			raidRole:ClearAllPoints()
			raidRole:Point(pos1, leader, pos2)
		end

		if masterLooter:IsShown() then
			masterLooter:Size(size)
			masterLooter:ClearAllPoints()

			if isMAMT then
				masterLooter:Point(pos1, raidRole, pos2)
			else
				masterLooter:Point(pos1, leader, pos2)
			end
		end
	end
end
