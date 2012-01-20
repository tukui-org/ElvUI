local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "zhCN")
if not L then return end

--Copy the entire english file here and set values = to something
--[[
	Where it says:
	L["Auto Scale"] = true
	
	That just means thats default, you can still set it to say something else like this
	L["Auto Scale"] = "Blah blah, speaking another language, blah blah"
	
	You can post the file here for it to be added to default ElvUI files: http://www.tukui.org/forums/forum.php?id=88
]]
--Static Popup
do
	L["One or more of the changes you have made require a ReloadUI."] = "一个或更多的改变,需要重载插件";
end

--General
do
	L["Version"] = true;
	L["Enable"] = "启用";

	L["General"] = "一般设置";
	L["ELVUI_DESC"] = "ElvUI 是一个用来替换WOW原始插件的用户界面.";
	L["Auto Scale"] = "自动缩放";
		L["Automatically scale the User Interface based on your screen resolution"] = "根据你的分辨率自动缩放UI界面";
	L["Scale"] = "比例";
		L["Controls the scaling of the entire User Interface"] = "缩放用户界面缩放比例";
	L["None"] = "无";
	L["You don't have permission to mark targets."] = "你没有权限标志目标";
	L['LOGIN_MSG'] = '欢迎使用 %sElvUI|r 版本 %s%s|r, 键入 /ec 来访问设置界面. 如果你需要技术支持请访问 http://www.tukui.org/forums/forum.php?id=84';
	L['Login Message'] = "登陆信息";
	
	L["Reset Anchors"] = "重设位置";
	L["Reset all frames to their original positions."] = "重新设置所有框体到它们的默认位置";
	
	L['Install'] = "安装";
	L['Run the installation process.'] = "运行安装进程";
	
	L["Credits"] = "创作组";
	L['ELVUI_CREDITS'] = "我想用一个特别的方式感谢那些测试,翻译和通过捐助帮助我的人. 请捐助过的人在论坛中PM给我, 我将把你的名字添加到这儿."
	L['Coding:'] = "翻译";
	L['Testing:'] = "测试";
	L['Donations:'] = "捐助";
	
	--Installation
	L["Welcome to ElvUI version %s!"] = "欢迎使用 ElvUI 版本 %s";
	L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "此安装过程将帮助你了解 ElvUI 特性";
	L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "内建的设置界面可以通过 /ec 命令来访问, \n或点击小地图旁边的 C 按钮来打开. \n如果你想跳过安装过程按下面的按钮";
	L["Please press the continue button to go onto the next step."] = "请按继续按钮到下一步";
	L["Skip Process"] = "跳过";
	L["ElvUI Installation"] = "ElvUI 安装";
	
	L["CVars"] = true;
	L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "此步骤是来改变你的WOW一些默认设置";
	L["Please click the button below to setup your CVars."] = "请点击下面的按钮设置 CVars";
	L["Setup CVars"] = "设置 CVars";
	
	L["Importance: |cff07D400High|r"] = "重要性: |cff07D400高|r";
	L["Importance: |cffD3CF00Medium|r"] = "重要性: |cffD3CF00中|r";

	L["Chat"] = "聊天";
	L["This part of the installation process sets up your chat windows names, positions and colors."] = "此部份的安装将会设置你聊天框的名字,位置和颜色";
	L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "此聊天框与WOW原始聊天框功能相似的, 你可以拖拉标签来移动或重命名等. 请点击下面的按钮设置你的聊天窗口.";
	L["Setup Chat"] = "设置聊天框";
	L['AutoHide Panels'] = "自动隐藏面板";
	L['When a chat frame does not exist, hide the panel.'] = "当聊天框不存在时,自动隐藏面板";
	
	L["Installation Complete"] = "安装过程";
	L["You are now finished with the installation process. Bonus Hint: If you wish to access blizzard micro menu, middle click on the minimap. If you don't have a middle click button then hold down shift and right click the minimap. If you are in need of technical support please visit us at www.tukui.org."] = "你已经完成安装过程. 如需技术支持请访问 www.tukui.org.";
	L["Please click the button below so you can setup variables and ReloadUI."] = "请点击下面的按钮设置变量并重载界面";
	L["Finished"] = "完成";
	L["CVars Set"] = "CVars 设置";
	L["Chat Set"] = "聊天设置";
	L['Trade'] = "交易";
	
	L['Panels'] = "面板(聊天框)";
	L['Announce Interrupts'] = "打断通告";
	L['Announce when you interrupt a spell to the specified chat channel.'] = "在你打断一个技能时,在指定频道发送消息";	
	L["Movers unlocked. Move them now and click Lock when you are done."] = "移动锁定. 现在可以移动它们移好了点击锁定";
	L['Lock'] = "锁定";	
end

