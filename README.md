# HTML Greet

> [!WARNING]
> 该项目还在开发中！功能尚不稳定！请小心每一次更新！

html-greet 是一个运行在 Linux 系统上的 Display Manager（登录管理器）。基于 [Wails](https://github.com/wailsapp/wails) 构建，借助 [Greetd](https://sr.ht/~kennylevinsen/greetd/) 实现用户登陆。

受 [Web-Greeter](https://github.com/JezerM/web-greeter) 启发，html-greet 旨在提供一个简单地方式实现登陆管理器，用户可以使用 web 技术轻松定制自己的登录界面。

该项目主要借助 Wails 制作了一些后端 API 用于实现在 web 上不便于实现的功能，例如 Greetd 的调用，获取用户头像和配置文件的存储等。得利于 Wails 的绑定功能，前端的 js 可以直接调用这些 API。

## 快速开始

### Nix 用户

1. 在你的系统配置中，添加该仓库的 flake

    ```nix
    {
      inputs.html-greet.url = "github:HumXC/html-greet";
      # ...
    }
    ```

2. 请查看 [nix/pkgs.nix](https://github.com/HumXC/html-greet/blob/main/nix/pkgs.nix) 文件，其中有一些可用的包。此 flake 还提供了 overlay。

    ```nix
    {
     lib,
     pkgs,
     config,
     ...
    }: let
     # argv 是提供给 html-greet 的命令行参数，详情查看 nix/lib/parse-argv.nix
     argv = {
       sessionDir = ["${config.services.displayManager.sessionData.desktops}/share"];
       assets = "${pkgs.html-greet.frontend}/share/html-greet-frontend";
     };
     cmd = "${pkgs.html-greet.cage-script argv}";
    in {
     config =  {
         nixpkgs.overlays = [ inputs.html-greet.overlays.default ];
         services.greetd.enable = true;
         services.greetd.settings.default_session = {
           command = cmd;
           user = "greeter";
         };
     };
    }
    ```

在 pkgs.nix 中，html-greet.frontend 是一个前端，仓库在 [frontend](https://github.com/HumXC/html-greet-frontend)。
如果不指定 assets，则默认使用该仓库的 index.html。

### 其他发行版用户

#### 构建

1. 安装 Go 语言环境
2. 克隆此仓库到本地
   `git clone https://github.com/HumXC/html-greet.git`
3. 进入仓库目录
   `cd html-greet`
4. 构建项目
   `./build.sh`
   构建完成后，目录下生成可执行文件 `html-greet`。

#### 使用

0. 你应该首先了解 [Greetd](https://sr.ht/~kennylevinsen/greetd/) 的使用方法。请查看 Greetd 的文档。
1. 关于 html-greet 的使用，请查看 `html-greet -h`

你可以在登陆状态下直接运行 `html-greet` 预览其效果，但是如果你不使用 `-a` 参数，你只会看到一个丑陋的登陆界面。我还准备了一个前端，在 [html-greet-frontend](https://github.com/HumXC/html-greet-frontend)，你可以先构建这个前端或者由编写你自己的前端，再使用 `html-greet -a <path-to-frontend>` 启动。

## 前端

html-greet 自带了一个前端，就在 [index.html](https://github.com/HumXC/html-greet/blob/main/index.html) 中。关于如何编写前端，与 html-greet 相关的部分你可以运行 `html-greet wailsjs` 命令，这会在当前目录下输出 wailsjs 文件夹，这是由 Wails 生成的。你可以在前端项目中导入 wailsjs 中的代码，其中有用于实现登陆管理器功能的关键函数。

你可以查看 [html-greet-frontend](https://github.com/HumXC/html-greet-frontend/blob/main/src/components/LoginScreen.vue#L162) 了解如何使用 wailsjs 中的代码。

## 参考

-   [Wails](https://github.com/wailsapp/wails)
-   [Greetd](https://sr.ht/~kennylevinsen/greetd/)
-   [Web-Greeter](https://github.com/JezerM/web-greeter)
-   [html-greet-frontend](https://github.com/HumXC/html-greet-frontend)
