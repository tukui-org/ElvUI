------------------------------------------------------------------------
-- Animation Functions
------------------------------------------------------------------------
local E, L, V, P, G = unpack(ElvUI)

local _G = _G
local issecurevariable = issecurevariable
local random, next, unpack, strsub = random, next, unpack, strsub

--[[ just to test the number thing
	local t = UIParent:CreateFontString(nil, 'OVERLAY', 'GameTooltipText')
	t:SetText(0)
	t:Point('CENTER')
	t:FontTemplate(nil, 20)
	E:SetUpAnimGroup(t, 'Number', 10, 5)

	local b = CreateFrame('BUTTON', nil, UIParent)
	b:Point('CENTER', 0, -100)
	b:SetTemplate()
	b:Size(40, 30)
	b:EnableMouse(true)
	b:SetScript('OnClick', function()
		if t:GetText() == 10 then
			t.NumberAnim:SetChange(0)
			t.NumberAnimGroup:Play()
		else
			t.NumberAnim:SetChange(10)
			t.NumberAnimGroup:Play()
		end
	end)
]]

E.AnimShake = {{-9,7,-7,12}, {-5,9,-9,5}, {-5,7,-7,5}, {-9,9,-9,9}, {-5,7,-7,5}, {-9,7,-9,5}}
E.AnimShakeH = {-5,5,-2,5,-2,5}
E.AnimMoveOut = function(out1) out1.parent:Hide() end
E.AnimElastic = {
	function(anim) anim:Stop() anim.elastic[2]:Play() end,
	function(anim) anim:Stop() if anim.loop then anim.elastic[1]:Play() end end,
	function(anim) anim:Stop() anim.elastic[4]:Play() end,
	function(anim) anim:Stop() if anim.loop then anim.elastic[3]:Play() end end
}

function E:FlashLoopFinished(requested)
	if not requested then self:Play() end
end

function E:RandomAnimShake(index)
	local p1, p2, p3, p4 = unpack(E.AnimShake[index])
	return random(p1, p2), random(p3, p4)
end

function E:SetUpAnimGroup(obj, animType, ...)
	if not animType then -- default it to something basic
		animType = 'Flash'
	end

	local shortType = strsub(animType, 1, 5)
	if shortType == 'Flash' then
		obj.anim = obj:CreateAnimationGroup('Flash')
		obj.anim.fadein = obj.anim:CreateAnimation('ALPHA', 'FadeIn')
		obj.anim.fadein:SetFromAlpha(0)
		obj.anim.fadein:SetToAlpha(1)
		obj.anim.fadein:SetOrder(2)

		obj.anim.fadeout = obj.anim:CreateAnimation('ALPHA', 'FadeOut')
		obj.anim.fadeout:SetFromAlpha(1)
		obj.anim.fadeout:SetToAlpha(0)
		obj.anim.fadeout:SetOrder(1)

		if animType == 'FlashLoop' then
			obj.anim:SetScript('OnFinished', E.FlashLoopFinished)
		end
	elseif shortType == 'Shake' then
		local shake = obj:CreateAnimationGroup(animType)
		shake:SetLooping('REPEAT')
		shake.path = shake:CreateAnimation('Path')

		if animType == 'Shake' then
			shake.path:SetDuration(0.7)
			obj.shake = shake
		elseif animType == 'ShakeH' then
			shake.path:SetDuration(2)
			obj.shakeh = shake
		end

		for i = 1, 6 do
			local point = shake.path:CreateControlPoint()
			point:SetOrder(i)

			if animType == 'Shake' then
				point:SetOffset(E:RandomAnimShake(i))
			else
				point:SetOffset(E.AnimShakeH[i], 0)
			end

			shake.path[i] = point
		end
	elseif animType == 'Elastic' then
		local width, height, duration, loop = ...
		local elastic = _G.CreateAnimationGroup(obj)
		obj.elastic = elastic

		for i = 1, 4 do
			local anim = elastic:CreateAnimation(i < 3 and 'width' or 'height')
			anim:SetChange((i==1 and width*0.45) or (i==2 and width) or (i==3 and height*0.45) or height)
			anim:SetEasing('inout-elastic')
			anim:SetDuration(duration)
			anim:SetScript('OnFinished', E.AnimElastic[i])
			anim.elastic = elastic
			anim.loop = loop

			elastic[i] = anim
		end
	elseif animType == 'Number' then
		local endingNumber, duration = ...
		obj.NumberAnimGroup = _G.CreateAnimationGroup(obj)
		obj.NumberAnim = obj.NumberAnimGroup:CreateAnimation('number')
		obj.NumberAnim:SetChange(endingNumber)
		obj.NumberAnim:SetEasing('in-circular')
		obj.NumberAnim:SetDuration(duration)
	else
		local x, y, duration, customName = ...
		local anim = obj:CreateAnimationGroup('Move_In')
		obj[customName or 'anim'] = anim

		-- anim play will cause it to move
		anim.in1 = anim:CreateAnimation('Translation')
		anim.in1:SetDuration(0)
		anim.in1:SetOrder(1)
		anim.in1:SetOffset(x, y)

		anim.in2 = anim:CreateAnimation('Translation')
		anim.in2:SetDuration(duration)
		anim.in2:SetOrder(2)
		anim.in2:SetSmoothing('OUT')
		anim.in2:SetOffset(-x, -y)

		-- out animation to play backwards (to start position of anim play)
		anim.out1 = obj:CreateAnimationGroup('Move_Out')
		anim.out1:SetScript('OnFinished', E.AnimMoveOut)
		anim.out1.parent = obj

		anim.out2 = anim.out1:CreateAnimation('Translation')
		anim.out2:SetDuration(duration)
		anim.out2:SetOrder(1)
		anim.out2:SetSmoothing('IN')
		anim.out2:SetOffset(x, y)
	end
