local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteEssence ~= true then return end
	if not C_AzeriteEssence.CanOpenUI() then return end
	--Probably Temp name
	local AzeriteEssenceUI = _G.AzeriteEssenceUI
	S:HandlePortraitFrame(AzeriteEssenceUI, true)
	S:HandleScrollBar(AzeriteEssenceUI.ScrollFrame.ScrollBar)

	--[[
	for _, Slot in pairs(AzeriteEssenceUI.SlotsFrame.Slots) do
	end
	]]
end

S:AddCallbackForAddon("Blizzard_AzeriteEssenceUI", "AzeriteEssenceUI", LoadSkin)
