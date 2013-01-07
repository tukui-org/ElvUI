local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = 'AdiBagsSkin'
local function SkinFrame(frame)
	local region = frame.HeaderRightRegion
	frame:StripTextures()
	frame:SetTemplate('Transparent')
	_G[frame:GetName()..'Bags']:StripTextures()
	_G[frame:GetName()..'Bags']:SetTemplate('Transparent')
	S:HandleCloseButton(frame.CloseButton)
	for i = 1, 3 do
		S:HandleButton(region.widgets[i].widget, true)
	end
end

local function AdiSkin(self,event)
	E:Delay(0, function()
		if event == 'PLAYER_ENTERING_WORLD' then
			if not AdiBagsContainer1 then ToggleBackpack() ToggleBackpack() end
			if AdiBagsContainer1 then
				SkinFrame(AdiBagsContainer1)
				S:HandleEditBox(AdiBagsContainer1SearchBox)
				AdiBagsContainer1SearchBox:Point("TOPRIGHT", AdiBagsSimpleLayeredRegion2, "TOPRIGHT", -75, -1)
			end
		end
	end)
	if event == 'BANKFRAME_OPENED' then
		E:Delay(0, function()
			SkinFrame(AdiBagsContainer2)
			AS:UnregisterEvent("BANKFRAME_OPENED")
		end)
	end
end

AS:RegisterSkin(name,AdiSkin,"BANKFRAME_OPENED")