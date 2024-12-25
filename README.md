# Aikadm

这是一个使用 Gtk4 构建，运行在 Linux 上的 display manager。

该项目主要由我个人使用，我会优先考虑自己的需求。但是如果有人对该项目感兴趣，我也会考虑加入更多的特性。
目前考虑过以下特性，但是我暂时用不上也没有空闲时间，所以没有加入：

-   多显示器支持
-   i18n
-   缩放支持

## 截图

![screenshot](https://raw.githubusercontent.com/HumXC/aikadm/refs/heads/main/screenshot/1.jpg)

![screenshot](https://raw.githubusercontent.com/HumXC/aikadm/refs/heads/main/screenshot/2.jpg)

## 构建

该项目使用 Meson，你可以在 src/meson.build 文件中找到构建配置。
一般来说，你只需要：

```bash
meson setup build
meson compile -C build
```

对于 Nix 用户，你应该看到了 flake.nix，我稍后介绍他。

### 依赖

对于所需的依赖，你可以在 [nix/package.nix](https://github.com/HumXC/aikadm/blob/main/nix/package.nix) 文件中找到。
其中 `astal-greet` 来自 [aylur/astal](https://github.com/aylur/astal)

## 使用

在输入密码的页面，点击 <用户名> 和 <session 名称> 可以切换不同的用户和 session。

请先运行 `aikadm -h` 来查看帮助信息。

-   `-w` 参数可以指定 wallpaper，wallpaper 是一个图片或包含了图片的文件夹。
    当 wallpaper 是文件夹时，aikadm 会随机选择文件夹中的图片显示在屏幕上。
    如果你将图片命名为 `<显示器编号>.<ext>` 例如 `0.png`、`1.png`、`2.png` 等，aikadm 会按照将图片显示到对应的显示器上。

-   `-d` 参数用于指定 session 的搜索路径，如果你传递这个参数，aikadm 找不到任何 session。
    对于 Arch Linux 用户，这个路径可能是 `/usr/share/xsessions` 和 `/usr/share/wayland-sessions`。

-   `-e` 参数用于设置启动的环境变量。

`-d` 和 `-e` 参数可以多次使用，例如：

```bash
    aikadm -d /usr/share/xsessions -d /usr/share/wayland-sessions -e EXAMPLE1=SOMEVALUE -e EXAMPLE2=ANOTHERVALUE
```

实际上，你需要配置 [Greetd](https://sr.ht/~kennylevinsen/greetd/)，还需要一个 Wayland 混成器用来显示 Aikadm。关于 Greetd，我推荐阅读 [Arch Wiki](https://wiki.archlinux.org/title/Greetd)

Wayland 混成器我选择 [Cage](https://github.com/cage-kiosk/cage)，你也可以使用 Hyprland 或者 Sway。

我不知道 Aikadm 能不能启动 Xorg 桌面环境，我对 Xorg 不感兴趣。不过按道理来说，它应该可以。

## NixOS

如果你使用 NixOS，你可以在你的 `flake.nix` 中添加这个仓库的到 inputs 中:

```nix
# flake.nix
inputs = {
    aikadm.url = "github:HumXC/aikadm";
    aikadm.inputs.nixpkgs.follows = "nixpkgs"; # 可选
}
```

然后在你的配置中添加 Greetd 的配置：

```nix
users.users.greeter = {
  isSystemUser = true;
  group = "greeter";
};
services.greetd =
  let
    argv = {
      inherit pkgs;
      sessionDirs = [ "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions" ];
      wallpaperDir = "/home/greeter/wallpaper"; # 换成你自己的壁纸文件夹
      cageEnv.LANG = "zh_CN.UTF-8"; # 换成你自己想要的环境变量
    };
    cmd = "${inputs.aikadm.lib.cage-script argv}";
  in
  {
    enable = true;
    settings.default_session = {
      command = cmd;
      user = "greeter";
    };
  };
```

## LICENSE

Aikadm 使用 GPL-3.0 许可证。

## 致谢

感谢以下项目为我提供的帮助和启发：

### Astal

[aylur/astal](https://github.com/aylur/astal) 是一个非常棒的库，这个库是 [aylur/ags](https://github.com/aylur/ags) 的依赖。我也在使用 ags 构建自己的桌面小组件。

该项目依赖 astal-greet 库，为我带来了许多方便。

### Kompass

[kotontrion/kompass](https://github.com/kotontrion/kompass) 是其开发者自己使用的状态栏。aikadm 受其启发，这是一个非常好的 Example。第一次接触 Vala 和 Meson 让我非常痛苦，kompass 让我节省了很多时间和精力。

### Fluent-icon-theme

[vinceliuice/Fluent-icon-theme](https://github.com/vinceliuice/Fluent-icon-theme/tree/master) 是一个非常棒的图标主题。这是我日常使用的图标主题。

aikadm 使用了其中的部分图标。你可以在 data/icons 目录下找到这些图标。

### ChatGPT

无需多言