--Media
do	
	L["Media"] = "材质字体";
	L["Fonts"] = "字体";
	L["Font Size"] = "字体尺寸";
		L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = "设置界面上所有字体尺寸,但不影响到那些有独立设置的(如单位框体字体,信息文字字体等...)";
	L["Default Font"] = "默认字体";
		L["The font that the core of the UI will use."] = "此字体是界面的核心字体";
	L["UnitFrame Font"] = "单位框体字体";
		L["The font that unitframes will use"] = "此字体被单位框体使用";
	L["CombatText Font"] = "战斗文字字体";
		L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "此字体被战斗文件使用, |cffFF0000需要重新启用游戏或重登录才会生效.|r";
	L["Textures"] = "材质";
	L["StatusBar Texture"] = "状态条材质";
		L["Main statusbar texture."] = "主状态条材质";
	L["Gloss Texture"] = "光亮材质";
		L["This gets used by some objects."] = "只被一些目标使用";
	L["Colors"] = "颜色";
	L["Border Color"] = "边框颜色";
		L["Main border color of the UI."] = "界面主边框颜色";
	L["Backdrop Color"] = "背景颜色";
		L["Main backdrop color of the UI."] = "界面主背景色";
	L["Backdrop Faded Color"] = "背景透明色";
		L["Backdrop color of transparent frames"] = "透明框体的背景颜色";
	L["Restore Defaults"] = "恢复默认";
		
	L["Toggle Anchors"] = "解锁开关";
	L["Unlock various elements of the UI to be repositioned."] = "解锁界面上的各种元件用来移动位置";
	
	L["Value Color"] = "数值颜色";
	L["Color some texts use."] = "一些字段使用的颜色";
end

--NamePlate Config
do
	L["NamePlates"] = "姓名版";
	L["NAMEPLATE_DESC"] = "修改姓名版设置.";
	L["Width"] = "宽度";
		L["Controls the width of the nameplate"] = "控制姓名版的宽度";
	L["Height"] = "高度";
		L["Controls the height of the nameplate"] = "控制姓名版的高度";
	L["Good Color"] = "安全色";
		L["This is displayed when you have threat as a tank, if you don't have threat it is displayed as a DPS/Healer"] = "做为坦克时获得仇恨, 或做为DPS/治疗时没有获得仇恨的颜色";
	L["Bad Color"] = "危险色";
		L["This is displayed when you don't have threat as a tank, if you do have threat it is displayed as a DPS/Healer"] = "做为坦克时未获得仇恨, 或做为DPS/治疗时获得仇恨的颜色";
	L["Good Transition Color"] = "安全过渡色";
		L["This color is displayed when gaining/losing threat, for a tank it would be displayed when gaining threat, for a dps/healer it would be displayed when losing threat"] = "做为坦克将获得仇恨,或做为DPS/治疗将丢失仇恨时显示的颜色";
	L["Bad Transition Color"] = "危险过渡色";
		L["This color is displayed when gaining/losing threat, for a tank it would be displayed when losing threat, for a dps/healer it would be displayed when gaining threat"] = "做为坦克将丢失仇恨,或做为DPS/治疗将获得仇恨";	
	L["Castbar Height"] = "施法条高度";
		L["Controls the height of the nameplate's castbar"] = "控制姓名版施法条的高度";
	L["Health Text"] = "生命值";
		L["Toggles health text display"] = "生命值显示开关";
	L["Personal Debuffs"] = "个人Debuff";
		L["Display your personal debuffs over the nameplate."] = "在姓名版上显示你个人的Debuffs";
	L["Display level text on nameplate for nameplates that belong to units that aren't your level."] = "在姓名版上显示该单位的等级,不是你的等级";
	L["Enhance Threat"] = "仇恨增强";
		L["Color the nameplate's healthbar by your current threat, Example: good threat color is used if your a tank when you have threat, opposite for DPS."] = "根据你的天赋改变姓名版血条的颜色";
	L["Combat Toggle"] = "战斗切换";
		L["Toggles the nameplates off when not in combat."] = "不在战斗时自动关闭姓名版";
	L["Friendly NPC"] = "友好的NPC";
	L["Friendly Player"] = "友好的玩家";
	L["Neutral"] = "中立";
	L["Enemy"] = "敌对";
	L["Threat"] = "仇恨";
	L["Reactions"] = "声望";
	L["Filters"] = "过滤";
	L['Add Name'] = "添加名字";
	L['Remove Name'] = "删除名字";
	L['Use this filter.'] = "使用过滤器";
	L["You can't remove a default name from the filter, disabling the name."] = "你不能删除过滤器的默认名字, 禁用此名字";
	L['Hide'] = "隐藏";
		L['Prevent any nameplate with this unit name from showing.'] = "阻止此单位名字的姓名版显示";
	L['Custom Color'] = "定制颜色";
		L['Disable threat coloring for this plate and use the custom color.'] = "禁用仇恨颜色,并使用定制颜色";
	L['Custom Scale'] = "定制比例";
		L['Set the scale of the nameplate.'] = "设置姓名版的缩放比例";
	L['Good Scale'] = "安全比例";
	L['Bad Scale'] = "危险比例";
	L["Auras"] = "光环";
