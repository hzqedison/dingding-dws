# Third-Party Notices / 第三方内容声明

This repository bundles reference materials originally extracted from the
**Wukong (悟空) desktop app**, developed by **DingTalk (a product of Alibaba Group)**.
The materials are included solely for installation convenience so that users
do not have to manually locate them inside their Wukong installation directory.

本仓库为了安装便利，捆绑了源自**钉钉 / Wukong（悟空）桌面端**的参考材料。
这些材料的著作权归**阿里巴巴集团（钉钉）**所有，仅作引用，**不**受本仓库 MIT 许可证约束。

---

## 1. Bundled Third-Party Content / 涉及的第三方内容

| Path / 路径 | Origin / 来源 | Copyright Holder / 著作权人 |
|---|---|---|
| `skills/dws-refs/` | Wukong desktop app | © Alibaba Group (DingTalk) |
| `skills/dws-scripts/` | Wukong desktop app | © Alibaba Group (DingTalk) |

These directories contain:
- **`dws-refs/`** — Reference documentation describing DingTalk product capabilities
  (used by AI agents to construct precise task descriptions).
- **`dws-scripts/`** — Helper Python scripts shipped alongside the dws CLI for
  common multi-step operations.

All other files in this repository are original work authored by the maintainer
of this project (hzqedison) and are licensed under the MIT License — see
[`LICENSE`](LICENSE).

---

## 2. Disclaimer / 免责声明

- This project is **unofficial and independent**.
  本项目为**非官方独立**开源项目。
- It is **not affiliated with, endorsed by, or sponsored by** Alibaba Group,
  DingTalk, the Wukong product team, or any related entity.
  与阿里巴巴集团、钉钉、Wukong（悟空）产品团队**无任何隶属、背书、赞助关系**。
- All product names, brands, logos, and trademarks referenced in this repository
  remain the property of their respective owners.
  所有提及的产品名、品牌、Logo、商标均为各自权利人所有。
- The bundled third-party content is included on a "fair-use reference" basis
  and remains the property of its original authors.
  捆绑的第三方内容基于「合理引用」基础引入，著作权归原作者所有。

---

## 3. Rights Holder Removal Request / 权利人下架请求

If you are the rights holder (Alibaba / DingTalk / Wukong team) and wish to
have the bundled content removed from this repository, the maintainer will
comply promptly upon request. Please:

如您为上述内容的权利人（阿里巴巴 / 钉钉 / Wukong 团队），希望将相关内容
从本仓库下架，请通过以下任一方式联系，维护者将**及时响应处理**：

1. **Open an issue** at https://github.com/hzqedison/dingding-dws/issues
   在仓库提 Issue
2. **Email** the maintainer via the contact information in the GitHub profile
   通过 GitHub 个人主页上的联系方式邮件告知

Upon receiving such a request, the maintainer will:
收到请求后，维护者将：

- Remove the affected files from the repository within 7 days.
  7 日内从仓库中移除相关文件。
- Restructure the installer to fetch these materials from the user's local
  Wukong installation at install time instead.
  重构安装脚本，改为在安装时从用户本地 Wukong 安装目录拷贝相关材料。

---

## 4. Why bundle at all? / 为什么要捆绑这些文件？

The bundling exists purely for installation convenience: it allows the one-line
PowerShell installer to set up the AI skill without first locating the Wukong
install directory on each user's machine. The maintainer acknowledges this
introduces a redistribution question, and is committed to switching to an
"install-time copy from local Wukong directory" model upon request from the
rights holder, or at the maintainer's discretion at any future point.

捆绑的唯一目的是**安装便利**：让一行命令的 PowerShell 安装器无需先定位用户机器上
Wukong 的安装目录就能完成 AI skill 部署。维护者承认这引入了再分发的版权讨论空间，
并承诺一旦权利人提出，或维护者后续判断需要切换，就改为「安装时从本地 Wukong 目录
拷贝」的模式。
