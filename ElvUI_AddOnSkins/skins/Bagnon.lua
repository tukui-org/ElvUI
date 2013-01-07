
local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = 'BagnonSkin'
local function SkinBagnon(self,event)
	if event == "BANKFRAME_OPENED" then
		E:Delay(0, function()
			if BagnonFramebank then
				if not bagnonbankonce then
					bagnonbankonce = true
					AS:SkinFrame(BagnonFramebank)
					S:HandleCloseButton(BagnonFramebankCloseButton)
				end
			end
		end)
	elseif event == "GUILDBANKFRAME_OPENED" then
		if BagnonFrameguildbank then
			if not bagnonguildonce then
				bagnonguildonce = true
				AS:SkinFrame(BagnonFrameguildbank)
				S:HandleCloseButton(BagnonFrameguildbankCloseButton)
			end
		end
	elseif event == "VOID_STORAGE_OPEN" then
		if BagnonFramevoidstorage then
			if not bagnonvoidonce then
				bagnonvoidonce = true
				AS:SkinFrame(BagnonFramevoidstorage)
				S:HandleCloseButton(BagnonFramevoidstorageCloseButton)
			end
		end
	end
	E:Delay(0, function()
		if not bagnononce then
			bagnononce = true
			ToggleBackpack()
			if BagnonFrameinventory then
				AS:SkinFrame(BagnonFrameinventory)
				S:HandleCloseButton(BagnonFrameinventoryCloseButton)
			end
			ToggleBackpack()
		end
	end)
end
AS:RegisterSkin(name,SkinBagnon,"BANKFRAME_OPENED","GUILDBANKFRAME_OPENED","VOID_STORAGE_OPEN")