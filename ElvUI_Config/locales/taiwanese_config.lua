-- Taiwanese localization file for zhTW.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "zhTW")
if not L then return end

-- *_DESC locales
L["AURAS_DESC"] = "小地圖旁的光環圖示設定."
L["BAGS_DESC"] = "調整 ElvUI 背包設定."
L["CHAT_DESC"] = "對話框架設定."
L["DATATEXT_DESC"] = "屏幕資訊文字顯示設定."
L["ELVUI_DESC"] = "ElvUI 為一套功能完整, 可用來替換 WOW 原始介面的 UI 套件"
L["NAMEPLATE_DESC"] = "修改血條設定."
L["PANEL_DESC"] = "調整左、右對話框的尺寸, 此設定將會影響對話與背包框架的尺寸."
L["SKINS_DESC"] = "調整外觀設定."
L["TOGGLESKIN_DESC"] = "啟用/停用此外觀."
L["TOOLTIP_DESC"] = "浮動提示資訊設定選項."
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
L["TEXT_FORMAT_DESC"] = [=[請填入代碼以變更文字格式。

範例：
[namecolor][name] [difficultycolor][smartlevel] [shortclassification]
[healthcolor][health:current-max]
[powercolor][power:current]

生命/能量值格式：
'current' - 目前數值
'percent' - 百分比
'current-max' - 目前數值 - 最大值，當兩者相同時，僅會顯示最大值
'current-percent' - 目前數值 - 百分比
'current-max-percent' - 目前數值 - 最大值 - 百分比，當目前數值等同於最大值時，僅會顯示最大值
'deficit' - 顯示損失數值，若未損失生命/能量值，將不予顯示

名稱格式：
'name:short' - 名稱上限為 10 個字元
'name:medium' - 名稱上限為 15 個字元
'name:long' - 名稱上限為 20 個字元

若要停用此功能，此欄位請留空。如需更多資訊，請至 http://www.tukui.org]=];
L["IGNORE_ITEMS_DESC"] = [=[Valid entries:

Item links or item names

Terms from Search Syntax. Examples:
q:epic
s:Tank Set
q:epic&lvl:>300

See "Bags->Search Syntax" for more.]=];

--ActionBars
L["Action Paging"] = "快捷列翻頁"
L["ActionBars"] = "快捷列"
L["Allow Masque to handle the skinning of this element."] = true;
L["Alpha"] = "透明度"
L["Anchor Point"] = "定位方向"
L["Backdrop Spacing"] = true;
L["Backdrop"] = "背景"
L["Button Size"] = "按鈕尺寸"
L["Button Spacing"] = "按鈕間距"
L["Buttons Per Row"] = "每行按鈕數"
L["Buttons"] = "按鈕數"
L["Change the alpha level of the frame."] = "改變框架透明度."
L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."] = "施放能量 (法力、怒氣、集中值、聖能) 不足的技能快捷鍵顏色."
L["Color of the actionbutton when out of range."] = "超出施放範圍的技能快捷鍵顏色."
L["Color when the text is about to expire"] = "即將冷卻完畢的數字顏色."
L["Color when the text is in the days format."] = "以天顯示的文字顏色."
L["Color when the text is in the hours format."] = "以小時顯示的文字顏色."
L["Color when the text is in the minutes format."] = "以分顯示的文字顏色."
L["Color when the text is in the seconds format."] = "以秒顯示的文字顏色."
L["Cooldown Text"] = "冷卻文字"
L["Darken Inactive"] = true;
L["Days"] = "天"
L["Display bind names on action buttons."] = "在快捷列按鈕上顯示快捷鍵名稱."
L["Display cooldown text on anything with the cooldown spiral."] = "顯示技能冷卻時間."
L["Display macro names on action buttons."] = "在快捷列按鈕上顯示巨集名稱."
L["Expiring"] = "即將冷卻完畢"
L["Global Fade Transparency"] = true;
L["Height Multiplier"] = "高度倍增"
L["Hide Cooldown Bling"] = true;
L["Hides the bling animation on buttons at the end of the global cooldown."] = true;
L["Hours"] = "時"
L["If you unlock actionbars then trying to move a spell might instantly cast it if you cast spells on key press instead of key release."] = true;
L["Inherit Global Fade"] = true;
L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = true;
L["Key Down"] = "按下施法"
L["Keybind Mode"] = "快捷鍵綁定模式"
L["Keybind Text"] = "快捷鍵文字"
L["Low Threshold"] = "冷卻時間低閥值"
L["Macro Text"] = "巨集名稱"
L["Masque Support"] = true;
L["Minutes"] = "分"
L["Mouse Over"] = "滑鼠滑過顯示"
L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."] = "根據此值增加背景的高度或寬度. 一般用來設定在一個背景框裡放置多條快捷列."
L["Out of Power"] = "施放能量不足"
L["Out of Range"] = "超出施放範圍"
L["Restore Bar"] = "還原快捷列"
L["Restore the actionbars default settings"] = "恢復此快捷列的預設設定"
L["Seconds"] = "秒"
L["Show Empty Buttons"] = true;
L["The amount of buttons to display per row."] = "每行按鈕顯示數量."
L["The amount of buttons to display."] = "快捷列按鈕顯示數量."
L["The button you must hold down in order to drag an ability to another action button."] = "需按住此按鈕，才可將技能拖曳至另一快捷鈕中."
L["The first button anchors itself to this point on the bar."] = "快捷列第一個按鈕的所在位置."
L["The size of the action buttons."] = "快捷列按鈕尺寸."
L["The spacing between the backdrop and the buttons."] = true;
L["This setting will be updated upon changing stances."] = true;
L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"] = "冷卻時間低於此秒數後將變為紅色數字, 並以小數顯示, 設為- 1 冷卻時間將不會變為紅色."
L["Toggles the display of the actionbars backdrop."] = "顯示/隱藏快捷列背景框."
L["Transparency level when not in combat, no target exists, full health, not casting, and no focus target exists."] = true;
L["Visibility State"] = "顯示狀態"
L["Width Multiplier"] = "寬度倍增"
L[ [=[This works like a macro, you can run different situations to get the actionbar to page differently.
 Example: '[combat] 2;']=] ] = [=[此功能與巨集概念類似，可根據不同情境，切換至不同的快捷列設置。
例如：'[combat] 2;']=]
L[ [=[This works like a macro, you can run different situations to get the actionbar to show/hide differently.
 Example: '[combat] show;hide']=] ] = [=[此功能與巨集概念類似，可根據不同情境，切換顯示/隱藏快捷列。
例如：'[combat] show;hide']=]

--Bags
L["Adjust the width of the bag frame."] = '調整背包框架寬度.'
L["Adjust the width of the bank frame."] = '調整銀行框架寬度.'
L["Align the width of the bag frame to fit inside the chat box."] = '調整背包框架寬度以適應對話框.'
L["Align To Chat"] = '對齊對話框架'
L["Ascending"] = "升序"
L["Bag Sorting"] = true;
L["Bag-Bar"] = "背包條"
L["Bar Direction"] = "背包條排序方向"
L["Blizzard Style"] = true;
L["Bottom to Top"] = "底部至頂部"
L["Button Size (Bag)"] = '單個格子尺寸 (背包)'
L["Button Size (Bank)"] = '單個格子尺寸 (銀行)'
L["Condensed"] = true;
L["Currency Format"] = '貨幣格式'
L["Descending"] = "降序"
L["Direction the bag sorting will use to allocate the items."] = "整理背包物品時，將依此排序方向排放物品."
L["Display Item Level"] = true;
L["Display the junk icon on all grey items that can be vendored."] = true;
L["Displays item level on equippable items."] = true;
L["Enable/Disable the all-in-one bag."] = "啟用/停用整合背包."
L["Enable/Disable the Bag-Bar."] = "啟用/停用背包條."
L["Full"] = true;
L["Icons and Text (Short)"] = true;
L["Icons and Text"] = '圖示與文字'
L["Ignore Items"] = "忽略項目"
L["Item Count Font"] = true;
L["Item Level Threshold"] = true;
L["Item Level"] = true;
L["Items in this list or items that match any Search Syntax query in this list will be ignored when sorting. Separate each entry with a comma."] = true;
L["Money Format"] = true;
L["Panel Width (Bags)"] = '框架寬度 (背包)'
L["Panel Width (Bank)"] = '框架寬度 (銀行)'
L["Search Syntax"] = true;
L["Set the size of your bag buttons."] = "設定你的背包格尺寸."
L["Short (Whole Numbers)"] = true;
L["Short"] = true;
L["Show Coins"] = true;
L["Show Junk Icon"] = true;
L["Smart"] = true;
L["Sort Direction"] = "整理排序方向"
L["Sort Inverted"] = '倒序排列'
L["The direction that the bag frames be (Horizontal or Vertical)."] = "背包框架排序方向 (水平或垂直)."
L["The direction that the bag frames will grow from the anchor."] = "新增的背包框架將依此定位方向排序."
L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"] = '背包主框架下方的兌換通貨圖示顯示格式.需先設定監控特定兌換通貨，才會顯示於背包框架.'
L["The display format of the money text that is shown at the top of the main bag."] = true;
L["The frame is not shown unless you mouse over the frame."] = "僅於游標移經快捷列時顯示框架."
L["The minimum item level required for it to be shown."] = true;
L["The size of the individual buttons on the bag frame."] = '背包框架單個格子的尺寸.'
L["The size of the individual buttons on the bank frame."] = '銀行框架單個格子的尺寸.'
L["The spacing between buttons."] = "兩個按鈕間的距離."
L["Top to Bottom"] = "頂部至底部"
L["Use coin icons instead of colored text."] = true;
L["X Offset Bags"] = true;
L["X Offset Bank"] = true;
L["Y Offset Bags"] = true;
L["Y Offset Bank"] = true;

--Buffs and Debuffs
L["Begin a new row or column after this many auras."] = "在這些光環旁開始新的行或列."
L["Consolidated Buffs"] = "整合增益"
L["Count xOffset"] = true;
L["Count yOffset"] = true;
L["Defines how the group is sorted."] = "請定義群組分類方式."
L["Defines the sort order of the selected sort method."] = "請定義所選分類方式的排序."
L["Disabled Blizzard"] = true;
L["Display the consolidated buffs bar."] = "顯示整合增益條"
L["Fade Threshold"] = "剩餘時間閥值"
L["Filter Consolidated"] = '篩選效益相同的光環';
L["Index"] = "索引"
L["Indicate whether buffs you cast yourself should be separated before or after."] = "將你自身施放的增益從整體增益之前或之後分離出來."
L["Limit the number of rows or columns."] = "最大行數或列數."
L["Max Wraps"] = "每行最大數"
L["No Sorting"] = "不分類"
L["Only show consolidated icons on the consolidated bar that your class/spec is interested in. This is useful for raid leading."] = '只在綜合光環條上僅顯示有益於玩家職業/天賦的增益光環, 指揮團隊時相當有用.'
L["Other's First"] = "他人光環優先"
L["Remaining Time"] = "剩餘時間"
L["Reverse Style"] = true;
L["Seperate"] = "光環分離"
L["Set the size of the individual auras."] = "設定每個光環的尺寸."
L["Sort Method"] = "分類方式"
L["The direction the auras will grow and then the direction they will grow after they reach the wrap after limit."] = true;
L["Threshold before text changes red, goes into decimal form, and the icon will fade. Set to -1 to disable."] = "冷卻時間低於此秒數後將變為紅色數字以小數顯示, 並且圖示會漸隱. 設定為-1 禁用此功能."
L["Time xOffset"] = true;
L["Time yOffset"] = true;
L["Time"] = "時間"
L["When enabled active buff icons will light up instead of becoming darker, while inactive buff icons will become darker instead of being lit up."] = true;
L["Wrap After"] = "每行光環數"
L["Your Auras First"] = "自身光環優先"

--Chat
L["Above Chat"] = '對話框上方'
L["Adjust the height of your right chat panel."] = true;
L["Adjust the width of your right chat panel."] = true;
L["Alerts"] = true;
L["Attempt to create URL links inside the chat."] = "對話視窗出現網址時建立連結."
L["Attempt to lock the left and right chat frame positions. Disabling this option will allow you to move the main chat frame anywhere you wish."] = "鎖定左右對話框架的位置.禁用此選項將允許你移動對話框架到任意位置."
L["Below Chat"] = '對話框下方'
L["Chat EditBox Position"] = '對話輸入框位置'
L["Chat History"] = "對話記錄"
L["Copy Text"] = "複製文字"
L["Display LFG Icons in group chat."] = true;
L["Display the hyperlink tooltip while hovering over a hyperlink."] = "滑鼠懸停在超鏈接上時顯示鏈接提示框."
L["Enable the use of separate size options for the right chat panel."] = true;
L["Fade Chat"] = "對話內容漸隱"
L["Fade Tabs No Backdrop"] = true;
L["Fade the chat text when there is no activity."] = '未出現新訊息時，隱藏對話框的文字.'
L["Fade Undocked Tabs"] = true;
L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."] = true;
L["Fades the text on chat tabs that are not docked at the left or right chat panel."] = true;
L["Font Outline"] = "字體描邊"
L["Font"] = "字體"
L["Hide Both"] = "全部隱藏"
L["Hyperlink Hover"] = "超連結提示資訊"
L["Keyword Alert"] = "關鍵字警報"
L["Keywords"] = "關鍵字"
L["Left Only"] = "僅顯示左框背景"
L["LFG Icons"] = true;
L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank"] = "如果在對話信息中發現如下文字會自動上色該文字. 如果你需要添加多個詞必須用逗號分開. 如要搜尋角色名稱可使用%MYNAME %.\n\n例如:\n%MYNAME%, ElvUI, RBGs, Tank"
L["Lock Positions"] = '鎖定位置'
L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session."] = '記錄對話歷史,當你重載,登錄和退出時會恢復你最後一次會話'
L["No Alert In Combat"] = true;
L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."] = "對話框滾動到底部所需要的滾動時間(秒)."
L["Panel Backdrop"] = "對話框背景"
L["Panel Height"] = "對話框高度"
L["Panel Texture (Left)"] = "對話框材質(左)"
L["Panel Texture (Right)"] = "對話框材質(右)"
L["Panel Width"] = "對話框寛度"
L["Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat."] = '對話編輯框位置,如果底部的信息文字被禁用的話,將會強制顯示在對話框頂部.'
L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."] = "單位時間(秒) 內屏蔽重複對話信息, 設定為0 禁用此功能."
L["Require holding the Alt key down to move cursor or cycle through messages in the editbox."] = true;
L["Right Only"] = "僅顯示右框背景"
L["Right Panel Height"] = true;
L["Right Panel Width"] = true;
L["Scroll Interval"] = "滾動間隔"
L["Separate Panel Sizes"] = true;
L["Set the font outline."] = "字體描邊設定."
L["Short Channels"] = "隱藏頻道名稱"
L["Shorten the channel names in chat."] = "在對話視窗中隱藏頻道名稱."
L["Show Both"] = "全部顯示"
L["Spam Interval"] = "洗頻訊息間隔"
L["Sticky Chat"] = "記憶對話頻道"
L["Tab Font Outline"] = "分頁字體描邊"
L["Tab Font Size"] = "分頁字體尺寸"
L["Tab Font"] = "分頁字體"
L["Tab Panel Transparency"] = "標籤面板透明"
L["Tab Panel"] = "標籤面板"
L["Toggle showing of the left and right chat panels."] = "顯示/隱藏左、右對話框背景."
L["Toggle the chat tab panel backdrop."] = "顯示/隱藏對話框架標籤面板背景."
L["URL Links"] = "網址連結"
L["Use Alt Key"] = true;
L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."] = "打開此選項將會保存你的輸入框為上一次輸入的頻道, 關閉此選項輸入框將始終保持在說的頻道."
L["Whisper Alert"] = "密語警報"
L[ [=[Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.

Please Note:
-The image size recommended is 256x128
-You must do a complete game restart after adding a file to the folder.
-The file type must be tga format.

Example: Interface\AddOns\ElvUI\media\textures\copy

Or for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here.]=] ] = [=[若要設定對話框背景, 請將你希望設定為背景的檔案置放於WoW 目錄底下的「Textures」資料夾中, 並指定該檔名.

請注意：
- 影像尺寸建議為 256 x 128
- 在此資料夾新增檔案後, 請務必重新啟動遊戲.
- 檔案必須為 tga 格式.

範例：Interface\AddOns\ElvUI\media\textures\copy

對多數玩家來說, 較簡易的方式是將 tga 檔放入 WoW 資料夾中, 然後在此處輸入檔案名稱.]=]

--Credits
L["Coding:"] = "編碼:"
L["Credits"] = "嗚謝"
L["Donations:"] = "捐款: "
L["ELVUI_CREDITS"] = "我想透過這個特別方式, 向那些協助測試、編碼及透過捐款協助過我的人表達感謝, 請曾提供協助的朋友至論壇傳私訊給我, 我會將你的名字添加至此處."
L["Testing:"] = "測試："

--DataTexts
L["24-Hour Time"] = "24小時制"
L["Battleground Texts"] = "戰場資訊"
L["Block Combat Click"] = true;
L["Block Combat Hover"] = true;
L["Blocks all click events while in combat."] = true;
L["Blocks datatext tooltip from showing in combat."] = true;
L["BottomMiniPanel"] = "Minimap Bottom (Inside)"
L["BottomLeftMiniPanel"] = "Minimap BottomLeft (Inside)"
L["BottomRightMiniPanel"] = "Minimap BottomRight (Inside)"
L["Change settings for the display of the location text that is on the minimap."] = "改變小地圖所在位置文字的顯示設定."
L["Datatext Panel (Left)"] = "左側資訊框"
L["Datatext Panel (Right)"] = "右側資訊框"
L["DataTexts"] = "資訊文字"
L["Display data panels below the chat, used for datatexts."] = "在對話框下顯示用於資訊的框架."
L["Display minimap panels below the minimap, used for datatexts."] = "顯示小地圖下方的資訊框."
L["Gold Format"] = true;
L["If not set to true then the server time will be displayed instead."] = "若關閉此選項將顯示伺服器時間."
L["left"] = "左"
L["LeftChatDataPanel"] = "左對話框"
L["LeftMiniPanel"] = "小地圖左側"
L["Local Time"] = "本地時間"
L["middle"] = "中"
L["Minimap Panels"] = "小地圖欄"
L["Panel Transparency"] = "面板透明"
L["Panels"] = "對話框"
L["right"] = "右"
L["RightChatDataPanel"] = "右對話框"
L["RightMiniPanel"] = "小地圖右側"
L["Small Panels"] = true;
L["The display format of the money text that is shown in the gold datatext and its tooltip."] = true;
L["Toggle 24-hour mode for the time datatext."] = "切換時間顯示為24小時制."
L["TopMiniPanel"] = "Minimap Top (Inside)"
L["TopLeftMiniPanel"] = "Minimap TopLeft (Inside)"
L["TopRightMiniPanel"] = "Minimap TopRight (Inside)"
L["When inside a battleground display personal scoreboard information on the main datatext bars."] = "處於戰場時, 在主資訊文字條顯示你的戰場得分訊息."
L["Word Wrap"] = true;

--Distributor
L["Must be in group with the player if he isn't on the same server as you."] = "如果不是同一服務器, 那他必需和你在同一隊伍中."
L["Sends your current profile to your target."] = "發送你的配置文件到當前目標."
L["Sends your filter settings to your target."] = "發送你的過濾器配置到當前目標."
L["Share Current Profile"] = "分享當前的配置文件"
L["Share Filters"] = "分享過濾器配置"
L["This feature will allow you to transfer, settings to other characters."] = "此功能將使你設置轉移給其他角色."
L["You must be targeting a player."] = "你必須以一名玩家為目標."

--General
L["Accept Invites"] = "接受組隊邀請"
L["Adjust the position of the threat bar to either the left or right datatext panels."] = "調整仇恨條的位置於左側或右側資訊面板"
L["Adjust the size of the minimap."] = "調整小地圖尺寸."
L["AFK Mode"] = true;
L["Announce Interrupts"] = "斷法通告"
L["Announce when you interrupt a spell to the specified chat channel."] = "在指定對話頻道通知斷法信息."
L["Attempt to support eyefinity/nvidia surround."] = true;
L["Auto Greed/DE"] = "自動貪婪/分解"
L["Auto Repair"] = "自動修裝"
L["Auto Scale"] = "自動縮放"
L["Auto"] = true;
L["Automatically accept invites from guild/friends."] = "自動接受公會成員/朋友的組隊邀請."
L["Automatically repair using the following method when visiting a merchant."] = "與商人對話時，透過下列方式自動修復裝備."
L["Automatically scale the User Interface based on your screen resolution"] = "依螢幕解析度自動縮放 UI 介面."
L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."] = "當你的等級達到滿級時, 自動選擇貪婪或分解綠色物品."
L["Automatically vendor gray items when visiting a vendor."] = "當訪問商人時自動出售灰色物品."
L["Bonus Reward Position"] = true;
L["Bottom Panel"] = '底部面板'
L["Chat Bubbles Style"] = true;
L["Chat Bubbles"] = true;
L["Direction the bar moves on gains/losses"] = true;
L["Disable Tutorial Buttons"] = true;
L["Disables the tutorial button found on some frames."] = true;
L["Display a panel across the bottom of the screen. This is for cosmetic only."] = '顯示跨越屏幕底部的面板,僅僅是用于裝飾.'
L["Display a panel across the top of the screen. This is for cosmetic only."] = '顯示跨越屏幕頂部的面板,僅僅是用于裝飾.'
L["Display battleground messages in the middle of the screen."] = true;
L["Display emotion icons in chat."] = "在對話中顯示表情圖示."
L["Emotion Icons"] = "表情圖示"
L["Enable/Disable the loot frame."] = "啟用/停用拾取框架."
L["Enable/Disable the loot roll frame."] = "啟用/停用擲骰框架."
L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r"] = "啟用/停用小地圖. |cffFF0000警告: 這將使你無法看見綜合增益框和小地圖資訊欄.|r"
L["Enhanced PVP Messages"] = true;
L["General"] = "一般設定"
L["Height of the objective tracker. Increase size to be able to see more objectives."] = true;
L["Hide At Max Level"] = true;
L["Hide Error Text"] = "隱藏錯誤文字"
L["Hide In Vehicle"] = true;
L["Hides the red error text at the top of the screen while in combat."] = "戰鬥中隱藏屏幕頂部紅字錯誤信息."
L["Log Taints"] = "錯誤記錄";
L["Login Message"] = "登入資訊"
L["Loot Roll"] = "擲骰"
L["Loot"] = "拾取"
L["Make the world map smaller."] = true;
L["Multi-Monitor Support"] = true;
L["Name Font"] = "名稱字體"
L["Objective Frame Height"] = true;
L["Party / Raid"] = true;
L["Party Only"] = true;
L["Position of bonus quest reward frame relative to the objective tracker."] = true;
L["Puts coordinates on the world map."] = true;
L["Raid Only"] = true;
L["Remove Backdrop"] = "移除背景"
L["Reset all frames to their original positions."] = "重設所有框架至預設位置."
L["Reset Anchors"] = "重置位置"
L["Reverse Fill Direction"] = true;
L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."] = "發送ADDON_ACTION_BLOCKED錯誤至Lua錯誤框, 這些錯誤並不重要, 不會影響你的遊戲體驗. 並且很多這類錯誤無法被修復. 請只將影響遊戲體驗的錯誤發送給我們."
L["Skin Backdrop"] = "美化背景"
L["Skin the blizzard chat bubbles."] = "美化暴雪對話泡泡."
L["Smaller World Map"] = true;
L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "玩家頭頂姓名的字體. |cffFF0000警告: 你需要重新開啟遊戲或重新登錄才能使用此功能.|r"
L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."] = true;
L["Thin Border Theme"] = true;
L["Toggle Tutorials"] = "教學開關"
L["Top Panel"] = '頂部面板'
L["When you go AFK display the AFK screen."] = true;
L["World Map Coordinates"] = true;

--Media
L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."] = true;
L["Applies the primary texture to all statusbars."] = true;
L["Apply Font To All"] = true;
L["Apply Texture To All"] = true;
L["Backdrop color of transparent frames"] = "透明框架的背景顏色"
L["Backdrop Color"] = "背景顏色"
L["Backdrop Faded Color"] = "背景透明色"
L["Border Color"] = "邊框顏色"
L["Color some texts use."] = "數值(非文字)使用的顏色"
L["Colors"] = "顏色"
L["CombatText Font"] = "戰鬥文字字體"
L["Default Font"] = "預設字體"
L["Font Size"] = "字體尺寸"
L["Fonts"] = "字體"
L["Main backdrop color of the UI."] = "介面背景主色"
L["Main border color of the UI. |cffFF0000This is disabled if you are using the Thin Border Theme.|r"] = true;
L["Media"] = "材質"
L["Primary Texture"] = "主要材質"
L["Replace Blizzard Fonts"] = true;
L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."] = true;
L["Secondary Texture"] = "次要材質"
L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = "設定介面上所有字體的尺寸, 但不包含本身有獨立設定的字體(如單位框架字體、資訊文字字體等...)"
L["Textures"] = "材質"
L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"] = "戰鬥資訊將使用此字體, |​​cffFF0000警告:需重啟遊戲或重新登入才可使此變更生效.|r"
L["The font that the core of the UI will use."] = "核心UI 所使用的字體."
L["The texture that will be used mainly for statusbars."] = "此材質主用於狀態列上."
L["This texture will get used on objects like chat windows and dropdown menus."] = "主要用於對話視窗及下拉選單等物件的材質."
L["Value Color"] = "數值顏色"

--Minimap
L["Always Display"] = "總是顯示"
L["Bottom Left"] = true;
L["Bottom Right"] = true;
L["Bottom"] = true;
L["Instance Difficulty"] = true;
L["Left"] = "左"
L["LFG Queue"] = true;
L["Location Text"] = "所在位置文字"
L["Minimap Buttons"] = true;
L["Minimap Mouseover"] = "小地圖滑鼠滑過"
L["Right"] = true;
L["Scale"] = "右"
L["Top Left"] = true;
L["Top Right"] = true;
L["Top"] = true;

--Misc
L["Install"] = "安裝"
L["Run the installation process."] = "執行安裝程序"
L["Toggle Anchors"] = "解鎖元件定位"
L["Unlock various elements of the UI to be repositioned."] = "解鎖介面上的各種元件, 以便更改位置."
L["Version"] = "版本"

--NamePlates
L["Add Name"] = "添加名稱"
L["Adjust nameplate size on low health"] = true;
L["Adjust nameplate size on smaller mobs to scale down. This will only adjust the health bar width not the actual nameplate hitbox you click on."] = "低級怪物啓用較小型的血條顯示, 此調整只改變血條的寬度."
L["All"] = "全部"
L["Alpha of current target nameplate."] = true;
L["Alpha of nameplates that are not your current target."] = true;
L["Always display your personal auras over the nameplate."] = "總是在血條上顯示你的個人光環."
L["Bad Transition"] = true;
L["Bring nameplate to front on low health"] = true;
L["Bring to front on low health"] = true;
L["Can Interrupt"] = true;
L["Cast Bar"] = true;
L["Castbar Height"] = "施法條高度"
L["Change color on low health"] = true;
L["Color By Healthbar"]  = true;
L["Color By Raid Icon"] = true;
L["Color Name By Health Value"] = true;
L["Color on low health"] = true;
L["Color the border of the nameplate yellow when it reaches this point, it will be colored red when it reaches half this value."] = "當到達此數值時, 血條的邊框將被上色為黃色. 當到達此數值一半時, 血條姓名面板的邊框將被上色為紅色."
L["Combat Toggle"] = "戰鬥顯示"
L["Combo Points"] = "連擊點"
L["Configure Selected Filter"] = "設置所選擇的過濾器"
L["Controls the height of the nameplate on low health"] = true;
L["Controls the height of the nameplate"] = "血條的高度設定"
L["Controls the width of the nameplate on low health"] = true;
L["Controls the width of the nameplate"] = "血條的寬度設定"
L["Custom Color"] = "自訂顏色"
L["Custom Scale"] = "自訂比例"
L["Disable threat coloring for this plate and use the custom color."] = "對特定的目標停用仇恨顏色,並使用定制顏色"
L["Display a healer icon over known healers inside battlegrounds or arenas."] = "戰場或競技場中，為已確認為補職的玩家標上補職圖示."
L["Display combo points on nameplates."] = "在血條上顯示連擊點."
L["Enemy"] = "敵對"
L["Filter already exists!"] = "過濾器已存在!"
L["Filters"] = "過濾器"
L["Friendly NPC"] = "友好的NPC"
L["Friendly Player"] = "友好的玩家"
L["Good Transition"] = true;
L["Healer Icon"] = "補職圖示"
L["Hide"] = "隱藏"
L["Horrizontal Arrows (Inverted)"] = true;
L["Horrizontal Arrows"] = true;
L["Low Health Threshold"] = "低生命值閥值"
L["Low HP Height"] = true;
L["Low HP Width"] = true;
L["Match the color of the healthbar."] = true;
L["NamePlates"] = "姓名面板(血條)"
L["No Interrupt"] = true;
L["Non-Target Alpha"] = true;
L["Number of Auras"] = true;
L["Prevent any nameplate with this unit name from showing."] = "不顯示特定目標的血條."
L["Raid/Healer Icon"] = true;
L["Reaction Coloring"] = true;
L["Remove Name"] = "刪除篩選名"
L["Scale if Low Health"] = true;
L["Scaling"] = true;
L["Set the scale of the nameplate."] = "設定血條的縮放比例."
L["Show Level"] = true;
L["Show Name"] = true;
L["Show Personal Auras"] = true;
L["Small Plates"] = "小型模塊"
L["Stretch Texture"] = true;
L["Stretch the icon texture, intended for icons that don't have the same width/height."] = true;
L["Tagged NPC"] = true;
L["Target Alpha"] = true;
L["Target Indicator"] = true;
L["Threat"] = "仇恨"
L["Toggle the nameplates to be visible outside of combat and visible inside combat."] = true;
L["Use this filter."] = "使用過濾器"
L["Vertical Arrow"] = true;
L["Wrap Name"] = true;
L["Wraps name instead of truncating it."] = true;
L["X-Offset"] = true;
L["Y-Offset"] = true;
L["You can't remove a default name from the filter, disabling the name."] = "你無法自篩選器移除，請停用預設名稱."

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
L["Alert Frames"] = "警報"
L["Archaeology Frame"] = "考古學框架"
L["Auction Frame"] = "拍賣"
L["Barbershop Frame"] = "美容院"
L["BG Map"] = "戰場地圖"
L["BG Score"] = "戰場積分"
L["Black Market AH"] = "黑市"
L["Calendar Frame"] = "行事曆"
L["Character Frame"] = "角色"
L["Death Recap"] = true;
L["Debug Tools"] = "除錯工具"
L["Dressing Room"] = "試衣間"
L["Encounter Journal"] = "地城導覽"
L["Glyph Frame"] = "雕文"
L["Gossip Frame"] = "對話"
L["Guild Bank"] = "公會銀行"
L["Guild Control Frame"] = "公會控制"
L["Guild Frame"] = "公會"
L["Guild Registrar"] = "公會註冊"
L["Help Frame"] = "幫助"
L["Inspect Frame"] = "觀察"
L["Item Upgrade"] = "裝備升級"
L["KeyBinding Frame"] = "快捷鍵"
L["LF Guild Frame"] = "尋求公會"
L["LFG Frame"] = "地下城"
L["Loot Frames"] = "拾取框架"
L["Loss Control"] = "失去控制"
L["Macro Frame"] = "巨集"
L["Mail Frame"] = "信箱"
L["Merchant Frame"] = "商人"
L["Mirror Timers"] = true;
L["Misc Frames"] = "其他"
L["Mounts & Pets"] = "寵物"
L["Non-Raid Frame"] = "非團隊框架"
L["Pet Battle"] = "寵物戰鬥"
L["Petition Frame"] = "回報GM"
L["PvP Frames"] = "PvP框架"
L["Quest Choice"] = true;
L["Quest Frames"] = "任務"
L["Raid Frame"] = "團隊框架"
L["Reforge Frame"] = "重鑄"
L["Skins"] = "美化外觀"
L["Socket Frame"] = "珠寶插槽"
L["Spellbook"] = "技能書"
L["Stable"] = "獸欄"
L["Tabard Frame"] = "外袍"
L["Talent Frame"] = "天賦"
L["Taxi Frame"] = "載具"
L["Time Manager"] = "時間管理"
L["Trade Frame"] = "交易"
L["TradeSkill Frame"] = "專業技能"
L["Trainer Frame"] = "訓練師"
L["Transmogrify Frame"] = "塑型"
L["Void Storage"] = "虛空存儲"
L["World Map"] = "世界地圖"

--Tooltip
L["Always Hide"] = "總是隱藏"
L["Bags Only"] = true;
L["Bags/Bank"] = true;
L["Bank Only"] = true;
L["Both"] = true;
L["Choose when you want the tooltip to show. If a modifer is chosen, then you need to hold that down to show the tooltip."] = true;
L["Comparison Font Size"] = true;
L["Cursor Anchor"] = true;
L["Custom Faction Colors"] = true;
L["Display guild ranks if a unit is guilded."] = "当目标有公會時顯示其在公會內的會階."
L["Display how many of a certain item you have in your possession."] = '顯示當前物品在你身上的數量'
L["Display player titles."] = "顯示玩家稱號."
L["Display the players talent spec and item level in the tooltip, this may not immediately update when mousing over a unit."] = true;
L["Display the spell or item ID when mousing over a spell or item tooltip."] = '鼠標提示中顯示技能或物品的ID'
L["Guild Ranks"] = "公會會階"
L["Header Font Size"] = true;
L["Health Bar"] = true;
L["Hide tooltip while in combat."] = "戰鬥時不顯示提示."
L["Inspect Info"] = true;
L["Item Count"] = '物品數量'
L["Never Hide"] = "从不隐藏"
L["Player Titles"] = "玩家稱號"
L["Should tooltip be anchored to mouse cursor"] = true;
L["Spell/Item IDs"] = '技能/物品ID'
L["Target Info"] = true;
L["Text Font Size"] = true;
L["This setting controls the size of text in item comparison tooltips."] = true;
L["Tooltip Font Settings"] = true;
L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."] = "顯示團隊中目標與你目前浮動提示目標相同的隊友."

--UnitFrames
L["%s and then %s"] = '%s 与 %s'
L["2D"] = "2D"
L["3D"] = "3D"
L["Above"] = "向上"
L["Absorbs"] = "吸收"
L["Add a spell to the filter."] = "添加一個技能到過濾器"
L["Add Spell Name"] = true;
L["Add Spell or spellID"] = true;
L["Add Spell"] = "添加技能"
L["Add SpellID"] = "添加技能ID"
L["Additional Filter"] = '額外的過濾器'
L["Affliction"] = "痛苦"
L["Allow auras considered to be part of a boss encounter."] = true;
L["Allow Boss Encounter Auras"] = true;
L["Allow Whitelisted Auras"] = '允許白名單中的光環'
L["An X offset (in pixels) to be used when anchoring new frames."] = true;
L["An Y offset (in pixels) to be used when anchoring new frames."] = true;
L["Anticipation"] = true;
L["Arcane Charges"] = "秘法充能"
L["Ascending or Descending order."] = true;
L["Assist Frames"] = "助理框架"
L["Assist Target"] = "助理目標"
L["At what point should the text be displayed. Set to -1 to disable."] = "在何時顯示文本. 設定為-1 禁用此功能."
L["Attach Text to Power"] = true;
L["Attach Text To"] = true;
L["Attach To"] = "附加到"
L["Aura Bars"] = "光環條"
L["Auto-Hide"] = true;
L["Bad"] = "危險"
L["Bars will transition smoothly."] = "狀態條平滑增減"
L["Below"] = "向下"
L["Blacklist Modifier"] = true;
L["Blacklist"] = "黑名單"
L["Block Auras Without Duration"] = "不顯示沒有持續時間的光環"
L["Block Blacklisted Auras"] = "不顯示黑名單中的光環"
L["Block Non-Dispellable Auras"] = "顯示可以驅散的光環"
L["Block Non-Personal Auras"] = "顯示個人光環"
L["Block Raid Buffs"] = "不顯示團隊BUFF"
L["Blood"] = "血魄符文"
L["Borders"] = "邊框"
L["Buff Indicator"] = "Buff 提示器"
L["Buffs"] = "增益光環"
L["By Type"] = "類型"
L["Camera Distance Scale"] = "視角鏡頭的距離"
L["Castbar"] = "施法條"
L["Center"] = '置中'
L["Check if you are in range to cast spells on this specific unit."] = "檢查你是否在技能有效範圍內."
L["Choose UIPARENT to prevent it from hiding with the unitframe."] = true;
L["Class Backdrop"] = "生命條背景職業色"
L["Class Castbars"] = "施法條職業色"
L["Class Color Override"] = "職業色覆蓋"
L["Class Health"] = "生命條職業色"
L["Class Power"] = "能量條職業色"
L["Class Resources"] = "職業能量"
L["Click Through"] = "點擊穿透";
L["Color all buffs that reduce the unit's incoming damage."] = "減少目標受到的傷害的所有 Buff 的顏色."
L["Color aurabar debuffs by type."] = "按類型顯示光環條顔色."
L["Color castbars by the class of player units."] = true;
L["Color castbars by the reaction type of non-player units."] = true;
L["Color health by amount remaining."] = "按數值變化血量顏色."
L["Color health by classcolor or reaction."] = "以職業色顯示生命."
L["Color power by classcolor or reaction."] = "以職業色顯示能量."
L["Color the health backdrop by class or reaction."] = "生命條背景色以職業色顯示."
L["Color the unit healthbar if there is a debuff that can be dispelled by you."] = "如果單位目標的減益光環可被驅散, 加亮顯示其生命值."
L["Color Turtle Buffs"] = "減傷類 Buff 的顏色"
L["Color"] = "顏色"
L["Colored Icon"] = "圖示色彩"
L["Coloring (Specific)"] = "著色（具體）"
L["Coloring"] = "著色"
L["Combat Fade"] = "戰鬥隱藏"
L["Combat Icon"] = true;
L["Combo Point"] = true;
L["Combobar"] = "連擊點"
L["Configure Auras"] = "設置光環"
L["Copy From"] = "複製自"
L["Count Font Size"] = "計數字體尺寸"
L["Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list."] = "輸入一個名稱創建自定義字體樣式之後, 你可以在組件的下拉菜單中選擇使用."
L["Create a filter, once created a filter can be set inside the buffs/debuffs section of each unit."] = "創造一個過濾器, 一旦創造, 每個單位的buff/debuff 都能使用."
L["Create Filter"] = "創造過濾器"
L["Current - Max | Percent"] = "目前值- 最大值| 百分比"
L["Current - Max"] = "目前值 - 最大值"
L["Current - Percent"] = "目前值 - 百分比"
L["Current / Max"] = "目前/最大值"
L["Current"] = "目前值"
L["Custom Dead Backdrop"] = true;
L["Custom Health Backdrop"] = "自訂生命條背景"
L["Custom Texts"] = "自定義字體"
L["Death"] = "死亡符文"
L["Debuff Highlighting"] = "減益光環加亮顯示"
L["Debuffs"] = "減益光環"
L["Decimal Threshold"] = true;
L["Deficit"] = "虧損值"
L["Delete a created filter, you cannot delete pre-existing filters, only custom ones."] = "刪除一個創造的過濾器, 你不能刪除內建的過濾器, 只能刪除你自已添加的."
L["Delete Filter"] = "刪除過濾器"
L["Demonology"] = "惡魔"
L["Destruction"] = "毀滅"
L["Detach From Frame"] = true;
L["Detached Width"] = true;
L["Direction the health bar moves when gaining/losing health."] = "生命條的增減方向."
L["Disable Debuff Highlight"] = true;
L["Disabled Blizzard Frames"] = true;
L["Disabled"] = "禁用"
L["Disables the focus and target of focus unitframes."] = true;
L["Disables the player and pet unitframes."] = true;
L["Disables the target and target of target unitframes."] = true;
L["Disconnected"] = "離線"
L["Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop."] = "在施法狀態條的末端顯示一個火花材質來區分施法條和背景條."
L["Display druid mana bar when in cat or bear form and when mana is not 100%."] = true;
L["Display Frames"] = "顯示框架"
L["Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground."] = "當處於競技場或戰場內, 在框架上顯示天賦圖示"
L["Display Player"] = "顯示玩家"
L["Display Target"] = "顯示目標"
L["Display Text"] = "顯示文本"
L["Display the castbar icon inside the castbar."] = true;
L["Display the castbar inside the information panel, the icon will be displayed outside the main unitframe."] = true;
L["Display the combat icon on the unitframe."] = true;
L["Display the rested icon on the unitframe."] = "在單位框架上顯示充分休息圖示."
L["Display the target of your current cast. Useful for mouseover casts."] = "顯示你當前的施法目標. 可以轉換成鼠标滑過類型."
L["Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste."] = "若為需引導的法術, 在施法條上顯示每跳週期傷害. 啟動此功能後, 針對吸取靈魂這類的法術, 將自動調整顯示每跳週期傷害, 並視加速等級增加額外的周期傷害."
L["Don't display any auras found on the 'Blacklist' filter."] = "不顯示任何'黑名單'過濾器中的光環."
L["Don't display auras that are longer than this duration (in seconds). Set to zero to disable."] = true;
L["Don't display auras that are not yours."] = "不顯示不是你施放的光環."
L["Don't display auras that cannot be purged or dispelled by your class."] = "不顯示你不能驅散的光環."
L["Don't display auras that have no duration."] = "不限時沒有持續時間的光環."
L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."] = "不顯示團隊BUFF,如王者祝福和野性印記."
L["Down"] = "下"
L["Druid Mana"] = true;
L["Duration Reverse"] = "持續時間反轉"
L["Duration Text"] = true;
L["Duration"] = "持續時間"
L["Enabling this allows raid-wide sorting however you will not be able to distinguish between groups."] = true;
L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."] = true;
L["Enemy Aura Type"] = "敵對光環類型"
L["Fade the unitframe when out of combat, not casting, no target exists."] = "非戰鬥/施法/目標不存在時隱藏單位框架"
L["Fill"] = "填充"
L["Filled"] = "全長"
L["Filter Type"] = "過濾器類型"
L["Force Off"] = "強制關閉"
L["Force On"] = "強制開啓"
L["Force Reaction Color"] = true;
L["Force the frames to show, they will act as if they are the player frame."] = "強制框架顯示."
L["Forces Debuff Highlight to be disabled for these frames"] = true;
L["Forces reaction color instead of class color on units controlled by players."] = true;
L["Format"] = "格式"
L["Frame Level"] = true;
L["Frame Orientation"] = true;
L["Frame Strata"] = true;
L["Frame"] = "框架"
L["Frequent Updates"] = "立即更新生命值"
L["Friendly Aura Type"] = "友好目標光環類型"
L["Friendly"] = "友好"
L["Frost"] = "冰霜符文"
L["Glow"] = "閃爍"
L["Good"] = "安全"
L["GPS Arrow"] = true;
L["Group By"] = "隊伍排列方式"
L["Grouping & Sorting"] = true;
L["Groups Per Row/Column"] = true;
L["Growth direction from the first unitframe."] = "增長方向從第一個頭像框架開始."
L["Growth Direction"] = "增長方向"
L["Harmony"] = "真氣"
L["Heal Prediction"] = "治療量預測"
L["Health Backdrop"] = "生命條背景"
L["Health Border"] = "生命條邊框"
L["Health By Value"] = "生命條顏色依數值變化"
L["Health"] = "生命條"
L["Height"] = "高"
L["Holy Power"] = "聖能"
L["Horizontal Spacing"] = "水平間隔"
L["Horizontal"] = "水平"
L["How far away the portrait is from the camera."] = "人像和鏡頭間有多遠"
L["Icon Inside Castbar"] = true;
L["Icon Size"] = true;
L["Icon"] = "圖示"
L["Icon: BOTTOM"] = "圖示: 底部"
L["Icon: BOTTOMLEFT"] = "圖示: 底部左側"
L["Icon: BOTTOMRIGHT"] = "圖示: 底部右側"
L["Icon: LEFT"] = "圖示: 左側"
L["Icon: RIGHT"] = "圖示: 右側"
L["Icon: TOP"] = "圖示: 頂部"
L["Icon: TOPLEFT"] = "圖示: 頂部左側"
L["Icon: TOPRIGHT"] = "圖示: 頂部右側"
L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = "若沒有啓用其他過濾器，那只會顯示'白名單'裡面的光環."
L["If not set to 0 then override the size of the aura icon to this."] = "若設為 0，光環圖示大小將不會變更為此值."
L["If the unit is an enemy to you."] = "如果是你的敵對目標"
L["If the unit is friendly to you."] = "如果是你的友好目標"
L["If you have a lot of 3D Portraits active then it will likely have a big impact on your FPS. Disable some portraits if you experience FPS issues."] = true;
L["Ignore mouse events."] = "忽略滑鼠事件.";
L["InfoPanel Border"] = true;
L["Information Panel"] = true;
L["Inset"] = "插入"
L["Inside Information Panel"] = true;
L["Interruptable"] = "可斷法的施法顏色"
L["Invert Grouping Order"] = "反轉隊伍排序"
L["JustifyH"] = '橫向字體對齊';
L["Latency"] = "延遲"
L["Left to Right"] = true;
L["Lunar"] = "月能"
L["Main statusbar texture."] = "主狀態條材質"
L["Main Tanks / Main Assist"] = "主坦克 / 主助理"
L["Make textures transparent."] = "材質透明"
L["Match Frame Width"] = "匹配視窗寬度"
L["Max Bars"] = true;
L["Maximum Duration"] = true;
L["Method to sort by."] = true;
L["Middle Click - Set Focus"] = "鼠標中鍵 - 設置焦點"
L["Middle clicking the unit frame will cause your focus to match the unit."] = "鼠標中鍵點擊單位框架設置焦點."
L["Middle"] = true;
L["Model Rotation"] = "模型旋轉"
L["Mouseover"] = "鼠標滑過顯示"
L["Name"] = "姓名"
L["Neutral"] = "中立"
L["Non-Interruptable"] = "不可斷法的施法條色"
L["None"] = "無"
L["Not valid spell id"] = "無效的技能ID"
L["Num Rows"] = "行數"
L["Number of Groups"] = "每隊單位數量"
L["Number of units in a group."] = "團隊隊伍數量."
L["Offset of the powerbar to the healthbar, set to 0 to disable."] = "偏移能量條與生命條的位置, 設定為0 禁用此功能."
L["Offset position for text."] = "偏移文本的位置."
L["Offset"] = "偏移"
L["Only show when the unit is not in range."] = "不在範圍內時顯示."
L["Only show when you are mousing over a frame."] = "鼠標滑過時顯示."
L["OOR Alpha"] = "超出距離透明度"
L["Orientation"] = "生命值增減方嚮"
L["Others"] = "他人的"
L["Overlay the healthbar"] = "頭像重疊顯示於生命條上"
L["Overlay"] = "重疊顯示"
L["Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance."] = "複寫可見性的設定, 例如: 在10人副本里只顯示1隊和2隊."
L["Override the default class color setting."] = "覆蓋默認職業色設置."
L["Owners Name"] = true;
L["Parent"] = true;
L["Party Pets"] = "隊伍寵物"
L["Party Targets"] = "隊伍目標"
L["Per Row"] = "每行"
L["Percent"] = "百分比"
L["Personal"] = "個人的"
L["Pet Name"] = true;
L["Player Frame Aura Bars"] = true;
L["Portrait"] = "頭像"
L["Position Buffs on Debuffs"] = true;
L["Position Debuffs on Buffs"] = true;
L["Position the Model horizontally."] = true;
L["Position the Model vertically."] = true;
L["Position"] = "位置"
L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."] = "NPC 目標將隱藏能量值文字."
L["Power"] = "能量"
L["Powers"] = "能量"
L["Priority"] = "優先級"
L["Profile Specific"] = true;
L["PVP Trinket"] = "PVP 飾品"
L["Raid Icon"] = "團隊圖示"
L["Raid-Wide Sorting"] = true;
L["Raid40 Frames"] = true;
L["RaidDebuff Indicator"] = "團隊副本減益光環標示"
L["Range Check"] = "距離檢查"
L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."] = "實時更新生命值會佔用更多的內存的和CPU, 只推薦治療角色開啟."
L["Reaction Castbars"] = true;
L["Reactions"] = "陣營聲望"
L["Remaining"] = "剩餘數值"
L["Remove a spell from the filter."] = "從過濾器中移除一個技能."
L["Remove Spell or spellID"] = true;
L["Remove Spell"] = "移除技能"
L["Remove SpellID"] = "移除技能ID"
L["Rest Icon"] = "充分休息圖示"
L["Restore Defaults"] = "恢復預設"
L["Right to Left"] = true;
L["RL / ML Icons"] = "團隊隊長/裝備分配圖示"
L["Role Icon"] = "角色定位圖示"
L["Seconds remaining on the aura duration before the bar starts moving. Set to 0 to disable."] = true
L["Select a filter to use."] = "選擇使用一個過濾器."
L["Select a unit to copy settings from."] = "選擇從哪單位複制."
L["Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings."] = "請選擇一個過濾器, 若你啓用的是'白名單', 則只顯示'白名單'裡的光環."
L["Select Filter"] = "選擇過濾器"
L["Select Spell"] = "選擇技能"
L["Select the display method of the portrait."] = "選擇頭像的顯示方式"
L["Set the filter type, blacklisted filters hide any aura on the like and show all else, whitelisted filters show any aura on the filter and hide all else."] = "設定過濾器類型, '黑名單'會隱藏名單裡面的光環, '白名單'則顯示名單裡的光環."
L["Set the font size for unitframes."] = "設定單位框架字體尺寸."
L["Set the order that the group will sort."] = "設定組排序的順序."
L["Set the orientation of the UnitFrame."] = true;
L["Set the priority order of the spell, please note that prioritys are only used for the raid debuff module, not the standard buff/debuff module. If you want to disable set to zero."] = "設定該法術的優先順序. 請注意, 優先級只用於Raid Debuff模塊, 而不是標準的Buff/Debuff模塊. 設定為0 禁用此功能."
L["Set the type of auras to show when a unit is a foe."] = "當單位是敵對時設定光環顯示的類型."
L["Set the type of auras to show when a unit is friendly."] = "當單位是友好時設定光環顯示的類型."
L["Sets the font instance's horizontal text alignment style."] = "設定橫向字體的對齊方式."
L["Shadow Orbs"] = "暗影寶珠"
L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."] = "在單位框架中顯示即將回复的的預測治療量, 過量治療則以不同顏色顯示. "
L["Show Aura From Other Players"] = "顯示其他玩家的光環"
L["Show Auras"] = "顯示光環"
L["Show Dispellable Debuffs"] = true;
L["Show For DPS"] = true;
L["Show For Healers"] = true;
L["Show For Tanks"] = true;
L["Show When Not Active"] = "顯示當前無效的光環"
L["Size and Positions"] = true;
L["Size of the indicator icon."] = "提示圖示尺寸"
L["Size Override"] = "尺寸覆蓋"
L["Size"] = "尺寸"
L["Smart Aura Position"] = true;
L["Smart Raid Filter"] = "智能團隊過濾"
L["Smooth Bars"] = "平滑化"
L["Solar"] = "日能"
L["Sort By"] = true;
L["Spaced"] = "留空"
L["Spacing"] = true;
L["Spark"] = "火花"
L["Spec Icon"] = "天賦圖示"
L["Spell not found in list."] = "列表中未發現技能"
L["Spells"] = "技能"
L["Stack Counter"] = true;
L["Stack Threshold"] = true;
L["Stagger Bar"] = "醉酒列"
L["Start Near Center"] = "由中心開始"
L["StatusBar Texture"] = "狀態條材質"
L["Strata and Level"] = true;
L["Style"] = "風格"
L["Tank Frames"] = "坦克框架"
L["Tank Target"] = "坦克目標"
L["Tapped"] = "被攻擊"
L["Target Glow"] = true;
L["Target On Mouse-Down"] = "鼠標按下設為目標"
L["Target units on mouse down rather than mouse up. \n\n|cffFF0000Warning: If you are using the addon 'Clique' you may have to adjust your clique settings when changing this."] = "按下滑鼠時設為目標,而不是鬆開滑鼠按鍵時. \n\n|cffFF0000警告: 如果使用'Clique'等點擊施法插件, 你可能需要調整這些插件的設置."
L["Text Color"] = "文字顔色"
L["Text Format"] = "文字格式"
L["Text Position"] = "文字位置"
L["Text Threshold"] = "文本閥值"
L["Text Toggle On NPC"] = "NPC 文字顯示開關"
L["Text xOffset"] = "文字X軸偏移"
L["Text yOffset"] = "文字Y軸偏移"
L["Text"] = "文本"
L["Textured Icon"] = "圖示紋理"
L["The alpha to set units that are out of range to."] = "單位框架超出距離的透明度."
L["The debuff needs to reach this amount of stacks before it is shown. Set to 0 to always show the debuff."] = true;
L["The following macro must be true in order for the group to be shown, in addition to any filter that may already be set."] = "為了顯示設定過的過濾器下面的巨集必須啟用."
L["The font that the unitframes will use."] = "單位框架字體."
L["The initial group will start near the center and grow out."] = "最初的隊伍由中心開始增長."
L["The name you have selected is already in use by another element."] = "你所選的名稱已經被另一組件佔用."
L["The object you want to attach to."] = "你想依附的目標."
L["Thin Borders"] = true;
L["This dictates the size of the icon when it is not attached to the castbar."] = true;
L["This filter is meant to be used when you only want to whitelist specific spellIDs which share names with unwanted spells."] = true;
L["This filter is used for both aura bars and aura icons no matter what. Its purpose is to block out specific spellids from being shown. For example a paladin can have two sacred shield buffs at once, we block out the short one."] = '這個篩檢程式作用於光環條和光環圖示,不管是什麼,其目的是為了用阻止特定技能ID的技能被顯示. 例如: 聖騎士可以一次有兩個神聖之盾BUFF, 我們阻止了時間短的那個顯示.'
L["This opens the UnitFrames Color settings. These settings affect all unitframes."] = true;
L["Threat Display Mode"] = "仇恨顯示模式"
L["Threshold before text goes into decimal form. Set to -1 to disable decimals."] = true;
L["Ticks"] = "週期傷害"
L["Time Remaining Reverse"] = "剩餘時間反轉"
L["Time Remaining"] = "剩餘時間"
L["Toggles health text display"] = "顯示/隱藏生命值文字"
L["Transparent"] = "透明"
L["Turtle Color"] = "減傷類的顏色"
L["Unholy"] = "穢邪符文"
L["Uniform Threshold"] = true;
L["UnitFrames"] = "單位框架"
L["Up"] = "上"
L["Use Custom Level"] = true;
L["Use Custom Strata"] = true;
L["Use Dead Backdrop"] = true;
L["Use Default"] = "自定義默認值"
L["Use the custom health backdrop color instead of a multiple of the main health color."] = "自定義生命條背景色."
L["Use the profile specific filter 'Buff Indicator (Profile)' instead of the global filter 'Buff Indicator'."] = true;
L["Use thin borders on certain unitframe elements."] = true;
L["Use this backdrop color for units that are dead or ghosts."] = true;
L["Value must be a number"] = "數值必須為一個數字"
L["Vertical Spacing"] = "垂直間隔"
L["Vertical"] = "垂直"
L["Visibility"] = "可見性"
L["What point to anchor to the frame you set to attach to."] = "增益光環框架於其依附框架的依附位置."
L["What to attach the buff anchor frame to."] = "Buff 定位附加到的框架."
L["What to attach the debuff anchor frame to."] = "Debuff 定位附加到的框架."
L["When true, the header includes the player when not in a raid."] = "若啟用, 隊伍中將顯示玩家."
L["Whitelist"] = "白名單"
L["Width"] = "寬"
L["Will show Buffs in the Debuff position when there are no Debuffs active, or vice versa."] = true;
L["xOffset"] = "X軸偏移"
L["yOffset"] = "Y軸偏移"
L["You can't remove a pre-existing filter."] = "你不能刪除一個內建的過濾器"
L["You cannot copy settings from the same unit."] = "你不能從相同的單位複制設定"
L["You may not remove a spell from a default filter that is not customly added. Setting spell to false instead."] = "你不能移除一個內建技能, 僅能停用此技能."
L["You need to hold this modifier down in order to blacklist an aura by right-clicking the icon. Set to None to disable the blacklist functionality."] = true;