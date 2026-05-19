local _, ns = ...
local oUF = ns.oUF

local wipe, next, type = wipe, next, type
local hooksecurefunc = hooksecurefunc

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local InCombatLockdown = InCombatLockdown
local _G = _G

-- sourced from Blizzard_UnitFrame/TargetFrame.lua
local MAX_BOSS_FRAMES = 5 -- blizzard can spawn more than the default 5 apparently

-- sourced from Blizzard_FrameXMLBase/Shared/Constants.lua
local MEMBERS_PER_RAID_GROUP = MEMBERS_PER_RAID_GROUP or 5

local hookedFrames = {}
local isArenaHooked = false
local isBossHooked = false
local isPartyHooked = false

local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local looseFrames = {}
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_REGEN_ENABLED')
watcher:SetScript('OnEvent', function()
	for frame in next, looseFrames do
		frame:SetParent(hiddenParent)
	end

	wipe(looseFrames)
end)

local function resetParent(self, parent)
	if(parent ~= hiddenParent) then
		if(InCombatLockdown() and self:IsProtected()) then
			looseFrames[self] = true
		else
			self:SetParent(hiddenParent)
		end
	end
end

local function handleFrame(baseName, doNotReparent)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		if(not doNotReparent) then
			frame:SetParent(hiddenParent)

			if(not hookedFrames[frame]) then
				hooksecurefunc(frame, 'SetParent', resetParent)

				hookedFrames[frame] = true
			end
		end

		local health = frame.healthBar or frame.healthbar or frame.HealthBar or (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar)
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar or frame.ManaBar
		if(power) then
			power:UnregisterAllEvents()
		end

		local castbar = frame.castBar or frame.spellbar or frame.CastingBarFrame
		if(castbar) then
			castbar:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt or frame.PowerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame or frame.AurasFrame
		if(buffFrame) then
			buffFrame:UnregisterAllEvents()
		end

		local petFrame = frame.petFrame or frame.PetFrame
		if(petFrame) then
			petFrame:UnregisterAllEvents()
		end

		local totFrame = frame.totFrame
		if(totFrame) then
			totFrame:UnregisterAllEvents()
		end

		local classPowerBar = frame.classPowerBar
		if(classPowerBar) then
			classPowerBar:UnregisterAllEvents()
		end

		local ccRemoverFrame = frame.CcRemoverFrame
		if(ccRemoverFrame) then
			ccRemoverFrame:UnregisterAllEvents()
		end

		local debuffFrame = frame.DebuffFrame
		if(debuffFrame) then
			debuffFrame:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == 'player') then
		handleFrame(_G.PlayerFrame)
	elseif(unit == 'pet') then
		handleFrame(_G.PetFrame)
	elseif(unit == 'target') then
		handleFrame(_G.TargetFrame)
	elseif(unit == 'focus') then
		handleFrame(_G.FocusFrame)
	elseif(unit:match('boss%d*$')) then
		if(not isBossHooked) then
			isBossHooked = true

			-- it's needed because the layout manager can bring frames that are
			-- controlled by containers back from the dead when a user chooses
			-- to revert all changes
			-- for now I'll just reparent it, but more might be needed in the
			-- future, watch it
			handleFrame(_G.BossTargetFrameContainer)

			-- do not reparent frames controlled by containers, the vert/horiz
			-- layout code will go insane because it won't be able to calculate
			-- the size properly, 0 or negative sizes in turn will break the
			-- layout manager, fun...
			for i = 1, MAX_BOSS_FRAMES do
				handleFrame('Boss' .. i .. 'TargetFrame', true)
			end
		end
	elseif(unit:match('party%d*$')) then
		if(not isPartyHooked) then
			isPartyHooked = true

			handleFrame(_G.PartyFrame)

			for frame in _G.PartyFrame.PartyMemberFramePool:EnumerateActive() do
				handleFrame(frame, true)
			end

			for i = 1, MEMBERS_PER_RAID_GROUP do
				handleFrame('CompactPartyFrameMember' .. i)
			end
		end
	elseif(unit:match('arena%d*$')) then
		if(not isArenaHooked) then
			isArenaHooked = true

			handleFrame(_G.CompactArenaFrame)

			for _, frame in next, _G.CompactArenaFrame.memberUnitFrames do
				handleFrame(frame, true)
			end
		end
	elseif(unit:match('nameplate%d+$')) then
		local frame = GetNamePlateForUnit(unit)
		if frame and frame.UnitFrame then
			handleFrame(frame.UnitFrame, true)
		end
	end
end
