const fs = require('fs');
const path = require('path');

const files = ['snake.svg', 'kabsol.svg', 'tong.svg'];

files.forEach(file => {
  const filePath = path.join('assets', 'images', file);
  if (fs.existsSync(filePath)) {
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Remove the background path which is usually the first path covering the whole SVG
    // e.g., <path fill="#fdfdfd" d="M0 0h1080v1080H0z"/>
    // We can use a regex to remove any path that has d="M0 0h...v...H0z" or similar.
    content = content.replace(/<path fill="[^"]+" d="M0 0h\d+v\d+H0z"\/>/i, '');
    
    // Also let's add viewBox to make them responsive, if missing.
    // snake and kabsol are 1080x1080
    if (file !== 'tong.svg' && !content.includes('viewBox')) {
        content = content.replace('width="1080" height="1080"', 'viewBox="0 0 1080 1080" width="1080" height="1080"');
    } else if (file === 'tong.svg' && !content.includes('viewBox')) {
        content = content.replace('width="512" height="512"', 'viewBox="0 0 512 512" width="512" height="512"');
    }
    
    fs.writeFileSync(filePath, content);
    console.log(`Optimized ${file}`);
  }
});
