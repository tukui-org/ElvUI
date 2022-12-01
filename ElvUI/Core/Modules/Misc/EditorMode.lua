local E, L, V, P, G = unpack(ElvUI)
local EM = E:GetModule('EditorMode')

local _G = _G

local CheckTargetFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.target end
local CheckCastFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.castbar end
local CheckArenaFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.arena end
local CheckPartyFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.party end
local CheckFocusFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.focus end
local CheckRaidFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.raid end
local CheckBossFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.boss end
local CheckAuraFrame = function() return E.private.auras.disableBlizzard end
local CheckActionBar = function() return E.private.actionbar.enable end

function EM:Initialize()
	-- account settings will be tainted
	local mixin = _G.EditModeManagerFrame.AccountSettings
	if CheckCastFrame() then mixin.RefreshCastBar = E.noop end
	if CheckAuraFrame() then mixin.RefreshAuraFrame = E.noop end
	if CheckBossFrame() then mixin.RefreshBossFrames = E.noop end
	if CheckArenaFrame() then mixin.RefreshArenaFrames = E.noop end

	if CheckRaidFrame() then
		mixin.RefreshRaidFrames = E.noop
		mixin.ResetRaidFrames = E.noop
	end
	if CheckPartyFrame() then
		mixin.RefreshPartyFrames = E.noop
		mixin.ResetPartyFrames = E.noop
	end
	if CheckTargetFrame() and CheckFocusFrame() then
		mixin.RefreshTargetAndFocus = E.noop
		mixin.ResetTargetAndFocus = E.noop
	end

	if CheckActionBar() then
		mixin.RefreshVehicleLeaveButton = E.noop
		mixin.RefreshActionBarShown = E.noop
		mixin.RefreshEncounterBar = E.noop
	end
end

E:RegisterModule(EM:GetName())
