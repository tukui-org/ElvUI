local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc')
local CH = E:GetModule('Chat')
local LSM = E.Libs.LSM

local format, wipe, pairs = format, wipe, pairs
local strmatch, strlower, gmatch, gsub = strmatch, strlower, gmatch, gsub

local Ambiguate = Ambiguate
local CreateFrame = CreateFrame
local RemoveExtraSpaces = RemoveExtraSpaces
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

--Message caches
local messageToGUID = {}
local messageToSender = {}

function M:UpdateBubbleBorder()
	local holder = self.holder
	local str = holder and holder.String
	if not str then return end

	local option = E.private.general.chatBubbles
	if option == 'backdrop' then
		holder:SetBackdropBorderColor(str:GetTextColor())
	elseif option == 'backdrop_noborder' then
		holder:SetBackdropBorderColor(0,0,0,0)
	end

	local name = self.Name and self.Name:GetText()
	if name then self.Name:SetText() end

	local text = str:GetText()
	if not text then return end

	if E.private.general.chatBubbleName then
		M:AddChatBubbleName(self, messageToGUID[text], messageToSender[text])
	end

	if E.private.chat.enable and E.private.general.classColorMentionsSpeech then
		local isFirstWord, rebuiltString
		if text and strmatch(text, '%s-%S+%s*') then
			for word in gmatch(text, '%s-%S+%s*') do
				local tempWord = gsub(word, '^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$', '%1%2')
				local lowerCaseWord = strlower(tempWord)

				local classMatch = CH.ClassNames[lowerCaseWord]
				local wordMatch = classMatch and lowerCaseWord

				if wordMatch and not E.global.chat.classColorMentionExcludedNames[wordMatch] then
					local classColorTable = E:ClassColor(classMatch)
					if classColorTable then
						word = gsub(word, gsub(tempWord, '%-','%%-'), format('\124cff%.2x%.2x%.2x%s\124r', classColorTable.r*255, classColorTable.g*255, classColorTable.b*255, tempWord))
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
				str:SetText(RemoveExtraSpaces(rebuiltString))
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
	chatBubble.Name:Width(chatBubble:GetWidth()-10)
end

local yOffset --Value set in M:LoadChatBubbles()
function M:SkinBubble(frame, holder)
	local bubbleFont = LSM:Fetch('font', E.private.general.chatBubbleFont)
	if holder.String then
		holder.String:FontTemplate(bubbleFont, E.private.general.chatBubbleFontSize, E.private.general.chatBubbleFontOutline)
	end

	local option = E.private.general.chatBubbles
	if option == 'nobackdrop' then
		holder:DisableDrawLayer('BORDER')
	else
		holder:SetTemplate('Transparent', nil, true)

		if option == 'backdrop_noborder' then
			holder.Center:SetInside(holder, 4, 4)
		end
	end

	if not frame.Name then
		local name = frame:CreateFontString(nil, 'BORDER')
		name:Height(10) --Width set in M:AddChatBubbleName()
		name:Point('BOTTOM', frame, 'TOP', 0, yOffset)
		name:FontTemplate(bubbleFont, E.private.general.chatBubbleFontSize * 0.85, E.private.general.chatBubbleFontOutline)
		name:SetJustifyH('LEFT')
		frame.Name = name
	end

	if not frame.holder then
		frame.holder = holder
		holder.Tail:Hide()

		frame:HookScript('OnShow', M.UpdateBubbleBorder)
		frame:SetFrameStrata('DIALOG') --Doesn't work currently in Legion due to a bug on Blizzards end
		frame:SetClampedToScreen(false)

		M.UpdateBubbleBorder(frame)
	end

	frame.isSkinnedElvUI = true
end

local function ChatBubble_OnEvent(_, event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
	if event == 'PLAYER_ENTERING_WORLD' then --Clear caches
		wipe(messageToGUID)
		wipe(messageToSender)
	elseif E.private.general.chatBubbleName then
		messageToGUID[msg] = guid
		messageToSender[msg] = Ambiguate(sender, 'none')
	end
end

local function ChatBubble_OnUpdate(eventFrame, elapsed)
	eventFrame.lastupdate = (eventFrame.lastupdate or -2) + elapsed
	if eventFrame.lastupdate < 0.1 then return end
	eventFrame.lastupdate = 0

	for _, frame in pairs(C_ChatBubbles_GetAllChatBubbles()) do
		local holder = frame:GetChildren()
		if holder and not holder:IsForbidden() and not frame.isSkinnedElvUI then
			M:SkinBubble(frame, holder)
		end
	end
end

function M:LoadChatBubbles()
	yOffset = (E.private.general.chatBubbles == 'backdrop' and 2) or (E.private.general.chatBubbles == 'backdrop_noborder' and -2) or 0

	M.BubbleFrame = CreateFrame('Frame')
	M.BubbleFrame:RegisterEvent('CHAT_MSG_SAY')
	M.BubbleFrame:RegisterEvent('CHAT_MSG_YELL')
	M.BubbleFrame:RegisterEvent('CHAT_MSG_MONSTER_SAY')
	M.BubbleFrame:RegisterEvent('CHAT_MSG_MONSTER_YELL')
	M.BubbleFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

	if E.private.general.chatBubbles ~= 'disabled' then
		M.BubbleFrame:SetScript('OnEvent', ChatBubble_OnEvent)
		M.BubbleFrame:SetScript('OnUpdate', ChatBubble_OnUpdate)
	else
		M.BubbleFrame:SetScript('OnEvent', nil)
		M.BubbleFrame:SetScript('OnUpdate', nil)
	end
end
