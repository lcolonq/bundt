export const _cheatLog = (a) => () => console.log(a);
export const _setInterval = (delay) => (f) => () => setInterval(f, delay);
export const _toJSON = (x) => JSON.stringify(x);