end

--ClassTimers
do
	L['ClassTimers'] = "职业计时条";
	L["CLASSTIMER_DESC"] = '在玩家和目标框体上显示 buff/debuff 信息.\n建议不要和技能监视同时开启.';
	
	L['Player Anchor'] = "玩家锚点";
	L['What frame to anchor the class timer bars to.'] = "职业计时条依附的框体.";
	L['Target Anchor'] = "目标锚点";
	L['Trinket Anchor'] = "饰品锚点";
	L['Player Buffs'] = "玩家 Buffs";
	L['Target Buffs']  = "目标 Buffs";
	L['Player Debuffs'] = "玩家 Debuffs";
	L['Target Debuffs']  = "目标 Debuffs";
	L['Player'] = "玩家";
	L['Target'] = "目标";
	L['Trinket'] = "饰品";
	L['Procs'] = "特效";
	L['Any Unit'] = "任意单元";
	L['Unit Type'] = "单元类型";	
	L["Buff Color"] = "Buff 颜色";
	L["Debuff Color"] = "Debuff 颜色";
	L['Attempting to position a frame to a frame that is dependant, try another anchor point.'] = "尝试定位的框体与另一框体是从属关系, 尝试其它的定位点";
	L['Remove Color'] = "删除颜色";
	L['Reset color back to the bar default.'] = "重设颜色为默认值";
	L['Add SpellID'] = "添加技能ID";
	L['Remove SpellID'] = "删除技能ID";
	L['You cannot remove a spell that is default, disabling the spell for you however.'] = "你不能删除默认内置的技能, 可以禁用它";
	L['Spell already exists in filter.'] = "技能在过滤器中已经存在";
	L['Spell not found.'] = "未找到此技能.";
	L["All"] = "所有人";
	L["Friendly"] = "友方";
	L["Enemy"] = "敌方";	
end
	
--ACTIONBARS
do
	--HOTKEY TEXTS
	L['KEY_SHIFT'] = 'S';
	L['KEY_ALT'] = 'A';
	L['KEY_CTRL'] = 'C';
	L['KEY_MOUSEBUTTON'] = 'M';
	L['KEY_MOUSEWHEELUP'] = 'MU';
	L['KEY_MOUSEWHEELDOWN'] = 'MD';
	L['KEY_BUTTON3'] = 'M3';
	L['KEY_NUMPAD'] = 'N';
	L['KEY_PAGEUP'] = 'PU';
	L['KEY_PAGEDOWN'] = 'PD';
	L['KEY_SPACE'] = 'SpB';
	L['KEY_INSERT'] = 'Ins';
	L['KEY_HOME'] = 'Hm';
	L['KEY_DELETE'] = 'Del';
	L['KEY_MOUSEWHEELUP'] = 'MwU';
	L['KEY_MOUSEWHEELDOWN'] = 'MwD';

	--BLIZZARD MODIFERS TO SEARCH FOR
	L['KEY_LOCALE_SHIFT'] = '(s%-)';
	L['KEY_LOCALE_ALT'] = '(a%-)';
	L['KEY_LOCALE_CTRL'] = '(c%-)';
	
	--KEYBINDING
	L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the escape key or right click to clear the current actionbutton's keybinding."] = "移动鼠标到动作条或技能书按钮上绑定快捷键. 按ESC或右击按钮取消当前绑定";
	L['Save'] = "保存";
	L['Discard'] = "取消";
	L['Binds Saved'] = "保存绑定";
	L['Binds Discarded'] = "取消绑定";
	L["All keybindings cleared for |cff00ff00%s|r."] = "取消 |cff00ff00%s|r 所有绑定的快捷键.";
	L[" |cff00ff00bound to |r"] = true;
	L["No bindings set."] = "无绑定设置";
	L["Binding"] = "绑定";
	L["Key"] = "键";	
	L['Trigger'] = true;
	
	--CONFIG
	L["ActionBars"] = "动作条";
		L["Keybind Mode"] = "快捷键绑定模式";
		
	L['Macro Text'] = "宏名字";
		L['Display macro names on action buttons.'] = "在动作条按钮上显示宏名字";
	L['Keybind Text'] = "快捷键";
		L['Display bind names on action buttons.'] = "在动作条按钮上显示快捷键名字";
	L['Button Size'] = "按钮尺寸";
		L['The size of the main action buttons.'] = "主动作条按钮尺寸";
	L['Button Spacing'] = "按钮间距";
		L['The spacing between buttons.'] = "两个按钮之间的距离";
	L['Bar '] = "动作条 ";
	L['Backdrop'] = "背景";
		L['Toggles the display of the actionbars backdrop.'] = "动作条显示背景框的开关";
	L['Buttons'] = "按钮数";
		L['The ammount of buttons to display.'] = "显示多少个动作条按钮";
	L['Buttons Per Row'] = "每行按钮数";
		L['The ammount of buttons to display per row.'] = "每行显示多少个按钮数";
	L['Anchor Point'] = "锚点方向";
		L['The first button anchors itself to this point on the bar.'] = "第一个按钮对齐动作条的方向";
	L['Height Multiplier'] = "高度倍增";
	L['Width Multiplier'] = "宽度倍增";
		L['Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop.'] = "根据此值增加背景的高度或宽度. 一般用来在一个背景框里放置多条动作条";
	L['Action Paging'] = "动作条翻页";
		L["This works like a macro, you can run different situations to get the actionbar to page differently.\n Example: '[combat] 2;'"] = "和宏一样工作, 能根据你不同的状态得到不同的动作条翻页.\n 比如: '[combat] 2;'";
	L['Visibility State'] = "可见状态";
		L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"] = "和宏一样工作, 能根据你不同的状态使动作条显示或隐藏.\n 比如: '[combat] show;hide'";
	L['Restore Bar'] = "还原动作条";
		L['Restore the actionbars default settings'] = "恢复此功能条的默认设置";
		L['Set the font size of the action buttons.'] = "设置此动作条按钮的字体尺寸";
	L['Mouse Over'] = "鼠标划过显示";
		L['The frame is not shown unless you mouse over the frame.'] = "此框体不显示,直到鼠标经过框体时";
	L['Pet Bar'] = "宠物动作条";
	L['Alt-Button Size'] = "小按钮尺寸";
		L['The size of the Pet and Shapeshift bar buttons.'] = "宠物动作条和姿态条按钮尺寸";
	L['ShapeShift Bar'] = "姿态条";
	L['Cooldown Text'] = "冷却文字";
		L['Display cooldown text on anything with the cooldown spiril.'] = "显示技能冷却时间";
	L['Low Threshold'] = "低门槛";
		L['Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red'] = "低于此门槛的文字将转为红色并显示小数. 设为 -1 则不会变为红色";
	L['Expiring'] = "到期";
		L['Color when the text is about to expire'] = "即将到期的文字颜色";
	L['Seconds'] = "秒";
		L['Color when the text is in the seconds format.'] = "以秒显示时的文字颜色";
	L['Minutes'] = "分";
		L['Color when the text is in the minutes format.'] = "以分显示时的文字颜色";
	L['Hours'] = "时";
		L['Color when the text is in the hours format.'] = "以小时显示时的文字颜色";
	L['Days'] = "天";
		L['Color when the text is in the days format.'] = "以天显示时的文字颜色";
	L['Totem Bar'] = "图腾条";
