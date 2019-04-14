------------------------------------------------------------------------
-- Animation Functions
------------------------------------------------------------------------
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Lua functions
local random, tremove, strsub = random, tremove, strsub
--WoW API / Variables

E.AnimShake = {{-9,7,-7,12}, {-5,9,-9,5}, {-5,7,-7,5}, {-9,9,-9,9}, {-5,7,-7,5}, {-9,7,-9,5}}
E.AnimShakeH = {-5,5,-2,5,-2,5}

function E:FlashLoopFinished(requested)
	if not requested then self:Play() end
end

function E:RandomAnimShake(index)
	local s = E.AnimShake[index]
	return random(s[1], s[2]), random(s[3], s[4])
end

function E:SetUpAnimGroup(obj, Type, ...)
	if not Type then Type = 'Flash' end

	if strsub(Type, 1, 5) == 'Flash' then
		obj.anim = obj:CreateAnimationGroup('Flash')
		obj.anim.fadein = obj.anim:CreateAnimation('ALPHA', 'FadeIn')
		obj.anim.fadein:SetFromAlpha(0)
		obj.anim.fadein:SetToAlpha(1)
		obj.anim.fadein:SetOrder(2)

		obj.anim.fadeout = obj.anim:CreateAnimation('ALPHA', 'FadeOut')
		obj.anim.fadeout:SetFromAlpha(1)
		obj.anim.fadeout:SetToAlpha(0)
		obj.anim.fadeout:SetOrder(1)

		if Type == 'FlashLoop' then
			obj.anim:SetScript('OnFinished', E.FlashLoopFinished)
		end
	elseif strsub(Type, 1, 5) == 'Shake' then
		local shake = obj:CreateAnimationGroup(Type)
		shake:SetLooping('REPEAT')
		shake.path = shake:CreateAnimation('Path')

		if Type == 'Shake' then
			shake.path:SetDuration(0.7)
			obj.shake = shake
		elseif Type == 'ShakeH' then
			shake.path:SetDuration(2)
			obj.shakeh = shake
		end

		for i = 1, 6 do
			shake.path[i] = shake.path:CreateControlPoint()
			if Type == 'Shake' then
				shake.path[i]:SetOffset(E:RandomAnimShake(i))
			else
				shake.path[i]:SetOffset(E.AnimShakeH[i], 0)
			end
			shake.path[i]:SetOrder(i)
		end
	else
		local x, y, duration, customName = ...
		if not customName then customName = 'anim' end

		local anim = obj:CreateAnimationGroup('Move_In')
		obj[customName] = anim

		anim.in1 = anim:CreateAnimation('Translation')
		anim.in1:SetDuration(0)
		anim.in1:SetOrder(1)
		anim.in1:SetOffset(E:Scale(x), E:Scale(y))

		anim.in2 = anim:CreateAnimation('Translation')
		anim.in2:SetDuration(duration)
		anim.in2:SetOrder(2)
		anim.in2:SetSmoothing('OUT')
		anim.in2:SetOffset(E:Scale(-x), E:Scale(-y))

		anim.out1 = obj:CreateAnimationGroup('Move_Out')
		anim.out1:SetScript('OnFinished', function() obj:Hide() end)

		anim.out2 = anim.out1:CreateAnimation('Translation')
		anim.out2:SetDuration(duration)
		anim.out2:SetOrder(1)
		anim.out2:SetSmoothing('IN')
		anim.out2:SetOffset(E:Scale(x), E:Scale(y))
	end
end

function E:Shake(obj)
	if not obj.shake then
		E:SetUpAnimGroup(obj, 'Shake')
	end

	obj.shake:Play()
end

function E:StopShake(obj)
	if obj.shake then
		obj.shake:Finish()
	end
end

function E:ShakeHorizontal(obj)
	if not obj.shakeh then
		E:SetUpAnimGroup(obj, 'ShakeH')
	end

	obj.shakeh:Play()
end

function E:StopShakeHorizontal(obj)
	if obj.shakeh then
		obj.shakeh:Finish()
	end
