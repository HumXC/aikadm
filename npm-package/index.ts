import "@wailsio/runtime";

import * as Aikadm_ from "./bindings/github.com/HumXC/aikadm/aikadm";
import * as DemoAikadm from "./demo";
// The demo mode is triggered when the GREETD_SOCK environment variable is not set or the wails backend cannot be connected to.
let isReady = false;
export let IsDemoMode = false;
let readyFunc: () => void;
Aikadm_.TestDemoMode()
    .catch(() => {
        IsDemoMode = true;
        console.log(
            "Cannot connect to wails backend or GREETD_SOCK environment variable is not set. Running in demo mode."
        );
    })
    .finally(() => {
        isReady = true;
        if (readyFunc) {
            readyFunc();
        }
    });
export function WaitReady(): Promise<void> {
    return new Promise((resolve) => {
        if (isReady) {
            resolve();
        } else {
            readyFunc = resolve;
        }
    });
}
export * from "./bindings/github.com/HumXC/aikadm/models.js";
export async function Login(username: string, password: string, session_index: number) {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.Login(username, password, session_index);
    }
    return DemoAikadm.Login(username, password, session_index);
}

export async function GetSessions() {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.GetSessions();
    }
    return DemoAikadm.GetSessions();
}

export async function GetUsers() {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.GetUsers();
    }
    return DemoAikadm.GetUsers();
}

export async function GetUserAvatar(username: string) {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.GetUserAvatar(username);
    }
    return DemoAikadm.GetUserAvatar(username);
}

export async function Shutdown() {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.Shutdown();
    }
    return DemoAikadm.Shutdown();
}

export async function Reboot() {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.Reboot();
    }
    return DemoAikadm.Reboot();
}

export async function ReadConfig() {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.ReadConfig();
    }
    return DemoAikadm.ReadConfig();
}

export async function SaveConfig(config: any) {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.SaveConfig(config);
    }
    return DemoAikadm.SaveConfig(config);
}

export async function Exec(...command: string[]) {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.Exec(command);
    }
    return DemoAikadm.Exec(command);
}

export async function KillProcess(pid: number) {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.KillProcess(pid);
    }
    return DemoAikadm.KillProcess(pid);
}

export async function ExecOutput(...command: string[]) {
    if (!isReady) {
        await WaitReady();
    }
    if (!IsDemoMode) {
        return Aikadm_.ExecOutput(command);
    }
    return DemoAikadm.ExecOutput(command);
}

export async function TestDemoMode() {
    if (!isReady) {
        await WaitReady();
    }
    return Aikadm_.TestDemoMode();
}