end

--UNITFRAMES
do
	L['X Offset'] = "X 方向偏移";
	L['Y Offset'] = "Y 方向偏移";
	L['RaidDebuff Indicator'] = "团队副本DEBUFF指示器";
	L['Debuff Highlighting'] = "Debuff 高亮";
		L['Color the unit healthbar if there is a debuff that can be dispelled by you.'] = "高亮显示单元,如果DEBUFF能被你驱散";
	L['Disable Blizzard'] = "禁用暴雪框体";
		L['Disables the blizzard party/raid frames.'] = "禁用暴雪小队/团队框架";
	L['OOR Alpha'] = "距离透明度";
		L['The alpha to set units that are out of range to.'] = "单元超出距离显示的透明度";
	L['You cannot set the Group Point and Column Point so they are opposite of each other.'] = "你不能设置队伍位置和列位置这些他们是互相对立的.";
	L['Orientation'] = "方向";
		L['Direction the health bar moves when gaining/losing health.'] = "当增加/减少血量时血条的移动方向";
		L['Horizontal'] = "水平";
		L['Vertical'] = "垂直";
	L['Camera Distance Scale'] = "镜头距离比例";
		L['How far away the portrait is from the camera.'] = "头像距镜头有多远";
	L['Offline'] = "离线";
	L['UnitFrames'] = "单位框体";
	L['Ghost'] = "死亡";
	L['Smooth Bars'] = "平滑条";
		L['Bars will transition smoothly.'] = "条将平滑过渡";
	L["The font that the unitframes will use."] = "单位框体字体";
		L["Set the font size for unitframes."] = "设置单位框体字体尺寸";
	L['Font Outline'] = "字体描边";
		L["Set the font outline."] = "设置字体的描边";
	L['Bars'] = "条";
	L['Fonts'] = "字体";
	L['Class Health'] = "职业色生命";
		L['Color health by classcolor or reaction.'] = "以职业色显示生命";
	L['Class Power'] = "职业色能量";
		L['Color power by classcolor or reaction.'] = "以职业色显示能量";
	L['Health By Value'] = "按数值变化血量";
		L['Color health by ammount remaining.'] = "按数值变化血量";
	L['Custom Health Backdrop'] = "定制血条背景";
		L['Use the custom health backdrop color instead of a multiple of the main health color.'] = "自定义血条背景色";
	L['Class Backdrop'] = "职业色背景";
		L['Color the health backdrop by class or reaction.'] = "血条背景色以职业色显示";
	L['Health'] = "血条";
	L['Health Backdrop'] = "血条背景";
	L['Tapped'] = "被攻击";
	L['Disconnected'] = "断开";
	L['Powers'] = "能量";
	L['Reactions'] = "声望";
	L['Bad'] = "危险";
	L['Neutral'] = "中立";
	L['Good'] = "安全";
	L['Player Frame'] = "玩家框体";
	L['Width'] = "宽";
	L['Height'] = "高";
	L['Low Mana Threshold'] = "低魔法阈值";
		L['When you mana falls below this point, text will flash on the player frame.'] = "当你的魔法低于此位置时,将在玩家框体上显示一行闪烁的文字";
	L['Combat Fade'] = "战斗隐藏";
		L['Fade the unitframe when out of combat, not casting, no target exists.'] = "隐藏框体在非战斗, 没有施法和没有目标时";
	L['Health'] = "血量";
		L['Text'] = "文字";
		L['Text Format'] = "文字格式";	
	L['Current - Percent'] = "当前值 - 百分比";
	L['Current - Max'] = "当前值 - 最大值";
	L['Current'] = "当前值";
	L['Percent'] = "百分比";
	L['Deficit'] = "亏损值";
	L['Filled'] = "全长";
	L['Spaced'] = "留空";
	L['Power'] = "能量";
	L['Offset'] = "偏移";
		L['Offset of the powerbar to the healthbar, set to 0 to disable.'] = "偏移能量条与血条的位置, 设为 0 禁用.";
	L['Alt-Power'] = "特殊能量值";
	L['Overlay'] = "覆盖";
		L['Overlay the healthbar']= "覆盖血条";
	L['Portrait'] = "头像";
	L['Name'] = "姓名";
	L['Up'] = "上";
	L['Down'] = "下";
	L['Left'] = "左";
	L['Right'] = "右";
	L['Num Rows'] = "行数";
	L['Per Row'] = "每行";
	L['Buffs'] = true;
	L['Debuffs'] = true;
	L['Y-Growth'] = "Y 方向增长";
	L['X-Growth'] = "X 方向增长";
		L['Growth direction of the buffs'] = "buffs 增长方向";
	L['Initial Anchor'] = "初始化位置";
		L['The initial anchor point of the buffs on the frame'] = "初始化框体 buff 的位置";
	L['Castbar'] = "施法条";
	L['Icon'] = "图标";
	L['Latency'] = "延时";
	L['Color'] = "颜色";
	L['Interrupt Color'] = "可打断颜色";
	L['Match Frame Width'] = "匹配框体宽度";
	L['Fill'] = "填充";
	L['Classbar'] = "施法条";
	L['Position'] = "位置";
	L['Target Frame'] = "目标框体";
	L['Text Toggle On NPC'] = "NPC 文字显示开关";
		L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'] = "NPC 目标将隐藏能量值文字";
	L['Combobar'] = "连击点";
	L['Use Filter'] = "使用过滤器";
		L['Select a filter to use.'] = "选择一个过滤器使用";
		L['Select a filter to use. These are imported from the unitframe aura filter.'] = "选择一个过滤器使用. 这些从单位框体的光环过滤器中输入";
	L['Personal Auras'] = "个人光环";
	L['If set only auras belonging to yourself in addition to any aura that passes the set filter may be shown.'] = "如果设置了只显示自己释放的光环，那么除了你设置的过滤条件（只显示自己释放的）以外的光环都不会显示";
	L['Create Filter'] = "创建过滤器";
		L['Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit.'] = "创建一个过滤器, 一旦创建能被每个单元的 buff/debuff 所使用";
	L['Delete Filter'] = "删除过滤器";
		L['Delete a created filter, you cannot delete pre-existing filters, only custom ones.'] = "删除一个创建的过滤器, 你不能删除内置的过滤器, 只有你自已添加的能";
	L["You can't remove a pre-existing filter."] = "你不能删除一个内置的过滤器";
	L['Select Filter'] = "选择过滤器";
	L['Whitelist'] = "白名单";
	L['Blacklist'] = "黑名单";
	L['Filter Type'] = "过滤器类型";
		L['Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else.'] = "设置过滤器类型, 黑名单隐藏所有在名单里面的光环, 白名字则显示所有在名单里的光环";
	L['Add Spell'] = "添加技能";
		L['Add a spell to the filter.'] = "添加一个技能到过滤器";
	L['Remove Spell'] = "移除技能";
		L['Remove a spell from the filter.'] = "重过滤器中移除一个技能";
	L['You may not remove a spell from a default filter that is not customly added. Setting spell to false instead.'] = "你不能移除一个内置技能, 可以禁用此技能.";
	L['Unit Reaction'] = "单元声望";
		L['This filter only works for units with the set reaction.'] = "此过滤器只工作在那些单元有声望时";
		L['All'] = "全部";
		L['Friend'] = "友好";
		L['Enemy'] = "敌对";
	L['Duration Limit'] = "时间限制";
		L['The aura must be below this duration for the buff to show, set to 0 to disable. Note: This is in seconds.'] = "光环必需低于此时间buff才会显示, 设为0禁用. 注意: 此时间单位为 秒.";
	L['TargetTarget Frame'] = "目标的目标框体";
	L['Attach To'] = "附加到";
		L['What to attach the buff anchor frame to.'] = "buff 锚点附加到哪儿";
		L['Frame'] = "框体";
	L['Anchor Point'] = "锚点方向";
		L['What point to anchor to the frame you set to attach to.'] = "框体的锚点对齐方向";
	L['Focus Frame'] = "焦点框体";
	L['FocusTarget Frame'] = "焦点目标框体";
	L['Pet Frame'] = "宠物框体";
	L['PetTarget Frame'] = "宠物目标框体";
	L['Boss Frames'] = "BOSS 框体";
	L['Growth Direction'] = "延展方向";
	L['Arena Frames'] = "竞技场框体";
	L['Profiles'] = "配置";
	L['New Profile'] = "新配置";
	L['Delete Profile'] = "删除配置";
	L['Copy From'] = "复制自";
	L['Talent Spec #1'] = "天赋位 #1";
	L['Talent Spec #2'] = "天赋位 #2";
	L['NEW_PROFILE_DESC'] = '你能创建一个新的单位框体配置文件, 你能分配某些配置为某个天赋使用. 在这儿你能删除, 复制或重置配置文件.';
	L["Delete a profile, doing this will permanently remove the profile from this character's settings."] = "删除一个配置文件, 将永远的从角色设置中移除此配置.";
	L["Copy a profile, you can copy the settings from a selected profile to the currently active profile."] = "复制一个配置文件, 你能复制设置从选择的配置到当前活动配置.";
	L["Assign profile to active talent specialization."] = "指定配置为当前天赋专用";
	L['Active Profile'] = "激活配置";
	L['Reset Profile'] = "重设配置";
		L['Reset the current profile to match default settings from the primary layout.'] = "重设当前配置为默认值";
	L['Party Frames'] = "队伍框";
	L['Group Point'] = "队伍位置";
		L['What each frame should attach itself to, example setting it to TOP every unit will attach its top to the last point bottom.'] = "每一个框体都会依附在你设定的位置上, 例如: 你设置依附于TOP那么每一个单元都将把它单元TOP依附于前一个单元的BOTTOM";
	L['Column Point'] = "列位置";
		L['The anchor point for each new column. A value of LEFT will cause the columns to grow to the right.'] = "每一行的锚点. 设置这个值为LEFT, 那么这一行的将从左向增长";
	L['Max Columns'] = "最大列数";
		L['The maximum number of columns that the header will create.'] = "最大显示多少列";
	L['Units Per Column'] = "每列单元数";
		L['The maximum number of units that will be displayed in a single column.'] = "一列最多显示多少个单元";
	L['Column Spacing'] = "列间距";
		L['The amount of space (in pixels) between the columns.'] = "列之间的间隔距离(像素)";
	L['xOffset'] = "X 方向偏移";
		L['An X offset (in pixels) to be used when anchoring new frames.'] = "新框体X方向的偏移值";
	L['yOffset'] = "Y 方向偏移";
		L['An Y offset (in pixels) to be used when anchoring new frames.'] = "新框体Y方向的偏移值";
	L['Show Party'] = "队伍时显示";
		L['When true, the group header is shown when the player is in a party.'] = "选中此项, 当玩家在队伍中时显示";
	L['Show Raid'] = "团队时显示";
		L['When true, the group header is shown when the player is in a raid.'] = "选中此项, 当玩家进入团队时显示";
	L['Show Solo'] = "单人时显示";
		L['When true, the header is shown when the player is not in any group.'] = "选中此项, 只有玩家一个人时也显示队伍";
	L['Display Player'] = "显示玩家";
		L['When true, the header includes the player when not in a raid.'] = "选中此项,队伍中将显示玩家";
	L['Visibility'] = "可见性";
		L['The following macro must be true in order for the group to be shown, in addition to any filter that may already be set.'] = "此处的宏为真将显示此组";
	L['Blank'] = "空";
	L['Buff Indicator'] = "Buff 提示器";
	L['Color Icons'] = "图标颜色";
		L['Color the icon to their set color in the filters section, otherwise use the icon texture.'] = "以色块显示图标, 否则使用图标自身的材质";
	L['Size'] = "尺寸";
		L['Size of the indicator icon.'] = "指示器图标尺寸";
	L["Select Spell"] = "选择技能";
	L['Add SpellID'] = "添加技能ID";
	L['Remove SpellID'] = "移除技能ID";
	L["Not valid spell id"] = "不正确的技能ID";
	L["Spell not found in list."] = "列表中未发现技能";
	L['Show Missing'] = "显示未命中";
	L['Any Unit'] = "任意单元";
	L['Move UnitFrames'] = "移动单位框体";
	L['Reset Positions'] = "重设位置";
	L['Sticky Frames'] = "粘性窗口";
	L['Attempt to snap frames to nearby frames.'] = "使窗口自动吸附旁边的窗口, 方便解锁移动时调整位置";
	L['Raid625 Frames'] = "25人团队";
	L['Raid2640 Frames'] = "40人团队";
	L['Copy From'] = "复制自";
	L['Select a unit to copy settings from.'] = "选择一个单元来复制设置从.";
	L['You cannot copy settings from the same unit.'] = "你不能从相同的单元复制设置";
	L['Restore Defaults'] = "恢复默认";
	L['Role Icon'] = "职责图标";
	L['Smart Raid Filter'] = "智能团队过滤";
	L['Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance.'] = "在某些必然的情况重写可见性的定义, 比如: 在10人副本里只显示1队和2队";	
