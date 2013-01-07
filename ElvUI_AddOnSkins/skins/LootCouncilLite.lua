local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "LootCouncilLiteSkin"
local function SkinLootCouncilLite(self)
	AS:SkinFrame(RankFrame)
	S:HandleDropDownBox(RankDropDown)
	S:HandleButton(RankAcceptButton)
	S:HandleButton(RankCancelButton)
	AS:SkinFrame(MainFrame)
	AS:SkinFrame(EntryFrame)
	AS:SkinFrame(LCTestFrame)
	S:HandleButton(CloseButton)
	S:HandleButton(RunTestButton)
	S:HandleButton(TestCancelButton)
	S:HandleButton(AbortButton)

	for i = 1,40 do
		if _G["EntryFrameEntry"..i.."AgainstButton"] then S:HandleCloseButton(_G["EntryFrameEntry"..i.."AgainstButton"]) end
		if _G["EntryFrameEntry"..i.."ForButton"] then AS:Desaturate(_G["EntryFrameEntry"..i.."ForButton"]) end
		if _G["EntryFrameEntry"..i.."CancelButton"] then AS:Desaturate(_G["EntryFrameEntry"..i.."CancelButton"]) end
	end
end

AS:RegisterSkin(name,SkinLootCouncilLite)