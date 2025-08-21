# dotfiles

个人 Linux/Unix 配置文件管理仓库，通过符号链接（Symlink）实现多设备同步。主要包含以下配置：

## 配置内容

- **SSH 配置** - OpenSSH 客户端配置、密钥管理
- **Git 配置** - 全局 Git 设置、别名、忽略规则
- **Zsh 配置** - Zsh shell 设置、别名、函数、主题
- **输入法配置** - Fcitx 中文输入法设置
- **1Password 配置** - 1Password CLI 和 SSH 集成
- **字体配置** - 编程字体、中文字体设置

## 目录结构

```
dotfiles/
├── home/                      # 同步到用户主目录的文件
│   ├── .ssh/                 # SSH 配置目录
│   │   └── config           # SSH 客户端配置
│   ├── .config/             # 应用程序配置目录
│   │   ├── fcitx/          # 输入法配置
│   │   ├── fontconfig/     # 字体渲染配置
│   │   └── 1password/      # 1Password 配置
│   ├── .gitconfig          # Git 全局配置
│   └── .zshrc             # Zsh shell 配置（包含别名定义）
├── .gitignore             # 仓库忽略规则
├── link_dotfiles.sh       # 配置文件链接脚本
└── README.md             # 说明文档
```

## 使用方法

所有配置文件都集中在 `home` 目录下，保持与用户主目录（`$HOME`）相同的结构。例如：
- `home/.config/fontconfig/fonts.conf` 对应 `~/.config/fontconfig/fonts.conf`
- `home/.zshrc` 对应 `~/.zshrc`

运行 `link_dotfiles.sh` 脚本会自动创建必要的符号链接：
```bash
./link_dotfiles.sh
```

## 配置说明

### SSH 配置
- 支持多密钥管理
- 集成 1Password SSH Agent
- 包含常用主机模板

### Git 配置
- 常用别名
- 提交签名设置
- 全局忽略规则

### Zsh 配置
- 自定义提示符和主题
- 常用命令别名（集成在 .zshrc 中）
- 历史记录和自动补全优化

### 输入法配置
- Fcitx 快捷键设置
- 词库和皮肤配置
- 输入习惯优化

### 1Password 配置
- CLI 工具配置
- SSH 密钥集成
- 生物认证设置

### 字体配置
- 字体渲染优化（通过 fontconfig）
- 中英文字体匹配规则
- 字体回退顺序设置

## 许可证
本项目采用 [木兰宽松许可证，第2版](https://license.coscl.org.cn/MulanPSL2) 开源。
可自由使用、修改和分发，如需商用请遵守许可证条款。