end

function E:Flash(obj, duration, loop)
	if not obj.anim then
		E:SetUpAnimGroup(obj, loop and 'FlashLoop' or 'Flash')
	end

	if not obj.anim.playing then
		obj.anim.fadein:SetDuration(duration)
		obj.anim.fadeout:SetDuration(duration)
		obj.anim:Play()
		obj.anim.playing = true
	end
end

function E:StopFlash(obj)
	if obj.anim and obj.anim.playing then
		obj.anim:Stop()
	end
end

function E:SlideIn(obj, customName)
	if not customName then customName = 'anim' end
	if not obj[customName] then return end

	obj[customName].out1:Stop()
	obj[customName]:Play()
	obj:Show()
end

function E:SlideOut(obj, customName)
	if not customName then customName = 'anim' end
	if not obj[customName] then return end

	obj[customName]:Finish()
	obj[customName]:Stop()
	obj[customName].out1:Play()
end

local frameFadeManager = CreateFrame('FRAME')
local FADEFRAMES = {}

function E:UIFrameFade_OnUpdate(elapsed)
	local index = 1
	local frame, fadeInfo
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index]
		fadeInfo = FADEFRAMES[index].fadeInfo

		-- Reset the timer if there isn't one, this is just an internal counter
		fadeInfo.fadeTimer = (fadeInfo.fadeTimer or 0) + elapsed
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed

		-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
		if fadeInfo.fadeTimer < fadeInfo.timeToFade then
			if fadeInfo.mode == 'IN' then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha)
			elseif fadeInfo.mode == 'OUT' then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha)
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha)
			-- If there is a fadeHoldTime then wait until its passed to continue on
			if fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0  then
				fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed
			else
				-- Complete the fade and call the finished function if there is one
				E:UIFrameFadeRemoveFrame(frame)
				if fadeInfo.finishedFunc then
					fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4)
					fadeInfo.finishedFunc = nil
				end
			end
		end

		index = index + 1
	end

	if #FADEFRAMES == 0 then
		frameFadeManager:SetScript('OnUpdate', nil)
	end
end

-- Generic fade function
function E:UIFrameFade(frame, fadeInfo)
	if not frame then return end

	if not fadeInfo.mode then
		fadeInfo.mode = 'IN'
	end

	if fadeInfo.mode == 'IN' then
		if not fadeInfo.startAlpha then
			fadeInfo.startAlpha = 0
		end
		if not fadeInfo.endAlpha then
			fadeInfo.endAlpha = 1.0
		end
	elseif fadeInfo.mode == 'OUT' then
		if not fadeInfo.startAlpha then
			fadeInfo.startAlpha = 1.0
		end
		if not fadeInfo.endAlpha then
			fadeInfo.endAlpha = 0
		end
	end

	frame:SetAlpha(fadeInfo.startAlpha)
	frame.fadeInfo = fadeInfo

	if not frame:IsProtected() then
		frame:Show()
	end

	for index = 1, #FADEFRAMES do
		-- If frame is already set to fade then return
		if FADEFRAMES[index] == frame then
			return
		end
	end

	FADEFRAMES[#FADEFRAMES + 1] = frame
	frameFadeManager:SetScript('OnUpdate', E.UIFrameFade_OnUpdate)
end

-- Convenience function to do a simple fade in
function E:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {}
	fadeInfo.mode = 'IN'
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha
	fadeInfo.endAlpha = endAlpha
	E:UIFrameFade(frame, fadeInfo)
end

-- Convenience function to do a simple fade out
function E:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {}
	fadeInfo.mode = 'OUT'
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha
	fadeInfo.endAlpha = endAlpha
	E:UIFrameFade(frame, fadeInfo)
end

function E:UIFrameFadeRemoveFrame(frame)
	for index = 1, #FADEFRAMES do
		if frame == FADEFRAMES[index] then
			tremove(FADEFRAMES, index)
			break
		end
	end
end
