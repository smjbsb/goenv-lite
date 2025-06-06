#!/bin/bash

set -e

INSTALL_DIR="$HOME/.goenv-lite"
BIN="$INSTALL_DIR/goenv-lite"
VERSIONS_DIR="$INSTALL_DIR/versions"
CURRENT_DIR="$INSTALL_DIR/current"

echo "📦 正在安装 goenv-lite 到 $INSTALL_DIR"

# 创建目录结构
mkdir -p "$INSTALL_DIR"
mkdir -p "$VERSIONS_DIR"
mkdir -p "$CURRENT_DIR"

# 下载主程序（替换成你的实际地址）
curl -sSf https://raw.githubusercontent.com/smjbsb/goenv-lite/main/goenv-lite.sh -o "$BIN"

# 赋予可执行权限
chmod +x "$BIN"

# 检测用户的 shell 类型
SHELL_NAME=$(basename "$SHELL")
PROFILE_FILE="$HOME/.bashrc"
if [[ "$SHELL_NAME" == "zsh" ]]; then
  PROFILE_FILE="$HOME/.zshrc"
fi

# 检测已有的GOROOT配置
OLD_GOROOT=$(grep -E '^export GOROOT=' "$PROFILE_FILE" | head -n1 | cut -d= -f2- | tr -d '"')
# 检测PATH中是否有go路径
OLD_GO_PATH=$(echo "$PATH" | tr ':' '\n' | grep -E 'go' | head -n1)

# 添加 PATH 和 alias 配置（避免重复添加）
if ! grep -q 'goenv-lite' "$PROFILE_FILE"; then
  {
    echo ''
    echo '# goenv-lite 环境变量（兼容原有 Go 环境）'
    if [ -n "$OLD_GOROOT" ]; then
      echo "# 备份原 GOROOT: $OLD_GOROOT"
    fi
    if [ -n "$OLD_GO_PATH" ]; then
      echo "# 备份原 PATH 中 Go 路径: $OLD_GO_PATH"
    fi
    echo "export GOROOT=\"$CURRENT_DIR\""
    echo 'export PATH="$GOROOT/bin:$PATH"'
    echo "alias g='$BIN'"
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
echo "之后你可以用 'g' 命令进行管理，比如："
echo "g install go1.22.0"
echo "g switch"
