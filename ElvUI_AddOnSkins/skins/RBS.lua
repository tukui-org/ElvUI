local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "RaidBuffStatusSkin"
local function SkinRBS(self)
	AS:SkinFrame(RBSFrame)
	S:HandleButton(RBSFrameScanButton)
	S:HandleButton(RBSFrameReadyCheckButton)
	S:HandleButton(RBSFrameBossButton)
	S:HandleButton(RBSFrameTrashButton)
	S:HandleNextPrevButton(RBSFrameOptionsButton)
	S:HandleNextPrevButton(RBSFrameTalentsButton)
	RBSFrameOptionsButton:Size(20)
	RBSFrameTalentsButton:Size(20)
end

AS:RegisterSkin(name,SkinRBS)