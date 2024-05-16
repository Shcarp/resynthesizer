import rawModule from './lib/remove_object.js';

async function loadImage(url) {
    return new Promise((resolve, reject) => {
        fetch(url)
            .then(response => response.blob())
            .then(blob => createImageBitmap(blob))
            .then(bitmap => {
                var canvas = document.createElement('canvas');
                canvas.width = bitmap.width;
                canvas.height = bitmap.height;
                var ctx = canvas.getContext('2d');
                if (ctx === null) {
                    reject('2d context is null');
                    return;
                }
                ctx.drawImage(bitmap, 0, 0);
                var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
                var data = imageData.data;
                resolve(data)
            })
            .catch(err => {
                reject(err);
            });
    });
}

// 将 rgba 数据写入 wasm 内存
function writeImageDataToMemory(module, data) {
    const length = data.length;
    const dataPointer = module._malloc(length);
    module.HEAPU8.set(data, dataPointer);
    return dataPointer;
}

// 从 wasm 内存读取 rgba 数据
function readImageDataFromMemory(module, dataPointer, length) {
    return module.HEAPU8.slice(dataPointer, dataPointer + length);
}

// 释放 wasm 内存
function freeImageDataMemory(module, dataPointer) {
    module._free(dataPointer);
}

function maskToAlpha(mask_surface_data) {

    const length = mask_surface_data.length / 4;

    let mask_buffer_data = new Uint8Array(length);

    for (let i = 0; i < length; i++) {
        mask_buffer_data[i] = mask_surface_data[i * 4];
    }

    return mask_buffer_data;
}

async function removeObject(imageUrl, maskUrl, height, width) {
    const Module = await rawModule({});

    const rgba_data = await loadImage(imageUrl)
    // 将黑白mask 转换为 alpha channel
    const mask_data = maskToAlpha(await loadImage(maskUrl))

    // 写入 wasm 内存
    const rgba_data_ptr = writeImageDataToMemory(Module, rgba_data)
    const mask_data_ptr = writeImageDataToMemory(Module, mask_data)

    // 调用 wasm 函数
    const remove_res = Module.ccall('remove_object_func', 'number', ['number', 'number', 'number', 'number'], [rgba_data_ptr, mask_data_ptr, width, height])

    const data = readImageDataFromMemory(Module, remove_res, height * width * 4)

    // 释放 wasm 内存
    freeImageDataMemory(Module, rgba_data_ptr)
    freeImageDataMemory(Module, mask_data_ptr)
    freeImageDataMemory(Module, remove_res)

    // 创建 canvas
    const canvas = document.createElement('canvas')
    canvas.width = width
    canvas.height = height

    const imageData = new ImageData(new Uint8ClampedArray(data), width, height)

    const ctx = canvas.getContext('2d')
    if (ctx !== null) {
        ctx.putImageData(imageData, 0, 0)
    }
    const base64 = canvas.toDataURL()

    return base64;
}

export default removeObject;
