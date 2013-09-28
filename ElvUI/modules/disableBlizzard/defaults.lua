local addonName, addon = ...
local defaults = addon:GetDefaults("private")

defaults.disableBlizzard = {
	actionBars = true,
	auras = true,
	playerFrame = true,
	targetFrame = true,
	petFrame = true,
	focusFrame = true,
	bossFrames = true,
	arenaFrames = true,
	partyFrames = true,
	raidFrames = true
}