end
--Datatext
do
	L['Bandwidth'] = "带宽";
	L['Download'] = "下载";
	L['Total Memory:'] = "总内存:";
	L['Home Latency:'] = "本地延迟:";
	
	L.goldabbrev = "|cffffd700g|r"
	L.silverabbrev = "|cffc7c7cfs|r"
	L.copperabbrev = "|cffeda55fc|r"	
	
	L['Session:'] = "本次登陆";
	L["Character: "] = "角色: ";
	L["Server: "] = "服务器: ";
	L["Total: "] = "合计: ";
	L["Saved Raid(s)"]= "已有进度的副本";
	L["Currency:"] = "货币";	
	L["Earned:"] = "挣取:";	
	L["Spent:"] = "花费:";	
	L["Deficit:"] = "赤字:";
	L["Profit:"	] = "利润:";	
	
	L["DataTexts"] = "信息文字";
	L["DATATEXT_DESC"] = "设置在屏幕上显示的一些信息文字.";
	L["Multi-Spec Swap"] = "多天赋切换";
	L['Swap to an alternative layout when changing talent specs. If turned off only the spec #1 layout will be used.'] = "当改变天赋时切换到另一个层. 当关闭时只有 #1 层被使用.";
	L['24-Hour Time'] = "24小时制";
	L['Toggle 24-hour mode for the time datatext.'] = "信息文件时间段以24小时制显示开关";
	L['Local Time'] = "本地时间";
	L['If not set to true then the server time will be displayed instead.'] = "如果关闭此项,将显示服务器时间";
	L['Primary Talents'] = "主天赋";
	L['Secondary Talents'] = "副天赋";
	L['left'] = '左';
	L['middle'] = '中';
	L['right'] = '右';
	L['LeftChatDataPanel'] = '左聊天框';
	L['RightChatDataPanel'] = '右聊天框';
	L['LeftMiniPanel'] = '小地图左';
	L['RightMiniPanel'] = '小地图右';
	L['Friends'] = "好友";
	L['Friends List'] = "好友列表";
	
	L['Head'] = "头";
	L['Shoulder'] = "肩";
	L['Chest'] = "胸";
	L['Waist'] = "腰";
	L['Wrist'] = "护腕";
	L['Hands'] = "手";
	L['Legs'] = "腿";
	L['Feet'] = "脚";
	L['Main Hand'] = "主手";
	L['Offhand'] = "副手";
	L['Ranged'] = "远程";
	L['Mitigation By Level: '] = "等级减伤";
	L['lvl'] = "等级";
	L["Avoidance Breakdown"] = "免伤统计";
	L['AVD: '] = "免伤: ";
	L['Unhittable:'] = "未命中: ";
	L['AP'] = "攻强";
	L['SP'] = "法强";
	L['HP'] = "生命";
	L['allunavailable'] = "无法获得战争的召唤信息."
	L['nodungeons'] = "没有副本提供战争的召唤."
	
	L["Armor"] = "护甲";
	L["Attack Power"] = "攻击强度";
	L["Avoidance"] = "免伤";
	L["Crit Chance"] = "爆击率";
	L["DTName"] = true;
	L["Durability"] = "耐久";
	L["Friends"] = "好友";
	L["Gold"] = "金币";
	L["Guild"] = "公会";
	L["Spell/Heal Power"] = "主要能力值";
	L["System"] = "系统信息";
	L["Time"] = "时间";
	L["Bags"] = "背包";
	L["Call to Arms"] = "战斗的召唤"
	L["Talent Spec"] = "当前天赋"
	L["Mana Regen"] = "法力回复"
	L["Expertise Rating"] = "专业等级"
	L["DPS"] = "DPS"
