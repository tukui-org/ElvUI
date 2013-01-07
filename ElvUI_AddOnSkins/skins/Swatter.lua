local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "SwatterSkin"
local function SkinSwatter(self)
	AS:SkinFrame(SwatterErrorFrame)
	S:HandleButton(Swatter.Error.Done)
	S:HandleButton(Swatter.Error.Next)
	S:HandleButton(Swatter.Error.Prev)
	S:HandleButton(Swatter.Drag)
	S:HandleScrollBar(SwatterErrorInputScrollScrollBar)
end

AS:RegisterSkin(name,SkinSwatter,'[!BugGrabber]','[!ImprovedErrorFrame]')