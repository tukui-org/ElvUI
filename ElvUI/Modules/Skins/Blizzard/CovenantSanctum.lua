local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
			frame.Background:SetAlpha(0)

			frame:CreateBackdrop('Transparent')
			frame.backdrop:SetInside()
			frame.backdrop:SetBackdropBorderColor(0, 1, 0)

			frame.Highlight:SetColorTexture(1, 1, 1, .25)
			frame.Highlight:SetInside(frame.backdrop)
			S:HandleIcon(frame.Icon, true)
			frame.Icon:Point('TOPLEFT', 7, -7)

			HandleIconString(frame.InfoText)
			hooksecurefunc(frame.InfoText, 'SetText', HandleIconString)

			frame.IsSkinned = true
		end
	end
end

local function HideRenownLevelBorder(frame)
	if not frame.IsSkinned then
		frame.Divider:SetAlpha(0)
		frame.BackgroundTile:SetAlpha(0)
		frame.Background:CreateBackdrop()

		frame.IsSkinned = true
	end

	for button in frame.milestonesPool:EnumerateActive() do
		if not button.IsSkinned then
			button.LevelBorder:SetAlpha(0)

			button.IsSkinned = true
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

	frame:HookScript('OnShow', function()
		if not frame.backdrop then
			frame:CreateBackdrop('Transparent')
			frame.NineSlice:SetAlpha(0)

			frame.CloseButton.Border:SetAlpha(0)
			S:HandleCloseButton(frame.CloseButton)
			frame.CloseButton:ClearAllPoints()
			frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', 2, 2)

			frame.LevelFrame.Level:FontTemplate()

			local UpgradesTab = frame.UpgradesTab
			UpgradesTab.Background:CreateBackdrop('Transparent')
			S:HandleButton(UpgradesTab.DepositButton)
			UpgradesTab.DepositButton:SetFrameLevel(10)

			local TalentList = frame.UpgradesTab.TalentsList
			TalentList:CreateBackdrop('Transparent')
			S:HandleButton(TalentList.UpgradeButton)
			TalentList.UpgradeButton:SetFrameLevel(10)
			TalentList.IntroBox.Background:Hide()

			if E.private.skins.parchmentRemoverEnable then
				frame.LevelFrame.Background:SetAlpha(0)
				UpgradesTab.Background:SetAlpha(0)
				TalentList.Divider:SetAlpha(0)
				TalentList.BackgroundTile:SetAlpha(0)

				for _, frame in ipairs(UpgradesTab.Upgrades) do
					if frame.RankBorder then
						frame.RankBorder:SetAlpha(0)
					end
				end
			end

			UpgradesTab.CurrencyBackground:SetAlpha(0)
			ReplaceCurrencies(UpgradesTab.CurrencyDisplayGroup)

			hooksecurefunc(TalentList, 'Refresh', ReskinTalents)
			hooksecurefunc(frame.RenownTab, 'Refresh', HideRenownLevelBorder)
		end
	end)

	S:HandleTab(_G.CovenantSanctumFrameTab1)
	S:HandleTab(_G.CovenantSanctumFrameTab2)
	_G.CovenantSanctumFrameTab1:ClearAllPoints()
	_G.CovenantSanctumFrameTab1:Point('BOTTOMLEFT', frame, 23, -32) --default is: 23, 9
end

S:AddCallbackForAddon('Blizzard_CovenantSanctum')
