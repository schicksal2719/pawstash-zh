#!/usr/bin/env bash
# Pawstash 简体中文语言包 —— 一键安装（在仓库根目录执行）
# 用法:  bash apply-zh.sh [仓库路径]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${1:-.}"
cd "$REPO"

[ -f package.json ] || { echo "错误: $REPO 不是 pawstash 仓库根目录"; exit 1; }
[ -f src/lib/i18n/i18nState.svelte.ts ] || { echo "错误: 找不到 src/lib/i18n/i18nState.svelte.ts"; exit 1; }

echo "==> 1/3 写入 zh-CN.json"
cp "$HERE/zh-CN.json" src/lib/i18n/locales/zh-CN.json

echo "==> 2/3 应用代码补丁"
if git rev-parse --git-dir >/dev/null 2>&1; then
  git apply --3way "$HERE/pawstash-zh.patch" 2>/dev/null \
    || git apply --whitespace=nowarn "$HERE/pawstash-zh.patch" \
    || { echo "补丁应用失败，改用整文件覆盖"; cp "$HERE/i18nState.svelte.ts" src/lib/i18n/i18nState.svelte.ts; }
else
  cp "$HERE/i18nState.svelte.ts" src/lib/i18n/i18nState.svelte.ts
fi

# 兜底：确保 SettingsModal 里有「简体中文」选项
if ! grep -q "简体中文" src/lib/components/settings/SettingsModal.svelte; then
  echo "    SettingsModal 未打上，尝试 sed 兜底"
  sed -i "s#^\( *\)import IconFlagRu from '~icons/circle-flags/ru';#\1import IconFlagRu from '~icons/circle-flags/ru';\n\1import IconFlagCn from '~icons/circle-flags/cn';#" src/lib/components/settings/SettingsModal.svelte
  sed -i "s#\({ value: 'ru', label: 'Русский', icon: IconFlagRu }\)#\1,\n              { value: 'zh', label: '简体中文', icon: IconFlagCn }#" src/lib/components/settings/SettingsModal.svelte
fi

echo "==> 3/3 校验"
node scripts/check-i18n.js

echo
echo "完成。运行 npm run dev 启动，然后：设置 → 界面语言 → 简体中文"
