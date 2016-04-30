-- Chinese localization file for zhCN.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "zhCN")
if not L then return end

-- *_DESC locales
L["AURAS_DESC"] = "小地图旁的光环图标设置."
L["BAGS_DESC"] = "调整 ElvUI 背包设置."
L["CHAT_DESC"] = "对话框架设定"
L["DATATEXT_DESC"] = "设定萤幕所显示的部份资讯文字."
L["ELVUI_DESC"] = "ElvUI 为一套功能完整，可用来替换 WOW 原始介面的套件"
L["NAMEPLATE_DESC"] = "修改血条设定."
L["PANEL_DESC"] = "调整左、右对话框的大小，此设定将会影响对话与背包框架的大小."
L["SKINS_DESC"] = "调整外观设定."
L["TOGGLESKIN_DESC"] = "启用/停用此外观."
L["TOOLTIP_DESC"] = "鼠标提示资讯设定选项."
L["SEARCH_SYNTAX_DESC"] = [=[With the new addition of LibItemSearch, you now have access to much more advanced item searches. The following is a documentation of the search syntax. See the full explanation at: https://github.com/Jaliborc/LibItemSearch-1.2/wiki/Search-Syntax.

Specific Searching:
    • q:[quality] or quality:[quality]. For instance, q:epic will find all epic items.
    • l:[level], lvl:[level] or level:[level]. For example, l:30 will find all items with level 30.
    • t:[search], type:[search] or slot:[search]. For instance, t:weapon will find all weapons.
    • n:[name] or name:[name]. For instance, typing n:muffins will find all items with names containing "muffins".
    • s:[set] or set:[set]. For example, s:fire will find all items in equipment sets you have with names that start with fire.
    • tt:[search], tip:[search] or tooltip:[search]. For instance, tt:binds will find all items that can be bound to account, on equip, or on pickup.


Search Operators:
    • ! : Negates a search. For example, !q:epic will find all items that are NOT epic.
    • | : Joins two searches. Typing q:epic | t:weapon will find all items that are either epic OR weapons.
    • & : Intersects two searches. For instance, q:epic & t:weapon will find all items that are epic AND weapons
    • >, <, <=, => : Performs comparisons on numerical searches. For example, typing lvl: >30 will find all items with level HIGHER than 30.


The following search keywords can also be used:
    • soulbound, bound, bop : Bind on pickup items.
    • bou : Bind on use items.
    • boe : Bind on equip items.
    • boa : Bind on account items.
    • quest : Quest bound items.]=];
