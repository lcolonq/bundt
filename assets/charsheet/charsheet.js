let GL = null;
let VERTS = null;
let IDXS = null;
let ATTRIB_VERTEX = null;
let ATTRIB_TEXCOORD = null;
let UNIFORM_PROJECTION = null;
let UNIFORM_VIEW = null;
let UNIFORM_POSITION = null;
let CUBE_ROTATION = 0.0;
let TALENTS = {};
let TALENT_SELECTED = null;

function showContents() {
    let elem = document.getElementById("contents");
    if (elem) {
        elem.classList.remove("invisible");
        elem.classList.add("contents-anim-unfold");
        let timeout = 500;
        for (let c of elem.children) {
            setTimeout(
                () => c.classList.add("opaque"),
                timeout
            );
            timeout += 200;
        }
        let badges = document.getElementById("badges");
        if (badges) {
            setTimeout(
                () => badges.classList.add("opaque"),
                timeout
            );
        }
    }
}

function showError(msg) {
    let elem = document.getElementById("error");
    if (elem) {
        elem.classList.remove("invisible");
        elem.classList.add("error-anim-unfold");
        let timeout = 500;
        for (let c of elem.children) {
            setTimeout(
                () => c.classList.add("opaque"),
                timeout
            );
            timeout += 200;
        }
    }
    let em = document.getElementById("error-message");
    if (em) { em.innerText = msg; }
}

function scaleName() {
    let elem = document.getElementById("name");
    if (elem && elem.firstElementChild) {
        elem.firstElementChild.style = `transform: scale(1, 1)`;
        let { width: pw, height: ph } = elem.getBoundingClientRect();
        let { width: cw, height: ch } = elem.firstElementChild.getBoundingClientRect();
        elem.firstElementChild.style = `transform: scale(${pw / cw}, ${ph / ch})`;
    }
}
function setName(nm) {
    let elem = document.getElementById("name");
    if (elem && elem.firstElementChild) {
        elem.firstElementChild.innerText = nm
        scaleName();
        new ResizeObserver(scaleName).observe(elem);
    }
}

function uploadCube(gl) {
    if (GL) {
        const verts = GL.createBuffer();
        GL.bindBuffer(GL.ARRAY_BUFFER, verts);
        const vertdata = [
            // front
            -0.5, -0.5, -0.5, 0, 0,
            +0.5, -0.5, -0.5, 1.0, 0,
            +0.5, +0.5, -0.5, 1.0, 1.0,
            -0.5, +0.5, -0.5, 0, 1.0,
            // right
            +0.5, -0.5, -0.5, 0, 0,
            +0.5, -0.5, +0.5, 1.0, 0,
            +0.5, +0.5, +0.5, 1.0, 1.0,
            +0.5, +0.5, -0.5, 0, 1.0,
            // left
            -0.5, -0.5, +0.5, 0, 0,
            -0.5, -0.5, -0.5, 1.0, 0,
            -0.5, +0.5, -0.5, 1.0, 1.0,
            -0.5, +0.5, +0.5, 0, 1.0,
            // top
            -0.5, -0.5, +0.5, 0, 0,
            +0.5, -0.5, +0.5, 1.0, 0,
            +0.5, -0.5, -0.5, 1.0, 1.0,
            -0.5, -0.5, -0.5, 0, 1.0,
            // bottom
            -0.5, +0.5, -0.5, 0, 0,
            +0.5, +0.5, -0.5, 1.0, 0,
            +0.5, +0.5, +0.5, 1.0, 1.0,
            -0.5, +0.5, +0.5, 0, 1.0,
            // back
            +0.5, -0.5, +0.5, 0, 0,
            -0.5, -0.5, +0.5, 1.0, 0,
            -0.5, +0.5, +0.5, 1.0, 1.0,
            +0.5, +0.5, +0.5, 0, 1.0
        ];
        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(vertdata), GL.STATIC_DRAW);
        const quadidx = (p0, p1, p2, p3) => [p0, p1, p2, p2, p3, p0];
        const idxs = GL.createBuffer();
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, idxs);
        const idxdata = [
            quadidx(0, 1, 2, 3), // front
            quadidx(4, 5, 6, 7), // right
            quadidx(8, 9, 10, 11), // left 
            quadidx(12, 13, 14, 15), // top 
            quadidx(16, 17, 18, 19), // bottom 
            quadidx(20, 21, 22, 23) // back 
        ].flat();
        GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Uint16Array(idxdata), GL.STATIC_DRAW);
        return { verts: verts, idxs: idxs };
    }
}
function uploadShader(type, source) {
    if (GL) {
        const shader = GL.createShader(type);
        GL.shaderSource(shader, source);
        GL.compileShader(shader);
        if (!GL.getShaderParameter(shader, GL.COMPILE_STATUS)) {
            alert(`shader compilation error: ${GL.getShaderInfoLog(shader)}`);
            GL.deleteShader(shader);
            return null;
        }
        return shader;
    }
}
function uploadImage(url) {
    if (GL) {
        const tex = GL.createTexture();
        GL.bindTexture(GL.TEXTURE_2D, tex);
        GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE, new Uint8Array([0, 0, 0, 1.0]));
        const img = new Image();
        img.onload = () => {
            GL.bindTexture(GL.TEXTURE_2D, tex);
            GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, img);
            GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
            GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
            GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
            GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        };
        img.src = url;
        return tex;
    }
}

