#!/bin/bash
# Compile C/C++ code with Emscripten
make remove_object

# Set variables
PACKAGE_NAME="remove_object"
VERSION="1.0.0"
DESCRIPTION="An NPM package wrapping the imageSynth function compiled from C/C++ using Emscripten."
AUTHOR="Your Name"
LICENSE="MIT"

cd output/$PACKAGE_NAME
# Create directory structure
# mkdir -p $PACKAGE_NAME
# cd $PACKAGE_NAME
npm init -y

# Update package.json
jq --arg name "$PACKAGE_NAME" --arg version "$VERSION" --arg description "$DESCRIPTION" --arg author "$AUTHOR" --arg license "$LICENSE" \
   '.name = $name | .version = $version | .description = $description | .main = "index.js" | .author = $author | .license = $license' \
   package.json > package.tmp.json && mv package.tmp.json package.json

# Create index.js
cat <<EOL > index.js
import rawModule from './lib/remove_object.js';

const module= rawModule({
    canvas: document.getElementById('canvas'),
    print: console.log,
})

export async function loadImage(Module, url, name) {
    return new Promise((resolve, reject) => {
        fetch(url)
            .then(response => response.blob())
            .then(blob => createImageBitmap(blob))
            .then(bitmap => {
                var canvas = document.createElement('canvas');
                canvas.width = bitmap.width;
                canvas.height = bitmap.height;
                var ctx = canvas.getContext('2d');
                ctx.drawImage(bitmap, 0, 0);
                var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
                var data = imageData.data;

                var width = canvas.width;
                var height = canvas.height;
                var ppmData = new Uint8Array(width * height * 3);

                for (var i = 0; i < width * height; i++) {
                    ppmData[3 * i] = data[4 * i];
                    ppmData[3 * i + 1] = data[4 * i + 1];
                    ppmData[3 * i + 2] = data[4 * i + 2];
                }

                // 生成PPM头部
                var header = \`P6\n\${width} \${height}\n255\n\`;
                var headerData = new TextEncoder().encode(header);
                var ppmFile = new Uint8Array(headerData.length + ppmData.length);
                ppmFile.set(headerData);
                ppmFile.set(ppmData, headerData.length);

                // 写入WASM文件系统
                Module.FS.writeFile(name, ppmFile);

                resolve(name);
            });
    });
}

export default module;

EOL

# Create README.md
cat <<EOL > README.md
# $PACKAGE_NAME

$DESCRIPTION

## Installation

\`\`\`sh
npm install $PACKAGE_NAME
\`\`\`

## Usage

\`\`\`javascript
const { wrappedImageSynth } = require('$PACKAGE_NAME');

const width = 256;
const height = 256;
const imageSize = width * height * 4;
const imageData = new Uint8Array(imageSize);
const maskData = new Uint8Array(imageSize);

// Initialize your imageData and maskData here

wrappedImageSynth(imageData, maskData, width, height).then(result => {
    console.log('Image Synth Result:', result);
});
\`\`\`
EOL

# Publish to npm
# npm publish
