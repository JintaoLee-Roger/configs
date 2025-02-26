## 在macos上使用 basictex 的一些配置

1. 安装 basictex

```bash
brew install basictex
```

2. 更新 tlmgr

```bash
tlmgr update --all
```

3. 如何安装 latex 的包

```bash
sudo tlmgr install xxx
sudo mktexlsr
```

4. 一些奇怪的包

```text
1). titletoc
sudo tlmgr install titlesec

2).  ctexbook 等, 需要安装 ctex 包
sudo tlmgr install ctex

3). perpage.sty 提示缺少
sudo tlmgr install bigfoot (or footmisc)

4). 字体提示缺少 KaiTi 字体, 将 fontset 设置为 mac, 这是因为windows和macos上的字体名称不一样
\documentclass[degree=doctor, fontset=mac]{ustcthesis}

5). 提示缺少 xits-math 字体, 安装 xits 包
sudo tlmgr install xits
```
