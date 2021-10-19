local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub, pairs, unpack = gsub, pairs, unpack
local hooksecurefunc = hooksecurefunc

-- Credits Siweia | AuroraClassic

local function UpdateSelection(frame)
	if not frame.backdrop then return end

	if frame.SelectedTexture:IsShown() then
		frame.backdrop:SetBackdropBorderColor(1, .8, 0)
	else
		frame.backdrop:SetBackdropBorderColor(0, 0, 0)
	end
end

local IconColor = E.QualityColors[Enum.ItemQuality.Epic or 4] -- epic color only
local function SkinRewardIcon(itemFrame)
	if not itemFrame.IsSkinned then
		itemFrame:CreateBackdrop('Transparent')
		itemFrame:DisableDrawLayer('BORDER')
		itemFrame.Icon:SetPoint('LEFT', 6, 0)
		S:HandleIcon(itemFrame.Icon, true)
		itemFrame.backdrop:SetBackdropBorderColor(IconColor.r, IconColor.g, IconColor.b)
		itemFrame.IsSkinned = true
	end
end

local function SkinActivityFrame(frame, isObject)
	if frame.Border then
		if isObject then
			frame.Border:SetAlpha(0)
			frame.SelectedTexture:SetAlpha(0)
			frame.LockIcon:SetVertexColor(unpack(E.media.rgbvaluecolor))
			hooksecurefunc(frame, 'SetSelectionState', UpdateSelection)
			hooksecurefunc(frame.ItemFrame, 'SetDisplayedItem', SkinRewardIcon)
		else
			frame.Border:SetTexCoord(.926, 1, 0, 1)
			frame.Border:Size(25, 137)
			frame.Border:Point('LEFT', frame, 'RIGHT', 3, 0)
		end
	end

	if frame.Background then
		frame.Background:CreateBackdrop()
	end
end

local function ReplaceIconString(self, text)
	if not text then text = self:GetText() end
	if not text or text == '' then return end

	local newText, count = gsub(text, '24:24:0:%-2', '14:14:0:0:64:64:5:59:5:59')
	if count > 0 then self:SetFormattedText('%s', newText) end
end

local function ReskinConfirmIcon(frame)
	S:HandleIcon(frame.Icon, true)
	S:HandleIconBorder(frame.IconBorder, frame.Icon.backdrop)
end

function S:Blizzard_WeeklyRewards()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.weeklyRewards) then return end

	-- /run UIParent_OnEvent({}, 'WEEKLY_REWARDS_SHOW')
	local frame = _G.WeeklyRewardsFrame
	local header = frame.HeaderFrame

	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
		frame:SetTemplate('Transparent')

		header:StripTextures()
		header:SetTemplate('Transparent')
		header:ClearAllPoints()
		header:Point('TOP', 1, -42)
	end

	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.SelectRewardButton)

	SkinActivityFrame(frame.RaidFrame)
	SkinActivityFrame(frame.MythicFrame)
	SkinActivityFrame(frame.PVPFrame)

	for _, activity in pairs(frame.Activities) do
		SkinActivityFrame(activity, true)
	end

	hooksecurefunc(frame, 'SelectReward', function(reward)
		local selection = reward.confirmSelectionFrame
		if selection then
			_G.WeeklyRewardsFrameNameFrame:Hide()
			ReskinConfirmIcon(selection.ItemFrame)

			local alsoItems = selection.AlsoItemsFrame
			if alsoItems and alsoItems.pool then
				for items in alsoItems.pool:EnumerateActive() do
					ReskinConfirmIcon(items)
				end
			end
		end
	end)

	hooksecurefunc(frame, 'UpdateOverlay', function()
		local overlay = frame.Overlay
		if overlay then
			overlay:StripTextures()
			overlay:SetTemplate()
		end
	end)

	local rewardText = frame.ConcessionFrame.RewardsFrame.Text
	ReplaceIconString(rewardText)
	hooksecurefunc(rewardText, 'SetText', ReplaceIconString)
end

S:AddCallbackForAddon('Blizzard_WeeklyRewards')
