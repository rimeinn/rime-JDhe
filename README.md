# Rime 输入法 「简单鹤」双拼辅助码方案
Rime 输入法配置方案，小鹤双拼+**简单鹤**乱序字根辅助方案+修改配置后的**全拼**（可加辅码）与 **虎码**（字词合并）方案

---

## 简单鹤介绍

![简单鹤字根图V8.4](image/简单鹤字根图V8.4.png)

####  乱序字根

使用字根记忆程序学习字根，最快能在一个小时内掌握简单鹤的字根

#### 单字低重

让你轻松盲打

#### 字词不重

简单鹤采用了极端的字词避重方式，在算码的时候尽量让更多的字处在三码位，剩下的四码单字则全部放在次选，好让四码首选永远可以畅快打词。

#### 没有小字

没有小字，拆分直观，使得简单鹤在打生字时也能快速反应

---

## 配置介绍

- 简体 | 全拼（可加辅码） | 双拼（可加辅码）|音形（自动上屏）|虎码（字词合并）

-  主要功能

  - 轻量的英文输入，支持中英混输（取自 [雾凇拼音](https://github.com/iDvel/rime-ice)）
  
  - [优化英文输入体验](https://dvel.me/posts/make-rime-en-better/)
  
  - 拆字反查  <kbd>oiz</kbd> + 拼音  (默认为小鹤双拼 支持改为**全拼**或**自然码双拼**)
  
  - 统配反查键 <kbd>\`</kbd> 横排数字键1左边 ，（支持改为**全拼**或**自然码双拼**）
    <kbd>\`</kbd> + 小鹤双拼 （此配置下所有方案均可以此形式反查，但「虎码」是临时双拼）
    小鹤双拼 + <kbd>\`</kbd>（**仅限**选择「简单鹤」方案以此形式反查）
    小鹤双拼+ <kbd>\`</kbd> + 形码 （形码默认是以「自然码字根」支持改为 简单鹤/自然码/虎码/官鹤）
    
  - 虎码输入 <kbd>ohm</kbd> + 虎码（本人再使用简单鹤前为虎码用户，所以有带上这个功能）
  
  - 雾凇方案下整理的 Emoji （取自 [雾凇拼音](https://github.com/iDvel/rime-ice)）
  
  - 以词定字（首字：<kbd>Shift</kbd> + <kbd>1</kbd>，末字：<kbd>Shift</kbd> + <kbd>2</kbd>）
  
  - 长词优先（**仅限**选择「朙月拼音」方案下） （取自 [雾凇拼音](https://github.com/iDvel/rime-ice)）
  
  - Unicode（<kbd>U</kbd>+Unicode 码位）（取自 [雾凇拼音](https://github.com/iDvel/rime-ice)）
  
  - 数字、人民币大写、简易计算器（<kbd>=</kbd> + 数字 或 算式）（取自 [空山五笔](https://github.com/mrshiqiqi/rime-wubi)）
  
  - 日期、时间、星期、农历（<kbd>/</kbd>+wd、wt、wk、nl 农历可加数字输入。<kbd>o</kbd> 加对应的简拼也可以，如orq、oxq、osj、onl、）（取自 [飞鹤快拼](https://github.com/boomker/rime-fast-xhup)）
  
  - Emoji 表情符号排序后置 （详见配置 `config_base.yaml/emoji_reduce` 节点）（取自 [飞鹤快拼](https://github.com/boomker/rime-fast-xhup)）
  
  - 置顶候选项， 将希望排序靠前的字词 按下<kbd>Ctrl</kbd>+<kbd>T</kbd>，再按一下取消指定。数据保存在 `Rime\lua\jdh\pin_word_record.lua` 或 `Rime\lua\tiger\pin_word_record.lua` **仅限 「简单鹤・字词」和「虎码」两个方案下使用**（取自 [飞鹤快拼](https://github.com/boomker/rime-fast-xhup)）
  
  - 隐藏候选词或降低排序，将不希望出现在候选中的词组，按下<kbd>Ctrl</kbd>+<kbd>X</kbd> 隐藏，按下<kbd>Ctrl</kbd>+<kbd>J</kbd> 降低排序，数据保存在 `Rime\lua\jdh\cold_word_records\hide_words.lua(隐藏组词)、reduce_freq_words.lua(降频词组)` 虎码方案下储存路径同理。**仅限 「简单鹤」「简单鹤・字词」和「虎码」三个方案下使用**（取自 [飞鹤快拼](https://github.com/boomker/rime-fast-xhup)）
    在使用该方案时，如果不满意排序的候选，**建议**以此功能来修改，这样独立于码表，方便在后续更新方案时，不被覆盖掉个人的使用习惯
  
  - 字集切换开关（区分常用单字和全字集）（取自 [虎码输入方案](https://github.com/ywxt/rime-huma?tab=readme-ov-file)）
  
  - 虎码拆字3重注释（已被本人修改为3.5重，0.5重为仅显示拼音，作为其他方案的拼音滤镜）（取自 [虎码输入方案](https://github.com/ywxt/rime-huma?tab=readme-ov-file)）
  
  - 字词候选嵌入输入栏开关（取自 [宇浩输入方案](https://github.com/forFudan/yuhao)）
  
  - 标点快符自动上屏 <kbd>；</kbd>+ 字母 比如输入 `;a` 自动上屏 `！`（详见配置 `custom_phrase/quick_symbol_phrase.txt` 文件）
  
  - <kbd>/FJ</kbd> 前缀: 用于输入常用短语(邮箱/手机号/银行卡号/收件地址); 和打开常用网站网址, 本地文件路径; 执行常见指令(开关系统设置) 等等, 可自行在`Rime\lua\launcher_config.lua` 里添加（取自 [飞鹤快拼](https://github.com/boomker/rime-fast-xhup)）
  
  - <kbd>/JK</kbd> 前缀: 用于快速启动或切换程序 可自行在`Rime\lua\launcher_config.lua` （取自 [飞鹤快拼](https://github.com/boomker/rime-fast-xhup)）
  
  - 根据是否在用户词典，在结尾加上一个标识（取自 [白霜拼音](https://github.com/gaboolic/rime-frost)）
    上屏过的候选词 末尾带有「✩」
  
    用户短语词库中的候选词（custom_phrase）末尾带有「❖」
  
    整句连拼时（输入词库中未有的词句）末尾带有「∞」
  
- 「简单鹤」方案下的特殊介绍（上述的主要功能全都包含，以下为专有） 

  - 固词动词切换开关 （简单鹤词库候选末尾会带一个「⌃」符号区分） （取自 [魔然输入方案](https://github.com/ksqsf/rime-moran)）
    **固词模式**下 输入的前4码 为简单鹤码表词库，固定排列在最前面，拼音词库作为补充，当简单鹤空码，排序靠前
    **动词模式**下 只有输入的前3码 为简单鹤码表词库，固定排序在最前面，拼音词库作为补充，4码排序靠前，而且会随着候选上屏情况，调节词序（此模式下 简单鹤的4码单字不会优先靠前）
    习惯音形，字词输入节奏的用户，建议<kbd>Ctrl</kbd>+<kbd>~</kbd> 切换成 **固词模式**，四码词序和单字确定性更强

  - 简码提示 （取自 [魔然输入方案](https://github.com/ksqsf/rime-moran)）
    如果以完整编码在输入2字词 3字词 4字词时，和在候选提示该词的简码

    如果希望单字也提示简码，可自行在`double_pinyin_flypy.custom.yaml/moran/quick_code_hint_min_len`修改

  - 自定义置顶词 自造词 快捷键响应（取自 [魔然输入方案](https://github.com/ksqsf/rime-moran)）
  
    详情见`double_pinyin_flypy.custom.yaml/moran/pin/enable`节点下注释
  
    该方案也是将希望排序靠前的字词 按下<kbd>Ctrl</kbd>+<kbd>T</kbd>，再按一下取消指定。但区别于主要功能中介绍的那个功能，该功能数据保存在 「moran_pin.userdb」中，可以方便的使用 RIME 自带的同步功能将设备间 调整过的内容同步合并
  
    造词功能 通过输入 “编码A”//“编码B” 实现造词功能，编码A是这个新词的新编码 
  
    比如 输入「aa」后加上<kbd>//</kbd>然后在完整打出候选「 jm dj hei fh an」（简单鹤方案），以后就能在输入「aa」时打出 「简单鹤方案」 这个候选了
  
    置顶词自造词候选末尾会带有「ᵀᴼᴾ」标识以作区分
  
    在使用简单鹤方案时，如果不满意排序的候选，**建议**以此功能来修改，这样独立于码表，方便在后续更新方案时，不被覆盖掉个人的使用习惯



本人自用的 简单鹤 rime配置  （暂时仅为已基本掌握简单鹤用户使用）

简单鹤码表与**方案作者 「简单」** 同步更新 （其中不同处为 3码3字词为本人手动维护， 3字词候选优先为那类连词如 「的样子」「非常的」。 3字名词类，作者建议 六码秒了，不要赌词）

ctrl+~切换方案 (简单鹤用户请在开关中开启 「固词」，体验最完全体的简单鹤)

**简单鹤**（虽然文件名是朴素的 double_pinyin_flypy，但实际上补丁中已让其大变样）

**简单鹤・字词**（四码定长，自动上屏）

**朙月拼音・全拼**（虽然文件名是朴素的 luna_pinyin，但实际上补丁中已让其大变样，词库也改为使用白霜拼音。因为小狼毫在「用户配置文件为空」时每次部署都会生成「luna_pinyin.userdb」，本人不想手动删除，索性自用方案也改为 「luna_pinyin」）

**虎码** （虽然文件名是朴素的 tiger，但实际上补丁中已让其大变样。本人在使用简单鹤前，为虎码用户，该方案是单字+词组，两库融合，纯单用户可用开关控制其为纯单 ）

功能介绍等待更新……

简单鹤作者信息等待更新……

感谢说明等待更新……

简单鹤交流群：819641961

