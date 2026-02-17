var GL = null;
var VERTS = null;
var IDXS = null;
var ATTRIB_VERTEX = null;
var ATTRIB_TEXCOORD = null;
var UNIFORM_PROJECTION = null;
var UNIFORM_VIEW = null;
var UNIFORM_POSITION = null;
var CUBE_ROTATION = 0.0;

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
    }
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
function uploadShader(type, source) {
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
function uploadImage(url) {
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
    uploadImage("./assets/l.png");
    VERTS = cube.verts;
    IDXS = cube.idxs;
    requestAnimationFrame(render);
}

function render() {
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

initGL();
setName("LCOLONQ");

setTimeout(
    () => showContents(),
    1000
);
