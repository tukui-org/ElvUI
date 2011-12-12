-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Spam Filter")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Spam Filter"]

local format			= string.format
local find				= string.find
local match				= string.match

local complaintAdded	= COMPLAINT_ADDED
local prevReportTime	= 0
local prevLineID		= 0
local prevMessage		= nil
local prevPlayer		= nil
local filterResult		= nil
local debug				= false -- for debugging purposes

local db
local options
local defaults = {
	profile = {
		spamGoldSelling			= true,
		spamAutoReport			= true,
		spamReportConfirm		= false,
		spamReportSilent		= false,
		spamGuildRecruit		= true,
		spamRemoveIcons			= false,
	}
}

-- from BadBoy
local function IsSpam(message)
	local points, phish, strict, icon = 0, 0, false, false
	local trigs = Module.triggers["GoldSelling"]
	for i = 1, #trigs do
		if find(message, trigs[i]) then
			if i > 92 then -- instant report
				points = points + 9
			elseif i > 67 and i < 93 then
				phish = phish + 1
			elseif i > 58 and i < 68 and not icon then
				points = points + 1
				icon = true
			elseif i > 52 and i < 59 and not strict then
				points = points + 2
				phish = phish + 1
				strict = true
			elseif i > 41 and i < 53 then
				points = points + 2
			elseif i > 7 and i < 42 then
				points = points + 1
			elseif i < 8 then
				-- remove points for safe words
				points = points - 2
				phish = phish - 2
			end
			if debug then print(i, trigs[i], message, points, phish) end
			if points > 3 or phish > 3 then
				return true
			end
		end
	end
end

local function FilterChat(_, channel, message, player, _, _, _, flag, channelID, _, _, _, lineID)
	local guildTrigs, iconTrigs = Module.triggers["Guild"], Module.triggers["RaidIcons"]
	if lineID == prevLineID then
		-- prevent duplicate messages from being reported
		return filterResult
	else
		prevLineID = lineID -- for above
		
		-- only scan officials channels (general, trade, etc.) not custom channels (minus guild recruitment)
		if channel == "CHAT_MSG_CHANNEL" and (channelID == 0 or channelID == 25) then filterResult = nil; return end
		-- dont scan ourselves/friends/GMs/guildies/etc.
		if not CanComplainChat(lineID) or UnitIsInMyGuild(player) or UnitInRaid(player) or UnitInParty(player) then filterResult = nil; return end
	
		-- check whispers
		if channel == "CHAT_MSG_WHISPER" then
			if flag == "GM" then filterResult = nil; return end -- dont scan GM messages
			
			for i = 1, select(2, BNGetNumFriends()) do
				local toon = BNGetNumFriendToons(i)
				for x = 1, toon do
					local _, name, game = BNGetFriendToonInfo(i, x)
					if name == player and game == "WoW" then filterResult = nil; return end
				end
			end
		end
	end
	
	-- powerleveling, gold selling, etc.
	if db.spamGoldSelling and IsSpam(message:lower():gsub(" ", "")) then
		
		-- dont report the same person twice
		if message == prevMessage and player == prevPlayer then filterResult = true; return true; end
		
		-- save for later
		prevMessage	= message
		prevPlayer	= player	
		
		local now = GetTime()
		-- dont report too fast!
		if (now - prevReportTime) > 0.5 then
			prevReportTime = now
			COMPLAINT_ADDED = "|cff33ff99ElvUI_ChatTweaks:|r " .. complaintAdded .. " |Hplayer:"..player.."|h["..player.."]|h"			
			if debug then 
				print(message, "-", channel, "-", player)
			else
				if db.spamReportConfirm then
					StaticPopupDialogs["CONFIRM_REPORT_SPAM_CHAT"].text = REPORT_SPAM_CONFIRMATION .. "\n\n" .. message:gsub("%%", "%%%%")
					local dialog = StaticPopup_Show("CONFIRM_REPORT_SPAM_CHAT", player)
					dialog.data = lineID
				else
					ComplainChat(lineID)
				end
			end
		end
		filterResult = true
		return true
	end
		
	-- guild recruitment spam
	if db.spamGuildRecruit and channel == "CHAT_MSG_CHANNEL" then
		message = message:lower()
		for i = 1, #guildTrigs do
			if message:find(guildTrigs[i]) then
				if debug then print(message, "-", guildTrigs[i], "-", player) end
				filterResult = true
				return true
			end
		end
	end
	
	-- remove raid icons from channels they dont belong
	if db.spamRemoveIcons then
		for i = 1, #iconTrigs do
			message, found = message:gsub(iconTrigs[i], "")
			if found > 0 then modify = true end
		end
		-- only filter if the message was modified
		if modify then return false, message, player, _, _, _, flag, channelID, _, _, _, lineID end
	end
	
	filterResult = nil
end

-- system messages get their own filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
	if not db.spamGoldSelling then return false end
	if message == complaintAdded then
		return -- manual report, so dont do anything
	elseif message == COMPLAINT_ADDED then
		COMPLAINT_ADDED = complaintAdded
		
		if db.spamReportConfirm then
			StaticPopupDialogs["CONFIRM_REPORT_SPAM_CHAT"].text = REPORT_SPAM_CONFIRMATION
		end
		
		if db.spamReportSilent then
			return true
		end
	else
		SetCVar("spamFilter", 1) -- let blizzard's spam filter help us :-)
	end
end)

