# 校验记录（VERIFY）

对象：上游 `pawstash/pawstash`（默认分支 `main`，克隆时 HEAD 见下）
本机克隆路径：`C:\Users\14929\WorkBuddy AI\2026-10-13-21-12-45\pawstash`

## 1. 上游基线

```
en.json  1121 键
ru.json  1121 键
en / ru 键集完全一致 = True
```

## 2. 语言包校验

```
i18n status: 1121 keys across en, ru, zh-CN
  • en    : ok (1121/1121)
  • ru    : ok (1121/1121)
  • zh-CN : ok (1121/1121)

i18n check passed.
```

`check-i18n.js` 同时检查：缺键、空值、占位符（`{count}` `{provider}` `{version}` …）跨语种错配、
代码里用到但语言文件里没有的键。以上四项全部为 0。

单独复核：

| 项 | 结果 |
|---|---|
| 键数 | 1121（= en） |
| 与 en 键集差集 | 0 |
| 占位符错配 | 0 |
| 西里尔字母残留 | 0 |
| 与英文原文完全相同的条目 | 11（均为专有名词/技术串：`Fancards`、`User Agent`、`v{rev}`、`Acrylic`、`Android/data/app.pawstash.client/files/Download` 等，属刻意保留） |

## 3. 前端构建 / 类型检查

```
npm run build  →  EXIT=0, ✓ built in 8.97s
npm run check  →  svelte-check found 0 errors and 0 warnings
```

产物抽查：

```
grep -c "简体中文" dist/assets/index-*.js        → 2
grep    "界面语言"                                → 命中
grep    "选择界面语言（简体中文 / English / Русский）。"  → 命中
grep    "在 Pawchive 上浏览和搜索创作者"           → 命中
```

国旗图标依赖：`@iconify-json/circle-flags` 内含 `cn` → `true`，`~icons/circle-flags/cn` 解析成功（构建无报错）。

## 4. 一键安装脚本独立性验证

把 `pawstash-zh-langpack/` 应用到一个**全新克隆**（`/tmp/paw_verify`）：

```
==> 1/3 写入 zh-CN.json
==> 2/3 应用代码补丁
==> 3/3 校验
i18n status: 1121 keys across en, ru, zh-CN
  • en    : ok (1121/1121)
  • ru    : ok (1121/1121)
  • zh-CN : ok (1121/1121)
i18n check passed.
```

改动落点确认（全新克隆）：

```
 M src/lib/components/settings/SettingsModal.svelte   → 61 行 import IconFlagCn；1204 行 { value: 'zh', label: '简体中文' }
 M src/lib/i18n/i18nState.svelte.ts                   → import zh / Locale 加 'zh' / LOCALES 加项 / translations 加 zh / init 加中文分支
 M src/lib/i18n/locales/en.json                       → language_desc 补上 简体中文
 M src/lib/i18n/locales/ru.json                       → language_desc 补上 简体中文
?? src/lib/i18n/locales/zh-CN.json                    → 新增，1121 键
```

## 5. 未执行项

- **桌面端可执行文件**：本机无 Rust 工具链（`cargo` / `rustc` 不存在），未构建 Tauri 桌面二进制。
- **Android APK**：本机无 Android SDK / NDK / Rust，未构建 APK。需要的话走 GitHub Actions 云端构建。
- 应用内实机截图：未执行（无可用构建产物）。

## 6. 复现命令

```bash
git clone https://github.com/pawstash/pawstash && cd pawstash
bash pawstash-zh-langpack/apply-zh.sh .
npm ci && npm run build      # 可选，验证编译
npm run dev                  # 启动后：设置 → 界面语言 → 简体中文
```