end

--Tooltip
do
	L["TOOLTIP_DESC"] = '提示信息设置选项.';
	L['Targeted By:'] = "同目标的有:";
	L['Tooltip'] = "鼠标提示";
	L['Count'] = "计数";
	L['Anchor Mode'] = "位置模式";
	L['Set the type of anchor mode the tooltip should use.'] = "设置鼠标提示位置显示模式";
	L['Smart'] = "智能";
	L['Cursor'] = "光标跟随";
	L['Anchor'] = "固定位置";
	L['UF Hide'] = "单位框体提示隐藏";
	L["Don't display the tooltip when mousing over a unitframe."] = "当鼠标指向单位框体时不显示鼠标提示";
	L["Who's targetting who?"] = "目标关注";
	L["When in a raid group display if anyone in your raid is targetting the current tooltip unit."] = "在团队中显示与你当前鼠标提示目标相同目标的队友";
	L["Combat Hide"] = "战斗隐藏";
	L["Hide tooltip while in combat."] = "战斗时不显示提示";
	L['Item-ID'] = "物品ID";
	L['Display the item id on item tooltips.'] = "在物品提示信息中显示物品ID";
end

--Chat
do
	L["CHAT_DESC"] = '设置聊天框选项.';
	L["Chat"] = "聊天";
	L['Invalid Target'] = "无效目标";
