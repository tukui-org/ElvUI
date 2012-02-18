local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.db.skins.blizzard.enable ~= true or E.db.skins.blizzard.guildcontrol ~= true then return end
	GuildControlUI:StripTextures()
	GuildControlUIHbar:StripTextures()
	GuildControlUI:SetTemplate("Transparent")
	GuildControlUI:CreateShadow("Default")
	
	local function SkinGuildRanks()
		for i=1, GuildControlGetNumRanks() do
			local rankFrame = _G["GuildControlUIRankOrderFrameRank"..i]
			if rankFrame then
				S:HandleButton(rankFrame.downButton)
				S:HandleButton(rankFrame.upButton)
				S:HandleButton(rankFrame.deleteButton)
				
				if not rankFrame.nameBox.backdrop then
					S:HandleEditBox(rankFrame.nameBox)
				end
				
				rankFrame.nameBox.backdrop:Point("TOPLEFT", -2, -4)
				rankFrame.nameBox.backdrop:Point("BOTTOMRIGHT", -4, 4)
			end
		end				
	end
	hooksecurefunc("GuildControlUI_RankOrder_Update", SkinGuildRanks)
	GuildControlUIRankOrderFrameNewButton:HookScript("OnClick", function()
		E.Delay(1, SkinGuildRanks)
	end)
	
	S:HandleDropDownBox(GuildControlUINavigationDropDown)
	S:HandleDropDownBox(GuildControlUIRankSettingsFrameRankDropDown, 180)
	GuildControlUINavigationDropDownButton:Width(20)
	GuildControlUIRankSettingsFrameRankDropDownButton:Width(20)
	
	for i=1, NUM_RANK_FLAGS do
		if _G["GuildControlUIRankSettingsFrameCheckbox"..i] then
			S:HandleCheckBox(_G["GuildControlUIRankSettingsFrameCheckbox"..i])
		end
	end
	
	S:HandleButton(GuildControlUIRankOrderFrameNewButton)
	
	S:HandleEditBox(GuildControlUIRankSettingsFrameGoldBox)
	GuildControlUIRankSettingsFrameGoldBox.backdrop:Point("TOPLEFT", -2, -4)
	GuildControlUIRankSettingsFrameGoldBox.backdrop:Point("BOTTOMRIGHT", 2, 4)
	GuildControlUIRankSettingsFrameGoldBox:StripTextures()
	
	GuildControlUIRankBankFrame:StripTextures()
	
	local once = false
	hooksecurefunc("GuildControlUI_BankTabPermissions_Update", function()
		local numTabs = GetNumGuildBankTabs()
		if numTabs < MAX_BUY_GUILDBANK_TABS then
			numTabs = numTabs + 1
		end
		for i=1, numTabs do
			local tab = _G["GuildControlBankTab"..i.."Owned"]
			local icon = tab.tabIcon
			local editbox = tab.editBox
			
			icon:SetTexCoord(unpack(E.TexCoords))
			
			if once == false then
				S:HandleButton(_G["GuildControlBankTab"..i.."BuyPurchaseButton"])
				_G["GuildControlBankTab"..i.."OwnedStackBox"]:StripTextures()
			end
		end
		once = true
	end)
	
	S:HandleDropDownBox(GuildControlUIRankBankFrameRankDropDown, 180)
	GuildControlUIRankBankFrameRankDropDownButton:Width(20)
end

S:RegisterSkin("Blizzard_GuildControlUI", LoadSkin)