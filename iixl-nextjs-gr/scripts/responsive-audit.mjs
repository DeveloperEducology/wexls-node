import fs from 'node:fs';
import path from 'node:path';

const rootDir = process.cwd();
const srcDir = path.join(rootDir, 'src');

const CSS_EXT = '.css';
const mediaPattern = /@media\s*\(([^)]+)\)/i;
const minWidthPattern = /min-width\s*:\s*(\d+)px\b/i;
const fixedWidthPattern = /(^|[^-])width\s*:\s*(\d+)px\b/i;
const fixedHeightPattern = /(^|[^-])height\s*:\s*(\d+)px\b/i;
const maxHeightPattern = /max-height\s*:\s*(\d+)px\b/i;

const warnings = [];

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(fullPath);
      continue;
    }
    if (entry.isFile() && fullPath.endsWith(CSS_EXT)) {
      inspectCss(fullPath);
    }
  }
}

function inspectCss(filePath) {
  const source = fs.readFileSync(filePath, 'utf8');
  const lines = source.split('\n');
  let inMobileMedia = false;
  let braceDepth = 0;
  let mediaDepth = -1;

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    const trimmed = line.trim();
    const lineNo = i + 1;

    const mediaMatch = trimmed.match(mediaPattern);
    if (mediaMatch) {
      const cond = mediaMatch[1].toLowerCase();
      inMobileMedia = cond.includes('max-width');
      mediaDepth = braceDepth;
    }

    const minWidth = trimmed.match(minWidthPattern);
    if (minWidth && !inMobileMedia && Number(minWidth[1]) >= 480) {
      pushWarning(filePath, lineNo, `Large min-width (${minWidth[1]}px) outside max-width media block`);
    }

    const fixedWidth = trimmed.match(fixedWidthPattern);
    if (fixedWidth && !inMobileMedia && Number(fixedWidth[2]) >= 360) {
      pushWarning(filePath, lineNo, `Fixed width (${fixedWidth[2]}px) outside max-width media block`);
    }

    const fixedHeight = trimmed.match(fixedHeightPattern);
    if (fixedHeight && !inMobileMedia && Number(fixedHeight[2]) >= 500) {
      pushWarning(filePath, lineNo, `Large fixed height (${fixedHeight[2]}px) outside max-width media block`);
    }

    const maxHeight = trimmed.match(maxHeightPattern);
    if (maxHeight && !inMobileMedia && Number(maxHeight[1]) >= 500) {
      pushWarning(filePath, lineNo, `Large max-height (${maxHeight[1]}px) outside max-width media block`);
    }

    for (const ch of line) {
      if (ch === '{') braceDepth += 1;
      if (ch === '}') braceDepth = Math.max(0, braceDepth - 1);
    }

    if (inMobileMedia && mediaDepth >= 0 && braceDepth <= mediaDepth) {
      inMobileMedia = false;
      mediaDepth = -1;
    }
  }
}

function pushWarning(filePath, lineNo, message) {
  warnings.push({
    filePath: path.relative(rootDir, filePath),
    lineNo,
    message,
  });
}

walk(srcDir);

if (!warnings.length) {
  console.log('Responsive audit: no high-risk fixed sizing patterns found.');
  process.exit(0);
}

console.log(`Responsive audit: ${warnings.length} warning(s) found.\n`);
for (const item of warnings) {
  console.log(`${item.filePath}:${item.lineNo} - ${item.message}`);
}

process.exitCode = 1;
