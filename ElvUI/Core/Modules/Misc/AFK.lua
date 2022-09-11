local E, L, V, P, G = unpack(ElvUI)
local AFK = E:GetModule('AFK')
local CH = E:GetModule('Chat')

local _G = _G
local floor = floor
local unpack = unpack
local tostring, pcall = tostring, pcall
local format, strsub, gsub = format, strsub, gsub

local CloseAllWindows = CloseAllWindows
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetGuildInfo = GetGuildInfo
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local RemoveExtraSpaces = RemoveExtraSpaces
local Screenshot = Screenshot
local SetCVar = SetCVar
local UnitCastingInfo = UnitCastingInfo
local UnitIsAFK = UnitIsAFK

local Chat_GetChatCategory = Chat_GetChatCategory
local ChatHistory_GetAccessID = ChatHistory_GetAccessID
local ChatFrame_GetMobileEmbeddedTexture = ChatFrame_GetMobileEmbeddedTexture
local C_PetBattles_IsInBattle = C_PetBattles and C_PetBattles.IsInBattle

local CinematicFrame = _G.CinematicFrame
local MovieFrame = _G.MovieFrame
local DNDstr = _G.DND
local AFKstr = _G.AFK

local CAMERA_SPEED = 0.035
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}
local printKeys = {
	PRINTSCREEN = true,
}

if IsMacClient() then
	printKeys[_G.KEY_PRINTSCREEN_MAC] = true
end

-- create these early and set the chat as moveable so the drag sticks
local afk = CreateFrame('Frame', 'ElvUIAFKFrame')
local chat = CreateFrame('ScrollingMessageFrame', 'ElvUIAFKChat', afk)
local bottom = CreateFrame('Frame', nil, afk)
chat:SetMovable(true)

AFK.AFKMode = afk
afk.chat = chat
afk.bottom = bottom

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime
	bottom.time:SetFormattedText('%02d:%02d', floor(time/60), time % 60)
end

function AFK:SetAFK(status)
	if status then
		MoveViewLeftStart(CAMERA_SPEED)
		afk:Show()
		CloseAllWindows()
		_G.UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo('player')
			bottom.guild:SetFormattedText('%s-%s', guildName, guildRankName)
		else
			bottom.guild:SetText(L["No Guild"])
		end

		local model = bottom.model
		model.curAnimation = 'wave'
		model.startTime = GetTime()
		model.duration = 2.3
		model.isIdle = nil
		model.idleDuration = 40
		model:SetUnit('player')
		model:SetAnimation(67)

		AFK.startTime = GetTime()
		AFK.timer = AFK:ScheduleRepeatingTimer('UpdateTimer', 1)

		bottom.LogoTop:SetVertexColor(unpack(E.media.rgbvaluecolor))
		chat:RegisterEvent('CHAT_MSG_WHISPER')
		chat:RegisterEvent('CHAT_MSG_BN_WHISPER')
		chat:RegisterEvent('CHAT_MSG_GUILD')

		AFK.isAFK = true
	elseif AFK.isAFK then
		_G.UIParent:Show()
		afk:Hide()
		MoveViewLeftStop()

		AFK:CancelTimer(AFK.timer)
		AFK:CancelTimer(AFK.animTimer)

		bottom.time:SetText('00:00')
		chat:UnregisterAllEvents()
		chat:Clear()

		if E.Retail and _G.PVEFrame:IsShown() then --odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		AFK.isAFK = false
	end
end

