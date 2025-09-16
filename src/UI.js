export const _cheatLog = (a) => () => console.log(a);
export const _setInterval = (delay) => (f) => () => setInterval(f, delay);
export const _toJSON = (x) => JSON.stringify(x);

export const _reload = () => {
    window.location.reload();
};

export const _redirect = (url) => () => {
    window.location.href = url;
};

export const _menuRedeemData = (cons) => (el) => () => {
    const redeem = el.children[0].textContent;
    const inp = el.children[1]?.value;
    return cons(redeem)(inp);
};

export const _submitRedeem = (url) => (redeem) => (inp) => () => {
    console.log(redeem, inp);
    const data = new FormData();
    data.append("name", redeem);
    data.append("input", inp);
    fetch(url, {
        method: "post",
        body: data,
    });
};

export const _setShader = (shader) => () => {
    window.wasmBindings.set_shader(shader);
};

export const _submitShader = (url) => (shader) => () => {
    const data = new FormData();
    data.append("name", "throw shade");
    data.append("input", shader);
    fetch(url, {
        method: "post",
        body: data,
    });
};

export const _addOption = (nm) => (el) => () => {
    const opt = document.createElement("option");
    opt.value = nm
    opt.innerHTML = nm;
    el.appendChild(opt);
};

export const _onInput = (el) => (f) => () => {
    el.addEventListener("input", (ev) => {
        f(ev.target.value)();
    });
};

let SOCKET = null;
function connectRefreshSocket(url, iframe) {
    if (!SOCKET) {
        SOCKET = new WebSocket(url);
        SOCKET.addEventListener("open", (ev) => {
            console.log("connected");
        });
        SOCKET.addEventListener("close", (ev) => {
            console.log("closed");
            SOCKET = null;
        });
        SOCKET.addEventListener("error", (ev) => {
            console.log("error");
            SOCKET = null;
        });
        const select = document.getElementById("lcolonq-gizmo-select");
        SOCKET.addEventListener("message", async (ev) => {
            console.log(`incoming: ${ev.data}`)
            if (select.value == ev.data) {
                iframe.src = iframe.src;
            }
        });
    }
};
export const _startBufferRefresh = (url) => (iframe) => () => {
    window.setInterval(() => connectRefreshSocket(url, iframe), 1000);
};