function initGL() {
    const canvas = document.getElementById("canvas");
    GL = canvas.getContext("webgl");
    console.log(GL);
    if (!GL) return;
    console.log("initialized opengl");
    GL.clearColor(1.0, 0.0, 0.0, 1.0);
    GL.clearDepth(1.0);
    GL.enable(GL.DEPTH_TEST);
    GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
    const vertsrc = `
      attribute vec3 vertex;
      attribute vec2 texcoord;
      uniform mat4 view;
      uniform mat4 position;
      uniform mat4 projection;
      varying highp vec2 vertex_texcoord;
      void main(void) {
        gl_Position = projection * view * position * vec4(vertex, 1.0);
        vertex_texcoord = texcoord;
      }
    `;
    const fragsrc = `
      varying highp vec2 vertex_texcoord;
      uniform sampler2D texture_data;
      void main(void) {
        gl_FragColor = texture2D(texture_data, vertex_texcoord);
        gl_FragColor.a = 1.0;
      }
    `;
    const vshader = uploadShader(GL.VERTEX_SHADER, vertsrc);
    const fshader = uploadShader(GL.FRAGMENT_SHADER, fragsrc);
    const prog = GL.createProgram();
    GL.attachShader(prog, vshader);
    GL.attachShader(prog, fshader);
    GL.linkProgram(prog);
    if (!GL.getProgramParameter(prog, GL.LINK_STATUS)) {
        alert(`shader linking error: ${gl.getProgramInfoLog(prog)}`);
        return null;
    }
    GL.useProgram(prog);
    ATTRIB_VERTEX = GL.getAttribLocation(prog, "vertex");
    ATTRIB_TEXCOORD = GL.getAttribLocation(prog, "texcoord");
    UNIFORM_PROJECTION = GL.getUniformLocation(prog, "projection");
    UNIFORM_VIEW = GL.getUniformLocation(prog, "view");
    UNIFORM_POSITION = GL.getUniformLocation(prog, "position");
    const cube = uploadCube();
    VERTS = cube.verts;
    IDXS = cube.idxs;
    requestAnimationFrame(render);
}

function render() {
    if (GL) {
        CUBE_ROTATION += 0.01;
        CUBE_ROTATION %= 2.0 * Math.PI;
        const projection = mat4.create();
        mat4.perspective(projection, Math.PI / 4.0, GL.canvas.clientWidth / GL.canvas.clientHeight, 0.1, 100.0);
        const view = mat4.create();
        mat4.lookAt(view, [0.0, 0.0, -5.0], [0.0, 0.0, 0.0], [0.0, 1.0, 0.0]);
        const position = mat4.create();
        mat4.rotateX(position, position, Math.PI / 4.0);
        mat4.rotateY(position, position, CUBE_ROTATION);
        mat4.rotateZ(position, position, CUBE_ROTATION);
        GL.bindBuffer(GL.ARRAY_BUFFER, VERTS);
        GL.vertexAttribPointer(ATTRIB_VERTEX, 3, GL.FLOAT, false, 20, 0);
        GL.enableVertexAttribArray(ATTRIB_VERTEX);
        GL.vertexAttribPointer(ATTRIB_TEXCOORD, 2, GL.FLOAT, false, 20, 12);
        GL.enableVertexAttribArray(ATTRIB_TEXCOORD);
        GL.uniformMatrix4fv(UNIFORM_PROJECTION, false, projection);
        GL.uniformMatrix4fv(UNIFORM_VIEW, false, view);
        GL.uniformMatrix4fv(UNIFORM_POSITION, false, position);
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, IDXS);
        GL.drawElements(GL.TRIANGLES, 36, GL.UNSIGNED_SHORT, 0);
        requestAnimationFrame(render);
    }
}