L["TEXT_FORMAT_DESC"] = [=[提供一个更改文字格式的方式

例如:
[namecolor][name] [difficultycolor][smartlevel] [shortclassification]
[healthcolor][health:current-max]
[powercolor][power:current]

生命条 / 能量条 格式:
'current' - 当前数值
'percent' - 百分比数值
'current-max' - 当前数值 - 最大数值. 当当前数值等于最大数值时只显示最大数值
'current-percent' - 当前数值 - 百分比. 当百分比为1时只显示当前数值
'current-max-percent' - 当前数值 - 最大数值 - 百分比, 当当前数值不等于最大值时显示
'deficit' - 赤字. 当没有赤字时不显示

姓名格式:
'name:short' - 姓名显示限制于10字节内
'name:medium' -姓名显示限制于15字节内
'name:long' - 姓名显示限制于20字节内

空白则为禁用. 如需技术支援请至 http://www.tukui.org]=];
L["IGNORE_ITEMS_DESC"] = [=[Valid entries:

Item links or item names

Terms from Search Syntax. Examples:
q:epic
s:Tank Set
q:epic&lvl:>300

See "Bags->Search Syntax" for more.]=];

--ActionBars
L["Action Paging"] = "快捷列翻页"
L["ActionBars"] = "快捷列"
L["Allow Masque to handle the skinning of this element."] = true;
L["Alpha"] = "透明度"
L["Anchor Point"] = "定位方向"
L["Backdrop Spacing"] = true;
L["Backdrop"] = "背景"
L["Button Size"] = "按钮大小"
L["Button Spacing"] = "按钮间距"
L["Buttons Per Row"] = "每行按钮数"
L["Buttons"] = "按钮数"
L["Change the alpha level of the frame."] = "改变框架透明度."
L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."] = "当能量不足时（如法力，怒力等）快捷列按键的颜色."
L["Color of the actionbutton when out of range."] = "当超出距离时快捷列按键的颜色."
L["Color when the text is about to expire"] = "即将冷却完毕的数字颜色."
L["Color when the text is in the days format."] = "以天显示的文字颜色."
L["Color when the text is in the hours format."] = "以小时显示的文字颜色."
L["Color when the text is in the minutes format."] = "以分显示的文字颜色."
L["Color when the text is in the seconds format."] = "以秒显示的文字颜色."
L["Cooldown Text"] = "冷却文字"
L["Darken Inactive"] = true;
L["Days"] = "天"
L["Display bind names on action buttons."] = "在快捷列按钮上显示快捷键名称."
L["Display cooldown text on anything with the cooldown spiral."] = "显示技能冷却时间."
L["Display macro names on action buttons."] = "在快捷列按钮上显示巨集名称."
L["Expiring"] = "即将冷却完毕"
L["Global Fade Transparency"] = true;
L["Height Multiplier"] = "高度倍增"
L["Hide Cooldown Bling"] = true;
L["Hides the bling animation on buttons at the end of the global cooldown."] = true;
L["Hours"] = "时"
L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."] = true;
L["Inherit Global Fade"] = true;
L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = true;
L["Key Down"] = "按下施法"
L["Keybind Mode"] = "快捷键绑定模式"
L["Keybind Text"] = "快捷键文字"
L["Low Threshold"] = "冷却时间低阀值"
L["Macro Text"] = "巨集内容"
L["Masque Support"] = true;
L["Minutes"] = "分"
L["Mouse Over"] = "滑鼠滑过显示"
L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."] = "根据此值增加背景的高度或宽度. 一般用来在一个背景框里放置多条快捷列"
L["Out of Power"] = "能量不足"
L["Out of Range"] = "超出范围"
L["Restore Bar"] = "还原快捷列"
L["Restore the actionbars default settings"] = "恢复此快捷列的预设设定"
L["Seconds"] = "秒"
L["Show Empty Buttons"] = true;
L["The amount of buttons to display per row."] = "每行显示多少个按钮数"
L["The amount of buttons to display."] = "显示多少个快捷列按钮"
L["The button you must hold down in order to drag an ability to another action button."] = "按住某个键后才能拖动快捷列的按钮."
L["The first button anchors itself to this point on the bar."] = "第一个按钮对齐快捷列的方向"
L["The size of the action buttons."] = "快捷列按钮尺寸"
L["The spacing between the backdrop and the buttons."] = true;
L["This setting will be updated upon changing stances."] = true;
L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"] = "冷却时间低于此秒数后将变为红色数字，并以小数显示，设为 -1 冷却时间将不会变为红色"
L["Toggles the display of the actionbars backdrop."] = "切换快捷列显示背景框"
L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."] = true;
L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."] = true;
L["Visibility State"] = "可见状态"
L["Width Multiplier"] = "宽度倍增"
L[ [=[This works like a macro, you can run different situations to get the actionbar to page differently.
 Example: '[combat] 2;']=] ] = [=[和巨集写法类似, 能根据不同姿态切换快捷列.
 例如: '[combat] 2;']=]
L[ [=[This works like a macro, you can run different situations to get the actionbar to show/hide differently.
 Example: '[combat] show;hide']=] ] = [=[和巨集写法类似, 能根据不同姿态切换快捷列显示或隐藏.
 例如: '[combat] show;hide']=]

--Bags
L["Adjust the width of the bag frame."] = '调整背包框架宽度'
L["Adjust the width of the bank frame."] = '调整银行框架宽度'
L["Align the width of the bag frame to fit inside the chat box."] = '调整背包框的宽度以适应对话框'
L["Align To Chat"] = '对齐到对话框'
L["Ascending"] = "升序"
L["Bag Sorting"] = true;
L["Bag-Bar"] = "背包条"
L["Bar Direction"] = "背包条排序方向"
L["Blizzard Style"] = true;
L["Bottom to Top"] = '底部到顶部'
L["Button Size (Bag)"] = '背包格子尺寸'
L["Button Size (Bank)"] = '银行背包格子尺寸'
L["Condensed"] = true;
L["Currency Format"] = "货币格式"
L["Descending"] = "降序"
L["Direction the bag sorting will use to allocate the items."] = '整理背包时物品排序方向.'
L["Display Item Level"] = true;
L["Display the junk icon on all grey items that can be vendored."] = true;
L["Displays item level on equippable items."] = true;
L["Enable/Disable the all-in-one bag."] = "开/关整合背包。"
L["Enable/Disable the Bag-Bar."] = "启用/禁用 背包条."
L["Full"] = true;
L["Icons and Text (Short)"] = true;
L["Icons and Text"] = "图标和文字"
L["Ignore Items"] = "忽略项目"
L["Item Count Font"] = true;
L["Item Level Threshold"] = true;
L["Item Level"] = true;
L["Items in this list or items that match any Search Syntax query in this list will be ignored when sorting. Separate each entry with a comma."] = true;
L["Money Format"] = true;
L["Panel Width (Bags)"] = '背包面板宽度'
L["Panel Width (Bank)"] = '银行面板宽度'
L["Search Syntax"] = true;
L["Set the size of your bag buttons."] = "设置背包按钮尺寸."
L["Short (Whole Numbers)"] = true;
L["Short"] = true;
L["Show Coins"] = true;
L["Show Junk Icon"] = true;
L["Smart"] = true;
L["Sort Direction"] = "排列方向"
L["Sort Inverted"] = "倒序"
L["The direction that the bag frames be (Horizontal or Vertical)."] = "此方向决定框架是横排还是竖排."
L["The direction that the bag frames will grow from the anchor."] = "背包框架将从此方向开始排列."
L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"] = "背包底部的货币显示格式. (你需要在货币页中勾选显示)."
L["The display format of the money text that is shown at the top of the main bag."] = true;
L["The frame is not shown unless you mouse over the frame."] = "仅于滑鼠移经动作列时显示其框架."
L["The minimum item level required for it to be shown."] = true;
L["The size of the individual buttons on the bag frame."] = '背包框架单个格子的尺寸.'
L["The size of the individual buttons on the bank frame."] = '银行框架单个格子的尺寸.'
L["The spacing between buttons."] = "两个按钮间的距离"
L["Top to Bottom"] = '顶部到底部'
L["Use coin icons instead of colored text."] = true;
L["X Offset Bags"] = true;
L["X Offset Bank"] = true;
L["Y Offset Bags"] = true;
L["Y Offset Bank"] = true;

--Buffs and Debuffs
L["Begin a new row or column after this many auras."] = "在这些光环旁开始新的行或列."
L["Consolidated Buffs"] = "整合增益"
L["Count xOffset"] = true;
L["Count yOffset"] = true;
L["Defines how the group is sorted."] = "定义组排序方式."
L["Defines the sort order of the selected sort method."] = "定义排序方式的排序方向."
L["Disabled Blizzard"] = true;
L["Display the consolidated buffs bar."] = "显示整合增益条"
L["Fade Threshold"] = "阈值渐隐"
L["Filter Consolidated"] = '过滤综合BUFF';
L["Index"] = "索引"
L["Indicate whether buffs you cast yourself should be separated before or after."] = "将你自身施放的增益从整体增益之前或之后分离出来."
L["Limit the number of rows or columns."] = "最大行数或列数."
L["Max Wraps"] = "每行最大数"
L["No Sorting"] = "不排序"
L["Only show consolidated icons on the consolidated bar that your class/spec is interested in. This is useful for raid leading."] = '只在综合光环条上显示与你天赋相关的综合图标, 这对团队领袖非常有用.';
L["Other's First"] = "他人光环优先"
L["Remaining Time"] = "剩余时间"
L["Reverse Style"] = true;
L["Seperate"] = "光环分离"
L["Set the size of the individual auras."] = "设置每个光环的尺寸."
L["Sort Method"] = "排序方式"
L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."] = true;
L["Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable."] = "冷却时间低于此秒数后将变为红色数字以小数显示, 并且图标会渐隐. 设置为 -1 禁用此功能."
L["Time xOffset"] = true;
L["Time yOffset"] = true;
L["Time"] = "时间"
L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."] = true;
L["Wrap After"] = "每行行数"
L["Your Auras First"] = "自身光环优先"

--Chat
L["Above Chat"] = '对话框上方'
L["Adjust the height of your right chat panel."] = true;
L["Adjust the width of your right chat panel."] = true;
L["Alerts"] = true;
L["Attempt to create URL links inside the chat."] = "在对话框中创建超链结"
L["Attempt to lock the left and right chat frame positions. Disabling this option will allow you to move the main chat frame anywhere you wish."] = "锁定左右对话框架的位置.禁用此选项将允许你移动对话框架到任意位置."
L["Below Chat"] = '对话框下方'
L["Chat EditBox Position"] = '对话輸入框位置'
L["Chat History"] = '对话历史'
L["Copy Text"] = "复制文字"
L["Display LFG Icons in group chat."] = true;
L["Display the hyperlink tooltip while hovering over a hyperlink."] = "鼠标悬停在超链接上时显示链接提示框"
L["Enable the use of separate size options for the right chat panel."] = true;
L["Fade Chat"] = '对话内容渐隐'
L["Fade Tabs No Backdrop"] = true;
L["Fade the chat text when there is no activity."] = '渐隐对话框内长期不活动的文字.'
L["Fade Undocked Tabs"] = true;
L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."] = true;
L["Fades the text on chat tabs that are not docked at the left or right chat panel."] = true;
L["Font Outline"] = "字体描边"
L["Font"] = "字体"
L["Hide Both"] = "全部隐藏"
L["Hyperlink Hover"] = "超链接悬停"
L["Keyword Alert"] = "关键字警报"
L["Keywords"] = "关键字"
L["Left Only"] = "仅显示左边"
L["LFG Icons"] = true;
L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank"] = "如果在对话信息中发现如下文字会自动上色该文字. 如果你需要添加多个词必须用逗号分开. 搜索你的名字可使用 %MYNAME%.\n\n例如:\n%MYNAME%, ElvUI, RBGs, Tank"
L["Lock Positions"] = '锁定位置'
L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session."] = '记录对话历史,当你重载,登录和退出时会恢复你最后一次会话'
L["No Alert In Combat"] = true;
L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."] = "对话框滚动到底部所需要的滚动时间（秒）"
L["Panel Backdrop"] = "对话框背景"
L["Panel Height"] = "对话框高度"
L["Panel Texture (Left)"] = "对话框材质 (左)"
L["Panel Texture (Right)"] = "对话框材质 (右)"
L["Panel Width"] = "对话框寛度"
L["Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat."] = '对话编辑框位置,如果底部的信息文字被禁用的话,将会强制显示在对话框顶部.'
L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."] = "单位时间（秒）内屏蔽重复对话信息，0为禁用此功能"
L["Require holding the Alt key down to move cursor or cycle through messages in the editbox."] = true;
L["Right Only"] = "仅显示右边"
L["Right Panel Height"] = true;
L["Right Panel Width"] = true;
L["Scroll Interval"] = "滚动间隔"
L["Separate Panel Sizes"] = true;
L["Set the font outline."] = "设定字体的描边"
L["Short Channels"] = "隐藏频道名称"
L["Shorten the channel names in chat."] = "在对话视窗中隐藏频道名称."
L["Show Both"] = "全部显示"
L["Spam Interval"] = "垃圾间隔"
L["Sticky Chat"] = "记忆对话频道"
L["Tab Font Outline"] = "标题栏字体描边"
L["Tab Font Size"] = "标题栏字体尺寸"
L["Tab Font"] = "标题栏字体"
L["Tab Panel Transparency"] = "标签面板透明"
L["Tab Panel"] = "标签面板"
L["Toggle showing of the left and right chat panels."] = "切换左/右对话框显示与否."
L["Toggle the chat tab panel backdrop."] = "显示/隐藏对话框架标签面板背景."
L["URL Links"] = "网址连结"
L["Use Alt Key"] = true;
L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."] = "当你开始输入消息时此选项的启用将会让你保留最后一次对话的频道, 如果关闭将始终使用说话频道."
L["Whisper Alert"] = "密语警报"
L[ [=[Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.

Please Note:
-The image size recommended is 256x128
-You must do a complete game restart after adding a file to the folder.
-The file type must be tga format.

Example: Interface\AddOns\ElvUI\media\textures\copy

Or for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here.]=] ] = [=[若要设定对话框背景，请将你希望设定为背景的档案置放于 WoW 目录底下的「Textures」资料夹中，并指定该档名。

请注意：
- 影像尺寸建议为 256 x 128
- 在此资料夹新增档案后，请务必重新启动游戏。
- 档案必须为 tga 格式。

范例：Interface\AddOns\ElvUI\media\textures\copy

对多数玩家来说，较简易的方式是将 tga 档放入 WoW 资料夹中，然后在此处输入档案名称。]=]

--Credits
L["Coding:"] = "编码:"
L["Credits"] = "呜谢"
L["Donations:"] = "捐款:"
L["ELVUI_CREDITS"] = "我想透过这个特别方式，向那些协助测试、编码及透过捐款协助过我的人表达感谢，请曾提供协助的朋友至论坛传私讯给我，我会将你的名字添加至此处。"
L["Testing:"] = "测试:"

--DataTexts
L["24-Hour Time"] = "24小时制"
L["Battleground Texts"] = "战场资讯"
L["Block Combat Click"] = true;
L["Block Combat Hover"] = true;
L["Blocks all click events while in combat."] = true;
L["Blocks datatext tooltip from showing in combat."] = true;
L["BottomMiniPanel"] = "Minimap Bottom (Inside)"
L["BottomLeftMiniPanel"] = "Minimap BottomLeft (Inside)"
L["BottomRightMiniPanel"] = "Minimap BottomRight (Inside)"
L["Change settings for the display of the location text that is on the minimap."] = "改变小地图所在位置文字的显示设置."
L["Datatext Panel (Left)"] = "左侧资讯框"
L["Datatext Panel (Right)"] = "右侧资讯框"
L["DataTexts"] = "资讯文字"
L["Display data panels below the chat, used for datatexts."] = "在对话框下显示用于资讯的框架."
L["Display minimap panels below the minimap, used for datatexts."] = "显示小地图下方的资讯框."
L["Gold Format"] = true;
L["If not set to true then the server time will be displayed instead."] = "若关闭此选项将显示伺服器时间."
L["left"] = "左"
L["LeftChatDataPanel"] = "对话视窗左方"
L["LeftMiniPanel"] = "小地图左方"
L["Local Time"] = "本地时间"
L["middle"] = "中"
L["Minimap Panels"] = "小地图栏"
L["Panel Transparency"] = "面板透明"
L["Panels"] = "对话框"
L["right"] = "右"
L["RightChatDataPanel"] = "对话视窗右方"
L["RightMiniPanel"] = "小地图右方"
L["Small Panels"] = true;
L["The display format of the money text that is shown in the gold datatext and its tooltip."] = true;
L["Toggle 24-hour mode for the time datatext."] = "切换时间显示为24小时制."
L["TopMiniPanel"] = "Minimap Top (Inside)"
L["TopLeftMiniPanel"] = "Minimap TopLeft (Inside)"
L["TopRightMiniPanel"] = "Minimap TopRight (Inside)"
L["When inside a battleground display personal scoreboard information on the main datatext bars."] = "处于战场时, 在主资讯文字条显示你的战场得分讯息."
L["Word Wrap"] = true;

--Distributor
L["Must be in group with the player if he isn't on the same server as you."] = "如果不是同一服务器, 那他必须和你在同一队伍中."
L["Sends your current profile to your target."] = "发送你的配置文件到当前目标."
L["Sends your filter settings to your target."] = "发送你的过滤器配置到当前目标."
L["Share Current Profile"] = "分享当前配置文件"
L["Share Filters"] = "分享过滤器配置"
L["This feature will allow you to transfer, settings to other characters."] = "此功能将使你设置转移给他角色."
L["You must be targeting a player."] = "你必须以一名玩家为目标."

--General
L["Accept Invites"] = "接受邀请"
L["Adjust the position of the threat bar to either the left or right datatext panels."] = "调整仇恨条的位置于左侧或右侧资讯面板"
L["Adjust the size of the minimap."] = "调整小地图尺寸。"
L["AFK Mode"] = true;
L["Announce Interrupts"] = "打断通告"
L["Announce when you interrupt a spell to the specified chat channel."] = "在指定对话频道通知打断信息."
L["Attempt to support eyefinity/nvidia surround."] = true;
L["Auto Greed/DE"] = "自动贪婪/分解"
L["Auto Repair"] = "自动修装"
L["Auto Scale"] = "自动缩放"
L["Auto"] = true;
L["Automatically accept invites from guild/friends."] = "自动接受工会或好友的邀请"
L["Automatically repair using the following method when visiting a merchant."] = "使用以下方式来自动修理装备."
L["Automatically scale the User Interface based on your screen resolution"] = "依据屏幕分辨率度自动缩放介面"
L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."] = "当你的等级达到满级时, 自动选择贪婪或分解绿色物品."
L["Automatically vendor gray items when visiting a vendor."] = "当访问商人时自动出售灰色物品."
L["Bonus Reward Position"] = true;
L["Bottom Panel"] = "底部面板"
L["Chat Bubbles Style"] = true;
L["Chat Bubbles"] = true;
L["Direction the bar moves on gains/losses"] = true;
L["Disable Tutorial Buttons"] = true;
L["Disables the tutorial button found on some frames."] = true;
L["Display a panel across the bottom of the screen. This is for cosmetic only."] = '显示跨越屏幕底部的面板,仅仅是用于装饰.'
L["Display a panel across the top of the screen. This is for cosmetic only."] = '显示跨越屏幕顶部的面板,仅仅是用于装饰.'
L["Display battleground messages in the middle of the screen."] = true;
L["Display emotion icons in chat."] = "在对话中显示表情图标."
L["Emotion Icons"] = "表情图标"
L["Enable/Disable the loot frame."] = "开/关物品掉落框架。"
L["Enable/Disable the loot roll frame."] = "开/关掷骰子框架。"
L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r"] = "开/关小地图. |cffFF0000警告: 这将使你无法看见综合增益框和小地图资讯栏.|r"
L["Enhanced PVP Messages"] = true;
L["General"] = "一般"
L["Height of the objective tracker. Increase size to be able to see more objectives."] = true;
L["Hide At Max Level"] = true;
L["Hide Error Text"] = "隐藏错误文字"
L["Hide In Vehicle"] = true;
L["Hides the red error text at the top of the screen while in combat."] = "战斗中隐藏屏幕顶部红字错误信息."
L["Log Taints"] = "错误记录"
L["Login Message"] = "登入资讯"
L["Loot Roll"] = "掷骰"
L["Loot"] = "拾取"
L["Make the world map smaller."] = true;
L["Multi-Monitor Support"] = true;
L["Name Font"] = "名称字体"
L["Objective Frame Height"] = true;
L["Party / Raid"] = true;
L["Party Only"] = true;
L["Position of bonus quest reward frame relative to the objective tracker."] = true;
L["Puts coordinates on the world map."] = true;
L["Raid Only"] = true;
L["Remove Backdrop"] = "去除背景"
L["Reset all frames to their original positions."] = "重设所有框架至预设位置."
L["Reset Anchors"] = "重置定位"
L["Reverse Fill Direction"] = true;
L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."] = "发送ADDON_ACTION_BLOCKED错误至Lua错误框, 这些错误并不重要, 不会影响你的游戏体验. 并且很多这类错误无法被修复. 请只将影响游戏体验的错误发送给我们."
L["Skin Backdrop"] = "美化背景"
L["Skin the blizzard chat bubbles."] = "美化暴雪对话泡泡."
L["Smaller World Map"] = true;
L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "玩家头顶姓名的字体. |cffFF0000警告: 你需要重新开启游戏或重新登录才能使用此功能.|r"
L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."] = true;
L["Thin Border Theme"] = true;
L["Toggle Tutorials"] = "教学开关"
L["Top Panel"] = '顶部面板'
L["When you go AFK display the AFK screen."] = true;
L["World Map Coordinates"] = true;

--Media
L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."] = true;
L["Applies the primary texture to all statusbars."] = true;
L["Apply Font To All"] = true;
L["Apply Texture To All"] = true;
L["Backdrop color of transparent frames"] = "透明框架的背景颜色"
L["Backdrop Color"] = "背景颜色"
L["Backdrop Faded Color"] = "背景透明色"
L["Border Color"] = "边框颜色"
L["Color some texts use."] = "数值(非文字)使用的颜色"
L["Colors"] = "颜色"
L["CombatText Font"] = "战斗文字字体"
L["Default Font"] = "预设字体"
L["Font Size"] = "字体大小"
L["Fonts"] = "字体"
L["Main backdrop color of the UI."] = "介面背景主色"
L["Main border color of the UI. |cffFF0000This is disabled if you are using the Thin Border Theme.|r"] = true;
L["Media"] = "材质"
L["Primary Texture"] = "主要材质"
L["Replace Blizzard Fonts"] = true;
L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."] = true;
L["Secondary Texture"] = "次要材质"
L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = "设定介面上所有字体的大小，但不包含本身有独立设定的字体(如单位框架字体、资讯文字字体等...)"
L["Textures"] = "材质"
L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "战斗资讯将使用此字体, |cffFF0000警告:需重启游戏或重新登入才可使此变更生效.|r"
L["The font that the core of the UI will use."] = "核心 UI 所使用的字体."
L["The texture that will be used mainly for statusbars."] = "此材质主用于状态列上。"
L["This texture will get used on objects like chat windows and dropdown menus."] = "主要用于对话视窗及下拉选单等物件的材质"
L["Value Color"] = "数值颜色"

--Minimap
L["Always Display"] = "总是显示"
L["Bottom Left"] = true;
L["Bottom Right"] = true;
L["Bottom"] = true;
L["Instance Difficulty"] = true;
L["Left"] = "左"
L["LFG Queue"] = true;
L["Location Text"] = "所在位置文字"
L["Minimap Buttons"] = true;
L["Minimap Mouseover"] = "小地图鼠标滑过"
L["Right"] = "右"
L["Scale"] = true;
L["Top Left"] = true;
L["Top Right"] = true;
L["Top"] = true;

--Misc
L["Install"] = "安装"
L["Run the installation process."] = "执行安装程序"
L["Toggle Anchors"] = "切换定位开关"
L["Unlock various elements of the UI to be repositioned."] = "解锁介面上的各种元件, 以便更改位置"
L["Version"] = "版本"

--NamePlates
L["Add Name"] = "添加名称"
L["Adjust nameplate size on low health"] = true;
L["Adjust nameplate size on smaller mobs to scale down. This will only adjust the health bar width not the actual nameplate hitbox you click on."] = "低级怪物启用较小型的血条显示, 此调整只改变血条的宽度."
L["All"] = "全部"
L["Alpha of current target nameplate."] = true;
L["Alpha of nameplates that are not your current target."] = true;
L["Always display your personal auras over the nameplate."] = "总是在血条上显示你的个人光环."
L["Bad Transition"] = true;
L["Bring nameplate to front on low health"] = true;
L["Bring to front on low health"] = true;
L["Can Interrupt"] = true;
L["Cast Bar"] = true;
L["Castbar Height"] = "施法条高度"
L["Change color on low health"] = true;
L["Color By Healthbar"]  = true;
L["Color By Raid Icon"] = true;
L["Color Name By Health Value"] = true;
L["Color on low health"] = true;
L["Color the border of the nameplate yellow when it reaches this point, it will be colored red when it reaches half this value."] = "当到达此数值时, 血条的边框将被上色为黄色. 当到达此数值一半时, 姓名面板的边框将被上色为红色."
L["Combat Toggle"] = "战斗显示"
L["Combo Points"] = "连击点"
L["Configure Selected Filter"] = "设置所选择的过滤器"
L["Controls the height of the nameplate on low health"] = true;
L["Controls the height of the nameplate"] = "血条的高度设定"
L["Controls the width of the nameplate on low health"] = true;
L["Controls the width of the nameplate"] = "血条的宽度设定"
L["Custom Color"] = "自定颜色"
L["Custom Scale"] = "自定大小比例"
L["Disable threat coloring for this plate and use the custom color."] = "对特定的目标停用仇恨颜色,并使用定制颜色"
L["Display a healer icon over known healers inside battlegrounds or arenas."] = "战场或竞技场中，为已确认为治疗的玩家标上补职图标."
L["Display combo points on nameplates."] = "在血条显示连击点."
L["Enemy"] = "敌对"
L["Filter already exists!"] = "过滤器已存在!"
L["Filters"] = "过滤器"
L["Friendly NPC"] = "友好的NPC"
L["Friendly Player"] = "友好的玩家"
L["Good Transition"] = true;
L["Healer Icon"] = "补职图标"
L["Hide"] = "隐藏"
L["Horrizontal Arrows (Inverted)"] = true;
L["Horrizontal Arrows"] = true;
L["Low Health Threshold"] = "低生命值阀值"
L["Low HP Height"] = true;
L["Low HP Width"] = true;
L["Match the color of the healthbar."] = true;
L["NamePlates"] = "姓名面板(血条)"
L["No Interrupt"] = true;
L["Non-Target Alpha"] = true;
L["Number of Auras"] = true;
L["Prevent any nameplate with this unit name from showing."] = "不显示特定目标的血条"
L["Raid/Healer Icon"] = true;
L["Reaction Coloring"] = true;
L["Remove Name"] = "删除筛选名"
L["Scale if Low Health"] = true;
L["Scaling"] = true;
L["Set the scale of the nameplate."] = "设定血条的缩放比例"
L["Show Level"] = true;
L["Show Name"] = true;
L["Show Personal Auras"] = true;
L["Small Plates"] = "小型模板"
L["Stretch Texture"] = true;
L["Stretch the icon texture, intended for icons that don't have the same width/height."] = true;
L["Tagged NPC"] = true;
L["Target Alpha"] = true;
L["Target Indicator"] = true;
L["Threat"] = "仇恨"
L["Toggle the nameplates to be visible outside of combat and visible inside combat."] = true;
L["Use this filter."] = "使用过滤器"
L["Vertical Arrow"] = true;
L["Wrap Name"] = true;
L["Wraps name instead of truncating it."] = true;
L["X-Offset"] = true;
L["Y-Offset"] = true;
L["You can't remove a default name from the filter, disabling the name."] = "你不能删除过滤器的预设筛选名, 仅能停用此筛选名"

--Profiles Export/Import
L["Choose Export Format"] = true;
L["Choose What To Export"] = true;
L["Decode Text"] = true;
L["Error decoding data. Import string may be corrupted!"] = true;
L["Error exporting profile!"] = true;
L["Export Now"] = true;
L["Export Profile"] = true;
L["Exported"] = true;
L["Filters (All)"] = true;
L["Filters (NamePlates)"] = true;
L["Filters (UnitFrames)"] = true;
L["Global (Account Settings)"] = true;
L["Import Now"] = true;
L["Import Profile"] = true;
L["Importing"] = true;
L["Plugin"] = true;
L["Private (Character Settings)"] = true;
L["Profile imported successfully!"] = true;
L["Profile Name"] = true;
L["Profile"] = true;
L["Table"] = true;

--Skins
L["Achievement Frame"] = "成就"
L["AddOn Manager"] = true;
L["Alert Frames"] = "警报"
L["Archaeology Frame"] = "考古学框架"
L["Auction Frame"] = "拍卖"
L["Barbershop Frame"] = "美容院"
L["BG Map"] = "战场地图"
L["BG Score"] = "战场记分"
L["Black Market AH"] = "黑市"
L["Calendar Frame"] = "日历框架"
L["Character Frame"] = "角色"
L["Death Recap"] = true;
L["Debug Tools"] = "除错工具"
L["Dressing Room"] = "试衣间"
L["Encounter Journal"] = "地城导览"
L["Glyph Frame"] = "雕文"
L["Gossip Frame"] = "闲谈"
L["Guild Bank"] = "公会银行"
L["Guild Control Frame"] = "公会控制"
L["Guild Frame"] = "公会"
L["Guild Registrar"] = "公会注册"
L["Help Frame"] = "帮助"
L["Inspect Frame"] = "观察"
L["Item Upgrade"] = "装备升级"
L["KeyBinding Frame"] = "快捷键"
L["LF Guild Frame"] = "寻求公会"
L["LFG Frame"] = "地下城"
L["Loot Frames"] = "拾取"
L["Loss Control"] = "失去控制"
L["Macro Frame"] = "巨集"
L["Mail Frame"] = "信箱"
L["Merchant Frame"] = "商人"
L["Mirror Timers"] = true;
L["Misc Frames"] = "其他"
L["Mounts & Pets"] = "宠物"
L["Non-Raid Frame"] = "非团队框架"
L["Pet Battle"] = "宠物战斗"
L["Petition Frame"] = "回报GM"
L["PvP Frames"] = "PvP框架"
L["Quest Choice"] = true;
L["Quest Frames"] = "任务"
L["Raid Frame"] = "团队"
L["Reforge Frame"] = "重铸"
L["Skins"] = "美化外观"
L["Socket Frame"] = "珠宝插槽"
L["Spellbook"] = "技能书"
L["Stable"] = "兽栏"
L["Tabard Frame"] = "外袍"
L["Talent Frame"] = "天赋"
L["Taxi Frame"] = "载具"
L["Time Manager"] = "时间管理"
L["Trade Frame"] = "交易"
L["TradeSkill Frame"] = "专业技能"
L["Trainer Frame"] = "训练师"
L["Transmogrify Frame"] = "幻化"
L["Void Storage"] = "虚空存储"
L["World Map"] = "世界地图"

--Tooltip
L["Always Hide"] = "总是隐藏"
L["Bags Only"] = true;
L["Bags/Bank"] = true;
L["Bank Only"] = true;
L["Both"] = true;
L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."] = true;
L["Comparison Font Size"] = true;
L["Cursor Anchor"] = true;
L["Custom Faction Colors"] = true;
L["Display guild ranks if a unit is guilded."] = "当目标有公会时显示其在公会内的等级."
L["Display how many of a certain item you have in your possession."] = '显示当前物品在你身上的数量.'
L["Display player titles."] = "显示玩家头衔."
L["Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit."] = true;
L["Display the spell or item ID when mousing over a spell or item tooltip."] = '在鼠标提示中显示技能或物品的ID.'
L["Guild Ranks"] = "公会等级"
L["Header Font Size"] = true;
L["Health Bar"] = true;
L["Hide tooltip while in combat."] = "战斗时不显示提示"
L["Inspect Info"] = true;
L["Item Count"] = '物品数量'
L["Never Hide"] = "从不隐藏"
L["Player Titles"] = "玩家头衔"
L["Should tooltip be anchored to mouse cursor"] = true;
L["Spell/Item IDs"] = '技能/物品ID'
L["Target Info"] = true;
L["Text Font Size"] = true;
L["This setting controls the size of text in item comparison tooltips."] = true;
L["Tooltip Font Settings"] = true;
L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."] = "显示团队中目标与你目前鼠标提示目标相同的队友"

--UnitFrames
L["%s and then %s"] = "%s 于 %s"
L["2D"] = "2D"
L["3D"] = "3D"
L["Above"] = "向上"
L["Absorbs"] = "吸收"
L["Add a spell to the filter."] = "添加一个技能到过滤器"
L["Add Spell Name"] = true;
L["Add Spell or spellID"] = true;
L["Add Spell"] = "添加技能"
L["Add SpellID"] = "添加技能ID"
L["Additional Filter"] = '额外的过滤器'
L["Affliction"] = "痛苦"
L["Allow auras considered to be part of a boss encounter."] = true;
L["Allow Boss Encounter Auras"] = true;
L["Allow Whitelisted Auras"] = '允许白名单中的光环'
L["An X offset (in pixels) to be used when anchoring new frames."] = true;
L["An Y offset (in pixels) to be used when anchoring new frames."] = true;
L["Anticipation"] = true;
L["Arcane Charges"] = "奥术充能"
L["Ascending or Descending order."] = true;
L["Assist Frames"] = "助理框架"
L["Assist Target"] = "助理目标"
L["At what point should the text be displayed. Set to -1 to disable."] = "在何时显示文本. 设定为-1 禁用此功能."
L["Attach Text to Power"] = true;
L["Attach Text To"] = true;
L["Attach To"] = "附加到"
L["Aura Bars"] = "光环条"
L["Auto-Hide"] = true;
L["Bad"] = "危险"
L["Bars will transition smoothly."] = "状态条平滑增减"
L["Below"] = "向下"
L["Blacklist Modifier"] = true;
L["Blacklist"] = "黑名单"
L["Block Auras Without Duration"] = "不显示没有持续时间的光环"
L["Block Blacklisted Auras"] = "不显示黑名单中的光环"
L["Block Non-Dispellable Auras"] = "显示可驱散的光环"
L["Block Non-Personal Auras"] = "显示个人光环"
L["Block Raid Buffs"] = "不显示团队BUFF"
L["Blood"] = "鲜血符文"
L["Borders"] = "边框"
L["Buff Indicator"] = "Buff 提示器"
L["Buffs"] = "增益光环"
L["By Type"] = "类型"
L["Camera Distance Scale"] = "视角镜头的距离"
L["Castbar"] = "施法条"
L["Center"] = '置中'
L["Check if you are in range to cast spells on this specific unit."] = "检查你是否在技能有效范围内."
L["Choose UIPARENT to prevent it from hiding with the unitframe."] = true;
L["Class Backdrop"] = "生命条背景职业色"
L["Class Castbars"] = "施法条职业色"
L["Class Color Override"] = "职业色覆盖"
L["Class Health"] = "生命条职业色"
L["Class Power"] = "能量条职业色"
L["Class Resources"] = "职业能量"
L["Click Through"] = "点击穿透"
L["Color all buffs that reduce the unit's incoming damage."] = "减少目标受到伤害的所有 Buff 的颜色."
L["Color aurabar debuffs by type."] = "按类型显示光环条颜色."
L["Color castbars by the class of player units."] = true;
L["Color castbars by the reaction type of non-player units."] = true;
L["Color health by amount remaining."] = "按数值变化血量颜色."
L["Color health by classcolor or reaction."] = "以职业色显示生命."
L["Color power by classcolor or reaction."] = "以职业色显示能量."
L["Color the health backdrop by class or reaction."] = "生命条背景色以职业色显示."
L["Color the unit healthbar if there is a debuff that can be dispelled by you."] = "如果单位目标的减益光环可被驱散，加亮显示其生命值."
L["Color Turtle Buffs"] = "减伤类 Buff 的颜色"
L["Color"] = "颜色"
L["Colored Icon"] = "图标色彩"
L["Coloring (Specific)"] = "着色（具体）"
L["Coloring"] = "着色"
L["Combat Fade"] = "战斗隐藏"
L["Combat Icon"] = true;
L["Combo Point"] = true;
L["Combobar"] = "连击点"
L["Configure Auras"] = "设置光环"
L["Copy From"] = "复制自"
L["Count Font Size"] = "计数字体尺寸"
L["Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list."] = "输入一个名称创建自定义字体样式之后, 你可以在组件的下拉菜单中选择使用."
L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."] = "创造一个过滤器, 一旦创造, 每个单位的 buff/debuff 都能使用"
L["Create Filter"] = "创造过滤器"
L["Current - Max | Percent"] = "目前值 - 最大值 | 百分比"
L["Current - Max"] = "目前值 - 最大值"
L["Current - Percent"] = "目前值 - 百分比"
L["Current / Max"] = "目前/最大生命值"
L["Current"] = "目前值"
L["Custom Dead Backdrop"] = true;
L["Custom Health Backdrop"] = "自订生命条背景"
L["Custom Texts"] = "自定义字体"
L["Death"] = "死亡符文"
L["Debuff Highlighting"] = "减益光环加亮显示"
L["Debuffs"] = "减益光环"
L["Decimal Threshold"] = true;
L["Deficit"] = "亏损值"
L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."] = "删除一个创造的过滤器, 你不能删除内建的过滤器, 只能删除你自已添加的"
L["Delete Filter"] = "删除过滤器"
L["Demonology"] = "恶魔"
L["Destruction"] = "毁灭"
L["Detach From Frame"] = true;
L["Detached Width"] = true;
L["Direction the health bar moves when gaining/losing health."] = "生命条的增减方向"
L["Disable Debuff Highlight"] = true;
L["Disabled Blizzard Frames"] = true;
L["Disabled"] = "禁用"
L["Disables the focus and target of focus unitframes."] = true;
L["Disables the player and pet unitframes."] = true;
L["Disables the target and target of target unitframes."] = true;
L["Disconnected"] = "断开"
L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."] = "在施法状态条的末端显示一个火花材质来区分施法条和背景条."
L["Display druid mana bar when in cat or bear form and when mana is not 100%."] = true;
L["Display Frames"] = "显示框架"
L["Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground."] = "当处于竞技场或战场内, 在框架上显示天赋图标"
L["Display Player"] = "显示玩家"
L["Display Target"] = "显示目标"
L["Display Text"] = "显示文本"
L["Display the castbar icon inside the castbar."] = true;
L["Display the castbar inside the information panel, the icon will be displayed outside the main unitframe."] = true;
L["Display the combat icon on the unitframe."] = true;
L["Display the rested icon on the unitframe."] = "在单位框架上显示充分休息图标。"
L["Display the target of your current cast. Useful for mouseover casts."] = "显示你当前的施法目标. 可以转换成鼠标滑过类型."
L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."] = "若为需引导的法术，在施法条上显示每跳周期伤害。启动此功能后，针对吸取灵魂这类的法术，将自动调整显示每跳周期伤害，并视加速等级增加额外的周期伤害。"
L["Don't display any auras found on the 'Blacklist' filter."] = "不显示任何'黑名单'过滤器中的光环."
L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."] = true;
L["Don't display auras that are not yours."] = "不显示不是你施放的光环."
L["Don't display auras that cannot be purged or dispelled by your class."] = "不显示你不能驱散的光环."
L["Don't display auras that have no duration."] = "不显示没有持续时间的光环."
L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."] = "不显示团队BUFF,如王者祝福或野性印记."
L["Down"] = "下"
L["Druid Mana"] = true;
L["Duration Reverse"] = "持续时间反转"
L["Duration Text"] = true;
L["Duration"] = "持续时间"
L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."] = true;
L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."] = true;
L["Enemy Aura Type"] = "敌对光环类型"
L["Fade the unitframe when out of combat, not casting, no target exists."] = "非战斗/施法/目标不存在时隐藏单位框架"
L["Fill"] = "填充"
L["Filled"] = "全长"
L["Filter Type"] = "过滤器类型"
L["Force Off"] = "强制关闭"
L["Force On"] = "强制开启"
L["Force Reaction Color"] = true;
L["Force the frames to show, they will act as if they are the player frame."] = "强制框架显示."
L["Forces Debuff Highlight to be disabled for these frames"] = true;
L["Forces reaction color instead of class color on units controlled by players."] = true;
L["Format"] = "格式"
L["Frame Level"] = true;
L["Frame Orientation"] = true;
L["Frame Strata"] = true;
L["Frame"] = "框架"
L["Frequent Updates"] = "频繁更新"
L["Friendly Aura Type"] = "友好光环类型"
L["Friendly"] = "友好"
L["Frost"] = "冰霜符文"
L["Glow"] = "闪烁"
L["Good"] = "安全"
L["GPS Arrow"] = true;
L["Group By"] = "队伍排列方式"
L["Grouping & Sorting"] = true;
L["Groups Per Row/Column"] = true;
L["Growth direction from the first unitframe."] = "增长方向从第一个头像框架开始."
L["Growth Direction"] = "增长方向"
L["Harmony"] = "真气"
L["Heal Prediction"] = "治疗量预测"
L["Health Backdrop"] = "生命条背景"
L["Health Border"] = "生命条边框"
L["Health By Value"] = "生命条颜色依数值变化"
L["Health"] = "生命条"
L["Height"] = "高"
L["Holy Power"] = "圣能"
L["Horizontal Spacing"] = "水平间隔"
L["Horizontal"] = "水平"
L["How far away the portrait is from the camera."] = "人像和镜头间有多远"
L["Icon Inside Castbar"] = true;
L["Icon Size"] = true;
L["Icon"] = "图标"
L["Icon: BOTTOM"] = "图标: 底部"
L["Icon: BOTTOMLEFT"] = "图标: 底部左侧"
L["Icon: BOTTOMRIGHT"] = "图标: 底部右侧"
L["Icon: LEFT"] = "图标: 左侧"
L["Icon: RIGHT"] = "图标: 侧"
L["Icon: TOP"] = "图标: 顶部"
L["Icon: TOPLEFT"] = "图标: 顶部左侧"
L["Icon: TOPRIGHT"] = "图标: 顶部侧"
L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = "若没有启用其他过滤器，那只会显示'白名单'里面的光环."
L["If not set to 0 then override the size of the aura icon to this."] = "如果不为 0, 此值将覆盖光环图标的尺寸."
L["If the unit is an enemy to you."] = "如果是你的敌对目标"
L["If the unit is friendly to you."] = "如果是你的友好目标"
L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."] = true;
L["Ignore mouse events."] = "忽略鼠标事件"
L["InfoPanel Border"] = true;
L["Information Panel"] = true;
L["Inset"] = "插入"
L["Inside Information Panel"] = true;
L["Interruptable"] = "可打断颜色"
L["Invert Grouping Order"] = "反转队伍排序"
L["JustifyH"] = '水平对齐'
L["Latency"] = "延迟"
L["Left to Right"] = true;
L["Lunar"] = "月能"
L["Main statusbar texture."] = "主状态条材质"
L["Main Tanks / Main Assist"] = "主坦克 / 主助理"
L["Make textures transparent."] = "材质透明"
L["Match Frame Width"] = "匹配视窗宽度"
L["Max Bars"] = true;
L["Maximum Duration"] = true;
L["Method to sort by."] = true;
L["Middle Click - Set Focus"] = "鼠标中键 - 设置焦点"
L["Middle clicking the unit frame will cause your focus to match the unit."] = "鼠标中键点击单位框架设置焦点."
L["Middle"] = true;
L["Model Rotation"] = "模型旋转"
L["Mouseover"] = "鼠标滑过显示"
L["Name"] = "姓名"
L["Neutral"] = "中立"
L["Non-Interruptable"] = "不可打断颜色"
L["None"] = "无"
L["Not valid spell id"] = "不正确的技能ID"
L["Num Rows"] = "行数"
L["Number of Groups"] = "每队单位数量"
L["Number of units in a group."] = "团队队伍数量."
L["Offset of the powerbar to the healthbar, set to 0 to disable."] = "偏移能量条与生命条的位置, 设为 0代表停用."
L["Offset position for text."] = "偏移文本的位置."
L["Offset"] = "偏移"
L["Only show when the unit is not in range."] = "不在范围内时显示."
L["Only show when you are mousing over a frame."] = "鼠标滑过时显示."
L["OOR Alpha"] = "超出距离透明度"
L["Orientation"] = "生命值增减方向"
L["Others"] = "他人的"
L["Overlay the healthbar"] = "头像重叠与生命条上"
L["Overlay"] = "重叠显示"
L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."] = "复写可见性的设定, 例如: 在10人副本里只显示1队和2队"
L["Override the default class color setting."] = "覆盖默认的职业色设置."
L["Owners Name"] = true;
L["Parent"] = true;
L["Party Pets"] = "队伍宠物"
L["Party Targets"] = "队伍目标"
L["Per Row"] = "每行"
L["Percent"] = "百分比"
L["Personal"] = "个人的"
L["Pet Name"] = true;
L["Player Frame Aura Bars"] = true;
L["Portrait"] = "单位"
L["Position Buffs on Debuffs"] = true;
L["Position Debuffs on Buffs"] = true;
L["Position the Model horizontally."] = true;
L["Position the Model vertically."] = true;
L["Position"] = "位置"
L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."] = "NPC 目标将隐藏能量值文字"
L["Power"] = "能量"
L["Powers"] = "能量"
L["Priority"] = "优先级"
L["Profile Specific"] = true;
L["PVP Trinket"] = "PVP 饰品"
L["Raid Icon"] = "团队图标"
L["Raid-Wide Sorting"] = true;
L["Raid40 Frames"] = true;
L["RaidDebuff Indicator"] = "团队副本减益光环标示"
L["Range Check"] = "距离检查"
L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."] = "实时更新生命值会占用更多的内存的和CPU，只推荐治疗角色开启。"
L["Reaction Castbars"] = true;
L["Reactions"] = "声望"
L["Remaining"] = "剩余生命值"
L["Remove a spell from the filter."] = "从过滤器中移除一个技能"
L["Remove Spell or spellID"] = true;
L["Remove Spell"] = "移除技能"
L["Remove SpellID"] = "移除技能ID"
L["Rest Icon"] = "充分休息图标"
L["Restore Defaults"] = "恢复预设"
L["Right to Left"] = true;
L["RL / ML Icons"] = "主坦克/主助理图标"
L["Role Icon"] = "角色定位图标"
L["Seconds remaining on the aura duration before the bar starts moving. Set to 0 to disable."] = true
L["Select a filter to use."] = "选择使用一个过滤器."
L["Select a unit to copy settings from."] = "选择从哪单位复制."
L["Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = "请选择一个过滤器, 若你启用的是'白名单', 则只显示'白名单'里的光环."
L["Select Filter"] = "选择过滤器"
L["Select Spell"] = "选择技能"
L["Select the display method of the portrait."] = "选择头像的显示方式"
L["Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else."] = "设定过滤器类型, '黑名单'会隐藏名单里面的光环, '白名单'则显示名单里的光环"
L["Set the font size for unitframes."] = "设置单位框架字体尺寸."
L["Set the order that the group will sort."] = "设置组排序的顺序."
L["Set the orientation of the UnitFrame."] = true;
L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."] = "设置该法术的优先顺序. 请注意, 优先级只用于Raid Debuff模块, 而不是标准的Buff/Debuff模块. 设置为 0 禁用此功能."
L["Set the type of auras to show when a unit is a foe."] = "当单位是敌对时设置光环显示的类型."
L["Set the type of auras to show when a unit is friendly."] = "当单位是友好时设置光环显示的类型."
L["Sets the font instance's horizontal text alignment style."] = "设置字体实例的水平文本对齐方式."
L["Shadow Orbs"] = "暗影宝珠"
L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."] = "在单位框架中显示即将回复的的预测治疗量，过量治疗则以不同颜色显示。"
L["Show Aura From Other Players"] = "显示其他玩家的光环"
L["Show Auras"] = "显示光环"
L["Show Dispellable Debuffs"] = true;
L["Show For DPS"] = true;
L["Show For Healers"] = true;
L["Show For Tanks"] = true;
L["Show When Not Active"] = "显示当前无效的光环"
L["Size and Positions"] = true;
L["Size of the indicator icon."] = "提示图标大小"
L["Size Override"] = "尺寸覆盖"
L["Size"] = "大小"
L["Smart Aura Position"] = true;
L["Smart Raid Filter"] = "智能团队过滤"
L["Smooth Bars"] = "平滑化"
L["Solar"] = "日能"
L["Sort By"] = true;
L["Spaced"] = "留空"
L["Spacing"] = true;
L["Spark"] = "火花"
L["Spec Icon"] = "天赋图标"
L["Spell not found in list."] = "列表中未发现技能"
L["Spells"] = "技能"
L["Stack Counter"] = true;
L["Stack Threshold"] = true;
L["Stagger Bar"] = "醉酒列"
L["Start Near Center"] = "从中心开始"
L["StatusBar Texture"] = "状态条材质"
L["Strata and Level"] = true;
L["Style"] = "风格"
L["Tank Frames"] = "坦克框架"
L["Tank Target"] = "坦克目标"
L["Tapped"] = "被攻击"
L["Target Glow"] = true;
L["Target On Mouse-Down"] = "鼠标按下设为目标"
L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon 'Clique' you may have to adjust your clique settings when changing this."] = "按下鼠标时设为目标,而不是松开鼠标按键时. \n\n|cffFF0000警告: 如果使用'Clique'等点击施法插件, 你可能需要调整这些插件的设置."
L["Text Color"] = "文字颜色"
L["Text Format"] = "文字格式"
L["Text Position"] = "文字位置"
L["Text Threshold"] = "文本阀值"
L["Text Toggle On NPC"] = "NPC 文字显示开关"
L["Text xOffset"] = "文字X轴偏移"
L["Text yOffset"] = "文字Y轴偏移"
L["Text"] = "文本"
L["Textured Icon"] = "图标纹理"
L["The alpha to set units that are out of range to."] = "单位框架超出距离的透明度"
L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."] = true;
L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."] = "为了显示设定过的过滤器下面的巨集必须启用"
L["The font that the unitframes will use."] = "单位框架字体"
L["The initial group will start near the center and grow out."] = "最初的队伍由中心开始增长."
L["The name you have selected is already in use by another element."] = "你所选的名称已经被另一组件占用."
L["The object you want to attach to."] = "你想依附的目标."
L["Thin Borders"] = true;
L["This dictates the size of the icon when it is not attached to the castbar."] = true;
L["This filter is meant to be used when you only want to whitelist specific spellIDs which share names with unwanted spells."] = true;
L["This filter is used for both aura bars and aura icons no matter what. Its purpose is to block out specific spellids from being shown. For example a paladin can have two sacred shield buffs at once, we block out the short one."] = '这个过滤器作用于光环条和光环图标,不管是什么,其目的是为了用阻止特定技能ID的技能被显示. 例如: 圣骑士可以一次有两个神圣之盾BUFF, 我们阻止了时间短的那个显示.'
L["This opens the UnitFrames Color settings. These settings affect all unitframes."] = true;
L["Threat Display Mode"] = "仇恨显示模式"
L["Threshold before text goes into decimal form. Set to -1 to disable decimals."] = true;
L["Ticks"] = "周期伤害"
L["Time Remaining Reverse"] = "剩余时间反转"
L["Time Remaining"] = "剩余时间"
L["Toggles health text display"] = "切换生命值显示"
L["Transparent"] = "透明"
L["Turtle Color"] = "减伤类的颜色"
L["Unholy"] = "邪恶符文"
L["Uniform Threshold"] = true;
L["UnitFrames"] = "单位框架"
L["Up"] = "上"
L["Use Custom Level"] = true;
L["Use Custom Strata"] = true;
L["Use Dead Backdrop"] = true;
L["Use Default"] = "自定義默認值"
L["Use the custom health backdrop color instead of a multiple of the main health color."] = "自定义生命条背景色"
L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."] = true;
L["Use thin borders on certain unitframe elements."] = true;
L["Use this backdrop color for units that are dead or ghosts."] = true;
L["Value must be a number"] = "数值必须为一个数字"
L["Vertical Spacing"] = "垂直间隔"
L["Vertical"] = "垂直"
L["Visibility"] = "可见性"
L["What point to anchor to the frame you set to attach to."] = "框架的定位对齐方向"
L["What to attach the buff anchor frame to."] = "buff 定位附加到哪儿"
L["What to attach the debuff anchor frame to."] = "Debuff 定位附加到的框架."
L["When true, the header includes the player when not in a raid."] = "若启用,队伍中将显示玩家"
L["Whitelist"] = "白名单"
L["Width"] = "宽"
L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."] = true;
L["xOffset"] = "X轴偏移"
L["yOffset"] = "Y轴偏移"
L["You can't remove a pre-existing filter."] = "你不能删除一个内建的过滤器"
L["You cannot copy settings from the same unit."] = "你不能从相同的单位复制设定"
L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."] = "你不能移除一个内建技能, 仅能停用此技能."
L["You need to hold this modifier down in order to blacklist an aura by right-clicking the icon. Set to None to disable the blacklist functionality."] = true;