end

--Skins
do
	L["Skins"] = "美化皮肤";
	L["SKINS_DESC"] = '调整皮肤设置.';
	L['Spacing'] = "空隙";
	L['The spacing in between bars.'] = "两个进度条之间的间隙";
	L["TOGGLESKIN_DESC"] = "启用/禁用此皮肤.";
	L["Encounter Journal"] = "地下城手册";
	L["Bags"] = "背包";
	L["Reforge Frame"] = "重铸";
	L["Calendar Frame"] = "日历";
	L["Achievement Frame"] = "成就";
	L["LF Guild Frame"] = true;
	L["Inspect Frame"] = "观察";
	L["KeyBinding Frame"] = "快捷键";
	L["Guild Bank"] = "公会银行";
	L["Archaeology Frame"] = "考古";
	L["Guild Control Frame"] = "公会控制";
	L["Guild Frame"] = "公会";
	L["TradeSkill Frame"] = "商业技能";
	L["Raid Frame"] = "团队";
	L["Talent Frame"] = "天赋";
	L["Glyph Frame"] = "雕文";
	L["Auction Frame"] = "拍卖";
	L["Barbershop Frame"] = "理发店";
	L["Macro Frame"] = "宏";
	L["Debug Tools"] = "调试工具";
	L["Trainer Frame"] = "训练师";
	L["Socket Frame"] = "珠宝";
	L["Achievement Popup Frames"] = "成就弹出窗";
	L["BG Score"] = "战场记分窗";
	L["Merchant Frame"] = "商人";
	L["Mail Frame"] = "信箱";
	L["Help Frame"] = "帮助";
	L["Trade Frame"] = "交易";
	L["Gossip Frame"] = "闲谈";
	L["Greeting Frame"] = "欢迎";
	L["World Map"] = "世界地图";
	L["Taxi Frame"] = "载具";
	L["LFD Frame"] = "寻求组队";
	L["Quest Frames"] = "任务";
	L["Petition Frame"] = "签名";
	L["Dressing Room"] = "试衣间";
	L["PvP Frames"] = "PvP窗口";
	L["Non-Raid Frame"] = true;
	L["Friends"] = "好友";
	L["Spellbook"] = "技能书";
	L["Character Frame"] = "角色";
	L["LFR Frame"] = true;
	L["Misc Frames"] = true;
	L["Tabard Frame"] = "战袍";
	L["Guild Registrar"] = "公会注册";
	L["Time Manager"] = "时间管理";	
