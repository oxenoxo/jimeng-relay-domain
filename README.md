# 即梦中转站 · 最新域名获取器

这是一个部署到 GitHub Pages 的静态页面。它读取同仓库的 `latest.json`，展示当前电脑同步上来的最新 tunnelmole 地址。

## 本地同步最新地址

```bash
bash sync-domain.sh https://你的最新隧道地址.tunnelmole.net
```

如果 `$HOME/jimeng-url.txt`、`/tmp/jimeng-tunnel.log` 或 `/tmp/tunnel_url.txt` 里已有地址，也可以直接运行：

```bash
bash sync-domain.sh
```

脚本会自动更新 `latest.json`、提交并推送到 GitHub，Pages 随后自动发布新内容。

> 这个页面不会保存或上传即梦 sessionid，只同步公网隧道地址。
