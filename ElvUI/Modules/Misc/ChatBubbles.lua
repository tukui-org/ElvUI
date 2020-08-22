local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc')
local CH = E:GetModule('Chat')

local format, wipe = format, wipe
local select, unpack, pairs = select, unpack, pairs

local Ambiguate = Ambiguate
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local RemoveExtraSpaces = RemoveExtraSpaces
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

--Message caches
local messageToGUID = {}
local messageToSender = {}

function M:UpdateBubbleBorder()
	if not self.text then return end

	if E.private.general.chatBubbles == 'backdrop' then
		if E.PixelMode then
			self:SetBackdropBorderColor(self.text:GetTextColor())
		else
			local r, g, b = self.text:GetTextColor()
			self.bordertop:SetColorTexture(r, g, b)
			self.borderbottom:SetColorTexture(r, g, b)
			self.borderleft:SetColorTexture(r, g, b)
			self.borderright:SetColorTexture(r, g, b)
		end
	end

	local name = self.Name and self.Name:GetText()
	if name then self.Name:SetText() end

	local text = self.text:GetText()
	if text and E.private.general.chatBubbleName then
		M:AddChatBubbleName(self, messageToGUID[text], messageToSender[text])
	end

	if E.private.chat.enable and E.private.general.classColorMentionsSpeech then
		local isFirstWord, rebuiltString
		if text and text:match('%s-%S+%s*') then
			for word in text:gmatch('%s-%S+%s*') do
				local tempWord = word:gsub('^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$','%1%2')
				local lowerCaseWord = tempWord:lower()

				local classMatch = CH.ClassNames[lowerCaseWord]
				local wordMatch = classMatch and lowerCaseWord

				if wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch] then
					local classColorTable = E:ClassColor(classMatch)
					if classColorTable then
						word = word:gsub(tempWord:gsub('%-','%%-'), format('\124cff%.2x%.2x%.2x%s\124r', classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
					end
				end

				if not isFirstWord then
					rebuiltString = word
					isFirstWord = true
				else
					rebuiltString = format('%s%s', rebuiltString, word)
				end
			end

			if rebuiltString then
				self.text:SetText(RemoveExtraSpaces(rebuiltString))
			end
		end
	end
end

function M:AddChatBubbleName(chatBubble, guid, name)
	if not name then return end

	local color = PRIEST_COLOR
	local data = guid and guid ~= '' and CH:GetPlayerInfoByGUID(guid)
	if data and data.classColor then
		color = data.classColor
	end

	chatBubble.Name:SetFormattedText('|c%s%s|r', color.colorStr, name)
	chatBubble.Name:SetWidth(chatBubble:GetWidth()-10)
end

local yOffset --Value set in M:LoadChatBubbles()
function M:SkinBubble(frame)
	if frame:IsForbidden() then return end

	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:IsObjectType('Texture') then
			region:SetTexture()
		elseif region:IsObjectType('FontString') then
			frame.text = region
		end
	end

	local name = frame:CreateFontString(nil, 'BORDER')
	name:SetHeight(10) --Width set in M:AddChatBubbleName()
	name:SetPoint('BOTTOM', frame, 'TOP', 0, yOffset)
	name:FontTemplate(E.Libs.LSM:Fetch('font', E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize * 0.85, E.private.general.chatBubbleFontOutline)
	name:SetJustifyH('LEFT')
	frame.Name = name

	if E.private.general.chatBubbles == 'backdrop' then
		if E.PixelMode then
			frame:SetBackdrop({
				bgFile = E.media.blankTex,
				edgeFile = E.media.blankTex,
				tile = false, tileSize = 0, edgeSize = E.mult,
				insets = {left = 0, right = 0, top = 0, bottom = 0}
			})

			frame:SetBackdropColor(unpack(E.media.backdropfadecolor))
			frame:SetBackdropBorderColor(0, 0, 0)
		else
			frame:SetBackdrop(nil)
		end

		if not E.PixelMode then
			local r, g, b = frame.text:GetTextColor()
			frame.backdrop = frame:CreateTexture(nil, 'ARTWORK')
			frame.backdrop:SetAllPoints(frame)
			frame.backdrop:SetColorTexture(unpack(E.media.backdropfadecolor))
			frame.backdrop:SetDrawLayer('ARTWORK', -8)

			frame.bordertop = frame:CreateTexture(nil, 'ARTWORK')
			frame.bordertop:SetPoint('TOPLEFT', frame, 'TOPLEFT', -2, 2)
			frame.bordertop:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 2, 2)
			frame.bordertop:SetHeight(1)
			frame.bordertop:SetColorTexture(r, g, b)
			frame.bordertop:SetDrawLayer('ARTWORK', -6)

			frame.bordertop.backdrop = frame:CreateTexture(nil, 'ARTWORK')
			frame.bordertop.backdrop:SetPoint('TOPLEFT', frame.bordertop, 'TOPLEFT', -1, 1)
			frame.bordertop.backdrop:SetPoint('TOPRIGHT', frame.bordertop, 'TOPRIGHT', 1, 1)
			frame.bordertop.backdrop:SetHeight(1 * 3)
			frame.bordertop.backdrop:SetColorTexture(0, 0, 0)
			frame.bordertop.backdrop:SetDrawLayer('ARTWORK', -7)

			frame.borderbottom = frame:CreateTexture(nil, 'ARTWORK')
			frame.borderbottom:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', -2, -2)
			frame.borderbottom:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 2, -2)
			frame.borderbottom:SetHeight(1)
			frame.borderbottom:SetColorTexture(r, g, b)
			frame.borderbottom:SetDrawLayer('ARTWORK', -6)

			frame.borderbottom.backdrop = frame:CreateTexture(nil, 'ARTWORK')
			frame.borderbottom.backdrop:SetPoint('BOTTOMLEFT', frame.borderbottom, 'BOTTOMLEFT', -1, -1)
			frame.borderbottom.backdrop:SetPoint('BOTTOMRIGHT', frame.borderbottom, 'BOTTOMRIGHT', 1, -1)
			frame.borderbottom.backdrop:SetHeight(1 * 3)
			frame.borderbottom.backdrop:SetColorTexture(0, 0, 0)
			frame.borderbottom.backdrop:SetDrawLayer('ARTWORK', -7)

			frame.borderleft = frame:CreateTexture(nil, 'ARTWORK')
			frame.borderleft:SetPoint('TOPLEFT', frame, 'TOPLEFT', -2, 2)
			frame.borderleft:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 2, -2)
			frame.borderleft:SetWidth(1)
			frame.borderleft:SetColorTexture(r, g, b)
			frame.borderleft:SetDrawLayer('ARTWORK', -6)

			frame.borderleft.backdrop = frame:CreateTexture(nil, 'ARTWORK')
			frame.borderleft.backdrop:SetPoint('TOPLEFT', frame.borderleft, 'TOPLEFT', -1, 1)
			frame.borderleft.backdrop:SetPoint('BOTTOMLEFT', frame.borderleft, 'BOTTOMLEFT', -1, -1)
			frame.borderleft.backdrop:SetWidth(1 * 3)
			frame.borderleft.backdrop:SetColorTexture(0, 0, 0)
			frame.borderleft.backdrop:SetDrawLayer('ARTWORK', -7)

			frame.borderright = frame:CreateTexture(nil, 'ARTWORK')
			frame.borderright:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 2, 2)
			frame.borderright:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, -2)
			frame.borderright:SetWidth(1)
			frame.borderright:SetColorTexture(r, g, b)
			frame.borderright:SetDrawLayer('ARTWORK', -6)

			frame.borderright.backdrop = frame:CreateTexture(nil, 'ARTWORK')
			frame.borderright.backdrop:SetPoint('TOPRIGHT', frame.borderright, 'TOPRIGHT', 1, 1)
			frame.borderright.backdrop:SetPoint('BOTTOMRIGHT', frame.borderright, 'BOTTOMRIGHT', 1, -1)
			frame.borderright.backdrop:SetWidth(1 * 3)
			frame.borderright.backdrop:SetColorTexture(0, 0, 0)
			frame.borderright.backdrop:SetDrawLayer('ARTWORK', -7)
		end

		frame.text:FontTemplate(E.Libs.LSM:Fetch('font', E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
	elseif E.private.general.chatBubbles == 'backdrop_noborder' then
		frame:SetBackdrop(nil)
		frame.backdrop = frame:CreateTexture(nil, 'ARTWORK')
		frame.backdrop:SetInside(frame, 4, 4)
		frame.backdrop:SetColorTexture(unpack(E.media.backdropfadecolor))
		frame.backdrop:SetDrawLayer('ARTWORK', -8)
		frame.text:FontTemplate(E.Libs.LSM:Fetch('font', E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
		frame:SetClampedToScreen(false)
	elseif E.private.general.chatBubbles == 'nobackdrop' then
		frame:SetBackdrop(nil)
		frame.text:FontTemplate(E.Libs.LSM:Fetch('font', E.private.general.chatBubbleFont), E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
		frame:SetClampedToScreen(false)
		frame.Name:Hide()
	end

	frame:HookScript('OnShow', M.UpdateBubbleBorder)
	frame:SetFrameStrata('DIALOG') --Doesn't work currently in Legion due to a bug on Blizzards end
	M.UpdateBubbleBorder(frame)

	frame.isSkinnedElvUI = true
end

local function ChatBubble_OnEvent(_, _, msg, sender, _, _, _, _, _, _, _, _, _, guid)
	if not E.private.general.chatBubbleName then return end

	messageToGUID[msg] = guid
	messageToSender[msg] = Ambiguate(sender, 'none')
end

local function ChatBubble_OnUpdate(frame, elapsed)
	frame.lastupdate = (frame.lastupdate or -2) + elapsed
	if frame.lastupdate < 0.1 then return end
	frame.lastupdate = 0

	for _, chatBubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
		if not chatBubble.isSkinnedElvUI then
			M:SkinBubble(chatBubble)
		end
	end
end

function M:ToggleChatBubbleScript()
	local _, instanceType = GetInstanceInfo()
	if instanceType == 'none' and E.private.general.chatBubbles ~= 'disabled' then
		M.BubbleFrame:SetScript('OnEvent', ChatBubble_OnEvent)
		M.BubbleFrame:SetScript('OnUpdate', ChatBubble_OnUpdate)
	else
		M.BubbleFrame:SetScript('OnEvent', nil)
		M.BubbleFrame:SetScript('OnUpdate', nil)

		--Clear caches
		wipe(messageToGUID)
		wipe(messageToSender)
	end
end

function M:LoadChatBubbles()
	yOffset = E.private.general.chatBubbles == 'backdrop' and 2 or E.private.general.chatBubbles == 'backdrop_noborder' and -2 or 0
	self.BubbleFrame = CreateFrame('Frame')
	self.BubbleFrame:RegisterEvent('CHAT_MSG_SAY')
	self.BubbleFrame:RegisterEvent('CHAT_MSG_YELL')
	self.BubbleFrame:RegisterEvent('CHAT_MSG_MONSTER_SAY')
	self.BubbleFrame:RegisterEvent('CHAT_MSG_MONSTER_YELL')
end
