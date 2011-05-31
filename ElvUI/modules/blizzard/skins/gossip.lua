local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].gossip ~= true then return end

local function LoadSkin()
	ItemTextFrame:StripTextures(true)
	ItemTextScrollFrame:StripTextures()
	ItemTextFrame:SetTemplate("Transparent")
	E.SkinCloseButton(ItemTextCloseButton)
	E.SkinNextPrevButton(ItemTextPrevPageButton)
	E.SkinNextPrevButton(ItemTextNextPageButton)
	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = E.dummy
	
	local StripAllTextures = {
		"GossipFrameGreetingPanel",
	}			

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local KillTextures = {
		"GossipFramePortrait",
	}

	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end

	local buttons = {
		"GossipFrameGreetingGoodbyeButton",
	}

	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures()
		E.SkinButton(_G[buttons[i]])
	end


	for i = 1, NUMGOSSIPBUTTONS do
		obj = select(3,_G["GossipTitleButton"..i]:GetRegions())
		obj:SetTextColor(1,1,1)
	end

	GossipGreetingText:SetTextColor(1,1,1)
	GossipFrame:CreateBackdrop("Transparent")
	GossipFrame.backdrop:Point("TOPLEFT", GossipFrame, "TOPLEFT", 15, -20)
	GossipFrame.backdrop:Point("BOTTOMRIGHT", GossipFrame, "BOTTOMRIGHT", -30, 65)
	E.SkinCloseButton(GossipFrameCloseButton,GossipFrame.backdrop)
	
	
	--Extreme hackage, blizzard makes button text on quest frame use hex color codes for some reason
	hooksecurefunc("GossipFrameUpdate", function()
		for i=1, NUMGOSSIPBUTTONS do
			local button = _G["GossipTitleButton"..i]
			
			if button:GetFontString() then
				if button:GetFontString():GetText() and button:GetFontString():GetText():find("|cff000000") then
					button:GetFontString():SetText(string.gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)	
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)