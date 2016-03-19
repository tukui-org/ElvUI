local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

--Cache global variables
--Lua functions
local assert, select, pairs, unpack = assert, select, pairs, unpack
local tinsert = tinsert
--WoW API / Variables
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo

function UF:Construct_AuraWatch(frame)
	local auras = CreateFrame("Frame", nil, frame)
	auras:SetFrameLevel(frame:GetFrameLevel() + 25)
	auras:SetInside(frame.Health)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.strictMatching = true;
	auras.icons = {}

	return auras
end

local counterOffsets = {
	['TOPLEFT'] = {6, 1},
	['TOPRIGHT'] = {-6, 1},
	['BOTTOMLEFT'] = {6, 1},
	['BOTTOMRIGHT'] = {-6, 1},
	['LEFT'] = {6, 1},
	['RIGHT'] = {-6, 1},
	['TOP'] = {0, 0},
	['BOTTOM'] = {0, 0},
}

local textCounterOffsets = {
	['TOPLEFT'] = {"LEFT", "RIGHT", -2, 0},
	['TOPRIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['BOTTOMLEFT'] = {"LEFT", "RIGHT", -2, 0},
	['BOTTOMRIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['LEFT'] = {"LEFT", "RIGHT", -2, 0},
	['RIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['TOP'] = {"RIGHT", "LEFT", 2, 0},
	['BOTTOM'] = {"RIGHT", "LEFT", 2, 0},
}

function UF:UpdateAuraWatchFromHeader(group, petOverride)
	assert(self[group], "Invalid group specified.")
	local group = self[group]
	for i=1, group:GetNumChildren() do
		local frame = select(i, group:GetChildren())
		if frame and frame.Health then
			UF:UpdateAuraWatch(frame, petOverride, group.db)
		elseif frame then
			for n = 1, frame:GetNumChildren() do
				local child = select(n, frame:GetChildren())
				if child and child.Health then
					UF:UpdateAuraWatch(child, petOverride, group.db)
				end
			end
		end
	end
end

function UF:UpdateAuraWatch(frame, petOverride, db)
	local buffs = {};
	local auras = frame.AuraWatch;
	local db = db and db.buffIndicator or frame.db.buffIndicator

	if not db.enable then
		auras:Hide()
		return;
	else
		auras:Show()
	end

	if frame.unit == 'pet' and not petOverride then
		local petWatch = E.global['unitframe'].buffwatch.PET or {}
		for _, value in pairs(petWatch) do
			if value.style == 'text' then value.style = 'NONE' end --depreciated
			tinsert(buffs, value);
		end
	else
		local buffWatch = not db.profileSpecific and (E.global['unitframe'].buffwatch[E.myclass] or {}) or (E.db['unitframe']['filters'].buffwatch or {})
		for _, value in pairs(buffWatch) do
			if value.style == 'text' then value.style = 'NONE' end --depreciated
			tinsert(buffs, value);
		end
	end

	--CLEAR CACHE
	if auras.icons then
		for i=1, #auras.icons do
			local matchFound = false;
			for j=1, #buffs do
				if #buffs[j].id and #buffs[j].id == auras.icons[i] then
					matchFound = true;
					break;
				end
			end

			if not matchFound then
				auras.icons[i]:Hide()
				auras.icons[i] = nil;
			end
		end
	end

	local unitframeFont = LSM:Fetch("font", E.db['unitframe'].font)

	for i=1, #buffs do
		if buffs[i].id then
			local name, _, image = GetSpellInfo(buffs[i].id);
			if name then
				local icon
				if not auras.icons[buffs[i].id] then
					icon = CreateFrame("Frame", nil, auras);
				else
					icon = auras.icons[buffs[i].id];
				end
				icon.name = name
				icon.image = image
				icon.spellID = buffs[i].id;
				icon.anyUnit = buffs[i].anyUnit;
				icon.style = buffs[i].style;
				icon.onlyShowMissing = buffs[i].onlyShowMissing;
				icon.presentAlpha = icon.onlyShowMissing and 0 or 1;
				icon.missingAlpha = icon.onlyShowMissing and 1 or 0;
				icon.textThreshold = buffs[i].textThreshold or -1
				icon.displayText = buffs[i].displayText
				icon.decimalThreshold = buffs[i].decimalThreshold

				icon:Width(db.size);
				icon:Height(db.size);
				--Protect against missing .point value
				if not buffs[i].point then buffs[i].point = "TOPLEFT" end
				
				icon:ClearAllPoints()
				icon:Point(buffs[i].point or "TOPLEFT", frame.Health, buffs[i].point or "TOPLEFT", buffs[i].xOffset, buffs[i].yOffset);

				if not icon.icon then
					icon.icon = icon:CreateTexture(nil, "BORDER");
					icon.icon:SetAllPoints(icon);
				end

				if not icon.text then
					local f = CreateFrame('Frame', nil, icon)
					f:SetFrameLevel(icon:GetFrameLevel() + 50)
					icon.text = f:CreateFontString(nil, 'BORDER');
				end

				if not icon.border then
					icon.border = icon:CreateTexture(nil, "BACKGROUND");
					icon.border:Point("TOPLEFT", -E.mult, E.mult);
					icon.border:Point("BOTTOMRIGHT", E.mult, -E.mult);
					icon.border:SetTexture(E["media"].blankTex);
					icon.border:SetVertexColor(0, 0, 0);
				end

				if not icon.cd then
					icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
					icon.cd:SetAllPoints(icon)
					icon.cd:SetReverse(true)
					icon.cd:SetHideCountdownNumbers(true)
					icon.cd:SetFrameLevel(icon:GetFrameLevel())
				end

				if icon.style == 'coloredIcon' then
					icon.icon:SetTexture(E["media"].blankTex);

					if (buffs[i]["color"]) then
						icon.icon:SetVertexColor(buffs[i]["color"].r, buffs[i]["color"].g, buffs[i]["color"].b);
					else
						icon.icon:SetVertexColor(0.8, 0.8, 0.8);
					end
					icon.icon:Show()
					icon.border:Show()
					icon.cd:SetAlpha(1)
				elseif icon.style == 'texturedIcon' then
					icon.icon:SetVertexColor(1, 1, 1)
					icon.icon:SetTexCoord(.18, .82, .18, .82);
					icon.icon:SetTexture(icon.image);
					icon.icon:Show()
					icon.border:Show()
					icon.cd:SetAlpha(1)
				else
					icon.border:Hide()
					icon.icon:Hide()
					icon.cd:SetAlpha(0)
				end

				if icon.displayText then
					icon.text:Show()
					local r, g, b = 1, 1, 1
					if buffs[i].textColor then
						r, g, b = buffs[i].textColor.r, buffs[i].textColor.g, buffs[i].textColor.b
					end

					icon.text:SetTextColor(r, g, b)
				else
					icon.text:Hide()
				end

				if not icon.count then
					icon.count = icon:CreateFontString(nil, "OVERLAY");
				end

				icon.count:ClearAllPoints()
				if icon.displayText then
					local point, anchorPoint, x, y = unpack(textCounterOffsets[buffs[i].point])
					icon.count:Point(point, icon.text, anchorPoint, x, y)
				else
					icon.count:Point("CENTER", unpack(counterOffsets[buffs[i].point]));
				end

				icon.count:FontTemplate(unitframeFont, db.fontSize, E.db['unitframe'].fontOutline);
				icon.text:FontTemplate(unitframeFont, db.fontSize, E.db['unitframe'].fontOutline);
				icon.text:ClearAllPoints()
				icon.text:Point(buffs[i].point, icon, buffs[i].point)

				if buffs[i].enabled then
					auras.icons[buffs[i].id] = icon;
					if auras.watched then
						auras.watched[buffs[i].id] = icon;
					end
				else
					auras.icons[buffs[i].id] = nil;
					if auras.watched then
						auras.watched[buffs[i].id] = nil;
					end
					icon:Hide();
					icon = nil;
				end
			end
		end
	end

	if frame.AuraWatch.Update then
		frame.AuraWatch.Update(frame)
	end

	frame:UpdateElement("AuraWatch")

	buffs = nil;
end