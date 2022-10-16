local E, L, V, P, G = unpack(ElvUI)
local EM = E:GetModule('EditorMode')

local tremove = tremove
local strmatch = strmatch

local CheckActionBar = function() return E.private.actionbar.enable end

local IgnoreFrames = {
	--- MinimapCluster: header underneath and rotate minimap (will need to add the setting)
	MinimapCluster = function() return E.private.general.minimap.enable end,
	GameTooltipDefaultContainer = function() return E.private.tooltip.enable end,

	-- UnitFrames
	PlayerCastingBarFrame = function() return E.private.unitframe.disabledBlizzardFrames.castbar end,
	PlayerFrame = function() return E.private.unitframe.disabledBlizzardFrames.player end,
	PartyFrame = function() return E.private.unitframe.disabledBlizzardFrames.party end,
	TargetFrame = function() return E.private.unitframe.disabledBlizzardFrames.target end,
	FocusFrame = function() return E.private.unitframe.disabledBlizzardFrames.focus end,
	BossTargetFrameContainer = function() return E.private.unitframe.disabledBlizzardFrames.boss end,
	ArenaEnemyFramesContainer = function() return E.private.unitframe.disabledBlizzardFrames.arena end,
	CompactRaidFrameContainer = function() return E.private.unitframe.disabledBlizzardFrames.raid end,

	-- Auras
	BuffFrame = function() return E.private.auras.disableBlizzard and E.private.auras.enable and E.private.auras.buffsHeader end,
	DebuffFrame = function() return E.private.auras.disableBlizzard and E.private.auras.enable and E.private.auras.debuffsHeader end,

	-- ActionBars
	StanceBar = CheckActionBar,
	EncounterBar = CheckActionBar,
	PetActionBar = CheckActionBar, -- ??
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

	if E.private.auras.disableBlizzard then
		editMode.AccountSettings.RefreshAuraFrame = E.noop
	end

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
