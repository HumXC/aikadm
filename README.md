# HTML Greet

> [!WARNING]
> 该项目还在开发中！功能尚不稳定！请小心每一次更新！

aikadm 是一个运行在 Linux 系统上的 Display Manager（登录管理器）。基于 [Wails](https://github.com/wailsapp/wails) 构建，借助 [Greetd](https://sr.ht/~kennylevinsen/greetd/) 实现用户登陆。

受 [Web-Greeter](https://github.com/JezerM/web-greeter) 启发，aikadm 旨在提供一个简单地方式实现登陆管理器，用户可以使用 web 技术轻松定制自己的登录界面。

该项目主要借助 Wails 制作了一些后端 API 用于实现在 web 上不便于实现的功能，例如 Greetd 的调用，获取用户头像和配置文件的存储等。得益于 Wails 的绑定功能，前端的 js 可以直接调用这些 API。

## 快速开始

### Nix 用户

1. 在你的系统配置中，添加该仓库的 flake

    ```nix
    {
      inputs.aikadm.url = "github:HumXC/aikadm";
      # ...
    }
    ```

2. 请查看 [nix/pkgs.nix](https://github.com/HumXC/aikadm/blob/main/nix/pkgs.nix) 文件，其中有一些可用的包。此 flake 还提供了 overlay。

    ```nix
    {
     lib,
     pkgs,
     config,
     ...
    }: let
      # argv 是提供给 aikadm 的命令行参数，详情查看 nix/lib/default.nix
      argv = {
        aikadm = pkgs.aikadm;
        sessionDir = [config.services.displayManager.sessionData.desktops.out];
      };
      cmd = "${inputs.aikadm.lib.cmdWithArgs args}";
    in {
     config =  {
         nixpkgs.overlays = [ inputs.aikadm.overlays.default ];
         services.greetd.enable = true;
         services.greetd.settings.default_session = {
           command = cmd;
           user = "greeter";
         };
     };
    }
    ```

### 其他发行版用户

你可以直接从 [Release](https://github.com/HumXC/aikadm/releases/tag/latest) 页面下载最新的自动构建

#### 构建

1. 安装 Go 语言环境
2. 安装 wails3

    ```bash
    go install github.com/wailsapp/wails/v3/cmd/wails3@latest
    ```

3. 克隆此仓库到本地
   `git clone https://github.com/HumXC/aikadm.git`
4. 进入仓库目录
   `cd aikadm`
5. 下载前端文件并解压到 frontend 文件夹中，此处使用 [aikadm-frontend](https://github.com/HumXC/aikadm-frontend) 前端。然后执行 `go build`

    ```bash
    wget https://github.com/HumXC/aikadm-frontend/releases/download/latest/   aikadm-frontend.tar.gz
    mkdir frontend
    tar -xf ./aikadm-frontend.tar.gz -C frontend
    go build
    ```

构建完成后，目录下生成可执行文件 `aikadm`。

#### 使用

0. 依赖:

    - greetd
    - cage
    - webkit2gtk

1. 关于 aikadm 的使用，请运行 `aikadm -h`

2. Assets
   你可以在桌面环境下直接运行 `aikadm` 预览其效果，但是如果你不使用 `-a` 参数，你只会看到一个丑陋的登陆界面。我还准备了一个前端，在 [aikadm-frontend](https://github.com/HumXC/aikadm-frontend)，你可以先构建这个前端或者编写你自己的前端，再使用 `aikadm -a <path-to-frontend>` 启动。-a 参数也可以是一个 url，例如 `aikadm -a https://humxc.github.io/aikadm-frontend/` 这在调试前端时非常有用，你也可以用于在线预览可用的前端。

    > [!WARNING]
    > 请勿调用不可信的前端！

3. SessionDir
   aikadm 会默认搜索 `/usr/share/xsessions` 和 `/usr/share/wayland-sessions` 中的 `.desktop` 文件，并通过 xsessions 和 wayland-sessions 目录来判断一个 session 是 Xorg 还是 Wayland。如果你 aikadm 找不到任何一个 session，你可能需要检查这两个文件夹。你也可以通过 -d 参数指定 session 搜索的目录。

4. Install Assets
   你可以使用 `install` 子命令来安装一个前端。例如 `aikadm install https://github.com/HumXC/aikadm-frontend/releases/download/latest/aikadm-frontend.tar.gz` 会将下载的压缩文档解压到 Assets 目录下。

跟其他大部分 greetd 的 dm 一样，aikadm 需要一个混成器来显示画面。例如 cage, sway, hyprland 等。aikadm 使用了 [Cage(https://github.com/cage-kiosk/cage)，因为 cage 足够简单，非常适合这种场景。aikadm 会自动调用 cage，请确保系统中装了 cage

##### 配置 Greetd

通过查阅 Greetd 的文档，你应该已经知道如何配置 Greetd，以下是 Greetd 配置的示例

```toml
[default_session]
command = "aikadm" # 或者 aikadm -a /path/to/aikadm-frontend
user = "greeter"

[terminal]
vt = 1
```

关于 [Greetd](https://sr.ht/~kennylevinsen/greetd/) 的更多内容。请查看 Greetd 的官方文档或查看 [Greetd Archwiki](https://wiki.archlinux.org/title/Greetd)。

## 前端

TODO:

你可以查看 [aikadm-frontend](https://github.com/HumXC/aikadm-frontend/blob/main/src/views/LoginScreen.vue#L162) 了解如何编写前端。

[预览 aikadm-frontend](https://humxc.github.io/aikadm-frontend/)

## 参考

-   [Wails](https://github.com/wailsapp/wails)
-   [Greetd](https://sr.ht/~kennylevinsen/greetd/)
-   [Web-Greeter](https://github.com/JezerM/web-greeter)
-   [Tuigreet](https://github.com/apognu/tuigreet/)
-   [aikadm-frontend](https://github.com/HumXC/aikadm-frontend)