end

function E:Elasticize(obj, width, height)
	if not obj.elastic then
		E:SetUpAnimGroup(obj, 'Elastic', width or obj:GetWidth(), height or obj:GetHeight(), 2, false)
	end

	obj.elastic[1]:Play()
	obj.elastic[3]:Play()
end

function E:StopElasticize(obj)
	if obj.elastic then
		obj.elastic[1]:Stop(true)
		obj.elastic[3]:Stop(true)
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

	if not obj.anim:IsPlaying() then
		obj.anim.fadein:SetDuration(duration)
		obj.anim.fadeout:SetDuration(duration)
		obj.anim:Play()
	end
end

function E:StopFlash(obj)
	if obj.anim and obj.anim:IsPlaying() then
		obj.anim:Stop()
	end
end

function E:SlideIn(obj, customName)
	local anim = obj[customName or 'anim']
	if not anim then return end

	anim.out1:Stop() -- out1 OnFinish will call Hide, see SlideOut
	anim:Play()
	obj:Show() -- Show is likely a secure var
end

function E:SlideOut(obj, customName)
	local anim = obj[customName or 'anim']
	if not anim then return end

	anim:Finish()
	anim:Stop()
	anim.out1:Play() -- triggers AnimMoveOut which calls Hide (likely secure var) on obj
end

local FADEFRAMES, FADEMANAGER = {}, CreateFrame('FRAME')
FADEMANAGER.delay = 0.05

function E:UIFrameFade_OnUpdate(elapsed)
	FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

	if FADEMANAGER.timer > FADEMANAGER.delay then
		FADEMANAGER.timer = 0

		for frame, info in next, FADEFRAMES do
			-- Reset the timer if there isn't one, this is just an internal counter
			if frame:IsVisible() then
				info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.delay)
			else
				info.fadeTimer = info.timeToFade + 1
			end

			-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
			if info.fadeTimer < info.timeToFade then
				if info.mode == 'IN' then
					frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
				else
					frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
				end
			else
				frame:SetAlpha(info.endAlpha)

				-- If there is a fadeHoldTime then wait until its passed to continue on
				if info.fadeHoldTime and info.fadeHoldTime > 0 then
					info.fadeHoldTime = info.fadeHoldTime - elapsed
				else
					-- Complete the fade and call the finished function if there is one
					E:UIFrameFadeRemoveFrame(frame)

					if info.finishedFunc then
						if info.finishedArgs then
							info.finishedFunc(unpack(info.finishedArgs))
						else -- optional method
							info.finishedFunc(info.finishedArg1, info.finishedArg2, info.finishedArg3, info.finishedArg4, info.finishedArg5)
						end

						if not info.finishedFuncKeep then
							info.finishedFunc = nil
						end
					end
				end
			end
		end

		if not next(FADEFRAMES) then
			FADEMANAGER:SetScript('OnUpdate', nil)
		end
	end
end

-- Generic fade function
function E:UIFrameFade(frame, info)
	if not frame or frame:IsForbidden() then return end

	if not info.mode then
		info.mode = 'IN'
	end

	if info.mode == 'IN' then
		if not info.startAlpha then info.startAlpha = 0 end
		if not info.endAlpha then info.endAlpha = 1 end
		if not info.diffAlpha then info.diffAlpha = info.endAlpha - info.startAlpha end
	else
		if not info.startAlpha then info.startAlpha = 1 end
		if not info.endAlpha then info.endAlpha = 0 end
		if not info.diffAlpha then info.diffAlpha = info.startAlpha - info.endAlpha end
	end

	frame.fadeInfo = info
	frame:SetAlpha(info.startAlpha)

	if not FADEFRAMES[frame] then
		FADEFRAMES[frame] = info -- read below comment
		FADEMANAGER:SetScript('OnUpdate', E.UIFrameFade_OnUpdate)
	else
		FADEFRAMES[frame] = info -- keep these both, we need this updated in the event its changed to another ref from a plugin or sth, don't move it up!
	end
end

-- Convenience function to do a simple fade in
function E:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	if not frame or frame:IsForbidden() then return end

	if frame.FadeObject then
		frame.FadeObject.fadeTimer = nil
	else
		frame.FadeObject = {}
	end

	frame.FadeObject.mode = 'IN'
	frame.FadeObject.timeToFade = timeToFade
	frame.FadeObject.startAlpha = startAlpha
	frame.FadeObject.endAlpha = endAlpha
	frame.FadeObject.diffAlpha = endAlpha - startAlpha

	E:UIFrameFade(frame, frame.FadeObject)
end

-- Convenience function to do a simple fade out
function E:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	if not frame or frame:IsForbidden() then return end

	if frame.FadeObject then
		frame.FadeObject.fadeTimer = nil
	else
		frame.FadeObject = {}
	end

	frame.FadeObject.mode = 'OUT'
	frame.FadeObject.timeToFade = timeToFade
	frame.FadeObject.startAlpha = startAlpha
	frame.FadeObject.endAlpha = endAlpha
	frame.FadeObject.diffAlpha = startAlpha - endAlpha

	E:UIFrameFade(frame, frame.FadeObject)
end

function E:UIFrameFadeRemoveFrame(frame)
	if frame and FADEFRAMES[frame] then
		if frame.FadeObject then
			frame.FadeObject.fadeTimer = nil
		end

		FADEFRAMES[frame] = nil
	end
end
