function generateNonce() {
    var arr = new Uint8Array(20);
    window.crypto.getRandomValues(arr);
    return Array.from(arr, b => b.toString(16).padStart(2, "0")).join("");
}

export const _startTwitchAuth = (clientID) => (redirectURL) => () => {
    const nonce = generateNonce();
    document.cookie = `authnonce=${nonce}; path=/; max-age=3000`;
    window.location.href =
        `https://id.twitch.tv/oauth2/authorize?response_type=id_token`
        + `&client_id=${clientID}`
        + `&redirect_uri=${redirectURL}`
        + `&scope=openid`
        + `&nonce=${nonce}`
        + `&claims=${JSON.stringify({id_token: {preferred_username: null}})}`
    ;
};

function getFragmentQuery() {
    let query = new Map();
    const hashQuery = document.location.hash.slice(1).split("&");
    for (let equals of hashQuery) {
        const pair = equals.split("=");
        query.set(decodeURIComponent(pair[0]), decodeURIComponent(pair[1]));
    }
    return query;
}

export const _getToken = (Just) => (Nothing) => (pair) => () => {
    const frag = getFragmentQuery();
    const token = frag.get("id_token");
    document.location.hash = "";
    // if (token) {
    //     document.cookie = `id_token=${token}; path=/; SameSite=Strict`;
    // }
    // let id_token = null;
    let authnonce = null;
    for (let c of document.cookie.split("; ")) {
        const [k, v] = c.split("=");
        // if (k === "id_token") id_token = v;
        if (k === "authnonce") authnonce = v;
    }
    if (token && authnonce) return Just(pair(token)(authnonce));
    return Nothing;
};

export const _clearSessionCookie = () => {
    document.cookie = "authelia_session=; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=None; Secure";
};

export const _getQueryRedirect = (Just) => (Nothing) => () => {
    const ps = new URLSearchParams(window.location.search);
    const p = ps?.get("rd");
    if (p) return Just(p);
    return Nothing;
};

export const _getResponseRedirect = (Just) => (Nothing) => (x) => () => {
    const data = x["data"];
    if (!data) return Nothing;
    const r = x["data"]["redirect"];
    if (r) return Just(r);
    return Nothing;
};
