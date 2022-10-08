local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local select = select

function S:Blizzard_ClassTalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local ClassTalentFrame = _G.ClassTalentFrame
	S:HandlePortraitFrame(ClassTalentFrame)

	S:HandleButton(ClassTalentFrame.TalentsTab.ApplyButton)
	S:HandleDropDownBox(ClassTalentFrame.TalentsTab.LoadoutDropDown.DropDownControl.DropDownMenu)

	S:HandleEditBox(ClassTalentFrame.TalentsTab.SearchBox)

	for i = 1, 2 do
		local tab = select(i, ClassTalentFrame.TabSystem:GetChildren())
		S:HandleTab(tab)
	end
end

S:AddCallbackForAddon('Blizzard_ClassTalentUI')