function AFK:OnEvent(event, arg1)
	if event == 'PLAYER_REGEN_ENABLED' then
		AFK:UnregisterEvent(event)
	elseif event == 'UPDATE_BATTLEFIELD_STATUS' or event == 'PLAYER_REGEN_DISABLED' or event == 'LFG_PROPOSAL_SHOW' then
		if event ~= 'UPDATE_BATTLEFIELD_STATUS' or (GetBattlefieldStatus(arg1) == 'confirm') then
			AFK:SetAFK(false)
		end

		if event == 'PLAYER_REGEN_DISABLED' then
			AFK:RegisterEvent('PLAYER_REGEN_ENABLED', 'OnEvent')
		end

		return
	elseif (not E.db.general.afk) or (event == 'PLAYER_FLAGS_CHANGED' and arg1 ~= 'player') or (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
		return
	elseif UnitCastingInfo('player') then
		AFK:ScheduleTimer('OnEvent', 30)
		return -- Don't activate afk if player is crafting stuff, check back in 30 seconds
	end

	AFK:SetAFK(UnitIsAFK('player') and not (E.Retail and C_PetBattles_IsInBattle()))
end

function AFK:Chat_OnMouseWheel(delta)
	if delta == 1 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	elseif delta == -1 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	end
end

function AFK:Chat_OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local chatType = strsub(event, 10)
	local info = _G.ChatTypeInfo[chatType]

	local coloredName
	if event == 'CHAT_MSG_BN_WHISPER' then
		coloredName = CH:GetBNFriendColor(arg2, arg13)
	else
		coloredName = CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	end

	local chatTarget
	local chatGroup = Chat_GetChatCategory(chatType)
	if chatGroup == 'BN_CONVERSATION' then
		chatTarget = tostring(arg8)
	elseif chatGroup == 'WHISPER' or chatGroup == 'BN_WHISPER' then
		if not(strsub(arg2, 1, 2) == '|K') then
			chatTarget = arg2:upper()
		else
			chatTarget = arg2
		end
	end

	local playerLink
	if chatType ~= 'BN_WHISPER' and chatType ~= 'BN_CONVERSATION' then
		playerLink = '|Hplayer:'..arg2..':'..arg11..':'..chatGroup..(chatTarget and ':'..chatTarget or '')..'|h'
	else
		playerLink = '|HBNplayer:'..arg2..':'..arg13..':'..arg11..':'..chatGroup..(chatTarget and ':'..chatTarget or '')..'|h'
	end

	--Escape any % characters, as it may otherwise cause an 'invalid option in format' error
	arg1 = gsub(arg1, '%%', '%%%%')

	--Remove groups of many spaces
	arg1 = RemoveExtraSpaces(arg1)

	-- isMobile
	if arg14 then
		arg1 = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..arg1
	end

	local success, body = pcall(format, _G['CHAT_'..chatType..'_GET']..arg1, playerLink..'['..coloredName..']'..'|h')
	if not success then
		E:Print('An error happened in the AFK Chat module. Please screenshot this message and report it. Info:', chatType, arg1, _G['CHAT_'..chatType..'_GET'])
		return
	end

	local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
	local typeID = ChatHistory_GetAccessID(chatType, chatTarget, arg12 == '' and arg13 or arg12)
	if CH.db.shortChannels then
		body = body:gsub('|Hchannel:(.-)|h%[(.-)%]|h', CH.ShortChannel)
		body = body:gsub('^(.-|h) '..L["whispers"], '%1')
		body = body:gsub('<'..AFKstr..'>', '[|cffFF9900'..L["AFK"]..'|r] ')
		body = body:gsub('<'..DNDstr..'>', '[|cffFF3333'..L["DND"]..'|r] ')
		body = body:gsub('%[BN_CONVERSATION:', '%['..'')
	end

	self:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID)
end

function AFK:Toggle()
	if E.db.general.afk then
		AFK:RegisterEvent('PLAYER_FLAGS_CHANGED', 'OnEvent')
		AFK:RegisterEvent('PLAYER_REGEN_DISABLED', 'OnEvent')
		AFK:RegisterEvent('LFG_PROPOSAL_SHOW', 'OnEvent')
		AFK:RegisterEvent('UPDATE_BATTLEFIELD_STATUS', 'OnEvent')

		SetCVar('autoClearAFK', '1')
	else
		AFK:UnregisterEvent('PLAYER_FLAGS_CHANGED')
		AFK:UnregisterEvent('PLAYER_REGEN_DISABLED')
		AFK:UnregisterEvent('LFG_PROPOSAL_SHOW')
		AFK:UnregisterEvent('UPDATE_BATTLEFIELD_STATUS')
	end

	if E.db.general.afkChat then
		chat:SetScript('OnEvent', AFK.Chat_OnEvent)
	else
		chat:SetScript('OnEvent', nil)
		chat:Clear()
	end
end

function AFK:LoopAnimations()
	local model = bottom.model
	if model.curAnimation == 'wave' then
		model:SetAnimation(69)
		model.curAnimation = 'dance'
		model.startTime = GetTime()
		model.duration = 300
		model.isIdle = false
		model.idleDuration = 120
	end
end

function AFK:ResetChatPosition(force)
	if force then
		chat:SetUserPlaced(false)
	end

	if not chat:IsUserPlaced() then
		chat:ClearAllPoints()
		chat:Point('TOPLEFT', afk, 'TOPLEFT', 4, -4)
	end
end

function AFK:OnKeyDown(key)
	if ignoreKeys[key] then return end

	if printKeys[key] then
		Screenshot()
	elseif AFK.isAFK then
		AFK:SetAFK(false)
		AFK:ScheduleTimer('OnEvent', 60)
	end
end

