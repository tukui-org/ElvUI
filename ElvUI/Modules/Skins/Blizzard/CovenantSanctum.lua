local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local gsub, ipairs = gsub, ipairs
local hooksecurefunc = hooksecurefunc

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

function S:Blizzard_CovenantSanctum()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantSanctum) then return end

	local frame = _G.CovenantSanctumFrame
	frame.LevelFrame.Level:FontTemplate()

	if E.private.skins.parchmentRemoverEnable then
		frame.LevelFrame.Background:SetAlpha(0)
	end

	local UpgradesTab = frame.UpgradesTab
	UpgradesTab.Background:CreateBackdrop('Transparent')
	S:HandleButton(UpgradesTab.DepositButton)
	UpgradesTab.DepositButton:SetFrameLevel(10)
	UpgradesTab.CurrencyBackground:SetAlpha(0)
	ReplaceCurrencies(UpgradesTab.CurrencyDisplayGroup)

	for _, upgrade in ipairs(UpgradesTab.Upgrades) do
		if upgrade.TierBorder then
			upgrade.TierBorder:SetAlpha(0)
		end
	end

	if E.private.skins.parchmentRemoverEnable then
		UpgradesTab.Background:SetAlpha(0)
	end

	local TalentList = frame.UpgradesTab.TalentsList
	TalentList:SetTemplate('Transparent')
	S:HandleButton(TalentList.UpgradeButton)
	TalentList.UpgradeButton:SetFrameLevel(10)
	TalentList.IntroBox.Background:Hide()
	hooksecurefunc(TalentList, 'Refresh', ReskinTalents)

	if E.private.skins.parchmentRemoverEnable then
		TalentList.Divider:SetAlpha(0)
		TalentList.BackgroundTile:SetAlpha(0)
	end

	frame:HookScript('OnShow', function()
		if not frame.IsSkinned then
			frame:SetTemplate('Transparent')
			frame.NineSlice:SetAlpha(0)

			frame.CloseButton.Border:SetAlpha(0)
			S:HandleCloseButton(frame.CloseButton)
			frame.CloseButton:ClearAllPoints()
			frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 2, 2)

			frame.IsSkinned = true
		end
	end)
end

S:AddCallbackForAddon('Blizzard_CovenantSanctum')
