local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs

local StripAllTextures = {
	'RaidGroup1',
	'RaidGroup2',
	'RaidGroup3',
	'RaidGroup4',
	'RaidGroup5',
	'RaidGroup6',
	'RaidGroup7',
	'RaidGroup8',
}

function S:Blizzard_RaidUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.raid) then return end

	for _, object in pairs(StripAllTextures) do
		local obj = _G[object]
		if obj then
			obj:StripTextures()
		else
			E:Print(object)
		end
	end

	for i=1, _G.MAX_RAID_GROUPS*5 do
		S:HandleButton(_G['RaidGroupButton'..i], true)
	end

	for i=1,8 do
		for j=1,5 do
			_G['RaidGroup'..i..'Slot'..j]:StripTextures()
			_G['RaidGroup'..i..'Slot'..j]:SetTemplate('Transparent')
		end
	end
end

S:AddCallbackForAddon('Blizzard_RaidUI')
