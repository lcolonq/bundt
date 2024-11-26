export const _cheatLog = (a) => () => console.log(a);
export const _setInterval = (delay) => (f) => () => setInterval(f, delay);
export const _toJSON = (x) => JSON.stringify(x);

export const _reload = () => {
    window.location.reload();
};

export const _redirect = (url) => () => {
    window.location.href = url;
};

export const _submitRedeem = (url) => (el) => () => {
    const redeem = el.children[0].textContent;
    const inp = el.children[1]?.value;
    console.log(redeem, inp);
    const data = new FormData();
    data.append("ayem", "test");
    data.append("name", redeem);
    data.append("input", inp);
    fetch(url, {
        method: "post",
        body: data,
    });
};
