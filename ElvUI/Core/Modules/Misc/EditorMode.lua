local E, L, V, P, G = unpack(ElvUI)
local EM = E:GetModule('EditorMode')

local tremove = tremove
local strmatch = strmatch

local CheckCastFrame = function() return E.private.unitframe.disabledBlizzardFrames.castbar end
local CheckRaidFrame = function() return E.private.unitframe.disabledBlizzardFrames.raid end
local CheckBossFrame = function() return E.private.unitframe.disabledBlizzardFrames.boss end
local CheckArenaFrame = function() return E.private.unitframe.disabledBlizzardFrames.arena end
local CheckTargetFrame = function() return E.private.unitframe.disabledBlizzardFrames.target end
local CheckPartyFrame = function() return E.private.unitframe.disabledBlizzardFrames.party end
local CheckFocusFrame = function() return E.private.unitframe.disabledBlizzardFrames.focus end
local CheckAuraFrame = function() return E.private.auras.disableBlizzard end
local CheckActionBar = function() return E.private.actionbar.enable end

local IgnoreFrames = {
	--- MinimapCluster: header underneath and rotate minimap (will need to add the setting)
	MinimapCluster = function() return E.private.general.minimap.enable end,
	GameTooltipDefaultContainer = function() return E.private.tooltip.enable end,

	-- UnitFrames
	PlayerCastingBarFrame = CheckCastFrame,
	PlayerFrame = function() return E.private.unitframe.disabledBlizzardFrames.player end,
	PartyFrame = CheckPartyFrame,
	TargetFrame = CheckTargetFrame,
	FocusFrame = CheckFocusFrame,
	ArenaEnemyFramesContainer = CheckArenaFrame,
	CompactRaidFrameContainer = CheckRaidFrame,
	BossTargetFrameContainer = CheckBossFrame,

	-- Auras
	BuffFrame = function() return E.private.auras.disableBlizzard and E.private.auras.enable and E.private.auras.buffsHeader end,
	DebuffFrame = function() return E.private.auras.disableBlizzard and E.private.auras.enable and E.private.auras.debuffsHeader end,

	-- ActionBars
	StanceBar = CheckActionBar,
	EncounterBar = CheckActionBar,
	PetActionBar = CheckActionBar,
	PossessActionBar = CheckActionBar,
	MainMenuBarVehicleLeaveButton = CheckActionBar,
	MultiBarBottomLeft = CheckActionBar,
	MultiBarBottomRight = CheckActionBar,
	MultiBarLeft = CheckActionBar,
	MultiBarRight = CheckActionBar,
	MultiBar5 = CheckActionBar,
	MultiBar6 = CheckActionBar,
	MultiBar7 = CheckActionBar
}

local PatternFrames = {
	['^ChatFrame%d+'] = function() return E.private.chat.enable end,
}

function EM:Initialize()
	local editMode = _G.EditModeManagerFrame

	-- account settings will be tainted
	local mixin = editMode.AccountSettings
	if CheckBossFrame then mixin.RefreshBossFrames = E.noop end
	if CheckRaidFrame then mixin.RefreshRaidFrames = E.noop end
	if CheckArenaFrame then mixin.RefreshArenaFrames = E.noop end
	if CheckCastFrame then mixin.RefreshCastBar = E.noop end
	if CheckAuraFrame then mixin.RefreshAuraFrame = E.noop end
	if CheckPartyFrame then mixin.RefreshPartyFrames = E.noop end
	if CheckTargetFrame or CheckFocusFrame then mixin.RefreshTargetAndFocus = E.noop end
	if CheckActionBar then
		mixin.RefreshVehicleLeaveButton = E.noop
		mixin.RefreshActionBarShown = E.noop
		mixin.RefreshEncounterBar = E.noop
	end

	-- remove the initial registers
	local frames = editMode.registeredSystemFrames
	for index, frame in next, frames do
		local frameName = frame:GetName()
		local ignoreFunc = IgnoreFrames[frameName]
		if ignoreFunc and ignoreFunc() then
			tremove(frames, index)
		end

		for pattern, patternFunc in next, PatternFrames do
			if strmatch(frameName, pattern) and patternFunc() then
				tremove(frames, index)
			end
		end
	end
end

E:RegisterModule(EM:GetName())
