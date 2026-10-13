local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub, ipairs = gsub, ipairs
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_CovenantSanctum', nil, nil, nil, nil, nil, 'covenantSanctum')

local function HandleIconString(self, text)
	if not text then text = self:GetText() end
	if not text or text == '' then return end

	local new, count = gsub(text, '|T([^:]-):[%d+:]+|t', '|T%1:14:14:0:0:64:64:5:59:5:59|t')
	if count > 0 then self:SetFormattedText('%s', new) end
end

local function ReskinTalents(self)
	for frame in self.talentPool:EnumerateActive() do
		if not frame.IsSkinned then
			frame.Border:SetAlpha(0)
			frame.IconBorder:SetAlpha(0)
			frame.TierBorder:SetAlpha(0)
			frame.Background:SetAlpha(0)

			frame:SetTemplate('Transparent')
			frame:SetBackdropBorderColor(0, 1, 0)

			S:HandleIcon(frame.Icon, true)
			frame.Icon:Point('TOPLEFT', 7, -7)
			frame.Highlight:SetColorTexture(1, 1, 1, .25)

			HandleIconString(frame.InfoText)
			hooksecurefunc(frame.InfoText, 'SetText', HandleIconString)

			frame.IsSkinned = true
		end
	end
end

local function ReplaceCurrencies(displayGroup)
	for frame in displayGroup.currencyFramePool:EnumerateActive() do
		if not frame.IsSkinned then
			HandleIconString(frame.Text)
			hooksecurefunc(frame.Text, 'SetText', HandleIconString)

			frame.IsSkinned = true
		end
	end
end

local function Sanctum_OnShow(frame)
	if not frame.IsSkinned then
		frame:SetTemplate('Transparent')
		frame.NineSlice:SetAlpha(0)

		S:HandleCloseButton(frame.CloseButton)
		frame.CloseButton:ClearAllPoints()
		frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 2, 2)
		frame.CloseButton.Border:SetAlpha(0)

		frame.IsSkinned = true
	end
end

function S:Blizzard_CovenantSanctum()
	local sanctumFrame = _G.CovenantSanctumFrame
	sanctumFrame.LevelFrame.Level:FontTemplate()

	if E.private.skins.parchmentRemoverEnable then
		sanctumFrame.LevelFrame.Background:SetAlpha(0)
	end

	local upgradesTab = sanctumFrame.UpgradesTab
	upgradesTab.Background:CreateBackdrop('Transparent')
	S:HandleButton(upgradesTab.DepositButton)

	upgradesTab.DepositButton:SetFrameLevel(10)
	upgradesTab.CurrencyBackground:SetAlpha(0)
	ReplaceCurrencies(upgradesTab.CurrencyDisplayGroup)

	for _, upgrade in ipairs(upgradesTab.Upgrades) do
		if upgrade.TierBorder then
			upgrade.TierBorder:SetAlpha(0)
		end
	end

	if E.private.skins.parchmentRemoverEnable then
		upgradesTab.Background:SetAlpha(0)
	end

	local talentList = upgradesTab.TalentsList
	talentList:SetTemplate('Transparent')
	S:HandleButton(talentList.UpgradeButton)

	talentList.UpgradeButton:SetFrameLevel(10)
	talentList.IntroBox.Background:Hide()
	hooksecurefunc(talentList, 'Refresh', ReskinTalents)

	if E.private.skins.parchmentRemoverEnable then
		talentList.Divider:SetAlpha(0)
		talentList.BackgroundTile:SetAlpha(0)
	end

	sanctumFrame:HookScript('OnShow', Sanctum_OnShow)
end