function setField(nm, v) {
    const elem = document.getElementById("info-" + nm);
    if (elem) {
        elem.innerText = v.toString();
    }
}

function addBadge(b) {
    const badges = document.getElementById("badges");
    const elem = document.createElement("span");
    elem.classList.add("badge");
    elem.title = b.desc;
    if (b.mode == "text") {
        elem.innerText = b.text;
    } else if (b.mode == "icon") {
        const img = document.createElement("img");
        img.src = `${globalThis.apiServer}/badge/icon/${b.bid}.png`;
        elem.appendChild(img);
    } else {
        return;
    }
    badges.appendChild(elem);
}

async function fetchUser(uid) {
    const resp = await fetch(`${globalThis.apiServer}/user/info/${uid}`);
    if (!resp.ok) {
        showError("user not found");
        return false;
    } else {
        uploadImage(`${globalThis.apiServer}/user/avatar/${uid}.png`);
        const info = await resp.json()
        setName(info.properties["name"]);
        for (let nm in info.stats) {
            setField(nm, info.stats[nm]);
        }
        for (let nm in info.properties) {
            setField(nm, info.properties[nm]);
        }
        const badges = document.getElementById("badges");
        if (badges) {
            const badges_resp = await fetch(`${globalThis.apiServer}/user/badges/${uid}`);
            if (badges_resp.ok) {
                const bs = await badges_resp.json();
                console.log(bs);
                for (let b of bs) {
                    addBadge(b);
                }
            }
        }
        return true;
    }
}

globalThis.mainPublic = async () => {
    const uid = location.hash.slice(1);
    initGL();
    if (await fetchUser(uid)) {
        showContents();
    }
}

async function getAuthedUser() {
    const resp = await fetch(`${globalThis.secureApiServer}/info`);
    const s = await resp.text();
    const [_nm, uid] = s.split(" ");
    return uid;
}

function showContentsSecure() {
    let elem = document.getElementById("edit-contents");
    if (elem) {
        let timeout = 500;
        for (let c of elem.children) {
            if (!c.dataset.skipfade) {
                setTimeout(
                    () => c.classList.add("opaque"),
                    timeout
                );
                timeout += 200;
            }
        }
    }
}

async function fetchTalents() {
    const resp = await fetch(`${globalThis.apiServer}/talents`);
    return await resp.json();
}
async function renderTalent(tid, x, y) {
    const p = document.getElementById("edit-talentarea");
    const elem = document.createElement("div");
    elem.id = `edit-talent-${tid}`;
    elem.dataset.tid = tid;
    elem.classList.add("edit-talent");
    elem.style = `top: ${y}px; left: ${x}px;`;
    elem.addEventListener("click", () => selectTalent(elem));
    const img = document.createElement("img");
    img.src = `${globalThis.apiServer}/talent/icon/${tid}.png`;
    elem.appendChild(img);
    p.appendChild(elem);
}
function selectTalent(elem) {
    const p = document.getElementById("edit-talentarea");
    for (let c of p.children) {
        c.classList.remove("edit-talent-selected");
    }
    if (elem.dataset.tid == TALENT_SELECTED) {
        TALENT_SELECTED = null;
        const box = document.getElementById("edit-selected-tooltip-box");
        box.classList.remove("opaque");
    } else {
        elem.classList.add("edit-talent-selected");
        TALENT_SELECTED = elem.dataset.tid;
        const box = document.getElementById("edit-selected-tooltip-box");
        box.classList.add("opaque");
        const name = document.getElementById("edit-selected-tooltip-name");
        name.innerText = TALENTS[TALENT_SELECTED].name;
        const tooltip = document.getElementById("edit-selected-tooltip");
        tooltip.innerText = TALENTS[TALENT_SELECTED].desc;
    }
}

globalThis.mainSecure = async () => {
    const scrollable = document.getElementById("edit-scrollable");
    const basex = window.innerWidth + window.innerWidth / 2 + 20;
    const basey = window.innerHeight + 20;
    scrollable.scroll(window.innerWidth, window.innerHeight);
    const uid = await getAuthedUser();
    if (await fetchUser(uid)) {
        showContentsSecure();
    }
    TALENTS = await fetchTalents();
    renderTalent("bigjoel", basex + 0, basey + 0);
    renderTalent("shaderopacity", basex + 100, basey + 0);
}
