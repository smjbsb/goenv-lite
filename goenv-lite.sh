#!/bin/bash

BASE_DIR="$HOME/.goenv-lite"
VERSIONS_DIR="$BASE_DIR/versions"
CURRENT_DIR="$BASE_DIR/current"

mkdir -p "$VERSIONS_DIR"

function print_env_hint() {
  echo ""
  echo "📌 请将以下内容加入你的 shell 配置文件（~/.zshrc 或 ~/.bashrc）："
  echo "export GOROOT=\"$CURRENT_DIR\""
  echo "export PATH=\"\$GOROOT/bin:\$PATH\""
  echo ""
  echo "⚠️ 更改后请执行 source ~/.zshrc 或重启终端"
}

function list_versions() {
  echo "✅ 已安装版本："
  ls "$VERSIONS_DIR"
}

function show_current() {
  if command -v go >/dev/null 2>&1; then
    go version
  else
    echo "⚠️ 当前未激活任何 Go 版本"
  fi
}

function switch_version() {
  cd "$VERSIONS_DIR" || exit 1
  versions=(*)
  PS3="请选择你要切换的 Go 版本: "
  select version in "${versions[@]}" "退出"; do
    if [ "$REPLY" -gt 0 ] && [ "$REPLY" -le "${#versions[@]}" ]; then
      selected="${versions[$REPLY-1]}"
      break
    elif [ "$REPLY" -eq $((${#versions[@]}+1)) ]; then
      echo "已取消切换。"
      exit 0
    else
      echo "无效选择，请重试。"
    fi
  done

  sudo rm -rf "$CURRENT_DIR"
  sudo cp -R "$VERSIONS_DIR/$selected" "$CURRENT_DIR"
  echo "✅ 已切换到 Go 版本: $selected"
  print_env_hint
}

function install_version() {
  ver="$1"
  if [ -z "$ver" ]; then
    echo "❌ 缺少版本号，例如：g install go1.22.0"
    exit 1
  fi

  if [ -d "$VERSIONS_DIR/$ver" ]; then
    echo "✅ 已安装版本 $ver"
    return
  fi

  echo "⬇️ 正在下载 $ver..."

  os="darwin"
  arch="arm64"
  url="https://go.dev/dl/${ver}.${os}-${arch}.tar.gz"

  tmpfile="/tmp/${ver}.tar.gz"
  curl -L "$url" -o "$tmpfile"

  if [ $? -ne 0 ]; then
    echo "❌ 下载失败，请检查版本号"
    exit 1
  fi

  tar -C "$VERSIONS_DIR" -xzf "$tmpfile"
  mv "$VERSIONS_DIR/go" "$VERSIONS_DIR/$ver"
  rm "$tmpfile"

  echo "✅ 安装完成: $ver"
}

function remove_version() {
  ver="$1"
  if [ -z "$ver" ]; then
    echo "❌ 缺少版本号，例如：g remove go1.20.3"
    exit 1
  fi

  rm -rf "$VERSIONS_DIR/$ver"
  echo "🗑️ 已删除版本: $ver"
}

# 命令分发
case "$1" in
  switch|"")
    switch_version
    ;;
  list)
    list_versions
    ;;
  v)
    show_current
    ;;
  install)
    install_version "$2"
    ;;
  remove)
    remove_version "$2"
    ;;
  *)
    echo "用法："
    echo "  g switch              # 切换版本"
    echo "  g install go1.22.0    # 安装版本"
    echo "  g list                # 列出所有已安装版本"
    echo "  g current             # 显示当前使用的版本"
    echo "  g remove go1.20.3     # 删除版本"
    ;;
esac
