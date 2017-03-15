local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return end

	-- Macro to show the WorldStateScoreFrame: /run WorldStateScoreFrame:Show()

	WorldStateScoreScrollFrame:StripTextures()
	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:SetTemplate("Transparent")
	S:HandleCloseButton(WorldStateScoreFrameCloseButton)
	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)
	WorldStateScoreFrameInset:SetAlpha(0)
	S:HandleButton(WorldStateScoreFrameLeaveButton)
	S:HandleButton(WorldStateScoreFrameQueueButton)
	for i = 1, 3 do
		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
	end

	WorldStateScoreFrame.XPBar:StripTextures()
	WorldStateScoreFrame.XPBar.Bar:CreateBackdrop("Default")
	WorldStateScoreFrame.XPBar.Bar.Spark:SetAlpha(0)

	WorldStateScoreFrame.XPBar.NextAvailable:ClearAllPoints()
	WorldStateScoreFrame.XPBar.NextAvailable:SetPoint("LEFT", WorldStateScoreFrame.XPBar.Bar, "RIGHT", -2, -2)

	WorldStateScoreFrame.XPBar.NextAvailable:StripTextures()
	WorldStateScoreFrame.XPBar.NextAvailable:CreateBackdrop("Default")
	WorldStateScoreFrame.XPBar.NextAvailable.backdrop:SetPoint("TOPLEFT", WorldStateScoreFrame.XPBar.NextAvailable.Icon, -2, 2)
	WorldStateScoreFrame.XPBar.NextAvailable.backdrop:SetPoint("BOTTOMRIGHT", WorldStateScoreFrame.XPBar.NextAvailable.Icon, 2, -2)

	WorldStateScoreFrame.XPBar.NextAvailable.Icon:SetDrawLayer("ARTWORK")
	WorldStateScoreFrame.XPBar.NextAvailable.Icon:SetTexCoord(unpack(E.TexCoords))
	WorldStateScoreFrame.XPBar.NextAvailable.Icon.SetTexCoord = E.noop
end

S:AddCallback("WorldStateScore", LoadSkin)