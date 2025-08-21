#!/bin/bash

# 彩色输出函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[信息]${NC} $1"; }
success() { echo -e "${GREEN}[成功]${NC} $1"; }
warn() { echo -e "${YELLOW}[警告]${NC} $1"; }
error() { echo -e "${RED}[错误]${NC} $1"; }

# 获取脚本所在目录的绝对路径
SCRIPT_PATH=$(readlink -f "$0")
DOTFILES_DIR=$(dirname "$SCRIPT_PATH")
SOURCE_DIR="$DOTFILES_DIR/home"
TARGET_DIR="$HOME"

# 安全性检查
if [[ "$DOTFILES_DIR" == "/" ]] || [[ "$DOTFILES_DIR" == "$HOME" ]]; then
    error "不能在根目录或用户主目录下执行此脚本"
    error "当前目录: $DOTFILES_DIR"
    exit 1
fi

# 确保在正确的仓库目录中运行
if [[ ! "$DOTFILES_DIR" =~ /dotfiles$ ]]; then
    error "此脚本必须在 dotfiles 仓库目录中运行"
    error "当前目录: $DOTFILES_DIR"
    exit 1
fi

# 确保 home 目录在仓库目录下
if [[ ! "$SOURCE_DIR" == "$DOTFILES_DIR/home" ]]; then
    error "源目录必须是仓库中的 home 目录"
    error "当前源目录: $SOURCE_DIR"
    error "期望源目录: $DOTFILES_DIR/home"
    exit 1
fi

# 检查源目录存在性
if [ ! -d "$SOURCE_DIR" ]; then
    error "home 目录不存在，请先创建: $SOURCE_DIR"
    exit 1
fi

info "开始同步配置文件..."
info "源目录: $SOURCE_DIR"
info "目标目录: $TARGET_DIR"
echo "----------------------------------------"

# 声明统计数组
declare -A dir_stats=([total]=0 [created]=0 [skipped]=0 [error]=0)

# 第一步：处理目录
info "第一步：创建目录结构..."

# 首先收集所有需要处理的目录
mapfile -t all_dirs < <(find "$SOURCE_DIR" -mindepth 1 -type d)

# 更新总数
dir_stats[total]=${#all_dirs[@]}

for src_dir in "${all_dirs[@]}"; do
    # 计算相对路径
    rel_path="${src_dir#$SOURCE_DIR/}"
    target_dir="$TARGET_DIR/$rel_path"
    
    if [ -e "$target_dir" ]; then
        if [ -d "$target_dir" ]; then
            info "• $rel_path (已存在)"
            ((dir_stats[skipped]+=1))
        else
            error "• $rel_path (目标存在但不是目录)"
            ((dir_stats[error]+=1))
        fi
    else
        mkdir -p "$target_dir"
        success "• $rel_path (已创建)"
        ((dir_stats[created]+=1))
    fi
done < <(find "$SOURCE_DIR" -type d)

# 输出目录处理统计
echo "----------------------------------------"
info "目录处理完成 (总计: ${dir_stats[total]}):"
success "  ✓ 创建: ${dir_stats[created]}"
info "  • 跳过: ${dir_stats[skipped]}"
# 只在有错误时显示
[ ${dir_stats[error]} -gt 0 ] && error "  ✗ 错误: ${dir_stats[error]}"

# 声明文件统计数组
declare -A file_stats=([total]=0 [linked]=0 [backup]=0 [skipped]=0 [error]=0)

# 第二步：处理文件
echo "----------------------------------------"
info "第二步：创建文件链接..."

# 首先收集所有需要处理的文件
mapfile -t all_files < <(find "$SOURCE_DIR" -type f)
file_stats[total]=${#all_files[@]}

for src_file in "${all_files[@]}"; do
    # 计算相对路径
    rel_path="${src_file#$SOURCE_DIR/}"
    target_file="$TARGET_DIR/$rel_path"
    
    # 检查目标文件状态
    if [ -L "$target_file" ]; then
        current_target=$(readlink -f "$target_file")
        if [ "$current_target" = "$src_file" ]; then
            info "• $rel_path (已链接)"
            ((file_stats[skipped]+=1))
            continue
        else
            error "• $rel_path (链接错误 -> $current_target)"
            ((file_stats[error]+=1))
            continue
        fi
    fi
    
    target_parent=$(dirname "$target_file")
    
    if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup_file="$target_file.backup_$timestamp"
        mv "$target_file" "$backup_file"
        # 创建绝对路径链接
        ln -s "$src_file" "$target_file"
        warn "• $rel_path (已备份并链接)"
        ((file_stats[backup]+=1))
    elif [ ! -e "$target_file" ]; then
        mkdir -p "$target_parent"
        # 创建绝对路径链接
        ln -s "$src_file" "$target_file"
        success "• $rel_path (已链接)"
        ((file_stats[linked]+=1))
    fi
done < <(find "$SOURCE_DIR" -type f)

# 输出文件处理统计
echo "----------------------------------------"
info "文件处理完成 (总计: ${file_stats[total]}):"
success "  ✓ 新建链接: ${file_stats[linked]}"
info "  • 跳过: ${file_stats[skipped]}"
# 只在有备份操作时显示
[ ${file_stats[backup]} -gt 0 ] && warn "  ! 备份文件: ${file_stats[backup]}"
# 只在有错误时显示
[ ${file_stats[error]} -gt 0 ] && error "  ✗ 错误: ${file_stats[error]}"

echo "----------------------------------------"
if [ ${dir_stats[error]} -eq 0 ] && [ ${file_stats[error]} -eq 0 ]; then
    success "同步完成 ✨"
else
    error "同步完成，但存在错误，请检查输出信息"
fi