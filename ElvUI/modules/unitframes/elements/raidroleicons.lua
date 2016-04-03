local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame)
	frame.Leader = anchor:CreateTexture(nil, 'OVERLAY')
	frame.Assistant = anchor:CreateTexture(nil, 'OVERLAY')
	frame.MasterLooter = anchor:CreateTexture(nil, 'OVERLAY')

	anchor:Size(24, 12)
	frame.Leader:Size(12)
	frame.Assistant:Size(12)
	frame.MasterLooter:Size(11)

	frame.Leader.PostUpdate = UF.RaidRoleUpdate
	frame.Assistant.PostUpdate = UF.RaidRoleUpdate
	frame.MasterLooter.PostUpdate = UF.RaidRoleUpdate

	return anchor
end

function UF:Configure_RaidRoleIcons(frame)
	local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

	if frame.db.raidRoleIcons.enable then
		raidRoleFrameAnchor:Show()
		if not frame:IsElementEnabled('Leader') then
			frame:EnableElement('Leader')
			frame:EnableElement('MasterLooter')
			frame:EnableElement('Assistant')
		end
		
		raidRoleFrameAnchor:ClearAllPoints()
		if frame.db.raidRoleIcons.position == 'TOPLEFT' then
			raidRoleFrameAnchor:Point('LEFT', frame.Health, 'TOPLEFT', 2, 0)
		else
			raidRoleFrameAnchor:Point('RIGHT', frame, 'TOPRIGHT', -2, 0)
		end
	elseif frame:IsElementEnabled('Leader') then
		raidRoleFrameAnchor:Hide()
		frame:DisableElement('Leader')
		frame:DisableElement('MasterLooter')
		frame:DisableElement('Assistant')
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local leader = anchor:GetParent().Leader
	local assistant = anchor:GetParent().Assistant
	local masterLooter = anchor:GetParent().MasterLooter

	if not leader or not masterLooter or not assistant then return; end

	local unit = anchor:GetParent().unit
	local db = anchor:GetParent().db
	local isLeader = leader:IsShown()
	local isMasterLooter = masterLooter:IsShown()
	local isAssist = assistant:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()
	masterLooter:ClearAllPoints()

	if db and db.raidRoleIcons then
		if isLeader and db.raidRoleIcons.position == 'TOPLEFT' then
			leader:Point('LEFT', anchor, 'LEFT')
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		elseif isLeader and db.raidRoleIcons.position == 'TOPRIGHT' then
			leader:Point('RIGHT', anchor, 'RIGHT')
			masterLooter:Point('LEFT', anchor, 'LEFT')
		elseif isAssist and db.raidRoleIcons.position == 'TOPLEFT' then
			assistant:Point('LEFT', anchor, 'LEFT')
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		elseif isAssist and db.raidRoleIcons.position == 'TOPRIGHT' then
			assistant:Point('RIGHT', anchor, 'RIGHT')
			masterLooter:Point('LEFT', anchor, 'LEFT')
		elseif isMasterLooter and db.raidRoleIcons.position == 'TOPLEFT' then
			masterLooter:Point('LEFT', anchor, 'LEFT')
		else
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		end
	end
end