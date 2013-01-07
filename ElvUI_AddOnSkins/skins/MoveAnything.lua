local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "MoveAnythingSkin"
local function SkinMoveAnything(self)
	AS:SkinFrame(MAOptions)
	MAScrollBorder:StripTextures(True)

	S:HandleScrollBar(MAScrollFrameScrollBar)
	S:HandleButton(MAOptionsSync)
	S:HandleButton(MAOptionsOpenBlizzardOptions)
	S:HandleButton(MAOptionsClose)
	S:HandleButton(GameMenuButtonMoveAnything)
	GameMenuButtonMoveAnything:CreateBackdrop("Transparent")
	GameMenuButtonMoveAnything:ClearAllPoints()
	GameMenuButtonMoveAnything:Point("TOP", GameMenuFrame, "BOTTOM", 0, -3)

	S:HandleCheckBox(MAOptionsToggleModifiedFramesOnly)
	S:HandleCheckBox(MAOptionsToggleCategories)
	S:HandleCheckBox(MAOptionsToggleFrameStack)
	S:HandleCheckBox(MAOptionsToggleMovers)
	S:HandleCheckBox(MAOptionsToggleFrameEditors)

	for i = 1, 100 do
		if _G["MAMove"..i.."Reset"] then S:HandleButton(_G["MAMove"..i.."Reset"]) end
		if _G["MAMove"..i.."Reset"] then S:HandleButton(_G["MAMove"..i.."Reset"]) end
		if _G["MAMove"..i.."Backdrop"] then AS:SkinFrame(_G["MAMove"..i.."Backdrop"]) end
		if _G["MAMove"..i.."Move"] then S:HandleCheckBox(_G["MAMove"..i.."Move"]) end
		if _G["MAMove"..i.."Hide"] then S:HandleCheckBox(_G["MAMove"..i.."Hide"]) end
	end

	AS:SkinFrame(MANudger)
	S:HandleButton(MANudger_CenterMe)
	S:HandleButton(MANudger_CenterH)
	S:HandleButton(MANudger_CenterV)
	S:HandleButton(MANudger_NudgeUp)
	S:HandleButton(MANudger_NudgeDown)
	S:HandleButton(MANudger_NudgeLeft)
	S:HandleButton(MANudger_NudgeRight)
	S:HandleButton(MANudger_Detach)
	S:HandleButton(MANudger_Hide)
end

AS:RegisterSkin(name,SkinMoveAnything)