function Module:OnEnable()
	local filterChannels = {
		"%s_CHANNEL", "%s_SAY", "%s_YELL", "%s_WHISPER",
		"%s_EMOTE", "%s_DND", "%s_AFK"
	}
	for _, channel in pairs(filterChannels) do
		ChatFrame_AddMessageEventFilter(format(channel, "CHAT_MSG"), FilterChat)
	end
	filterChannels = nil
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("SpamFilter", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Filters text based on numerous triggers, with the ability to automatically report the offender."]
end

function Module:GetOptions()
	if not options then
		options = {
			spamGoldSelling 	= {
				type		= "toggle",
				name		= L["Gold Selling"],
				desc		= L["Filters gold selling, powerleveling, and other services that are against Blizzard's EULA."],
				get			= function() return db.spamGoldSelling end,
				set			= function(_, value) db.spamGoldSelling = value end,
			},
			spamGuildRecruit	= {
				type		= "toggle",
				name		= L["Guild Recruitment"],
				desc		= L["Filters guild recruitment messages.\n\n|cffff0000DOES NOT REPORT THEM!|r"],
				get			= function() return db.spamGuildRecruit end,
				set			= function(_, value) db.spamGuildRecruit = value end,
			},
			spamRemoveIcons	= {
				type		= "toggle",
				name		= L["Remove Icons"],
				desc		= L["Removes icons from messages to prevent the various objects people try to make."],
				get			= function() return db.spamRemoveIcons end,
				set			= function(_, value) db.spamRemoveIcons = value end,
			},
			spamReportingOptions	= {
				type		= "group",
				guiInline	= true,
				order		= 100,
				name		= L["Reporting Options"],
				disabled	= function() return not db.spamGoldSelling end,
				args		= {
					spamAutoReport		= {
						type		= "toggle",
						order		= 1,
						name		= L["Report"],
						desc		= L["Auto report anyone reaching the spam threshold (3 points)."],
						get			= function() return db.spamAutoReport end,
						set			= function(_, value) db.spamAutoReport = value end,
					},
					spamReportConfirm	= {
						type		= "toggle",
						order		= 2,
						name		= L["Confirm Report?"],
						desc		= L["Confirm reporting before actually reporting them."],
						disabled	= function() return not db.spamAutoReport end,
						get			= function() return db.spamReportConfirm end,
						set			= function(_, value) db.spamReportConfirm = value end,
					},
					spamReportSilent	= {
						type		= "toggle",
						order		= 3,
						name		= L["Silent Report"],
						desc		= L["Surpress the reporting system message."],
						disabled	= function() return not db.spamAutoReport end,
						get			= function() return db.spamReportSilent end,
						set			= function(_, value) db.spamReportSilent = value end,
					},
				}
			}
		}
	end
	return options
end

-- most are from BadBoy line of chat filters with my own goodies sprinkled in
Module.triggers = {
	["RaidIcons"]	= {	-- raid icons for various faces/shapes people make
		"{rt%d}",
		"{RT%d}",
		"{x}",
		"{X}",
		"{"..(RAID_TARGET_1):lower().."}",
		"{"..(RAID_TARGET_2):lower().."}",
		"{"..(RAID_TARGET_3):lower().."}",
		"{"..(RAID_TARGET_4):lower().."}",
		"{"..(RAID_TARGET_5):lower().."}",
		"{"..(RAID_TARGET_6):lower().."}",
		"{"..(RAID_TARGET_7):lower().."}",
		"{"..(RAID_TARGET_8):lower().."}",
		"{"..(RAID_TARGET_1):upper().."}",
		"{"..(RAID_TARGET_2):upper().."}",
		"{"..(RAID_TARGET_3):upper().."}",
		"{"..(RAID_TARGET_4):upper().."}",
		"{"..(RAID_TARGET_5):upper().."}",
		"{"..(RAID_TARGET_6):upper().."}",
		"{"..(RAID_TARGET_7):upper().."}",
		"{"..(RAID_TARGET_8):upper().."}",
	},
	
	["GoldSelling"] = {	-- gold selling + powerleveling spam
		--White
		"recruit", --1
		"dkp", --2
		"looking", --3 --guild
		"lf[gm]", --4
		"|cff", --5
		"raid", --6
		"roleplay", --7

		--English - Common
		"bonus", --8
		"buy", --9
		"cheap", --10
		"code", --11
		"coupon", --12
		"customer", --13
		"deliver", --14
		"discount", --15
		"express", --16
		"gold", --17
		"lowest", --18
		"order", --19
		"powerle?ve?l", --20
		"price", --21
		"promoti[on][gn]", --22
		"reduced", --23
		"rocket", --24
		"sa[fl]e", --25
		"server", --26
		"service", --27
		"stock", --28
		"well?come", --29

		--French - Common
		"livraison", --delivery --30

		--German - Common
		"billigster", --cheapest --31
		"lieferung", --delivery --32
		"preis", --price --33
		"willkommen", --welcome --34

		--Spanish - Common
		"barato", --cheap --35
		"gratuito", --free --36
		"r[\195\161a]+pido", --fast --37
		"seguro", --safe/secure --38
		"servicio", --service --39

		--Chinese - Common
		"金币", --gold currency --40
		"大家好", --hello everyone --41

		--Heavy
		"[\226\130\172%$\194\163]+%d+[%.%-]?%d*[fp][oe]r%d+%.?%d*[kg]", --42 --Add separate line if they start approx prices
		"[\226\130\172%$\194\163]+%d+%.?%d*[/\\=]%d+%.?%d*[kg]", --43
		"%d+%.?%d*eur?o?s?[fp][oe]r%d+%.?%d*[kg]", --44
		"%d+%.?%d*[\226\130\172%$\194\163]+[/\\=%-]%d+%.?%d*[kg]", --45
		"%d+%.?%d*[kg][/\\=][\226\130\172%$\194\163]+%d+", --46
		"%d+%.?%d*[kg][/\\=]%d+%.?%d*[\226\130\172%$\194\163]+", --47
		"%d+%.?%d*[kg][/\\=]%d+[%.,]?%d*eu", --48
		"%d+%.?%d*eur?o?s?[/\\=]%d+%.?%d*[kg]", --49
		"%d+%.?%d*usd[/\\=]%d+%.?%d*[kg]", --50
		"%d+%.?%d*usd[fp][oe]r%d+%.?%d*[kg]", --51
		"%d+%.?%d*кзa%d+%.?%d*р", -- 52

		--Heavy Strict
		"www[%.,{]", --53
		"[%.,]c%-?[o0@]%-?m", --54
		"[%.,]c{circle}m", --55
		"[%.,]c{rt2}m", --56
		"[%.,]cqm", --57
		"[%.,]net", --58

		--Icons
		"{rt%d}", --59
		"{star}", --60
		"{circle}", --61
		"{diamond}", --62
		"{triangle}", --63
		"{moon}", --64
		"{square}", --65
		"{cross}", --66
		"{цр%d}", --Russian -- 67

		--Phishing - English
		"account", --68
		"blizz", --69
		"claim", --70
		"congratulations", --71
		"free", --72
		"gamemaster", --73
		"gift", --74
		"investigat", --75
		"launch", --76
		"log[io]n", --77
		"luckyplayer", --78
		"mount", --79
		"pleasevisit", --80
		"receive", --81
		"service", --82
		"surprise", --83
		"suspe[cn][td]", --84 --suspect/suspend
		"system", --85
		"validate", --86

		--hello![Game Master]GM: Your world of warcraft account has been temporarily suspended. go to  [http://www.*********.com/wow.html] for further informatio

		--Phishing - German
		"berechtigt", --entitled --87
		"erhalten", --get/receive --88
		"deaktiviert", --deactivated --89
		"konto", --acount --90
		"kostenlos", --free --91
		"qualifiziert", --qualified --92

	--Personal Whispers
	"so?rr?y.*%d+[kg].*stock.*buy", --sry to bother, we have 60k g in stock today. do u wanna buy some?:)
	"server.*purchase.*gold.*deliv", --sorry to bother,currently we have 29200g on this server, wondering if you might purchase some gold today? 15mins delivery:)
	"%d+.*lfggameteam", --actually we have 10kg in stock from Lfggame team ,do you want some?
	"free.*powerleveling.*level.*%d+.*interested", --Hello there! I am offering free powerleveling from level 70-80! Perhaps you are intrested? :)v
	"friend.*price.*%d+k.*gold", --dear friend.. may i tell you the price for 10k wow gold ?^^
	"we.*%d+k.*stock.*realm", --hi, we got 25k+++ in stock on this realm. r u interested?:P
	"we.*%d+k.*gold.*buy", --Sorry to bother. We got around 27.4k gold on this server, wondering if you might buy some quick gold with face to face trading ingame?
	"so?rr?y.*interest.*cheap.*gold", --sorry to trouble you , just wondering whether you have  any interest in getting some cheap gold at this moment ,dear dude ? ^^
	"we.*%d+k.*stock.*interest", --hi,we have 40k in stock today,interested ?:)
	"we.*%d%d%d+g.*stock.*price", --hi,we have the last 23600g in stock now ,ill give you the bottom price.do u need any?:D
	"hi.*%d%d+k.*stock.*interest", --hi ,30k++in stock any interest?:)
	"wondering.*you.*need.*buy.*g.*so?r?ry", --I am sunny, just wondering if you might need to buy some G. If not, sry to bother.:)
	"buy.*wow.*curr?ency.*deliver", --Would u like to buy WOW CURRENCY on our site?:)We deliver in 5min:-)
	"interest.*%d+kg.*price.*delive", --:P any interested in the last 30kg with the bottom price.. delivery within 5 to 10 mins:)
	"sorr?y.*bother.*another.*wow.*account.*use", --Hi,mate,sorry to bother,may i ask if u have another wow account that u dont use?:)
	"hello.*%d%d+k.*stock.*buy.*now", --hello mate :) 40k stock now,wanna buy some now?^^
	"price.*%d%d+g.*sale.*gold", --Excuse me. Bottom price!.  New and fresh 30000 G is for sale. Are you intrested in buying some gold today?
	"so?rr?y.*you.*tellyou.*%d+k.*wow.*gold", --sorry to bother you,may i tell you how much for 5k wow gold
	"excuse.*do.*need.*buy.*wow.*gold", --Excuse me,do u need to buy some wowgold?
	"bother.*%d%d%d+g.*server.*quick.*gold", --Sry to bother you, We have 57890 gold on this server do you want to purchase some quick gold today?
	"hey.*interest.*some.*fast.*%d+kg.*left", --hey,interested in some g fast?got 27kg left atm:)
	"know.*need.*buy.*gold.*delivery", --hi,its kitty here. may i know if you need to buy some quick gold today. 20-50 mins delivery speed,
	"may.*know.*have.*account.*don.*use", -- Hi ,May i know if you have an useless account that you dont use now ? :)
	"company.*le?ve?l.*char.*%d%d.*free", --our company  can lvl your char to lvl 80 for FREE.
	"so?r?ry.*need.*cheap.*gold.*%d+", --sorry to disurb you. do you need some cheap gold 20k just need 122eur(108GBP)
	"stock.*gold.*wonder.*buy.*so?rr?y", --Full stock gold! Wondering you might wanna buy some today ? sorry for bothering you.
	"hi.*you.*need.*gold.*we.*promotion", --[hi.do] you need some gold atm?we now have a promotion for it ^^
	"brbgame.*need.*gold.*only.*fast.*deliver", --sry to bother i am maria from brbgame, may i pease enquire as to whether u r in need of wow gold ?:P only 3$ per k with fast delivery !\
	"so?r?ry.*bother.*still.*%d+k.*left.*buy.*gold", --sry to bother you ,we still have around 52k left atm, you wanna buy some gold quickly today ?
	"may.*ask.*whether.*interest.*ing.*boe.*stuff.*rocket", --hmm, may i ask whether u r interested in g or boe stuffs such as X-53 Touring Rocket:P

	--Casino
	"%d+%-%d+.*d[ou][ub]ble.*%d+%-%d+.*trip", --10 minimum 400 max\roll\61-97 double, 98-100 triple, come roll,
	"casino.*%d+x2.*%d+x3", --{star} CASINO {star} roll 64-99x2 your wager roll 100x3 your wager min bet 50g max 10k will show gold 100% legit (no inbetween rolls plz){diamond} good luck {diamond}
	"casino.*%d+.*double.*%d+.*tripp?le", --The Golden Casino is offering 60+ Doubles, and 80+ Tripples!
	"casino.*whisper.*info", --<RollReno's Casino> <Whisper for more information!>
	"d[ou][ub]ble.*%d+%-%d+.*%d+%-%d+.*tripp?le", --come too the Free Roller  gaming house!  and have ur luck of winning gold! :) pst me for invite:)  double is  62-96 97-100 tripple we also play blackjack---- u win double if you beat the host in blackjack
	"d[ou][ub]ble.*%d+%-%d+.*tripp?le.*%d+%-%d+", --come to free roller gaming house! and have u luck of winning gold :) pst for invite :) double is 62-96 triple is 97-100. we also play blacjack---u win doubleif u beat host in blacjack
	"casino.*bet.*%d+%-%d+", --Casino time. You give me your bet, Than You roll from 1-11 unlimited times.Your rolls add up. If you go over 21 you lose.You can stop before 21.When you stop I do the same, and if your closer to 21 than me than you get back 2 times your bet
	"roll.*%d+.*roll.*%d+.*bet", --Roll 63+ x2 , Roll 100 x3, Roll 1 x4 NO MAX BETS

	--Russian
	--[skull]Ovoschevik.rf[skull] continues to harm the enemy, to please you with fresh [circle]vegetables! BC 450. Operators of girls waiting for you!
	"{.*}.*oвoщeвик%.рф.*{.*}", --[skull]Овощевик.рф[skull] продолжает, на зло врагaм, радовaть вас свежими [circle]oвoщaми! Бл 450. oператoры девyшки ждyт вaс!
	-- [[MMOSHOP.RU]] [circle] ot23r] real price [WM BL:270] [ICQ:192625006 Skype:MMOSHOP.RU, chat on the site] [Webmoney,Yandex,other]
	"mmoshop%.ru.*цeнa.*skype", -- [ [MMOSHOP.RU]] [circle] от23р] реальная цена [WM BL:270] [ICQ:192625006 Skype:MMOSHOP.RU, Чат на сайте] [Вебмани,Яндекс,другие]
	--[square] [RPGdealer.ru] [square] gives you quick access to wealth. Always on top!
	--[square] [RPGdealer.ru] [square] предоставит Вам быстрый доступ к богатству. Всегда на высоте!
	--GOLD WOW + SATELLITE PRESENT EACH! Lotteries 2 times a month of valuable prizes [circle] Site : [RPGdealer.ru] [circle] ICQ: 485552474. BL 360 Info on the site.
	"rpgdealer%.ru.*{.*}", --ЗОЛОТО WOW + СПУТНИК В ПОДАРОК КАЖДОМУ! Розыгрыши 2 раза в мес ценных призов [circle] Сайт: [RPGdealer.ru] [circle] ICQ: 485552474. BL 360 Инфа на сайте.
	--Buy MERRY COINS on the funny-money.rf Funny price:)
	--Купи ВЕСЕЛЫЕ МОНЕТКИ на фани-мани.рф Смешные цены:)
	--Buy GOLD at [circle]funny-money.rf[circle] Price Calculator on the site.
	"купи.*фaни-мaни%.рф", --Купи ЗОЛОТО на [circle]фани-мани.рф[circle] Калькулятор цен на сайте.
	--[COINS] of 23 per 1OOO | website | INGMONEY. RU | | SALE + Super Award - Spectral Tiger! ICQ 77-21-87 | | Skype INGMONEY. RU
	"ingmoney%.ru.*skype", --[МОНЕТЫ]  от 23 за 1OOO | сайт | INGMONEY. RU ||АКЦИЯ + Супер Приз - Спектральный Тигр! ICQ 77-21-87 || Skype INGMONEY. RU
	--Sell 55kg of potatoes at a low price quickly! Skype v_techno_delo [circle] 8 = 1kg
	"прoдaм.*кaртoшки.*cрoчнo.*cкaйп", --Продам 55кг картошки по дешевке  срочно! скайп v_techno_delo  [circle] 8 = 1кг
	--Gold Exchange Invitation to participate suppliers and shops. With our more than 800 suppliers and 100 stores. GexDex.ru
	"з[o0]л[o0]т[ao0].*gexdex%.ru", --[skull][skull][skull] Биржа золота приглaшaет к учaстию постaвщиков и магазины. С нами болee 800 постaвщиков и 100 магaзинов. GеxDеx.ru
	--Cheapest price only here! Price 1000 gold-20R, from 40k-18r on, from-60k to 17p! Website [playwowtime.vipshop.ru]! ICQ 196-353-353, skype nickname playwowtime2011!
	"vipshop%.ru.*skype", --Самые дешевые цены только у нас! Цены 1000 золотых- 20р , от 40к -по 18р , от 60к-по 17р ! Сайт [playwowtime.vipshop.ru] ! ICQ 196-353-353 , skype ник playwowtime2011!

	--Chinese
	--嗨 大家好  团购金币送代练 炼金龙 还有各职业账号 详情请咨询 谢谢$18=10k;$90=50k+1000G free;$180=100k+2000g+月卡，也可用G 换月卡
	--{rt3}{rt1} 春花秋月何时了，买金知多少.小楼昨夜又东风，金价不堪回首月明中. 雕栏玉砌金犹在，只是价格改.问君能有几多愁，恰似我家金价在跳楼.QQ:1069665249
	--大家好，金币现价：19$=10k,90$=50k另外出售火箭月卡，还有70,80,85账号，全手工代练，技能代练，荣誉等，华人价格从优！！买金币还是老牌子可靠，sky牌金币，您最好的选择！
	"only%d+.*for%d+k.*rocket.*card", --only 20d for 10k,90d for 50k,X-53 rocket,recuit month card ,pst for more info{rt1}另外出售火箭月卡，买金送火箭月卡，账号，代练等，华人价格从优！！
	"金币.*%d+k.*惊喜大奖", --卖坐骑啦炽热角鹰兽白色毛犀牛大小幽灵虎红色DK马等拉风坐骑热销中，金币价格170$/105k,更有惊喜大奖等你拿=D
	--17=10k 160=100K 359BOE LVL85 Account For SaIe 疯狂甩卖 P0werleveling 1-85 only need 7days 还有大小幽灵虎
	"%d+=%d+k.*boe.*p[0o]we?rle?ve?ling.*虎", --17=10k 160=100K 359BOE疯狂甩卖 P0werleveling 1-85还有大小幽灵虎等你来拿PST
	"%d+=%d+k.*r0cket.*p[0o]we?rle?ve?ling", --$50=30k $80=50K+X-53T0uring R0cket+1 M0nth G@me Time , 378B0Es For SaIe 疯狂甩卖 P0werleveling 1-85 only 7 days, Help Do Bloodbathed Frostbrood Vanquisher Achivement!代打ICC成就龙,华人优惠哦
	"金.*%d+=%d+k.*boe.*虎", --暑假WOW大促销啦@，金币超低价 <200=100k+10kextra> , 国服/美服1-85效率代练5天完成，378BOE各种装备甩卖，各职业帐号，大小幽灵虎等稀有坐骑现货，金币换火箭，月卡牛
	"only.*%d+k.*deliver.*售", --only 17d for 10k,160d for 100k,deliver in 5mins, pst for more info另出售装备，账号，坐骑，85代练，华人价格从优！！!
	"专业代练.*安全快速发货", --17美元=10k  大量金币薄利多销，货比三家，专业代练1-85，练技能，账号，火箭月卡，还有各种378BOE装备，各种新材料，大小幽灵虎，专业团队代打ICC成就龙，刷荣誉等，安全快速发货
	"cheap.*sale.*囤货", --WTS [Blazing Hippogryph] [Amani Dragonhawk]cheapest for sale,pst,plz 龙鹰和角鹰兽囤货，需要速密，谢谢
	"金币.*卖.*买金币", --感恩大回馈金币大甩卖 ,买金币送坐骑，送代练，需要的请M,另外有378装备，代练，帐号，月卡出售。大、小幽灵虎，犀牛，角鹰兽， 魔法公鸡，赤红DK战马,战斗熊等

	--Advanced URL's/Misc
	"%d+eu.*deliver.*credible.*kcq[%.,]", --12.66EUR/10000G 10 minutes delivery.absolutely credible. K C Q .< 0 M
	"happy.*%d+for%d+k.*gear.*mount", --{star}{star}{star}happy new year, $100=30K,$260 for 100K, and have the nice 359lvl gears about $39~99 best mount for ya as well{star}{star}{star}{star}
	"deliver.*gears.*g4p", --Fast delivery for Level 359/372 BoE gears!Vist <www.g4pitem.com> to get whatever you need!
	"sale.*joygold.*store", --Great sale! triangletriangletriangle www.joygold.com.www.joygold.com diamonddiamonddiamond 10000G.only.13.99 EUR circle WWWE have 257k stores and you can receive within 5-10 minutes star
	"pkpkg.*boe.*deliver", --[PKPKG.COM] sells all kinds of 346,359lvl BOE gears. fast delivery. your confidence is all garanteed
	"service.*pst.*info.*%d+k.*usd", --24 hrs on line servicer PST for more infor. Thanks ^_^  10k =32 u s d  -happy friday :)
	"deathwing.*fear.*terror.*official.*cata.*surprise.*ZYY", --Deathwing has come spreading fear and terror, it is now officially World of WarCraft Cataclysm. Make sure you are prepared and find surprises at ZYY.
	"okgolds.*only.*%d+.*euro", --WWW.okgolds.COM,10000G+2000G.only.15.99EURO}/2
	"mmo4store.*%d+[kg].*good.*choice", --{square}MMO4STORE.C0M{square}14/10000G{square}Good Choice{square}
	"^%W+.*mmoggg", -->>> MMOGGG is recruiting now!
	"%d+.*items.*deliver.*k4gg", --10K=13.98For more items and for fast delivery,come toWWW.K4gg.C@M
	"customer.*promotion.*cost.*gold", --Dear customer: This is kyla from promotion site : mmowin ^_^Long time no see , how is going? Been miss ya :)As the cataclysm coming and the market cost line for gold and boe item has been down a lot recently , we will send present if ya get 30k or 50k
	--40$ for 10k gold or 45$ for  10k gold + 1 rocket  + one month  time card  .   25$ for  a  rocket .  we have  all boe items and 264 gears selled . if u r interested in .  plz whsiper me . :) ty
	--$45=10k + one X-53 Touring Rocket, $107=30K + X-53 Touring Rocket, the promotion will be done in 10 minutes, if you like it, plz whisper me :) ty
	"%$.*rocket.*%$.*rocket.*ple?a?[sz]", --$45 for 10k with a rocket {star} and 110$ for 30k with a Rocket{moon},if you like,plz pst
	--WTS X-53 Touring Rocket.( the only 2 seat flying mount you can aslo get a free month game time) .. pst
	--WTS [X-53 Touring Rocket], the only 2seats flying mount, PST
	"wts.*touringrocket.*mount.*pst", --!!!!!! WTS*X-53 TOURING ROCKET Mount(2seats)for 10000G (RAF things), you also can get a free month game time,PST me !!!
	"wts.*touringrocket.*%d+k", --WTS[Celestial Steed],[X-53 Touring Rocket],Race,Xfer 15K,TimeCard 6K,[Cenarion Hatchling]*Rag*KT*XT*Moonk*Panda 5K
	"{.*}.*mm4ss.*{.*}", --{triangle}www.mm4ss.com{triangle} --multi
	"promotion.*serve.*%d+k", --Special promotion in this serve now, 21$ for 10k
	"pkpkg.*gear.*pet", --WWW.PkPkg.C{circle}M more gears,mount,pet and items on
	"euro.*gold.*safer.*trade", --Only 1.66 Euros per 1000 gold, More safer trade model.
	--WWW.PVPBank.C{circle}MCODE=itempvp(20% price off)
	"www[%.,]pvpbank[%.,]c.*%d+", --Wir haben mehr Ausr?stungen, Mounts und Items, die Sie mochten. Professionelles Team fuer 300 Personen sind 24 Stunde fuer Sie da.Wenn Sie Fragen haben,wenden Sie an uns bitteWWW.PVPBank.C{circle}M7 Tage 24 Uhr Service.
	"^%W+mm[0o]%[?yy[%.,]c[0o]m%W+$", --May 10
	"^%W+diymm[0o]game[%.,]c[0o]m%W+$", --June 10
	"sell.*safe.*fast.*site.*gold2wow", --()()Hot selling:safest and fastest trade,reliable site gold2wow()() --June 10
	"^%W+m+oggg[%.,][cd][oe]m?%W+$", --April 10
	"%W+mmo4store[%.,]c[0o]m%W+", --June 10
	"wts.*boeitems.*sale.*ignah", --wts [Lightning-Infused Leggings] [Carapace of Forgotten Kings] we have all the Boe items,mats and t10/t10.5 for sale .<www.ignah.com>!!
	"mmoarm2teeth.*wanna.*gear.*season.*wowgold", --hey,this is [3w.mmoarm2teeth.com](3w=www).do you wanna get heroic ICC gear,season8 gear and wow gold?
	"skillcopper.*wow.*mount.*gold", --skillcopper.eu Oldalunk ujabb termekekel bovult WoWTCG Loot Card-okal pl.:(Mount: Spectral Tiger, pet: Tuskarr Kite, Spectral Kitten Fun cuccok: Papa Hummel es meg sok mas) Gold, GC, CD kulcsok Akcio! Latogass el oldalunkra skillcopper.eu
	"meingd[%.,]de.*eur.*gold", --[MeinGD.de] - 0,7 Euro - 1000 Gold - [MeinGD.de]
	"{.*}.*ourgamecenter.*{.*}", --Off 30% {square} 'www' OurGameCenter 'com' {square}100K=142$ !!
	--"cheap.*ourgamecenter.*deliver", --The Cheapest,10K=15,{moon} 'www' OurGameCenter 'com' {moon}Fast Delivery
	--"surprise.*%d+k.*ourgamecenter", --surprise!!11K~15.99 {square} 'www' OurGameCenter 'com' {square}
	--Sorry for disturb{diamond}(cyrillic sha sha sha) OurGameCenter (cyrillic c o m){diamond}10K=15,have stock.
	"ourgamecenter.*%d+k.*stock", --OurGameCenter com 10K~14K,full stock,fulfill 10 Mins.
	"ourgamecenter.*deliver", --www OurGameCenter com not only ensure prompt delivery but that your order remains secure every timewe guarantee it! 
	"secure.*gamecenter.*discount", --Sorry for disturb you We are a secure website 'www' OurGameCenter 'com' 11K~15.99!(EASY TO GET 10% DISCOUNT  GET ANOTHER 5% FOR INTRODUCING FRIENDS TO US)
	"%$.*boe.*deliver.*interest", --{rt3}{rt1} WTS WOW G for $$. 10k for 20$, 52k for 100$. 105k for 199$. all item level 359 BOE gear. instant delivery! PST if ya have insterest in it. ^_^
	"gold.*trading.*ourgamecenter", --A WoW Gold Professional trading siteшшш OurGameCenter сом
	--WTS [Theresa's Booklight] [Vial of the Sands] [Heaving Plates of Protection]and others pls go <buyboe dot com> 
	--WTS [Heaving Plates of Protection] [Vial of the Sands] [Theresa's Booklight], best service on<buyboe dot com> 
	--WTS[Krol Decapitator][Vitreous Beak of Julak-Doom][Pauldrons of Edward the Odd]cheapest on <buyboe dot com>
	--WTS[Gloves of Unforgiving Flame]order multiple lv378 epics to get a pet or 365 epic free on<buyboe dot com>. 
	--Free[Parrot Cage (Hyacinth Macaw)][Disgusting Oozeling][Masterwork Elementium Deathblade]on<buyboe dot com>. 
	--VK[Vial of the Sands]kauf mehr als 50k bekommt 20%-30% extra gold on <buyboe dot de>.
	--VK [Phiole der Sande][Theresas Leselampe][Maldos Shwertstock],25 Minuten Lieferung auf <buyboe(dot)de>
	"%[.*%].*buyboe.*dot.*[fcd][ro0e]", --WTS [Theresa's Booklight] [Vial of the Sands] [Heaving Plates of Protection] 15mins delivery on<buyboe dot com>
	"code.*hatchling.*card.*%d%d+[kg]", --WTS Codes redeem:6PETS [Cenarion Hatchling],Lil Rag,KT,XT,Moonkin,Pandaren 5k each;Prepaid gametimecard 6K;Flying mount[Celestial Steed] 15K.PST
	"%d+k.*card.*rocket.*deliver", --{rt6}{rt1} 19=10k,90=51K+gamecard+rocket? deliver10mins
	"%d%d+[kg].*g4pgold@com.*discount", --Speedy!10=5000G,g4pgold@com,discount code:Manager
	"%[.*%].*%[.*%].*facebook.com/buyboe", --Win Free[Volcano][Spire of Scarlet Pain][Obsidium Cleaver]from a simple contest, go www.facebook.com/buyboe now!
	"wts.*pets.*card.*mount", --WTS 6PETS [Cenarion Hatchling],Lil'Rag,XT,KT,Moonkin,Panda 8K each;Prepaid gametimecard 10K;Flying Mounts[Winged Guardian],[Celestial Steed]20K each.
	"wts.*pets.*mount.*card", --wts 6pets .mounts .rocket. gametimecard .Change camp. variable race. turn area. change a name. ^_^!
	"wts.*gametime.*mount.*pet", --WTS Prepaid gametime code 8k per month. the mount [Winged Guardian]'[Celestial Steed] 15K each and the pets 6k each, if u are interested,PST
	"wts.*mount.*pet.*card", --WTS {star}flying mounts:[Celestial Steed] and [Winged Guardian]30k each {star}PETS:Lil'Ragnaros/Lil'XT/Lil'K.T./Moonkin/Pandaren/Cenarion Hatchling 12k each,{star}prepaid timecards 15k each.{star}
	"wowhelp%.1%-click%.hu", --{square}Have a nice day, enjoy the game!{square} - {star} [http://wowhelp.1-click.hu/] - One click for all WoW help! {star}
	"g4p.*gold.*discount", --Saray Daily Greetings ? thanks for your previous support on G4P,here I am reminding you of our info, you may need it again :web:G4Pgold,Discount code:saray,introducer ID:saray 
	"wts.*rocket.*gametime", --WTS{rt3}"[X-53 Touring Rocket]&[Winged Guardian]&Celestial Steed&xt,kt,mo nk,cen.rag.moonkin and game time"{rt3}pst for more info.
	"$%d+=%d+k.*deliver.*item", --$20=10K, $100=57k,$200=115k with instant delivery,all lvl378 items,pst
	"money.*gold.*gold2sell", --Ingame gold for real money! Real gold for Ingame gold! Ingame gold for a account key! If you're intrested, then check out: "gold2sell.org" now!
	"kb8gold.*sale.*deliver", --KB8GOLD C0M 7.9€->10K Hot sales and Fast delivery 
	"pet.*rag.*panda.*gametimecard", --Vends 6PETS [Bébé hippogriffe cénarien],Mini'Rag,XT,KT,Sélénien,Panda 12K each;payé d'avance gametimecard 15K;Bâtis volants[Gardien ailé],[Palefroi célest 
	"wts.*deliver.*cheap.*price", --WTS [Reins of Poseidus],deliver fast,cheaper price ,pst,plz 
	"%d+[/\\=]%d+.*gold4power", --?90=5oK Google:Gold4Power, Introducer ID:saray
	"wts.*mount.*rocket.*gift", --WTS 2 seat flying mount the X-53 Touring rocket , you can also get a gift--one month game , PST 
	"k{.*}4%.?{.*}g{.*}[o0]{.*}l{.*}d", --{star}.W{star}.W{star}W {square} k{triangle}.4{triangle}g{triangle}o{triangle}l{triangle}d {square} c{star}o{star}m -------{square}- c{star}o{star}d{star}e : CF \ CO \ CK
	"kb8g[o0]ld.*%d+.*st[o0]ck", --KB8GOLD com 8.5EUR = 10000,269K IN STOCK NOW!
	"reins.*vial.*%d+.*rocket", --WTS [Reins of the Crimson Deathcharger] [Vial of the Sands] [Reins of Poseidus],170usd=100k+a rocket for free
	"boe.*sale.*upitems", --wts [Krol Decapitator] we have all the Boe items,mats and 378 items for sale .<www.upitems.com>!!
	"wts.*rocket.*deliver", --WTSx-53 touring rocketinstant delivery,pst！！！！！
	"wts.*%[.*%].*$%d+.*%[.*%].*$%d+" --wts[Blauvelt's Family Crest]$34.00[Gilnean Ring of Ruination]$34.99[Signet of High Arcanist Savor]$34.90pst
	},
	["Guild"] = {	-- guild recruitment
	"%.wowstead%.com",
	"recruit",
	"looking for.*join [ou][us]r?",--<> is Looking for Dedicated and skilled DPS and Healer classes to join us in the current 10 man  raids and expand to 25 man raids. Raids on mon,wed,thurs,sunday 21.00-24.00 18+
	"www.*apply", --pls go to www.<>.com to apply or wisp me for extra info.
	"looking.*members", -- <<>> is a social levelling looking for all members no lvl requirement, Once we have more members were looking to do Raids and PvP premades, /w if you would like to join please or  /w me for info.
	"guild.*join", --<> is a lvling guild but as soon as we have enough 85 we will raid  we are here not 2 take the game 2 serously and 2 have fun if u wanna join wisper me or <> any lvl welcome :) 
	"levell?in.*guild", --<> Easy Going Leveling Guild LFM of any levels, we are friendly, helpfull and have 6 guild tabs available.
	"gilde.*inte?rr?esse", --Die Gilde <> sucht nette Mitspieler zum gemeinsamen questen, spass haben, heros abfarmen, pvp zocken usw... Sind keine raidgilde und wollen es auch nicht werden. Neuanfänger sowie lowlvl gerne willkommen. Intresse? pls w/m
	"apply.*www", --<> We Are Looking For people Item lvl 333+ for our25man Cataclysm Raiding team. Must Be over 18+ to Apply or Have some insane Skills. If you Got Any Questions Go to www.<>.net Or contact me or a officer.
	"gu?ilde?.*[/w][/w]", --<> is a newly formed social guild for all classes and levels. Our aim is to have fun and we hope to do raids when we are big enough. For any more info or an invite /w me. Thank You.
	"gu?ilde?.*pvp.*raid", --Die PvP und Twink Gilde <> sucht gute PvPler für gemeinsame Events,Raids und Bgs. Aufgenommen wird ab lvl.50! w me oder Geilertyp
	"gu?ilde?.*raid.*bank", --Die neue Gilde "<>" sucht noch nette Mitspieler zum Leveln, Questen, Raiden und Spaß haben. Ts³ und Gildenbank ist vorhanden.
	"gilde.*such[et]", --Moin, der lustige Haufen (Gilde) "<>" suchen noch ältere Spieler (22+) für Instanzen, Questen, Heros und 10er; Spielspaß ist dabei die absolute Mussbedingung! Wenn du dich angesprochen fühlst, schreib uns einfach mal:) [www.<>.de]
	"pvp.*pve.*wh?isper", --instead of joining solo and end up loosing with randoms. Ofcourse we group up for Random HCs with both PvP and PvE players aswell and if the PvE group need an extra player for the raid, PvP guys can get invited. Whisper me for more info.
	"looking for.*http", --<> Looking for: Resto shaman&Tank. You need skill, focus and patience to learn and pass the fights. If you want to clear bosses before the nerfs then this is the right place for you /w or go to http://<>.info
	"guild.*pst",--<> an adult guild looking for more players who are active ,like to have fun ,talk in vent & will help others. LVL 5 GUILD !we'd like fun people to enjoy the new content of CATA,all lvls, classes, races are welcome PST FOR MORE INFO/INVI
	"guild.*bank.*tabs", --Looking for a guild to relax after a hard day of work or school? <> is layed back and alota fun. We are a lev 7 guild and have 7 Guild Bank tabs. we have vent as well so stop by and check us out. come run some dungeons..
	"guild.*wh?isper m[ey]", -- <> is a layed-back social level 10  heroic/raiding guild. We organize a few heroics/raids a week and ALWAYS use teamspeak while doing so. Is this something you like to do? Whisper me!
	"www.*/w", --noch gute und zuverlässige Member für weitere 10er Stammgruppen später 25er.Gesucht werden:Heiler;Pala,Dudu - DD;Eule,Feral,Mage,Verstärker!Raidzeiten Mi,Do,So 19-22:30!Bewerbung unter [www.xyz.de] für Infos /w me
	"looking.*strengthen.*raid", --<> is looking for, 1 ele sham, 1 balance druid, 1 holy pala,  to strengthen our raid teams for the current 10 man raids. Raids 21.00-24.00 Mon,Wed,Thurs,Sun. 349+ gear req age 18+
	"looking for.*/w.*info", --<><level10>Is looking for more people to start raiding with. We are in need of everything and dps needs to do atleast 10k+ dps and have atleast 345 Item level, /w me for an inv, or for more info
	"guild.*welcome", -->< is a new dungeon/raid guild we are setting up our raid/HC group. ofc every lvl is welcome in our guild but we preff 60-85 all classes/races. You also have to be an active player
	"guild.*looking", -->< raiding guild. (5/12) we are looking for exp/dedicated players for our 10mans. slowly moving into 25mans. must have a ilvl 350+ (need 1 tank, 2 ranged(pref. boomkin), 1 melee(pref enhance)
	"lookk?ing.*welcome", --<> is a lvl 11 recuiting for their 10man group, lookking for people with experiance with a min 348 ilvl (2ranged dps ) all other players are welcome we are 6/12 with cataclysm bosses - raid times are mon - thurs 8:00pm to 12:00am (midnight) Pst
	"raid.*%.com", --<> <lvl 23> has openings in its' 25 man raid group, Raids are Sunday - Thurs 9-12. see xyz.com for info
	"sucht.*willkommen", --<> sucht für ihre 10er Raids Mi + Fr 19.30-23.00 (10/12) noch tatkräftige Unterstützung! Hirn, flinke Finger, wache Augen und ein sehr! gutes Klassenverständnis sind uns in jeder Klasse willkommen. [www.xyz.de]
	"such[et]n?.*%.de", --Die "" (Glvl5) suchen noch Mitglieder, egal ob groß oder klein, zum gemeinsamen leveln, Instanzen(und HC's)-, PvP- und später Cata-Raid erleben. Weitere Infos findet ihr auf [www.xyz.de]  Ts Vorhanden
	"such[et]n?.*gilde", --Hi wir suchen für unsere LvL-Gilde <>(Stufe 2) noch Member. Wir wollen zusammen Leveln und Instanzen laufen. Den 5% ep Bonus gibts auch dazu. Hast du lust? Dann melde dich bei mir :)
	"lookout.*raidtimes.*/w", --Knixxs Order of the Darkside -  Lvl 25. We are on the lookout for Tanks and Healers for our raidteam. We are currently 5/12 and looking to progress further. Our raidtimes are: Wed, Thurs and Sunday, 21:15 realm time. For more info /w me. Thanks :)
	"social leveling looking.*healer", --<> <level 6> Is a social leveling looking for people to fill out raiding spots. Currently in need of dps and healers. Starting firelands trash runs & eventually boss runs. 
	}
}