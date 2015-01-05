local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end

	GlyphFrame.background:ClearAllPoints()
	GlyphFrame.background:SetAllPoints(PlayerTalentFrameInset)

	GlyphFrame:HookScript('OnShow', function()
		PlayerTalentFrameInset.backdrop:Show()
	end)

	GlyphFrame:HookScript('OnHide', function()
		PlayerTalentFrameInset.backdrop:Hide()
	end)

	GlyphFrameSideInset:StripTextures()

	GlyphFrameClearInfoFrame:CreateBackdrop('Default')
	GlyphFrameClearInfoFrame.icon:SetTexCoord(unpack(E.TexCoords))
	GlyphFrameClearInfoFrame:Width(GlyphFrameClearInfoFrame:GetWidth() - 2)
	GlyphFrameClearInfoFrame:Height(GlyphFrameClearInfoFrame:GetHeight() - 2)
	GlyphFrameClearInfoFrame.icon:Size(GlyphFrameClearInfoFrame:GetSize())
	GlyphFrameClearInfoFrame:Point('TOPLEFT', GlyphFrame, 'BOTTOMLEFT', 6, -10)

	S:HandleDropDownBox(GlyphFrameFilterDropDown, 212)
	S:HandleEditBox(GlyphFrameSearchBox)
	S:HandleScrollBar(GlyphFrameScrollFrameScrollBar, 5)

	for i=1, 10 do
		local button = _G["GlyphFrameScrollFrameButton"..i]
		local icon = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

		button:StripTextures()
		S:HandleButton(button)
		icon:SetTexCoord(unpack(E.TexCoords))
	end

	GlyphFrameHeader1:StripTextures()
	GlyphFrameHeader2:StripTextures()
end

S:RegisterSkin("Blizzard_GlyphUI", LoadSkin)