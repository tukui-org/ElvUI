local E, L, V, P, G = unpack(ElvUI)
local EM = E:GetModule('EditorMode')

local _G = _G
local tremove = tremove

local CheckTargetFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.target end
local CheckCastFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.castbar end
local CheckArenaFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.arena end
local CheckPartyFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.party end
local CheckFocusFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.focus end
local CheckRaidFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.raid end
local CheckBossFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.boss end
local CheckAuraFrame = function() return E.private.auras.disableBlizzard end
local CheckActionBar = function() return E.private.actionbar.enable end

local IgnoreFrames = {
	MinimapCluster = function() return E.private.general.minimap.enable end, -- header underneath and rotate minimap (will need to add the setting)
	GameTooltipDefaultContainer = function() return E.private.tooltip.enable end,

	-- UnitFrames
	PartyFrame = CheckPartyFrame,
	FocusFrame = CheckFocusFrame,
	TargetFrame = CheckTargetFrame,
	PlayerCastingBarFrame = CheckCastFrame,
	ArenaEnemyFramesContainer = CheckArenaFrame,
	CompactRaidFrameContainer = CheckRaidFrame,
	BossTargetFrameContainer = CheckBossFrame,
	PlayerFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.player end,

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

function EM:Initialize()
	local editMode = _G.EditModeManagerFrame

	-- remove the initial registers
	local registered = editMode.registeredSystemFrames
	for i = #registered, 1, -1 do
		local name = registered[i]:GetName()
		local ignore = IgnoreFrames[name]

		if ignore and ignore() then
			tremove(editMode.registeredSystemFrames, i)
		end
	end

	-- account settings will be tainted
	local mixin = editMode.AccountSettings
	if CheckCastFrame() then mixin.RefreshCastBar = E.noop end
	if CheckAuraFrame() then mixin.RefreshAuraFrame = E.noop end
	if CheckBossFrame() then mixin.RefreshBossFrames = E.noop end
	if CheckRaidFrame() then mixin.RefreshRaidFrames = E.noop end
	if CheckArenaFrame() then mixin.RefreshArenaFrames = E.noop end
	if CheckPartyFrame() then mixin.RefreshPartyFrames = E.noop end
	if CheckTargetFrame() and CheckFocusFrame() then mixin.RefreshTargetAndFocus = E.noop end -- technically dont need this
	if CheckActionBar() then
		mixin.RefreshVehicleLeaveButton = E.noop
		mixin.RefreshActionBarShown = E.noop
		mixin.RefreshEncounterBar = E.noop
	end
end

E:RegisterModule(EM:GetName())
