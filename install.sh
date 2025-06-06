#!/bin/bash

set -e

INSTALL_DIR="$HOME/.goenv-lite"
BIN="$INSTALL_DIR/goenv-lite"

echo "📦 正在安装 goenv-lite 到 $INSTALL_DIR"

# 创建目录
mkdir -p "$INSTALL_DIR"

# 下载主程序（你这里替换成你GitHub的raw地址）
curl -sSf https://raw.githubusercontent.com/smjbsb/goenv-lite/main/goenv-lite.sh -o "$BIN"

# 赋予可执行权限
chmod +x "$BIN"

# 检测用户的 shell 类型
SHELL_NAME=$(basename "$SHELL")
PROFILE_FILE="$HOME/.bashrc"
if [[ "$SHELL_NAME" == "zsh" ]]; then
  PROFILE_FILE="$HOME/.zshrc"
fi

# 添加 PATH 配置（如果没有配置过）
if ! grep -q 'goenv-lite' "$PROFILE_FILE"; then
  {
    echo ''
    echo '# goenv-lite 环境变量'
    echo 'export PATH="$HOME/.goenv-lite:$PATH"'
    echo "alias g=\"$BIN\""
    echo ''
  } >> "$PROFILE_FILE"
  echo "✅ 已自动写入 $PROFILE_FILE，包含 PATH 和 alias 配置"
else
  echo "ℹ️ 已检测到 $PROFILE_FILE 中包含 goenv-lite 配置，跳过添加"
fi

echo ""
echo "✅ 安装完成！请执行以下命令使配置生效："
echo "source $PROFILE_FILE"
echo ""
echo "然后你可以用命令 'g' 来调用 goenv-lite，比如："
echo "g install go1.22.0"
echo "g switch"
