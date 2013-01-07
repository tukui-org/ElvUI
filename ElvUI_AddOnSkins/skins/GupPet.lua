local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "GupPetSkin"
local function SkinGupPet(self,event)
	AS:SkinFrame(GupPet_InterfaceOptionsFrame)
	AS:SkinFrame(GupPet_InterfaceOptionsFrameOptions)
	AS:SkinFrame(GupPet_InterfaceOptionsFrameMountsCompanions)
	AS:SkinFrame(GupPet_InterfaceOptionsFrameHelp)

	S:HandleButton(GupPet_IngameFrameTemplateMoveBottomRight)
	S:HandleButton(GupPet_IngameFrameTemplateMoveTopRight)
	S:HandleButton(GupPet_IngameFrameTemplateMoveBottomLeft)
	S:HandleButton(GupPet_IngameFrameTemplateMoveTopLeft)

	AS:SkinIconButton(GupPet_IngameFrameTemplateAuto, true, true)
	AS:SkinIconButton(GupPet_IngameFrameTemplateCompanion, true, true)

	S:HandleTab(GupPet_InterfaceOptionsFrameTab1)
	S:HandleTab(GupPet_InterfaceOptionsFrameTab2)
	S:HandleTab(GupPet_InterfaceOptionsFrameTab3)
	S:HandleTab(GupPet_InterfaceOptionsFrameTab4)

	S:HandleTab(GupPet_InterfaceOptionsFrameMountsCompanionsLocationsTabAdd)
	S:HandleTab(GupPet_InterfaceOptionsFrameMountsCompanionsLocationsTabRemove)
	S:HandleTab(GupPet_InterfaceOptionsFrameMountsCompanionsMainTabAquatic)
	S:HandleTab(GupPet_InterfaceOptionsFrameMountsCompanionsMainTabGround)
	S:HandleTab(GupPet_InterfaceOptionsFrameMountsCompanionsMainTabFly)
	S:HandleTab(GupPet_InterfaceOptionsFrameMountsCompanionsMainTabCompanion)
end

AS:RegisterSkin(name,SkinGupPet)