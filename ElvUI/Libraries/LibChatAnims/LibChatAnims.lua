
local MAJOR, MINOR = "LibChatAnims", 2 -- Bump minor on changes
local LCA = LibStub:NewLibrary(MAJOR, MINOR)
if not LCA then return end -- No upgrade needed

LCA.animations = LCA.animations or {} -- Animation storage
local anims = LCA.animations

----------------------------------------------------
-- Note, most of this code is simply replicated from
-- Blizzard's FloatingChatFrame.lua file.
-- The only real changes are the creation and use
-- of animations vs the use of UIFrameFlash.
--

FCFDockOverflowButton_UpdatePulseState = function(self)
	local dock = self:GetParent()
	local shouldPulse = false
	for _, chatFrame in pairs(FCFDock_GetChatFrames(dock)) do
		local chatTab = _G[chatFrame:GetName().."Tab"]
		if ( not chatFrame.isStaticDocked and chatTab.alerting) then
			-- Make sure the rects are valid. (Not always the case when resizing the WoW client
			if ( not chatTab:GetRight() or not dock.scrollFrame:GetRight() ) then
				return false
			end
			-- Check if it's off the screen.
			local DELTA = 3 -- Chosen through experimentation
			if ( chatTab:GetRight() < (dock.scrollFrame:GetLeft() + DELTA) or chatTab:GetLeft() > (dock.scrollFrame:GetRight() - DELTA) ) then
				shouldPulse = true
				break
			end
		end
	end

	local tex = self:GetHighlightTexture()
	if shouldPulse then
		if not anims[tex] then
			anims[tex] = tex:CreateAnimationGroup()

			local fade1 = anims[tex]:CreateAnimation("Alpha")
			fade1:SetDuration(1)
			fade1:SetFromAlpha(0)
			fade1:SetToAlpha(1)
			fade1:SetOrder(1)

			local fade2 = anims[tex]:CreateAnimation("Alpha")
			fade2:SetDuration(1)
			fade2:SetFromAlpha(1)
			fade2:SetToAlpha(0)
			fade2:SetOrder(2)
		end
		tex:Show()
		tex:SetAlpha(0)
		anims[tex]:SetLooping("REPEAT")
		anims[tex]:Play()

		self:LockHighlight()
		self.alerting = true
	else
		if anims[tex] then
			anims[tex]:Stop()
		end
		self:UnlockHighlight()
		tex:SetAlpha(1)
		tex:Show()
		self.alerting = false
	end

	if self.list:IsShown() then
		FCFDockOverflowList_Update(self.list, dock)
	end
	return true
end

FCFDockOverflowListButton_SetValue = function(button, chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"]
	button.chatFrame = chatFrame
	button:SetText(chatFrame.name)

	local colorTable = chatTab.selectedColorTable or DEFAULT_TAB_SELECTED_COLOR_TABLE

	if chatTab.selectedColorTable then
		button:GetFontString():SetTextColor(colorTable.r, colorTable.g, colorTable.b)
	else
		button:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end

	button.glow:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)

	if chatTab.conversationIcon then
		button.conversationIcon:SetVertexColor(colorTable.r, colorTable.g, colorTable.b)
		button.conversationIcon:Show()
	else
		button.conversationIcon:Hide()
	end

	if chatTab.alerting then
		button.alerting = true
		if not anims[button.glow] then
			anims[button.glow] = button.glow:CreateAnimationGroup()

			local fade1 = anims[button.glow]:CreateAnimation("Alpha")
			fade1:SetDuration(1)
			fade1:SetFromAlpha(0)
			fade1:SetToAlpha(1)
			fade1:SetOrder(1)

			local fade2 = anims[button.glow]:CreateAnimation("Alpha")
			fade2:SetDuration(1)
			fade2:SetFromAlpha(1)
			fade2:SetToAlpha(0)
			fade2:SetOrder(2)
		end
		button.glow:Show()
		button.glow:SetAlpha(0)
		anims[button.glow]:SetLooping("REPEAT")
		anims[button.glow]:Play()
	else
		button.alerting = false
		if anims[button.glow] then
			anims[button.glow]:Stop()
		end
		button.glow:Hide()
	end
	button:Show()
end

FCF_StartAlertFlash = function(chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"]

	if chatFrame.minFrame then
		if not anims[chatFrame.minFrame] then
			anims[chatFrame.minFrame] = chatFrame.minFrame.glow:CreateAnimationGroup()

			local fade1 = anims[chatFrame.minFrame]:CreateAnimation("Alpha")
			fade1:SetDuration(1)
			fade1:SetFromAlpha(0)
			fade1:SetToAlpha(1)
			fade1:SetOrder(1)

			local fade2 = anims[chatFrame.minFrame]:CreateAnimation("Alpha")
			fade2:SetDuration(1)
			fade2:SetFromAlpha(1)
			fade2:SetToAlpha(0)
			fade2:SetOrder(2)
		end
		chatFrame.minFrame.glow:Show()
		chatFrame.minFrame.glow:SetAlpha(0)
		anims[chatFrame.minFrame]:SetLooping("REPEAT")
		anims[chatFrame.minFrame]:Play()
		chatFrame.minFrame.alerting = true
	end

	if not anims[chatTab.glow] then
		anims[chatTab.glow] = chatTab.glow:CreateAnimationGroup()

		local fade1 = anims[chatTab.glow]:CreateAnimation("Alpha")
		fade1:SetDuration(1)
		fade1:SetFromAlpha(0)
		fade1:SetToAlpha(1)
		fade1:SetOrder(1)

		local fade2 = anims[chatTab.glow]:CreateAnimation("Alpha")
		fade2:SetDuration(1)
		fade2:SetFromAlpha(1)
		fade2:SetToAlpha(0)
		fade2:SetOrder(2)
	end
	chatTab.glow:Show()
	chatTab.glow:SetAlpha(0)
	anims[chatTab.glow]:SetLooping("REPEAT")
	anims[chatTab.glow]:Play()
	chatTab.alerting = true

	FCFTab_UpdateAlpha(chatFrame)
	FCFDockOverflowButton_UpdatePulseState(GENERAL_CHAT_DOCK.overflowButton)
end

FCF_StopAlertFlash = function(chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"]

	if chatFrame.minFrame then
		if anims[chatFrame.minFrame] then
			anims[chatFrame.minFrame]:Stop()
		end
		chatFrame.minFrame.glow:Hide()
		chatFrame.minFrame.alerting = false
	end

	if anims[chatTab.glow] then
		anims[chatTab.glow]:Stop()
	end
	chatTab.glow:Hide()
	chatTab.alerting = false

	FCFTab_UpdateAlpha(chatFrame)
	FCFDockOverflowButton_UpdatePulseState(GENERAL_CHAT_DOCK.overflowButton)
end

