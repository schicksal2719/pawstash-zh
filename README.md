# Pawstash 简体中文语言包（zh-CN）

给上游 [pawstash/pawstash](https://github.com/pawstash/pawstash)（GPL-3.0）加上第三个界面语言：**简体中文**。
原版只有 `ru` / `en` 两种。

## 一句话安装

```bash
# 先拿到上游源码
git clone https://github.com/pawstash/pawstash && cd pawstash

# 再应用语言包（二选一）
bash <本目录>/apply-zh.sh .
# 或 Windows:
pwsh -File <本目录>\install-zh.ps1 -Repo .
```

装完 `npm run dev`，进 **设置 → 界面语言 → 简体中文**。

## 目录内容

| 文件 | 说明 |
|---|---|
| `zh-CN.json` | 完整中文语言文件，**1121 键**，与上游 `en.json` 键集 100% 一致 |
| `i18nState.svelte.ts` | 已注册 `zh` 语种的 i18n 状态文件（整文件，可直接覆盖） |
| `pawstash-zh.patch` | 上游源码的 unified diff（3 个文件） |
| `apply-zh.sh` / `install-zh.ps1` | 一键安装脚本（bash / PowerShell） |
| `VERIFY.md` | 校验结果与逐项改动清单 |

## 改了哪三处

**1. 新增 `src/lib/i18n/locales/zh-CN.json`** — 1121 个键全量中文。

**2. `src/lib/i18n/i18nState.svelte.ts`**
```diff
+import zh from './locales/zh-CN.json';
-export type Locale = 'ru' | 'en';
+export type Locale = 'ru' | 'en' | 'zh';
 export const LOCALES: LocaleConfig[] = [
   { code: 'ru', name: 'Russian', nativeName: 'Русский' },
   { code: 'en', name: 'English', nativeName: 'English' },
+  { code: 'zh', name: 'Chinese (Simplified)', nativeName: '简体中文' },
 ];
 const translations: Record<Locale, typeof ru> = {
   ru,
   en,
+  zh,
 };
```
`init()` 里补上按浏览器语言自动选中：
```diff
   if (browserLang === 'en') {
     this.currentLocale = 'en';
+  } else if (browserLang === 'zh') {
+    this.currentLocale = 'zh';
   } else {
     this.currentLocale = 'ru';
   }
```

**3. `src/lib/components/settings/SettingsModal.svelte`**
```diff
+import IconFlagCn from '~icons/circle-flags/cn';
```
```diff
 options={[
   { value: 'en', label: 'English', icon: IconFlagUs },
   { value: 'ru', label: 'Русский', icon: IconFlagRu },
+  { value: 'zh', label: '简体中文', icon: IconFlagCn }
 ]}
```

另外顺手把 `en.json` / `ru.json` 里那句「(English / Russian)」的描述改成三语，避免文案与实际选项不符。

## 云端构建 APK（不需要本地 Rust / Android SDK）

仓库里带了 `.github/workflows/build-apk.yml`：拉上游源码 → 注入中文包 → 构建 Android APK → 上传 artifact。

- 自动触发：push 到 `main`
- 手动触发：仓库页 → **Actions** → **Build zh-CN APK** → **Run workflow**（`upstream_ref` 默认 `main`，也可填 tag）
- 产物：该次 run 页面底部 **Artifacts** → `pawstash-zh-apk`
  - `Pawstash-arm64-zh.apk`（绝大多数手机，推荐）
  - `Pawstash-v7a-zh.apk`（老旧 32 位）
  - `Pawstash-x86_64-zh.apk`（模拟器）
  - `Pawstash-universal-zh.apk`（不确定机型时用）
- APK 用 Android debug 密钥签名。手机上若已装官方版，需先卸载（签名不同无法覆盖）。

首次构建约 30–60 分钟（要编译 3 个 Rust target）。

## 注意

- 语言选择存在 `localStorage` 的 `pawstash_locale` 键，重启保持。
- 系统语言是中文时首次启动会自动选中中文。
- 上游更新后重跑一次安装脚本即可；`zh-CN.json` 里若缺新键，`i18n:check` 会直接报出来，缺的键运行时会回退到俄语原文，不会显示成 key 名。

## 授权

源码版权归上游 `pawstash/pawstash`（GPL-3.0）。本语言包只做本地化，分发时同样遵循 GPL-3.0。