end

--Misc
do
	L['Experience'] = "经验/声望条";
	L['Bars'] = "条";
	L['XP:'] = "经验:";
	L['Remaining:'] = "剩余:";
	L['Rested:'] = "休息:";
	
	L['Empty Slot'] = "空位";
	L['Fishy Loot'] = "鱼";
	L["Can't Roll"] = "不能 Roll";
	L['Disband Group'] = "解散队伍";
	L['Raid Menu'] = "团队菜单";
end	

--Bags
do
	L['Click to search..'] = "点击搜索";
	L['Sort Bags'] = "背包整理";
	L['Stack Items'] = "堆叠物品";
	L['Vender Grays'] = "出售灰色物品";
	L['Toggle Bags'] = "背包开关";
	L['You must be at a vender.'] = "你必需以商人为目标.";
	L['Vendered gray items for:'] = "已出售灰色物品: ";
	L['No gray items to sell.'] = "无灰白物品出售.";
	L['Hold Shift:'] = "按住 Shift:";
	L['Stack Special'] = "堆叠特殊背包";
	L['Sort Special'] = "整理特殊背包";
	L['Purchase'] = "购买";
	L["Can't buy anymore slots!"] = "再也不能购买空的背包位置";
	L['You must purchase a bank slot first!'] = "你必需购买一个银行包位置";
end