function AFK:Model_OnUpdate()
	if not self.isIdle then
		local timePassed = GetTime() - self.startTime
		if timePassed > self.duration then
			self:SetAnimation(0)
			self.isIdle = true

			AFK.animTimer = AFK:ScheduleTimer('LoopAnimations', self.idleDuration)
		end
	end
end

function AFK:Initialize()
	AFK.Initialized = true

	afk:SetFrameLevel(1)
	afk:SetScale(E.uiscale)
	afk:SetAllPoints(_G.UIParent)
	afk:EnableKeyboard(true)
	afk:SetScript('OnKeyDown', AFK.OnKeyDown)
	afk:Hide()

	chat:Size(500, 200)
	chat:FontTemplate()
	chat:SetJustifyH('LEFT')
	chat:SetMaxLines(500)
	chat:EnableMouseWheel(true)
	chat:SetFading(false)
	chat:EnableMouse(true)
	chat:RegisterForDrag('LeftButton')
	chat:SetScript('OnDragStart', chat.StartMoving)
	chat:SetScript('OnDragStop', chat.StopMovingOrSizing)
	chat:SetScript('OnMouseWheel', AFK.Chat_OnMouseWheel)
	AFK:ResetChatPosition()

	bottom:SetFrameLevel(0)
	bottom:SetTemplate('Transparent')
	bottom:Point('BOTTOM', afk, 'BOTTOM', 0, -E.Border)
	bottom:Width(E.screenWidth + (E.Border*2))
	bottom:Height(E.screenHeight * 0.10)

	local logoTop = afk:CreateTexture(nil, 'OVERLAY')
	logoTop:Size(320, 150)
	logoTop:Point('CENTER', bottom, 'CENTER', 0, 50)
	logoTop:SetTexture(E.Media.Textures.LogoTop)
	bottom.LogoTop = logoTop

	local logoBottom = afk:CreateTexture(nil, 'OVERLAY')
	logoBottom:Size(320, 150)
	logoBottom:Point('CENTER', bottom, 'CENTER', 0, 50)
	logoBottom:SetTexture(E.Media.Textures.LogoBottom)
	bottom.LogoBottom = logoBottom

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = E.myfaction, 140, -20, -16, -10, -28
	if factionGroup == 'Neutral' then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = 'Panda', 90, 15, 10, 20, -5
	end

	local faction = bottom:CreateTexture(nil, 'OVERLAY')
	faction:Point('BOTTOMLEFT', bottom, 'BOTTOMLEFT', offsetX, offsetY)
	faction:SetTexture(format([[Interface\Timer\%s-Logo]], factionGroup))
	faction:Size(size, size)
	bottom.faction = faction

	local classColor = E:ClassColor(E.myclass)
	local name = bottom:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(nil, 20)
	name:SetFormattedText('%s-%s', E.myname, E.myrealm)
	name:Point('TOPLEFT', bottom.faction, 'TOPRIGHT', nameOffsetX, nameOffsetY)
	name:SetTextColor(classColor.r, classColor.g, classColor.b)
	bottom.name = name

	local guild = bottom:CreateFontString(nil, 'OVERLAY')
	guild:FontTemplate(nil, 20)
	guild:SetText(L["No Guild"])
	guild:Point('TOPLEFT', bottom.name, 'BOTTOMLEFT', 0, -6)
	guild:SetTextColor(0.7, 0.7, 0.7)
	bottom.guild = guild

	local afkTime = bottom:CreateFontString(nil, 'OVERLAY')
	afkTime:FontTemplate(nil, 20)
	afkTime:SetText('00:00')
	afkTime:Point('TOPLEFT', bottom.guild, 'BOTTOMLEFT', 0, -6)
	afkTime:SetTextColor(0.7, 0.7, 0.7)
	bottom.time = afkTime

	--Use this frame to control position of the model
	local modelHolder = CreateFrame('Frame', nil, bottom)
	modelHolder:Size(150, 150)
	modelHolder:Point('BOTTOMRIGHT', bottom, 'BOTTOMRIGHT', -200, 220)
	bottom.modelHolder = modelHolder

	local model = CreateFrame('PlayerModel', 'ElvUIAFKPlayerModel', modelHolder)
	model:Point('CENTER', modelHolder, 'CENTER')
	model:Size(E.screenWidth * 2, E.screenHeight * 2) --YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	model:SetCamDistanceScale(4.5) --Since the model frame is huge, we need to zoom out quite a bit.
	model:SetFacing(6)
	model:SetScript('OnUpdate', AFK.Model_OnUpdate)
	bottom.model = model

	AFK:Toggle()

	AFK.isActive = false
end

E:RegisterModule(AFK:GetName())
