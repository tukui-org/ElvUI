local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local CreateFrame = CreateFrame

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame.RaisedElementParent)
	frame.LeaderIndicator = anchor:CreateTexture(nil, 'OVERLAY')
	frame.AssistantIndicator = anchor:CreateTexture(nil, 'OVERLAY')

	anchor:SetSize(24, 12)
	frame.LeaderIndicator:SetSize(12, 12)
	frame.AssistantIndicator:SetSize(12, 12)

	frame.LeaderIndicator.PostUpdate = UF.RaidRoleUpdate
	frame.AssistantIndicator.PostUpdate = UF.RaidRoleUpdate

	return anchor
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

	if frame.db.raidRoleIcons.enable then
		raidRoleFrameAnchor:Show()
		if not frame:IsElementEnabled('LeaderIndicator') then
			frame:EnableElement('LeaderIndicator')
			frame:EnableElement('AssistantIndicator')
		end

		raidRoleFrameAnchor:ClearAllPoints()
		if frame.db.raidRoleIcons.position == 'TOPLEFT' then
			raidRoleFrameAnchor:SetPoint('LEFT', frame, 'TOPLEFT', frame.db.raidRoleIcons.xOffset, frame.db.raidRoleIcons.yOffset)
		else
			raidRoleFrameAnchor:SetPoint('RIGHT', frame, 'TOPRIGHT', -frame.db.raidRoleIcons.xOffset, frame.db.raidRoleIcons.yOffset)
		end
	elseif frame:IsElementEnabled('LeaderIndicator') then
		raidRoleFrameAnchor:Hide()
		frame:DisableElement('LeaderIndicator')
		frame:DisableElement('AssistantIndicator')
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local frame = anchor:GetParent():GetParent()
	local leader = frame.LeaderIndicator
	local assistant = frame.AssistantIndicator

	if not leader or not assistant then return; end

	local db = frame.db
	local isLeader = leader:IsShown()
	local isAssist = assistant:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()

	if db and db.raidRoleIcons then
		if isLeader and db.raidRoleIcons.position == 'TOPLEFT' then
			leader:SetPoint('LEFT', anchor, 'LEFT', db.raidRoleIcons.xOffset, db.raidRoleIcons.yOffset)
		elseif isLeader and db.raidRoleIcons.position == 'TOPRIGHT' then
			leader:SetPoint('RIGHT', anchor, 'RIGHT', -db.raidRoleIcons.xOffset, db.raidRoleIcons.yOffset)
		elseif isAssist and db.raidRoleIcons.position == 'TOPLEFT' then
			assistant:SetPoint('LEFT', anchor, 'LEFT', db.raidRoleIcons.xOffset, db.raidRoleIcons.yOffset)
		elseif isAssist and db.raidRoleIcons.position == 'TOPRIGHT' then
			assistant:SetPoint('RIGHT', anchor, 'RIGHT', -db.raidRoleIcons.xOffset, db.raidRoleIcons.yOffset)
		end
	end
end
