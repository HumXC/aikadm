import * as Aikadm_ from "./bindings/github.com/HumXC/aikadm/aikadm.js";
import * as DemoAikadm from "./demo";
// The demo mode is triggered when the GREETD_SOCK environment variable is not set or the wails backend cannot be connected to.
export let IsDemoMode = false;
try {
    await Aikadm_.TestDemoMode();
} catch (error) {
    console.log(
        "Cannot connect to wails backend or GREETD_SOCK environment variable is not set. Running in demo mode."
    );
    IsDemoMode = true;
}
export * from "./bindings/github.com/HumXC/aikadm/models.js";
let Aikadm = IsDemoMode ? (DemoAikadm as typeof Aikadm_) : Aikadm_;
export { Aikadm };
