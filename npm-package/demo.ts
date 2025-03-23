import { SessionEntry } from "./bindings/github.com/HumXC/aikadm/models.js";
import { User } from "./bindings/os/user/models.js";
let config_: any = {};

function Wrap<T extends (...args: any[]) => any>(
    func: T
): (...args: Parameters<T>) => Promise<ReturnType<T>> & { cancel(): void } {
    return (...args: Parameters<T>) => {
        const promise = new Promise((resolve, reject) => {
            try {
                resolve(func(...args));
            } catch (e) {
                reject("Demo mode: " + e);
            }
        }) as Promise<ReturnType<T>> & { cancel(): void };
        promise.cancel = () => {};
        return promise;
    };
}
function Login_(username: string, password: string, session: string) {
    const true_password = "password";
    if (password !== true_password) {
        throw "Invalid password. In demo mode, only the password 'password' is allowed.";
    }
}

function GetSessions_(): SessionEntry[] {
    return [
        new SessionEntry({
            Name: "Hyprland",
            SessionType: "wayland",
            Exec: "Hyprland",
            Comment: "Hyprland session",
        }),
        new SessionEntry({
            Name: "Dwm",
            SessionType: "xorg",
            Exec: "Dwm",
            Comment: "Dwm session",
        }),
    ];
}
function GetUsers_(): User[] {
    return [
        new User({
            Name: "Aika",
            Username: "aika",
            Uid: "1000",
            Gid: "1000",
            HomeDir: "/home/aika",
        }),
        new User({
            Name: "Bob",
            Username: "bob",
            Uid: "1001",
            Gid: "1000",
            HomeDir: "/home/bob",
        }),
        new User({
            Name: "小明",
            Username: "xiaoming",
            Uid: "1002",
            Gid: "1000",
            HomeDir: "/home/xiaoming",
        }),
    ];
}
function GetUserAvatar_(username: string): string {
    throw "GetUserAvatar not implemented";
}
function Shutdown_() {
    throw "Shutdown not implemented";
}
function Reboot_() {
    throw "Reboot not implemented";
}
function ReadConfig_(): ReturnType<any> {
    return config_;
}
function SaveConfig_(config: any) {
    config_ = config;
}
function Exec_(command: string[]): number {
    throw "Exec not implemented";
}
function KillProcess_(pid: number) {
    throw "KillProcess not implemented";
}
function ExecOutput_(command: string[]): string {
    throw "ExecOutput not implemented";
}
function TestDemoMode_() {
    throw "Running in demo mode";
}
export const Login = Wrap(Login_);
export const GetSessions = Wrap(GetSessions_);
export const GetUsers = Wrap(GetUsers_);
export const GetUserAvatar = Wrap(GetUserAvatar_);
export const Shutdown = Wrap(Shutdown_);
export const Reboot = Wrap(Reboot_);
export const ReadConfig = Wrap(ReadConfig_);
export const SaveConfig = Wrap(SaveConfig_);
export const Exec = Wrap(Exec_);
export const KillProcess = Wrap(KillProcess_);
export const ExecOutput = Wrap(ExecOutput_);
export const TestDemoMode = Wrap(TestDemoMode_);
