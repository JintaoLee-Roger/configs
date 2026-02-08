
# clash verge的TUN模式和企业VPN（aTrust）冲突

## 问题描述

- 开启TUN模式后, 在终端可以成功连接google等网站。
- 但是启动aTrust后, 终端连接google等网站失败。

## 原因

- TUN 模式和企业 VPN 都会接管系统路由
- macOS 只允许一个“赢家”
- aTrust 启动后，Clash TUN 会被系统覆盖 → 看起来开着，实际上不生效

## 解决

### 1️⃣ Clash Verge 中关闭 TUN

### 2️⃣ 浏览器继续正常使用（无需任何修改）

### 3️⃣ 终端使用“终端级代理”
在 需要访问外网 / API 的终端 中：
```bash
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897
```

**不要使用 `ping` 来验证**


# 🧭 mihomo（Clash Meta v1）远程服务器使用教程（精简终版）

> **适用场景**
>
> * 无桌面 Linux 服务器
> * 访问 GitHub / HuggingFace / OpenAI / Claude
> * 不影响 SSH / 不影响其他用户
> * 用户级使用（不需要 root）

---

## 一、下载安装 mihomo（v1）

```bash
wget https://github.com/MetaCubeX/mihomo/releases/download/v1.19.20/mihomo-linux-amd64-v1-v1.19.20.gz
gunzip mihomo-linux-amd64-v1-v1.19.20.gz
chmod +x mihomo-linux-amd64-v1-v1.19.20
mv mihomo-linux-amd64-v1-v1.19.20 ~/mihomo
```

---

## 二、准备配置文件（从 Clash Verge 来）

### 1️⃣ 本地机器（macOS 举例）

```text
~/Library/Application Support/clash-verge/profiles/current.yaml
```

把这个文件拷到服务器：

```bash
scp current.yaml user@server:/home/user/.config/clash/config.yaml
```

---

## 三、【关键】把 config.yaml 改成“远程服务器模式”

在服务器上编辑：

```bash
nano ~/.config/clash/config.yaml
```

### ✅ 必须确认 / 修改的几项（重点）

#### 1️⃣ 只监听本机（安全）

```yaml
bind-address: 127.0.0.1
```

❌ 不要用 `*` 或 `0.0.0.0`

---

#### 2️⃣ 关闭 TUN（必须）

```yaml
tun:
  enable: false
```

---

#### 3️⃣ controller 用于远程面板（保留）

```yaml
external-controller: 127.0.0.1:9090
```

---

#### 4️⃣ **删除或注释 secret（否则 yacd 会 Unauthorized）**

```yaml
# secret: set-your-secret
```

> 如果不删，后面 yacd 必须填 secret
> 对你现在这个“127.0.0.1 + SSH 隧道”模式来说，**删掉最简单**

---

> ⚠️ 其他内容 **一律不动**
>
> * rules 几千行 ✅ 正常
> * 中文乱码样式 ✅ 没问题
> * proxy-groups / proxies ✅ 不要改

---

## 四、启动 mihomo（用户级）

```bash
~/mihomo -d ~/.config/clash
```

看到类似：

```text
Mixed(http+socks) proxy listening at: 127.0.0.1:7897
Initial configuration complete
```

说明成功。

---

## 五、让 mihomo 常驻（推荐 tmux）

```bash
tmux new -s clash
~/mihomo -d ~/.config/clash
```

* 断开 SSH → 不会停
* 回来继续用：

```bash
tmux attach -t clash
```

---

## 六、使用代理（只影响当前终端）

### 开启

```bash
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897
```

### 关闭

```bash
unset http_proxy https_proxy
```

> 只影响当前终端
> 不影响 SSH / 其他终端 / 其他用户

---

## 七、验证是否可用（正确方式）

```bash
curl https://www.google.com
curl https://ipinfo.io
```

❌ 不要用 `ping`

---

## 八、远程 Web 面板（yacd，用来选节点）

### 1️⃣ 在本地电脑开 SSH 隧道

```bash
ssh -N -L 9090:127.0.0.1:9090 user@server
```

> 这个窗口保持打开

---

### 2️⃣ 打开浏览器

访问：

```
https://yacd.metacubex.one
```

填写：

* **API Base URL**：`http://127.0.0.1:9090`
* **Secret**：留空（你已删除）

点 **Add**

---

### 3️⃣ 选择节点（比如台湾）

```
Proxy Groups
 └─ 🚀 节点选择
      └─ 【台湾 01 / 02 / 03】
```

👉 **立即生效，不用重启 mihomo**

---

## 九、proxy推荐命令

在.bashrc/.zshrc中使用
```bash
alias proxy_on='export http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897'
alias proxy_off='unset http_proxy https_proxy'
```

在终端中
```bash
proxy_on   # 用外网
proxy_off  # 回直连
```
