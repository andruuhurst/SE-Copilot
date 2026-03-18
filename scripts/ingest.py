#!/usr/bin/env python3
"""
SE Copilot — Document & URL Ingestion Engine
Extracts text from PDFs, DOCX, TXT, MD, and web URLs.
Zero third-party dependencies — uses Python stdlib only.
"""

import os
import re
import sys
import json
import zipfile
import urllib.request
import urllib.error
import html
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from pathlib import Path

# ── Supported file types ──────────────────────────────────────────────────────
SUPPORTED_EXTENSIONS = {'.pdf', '.docx', '.txt', '.md', '.csv', '.json'}

# ── HTML → plain text ─────────────────────────────────────────────────────────
class HTMLTextExtractor(HTMLParser):
    """Strip HTML tags and decode entities into plain text."""

    SKIP_TAGS = {'script', 'style', 'nav', 'footer', 'header',
                 'aside', 'noscript', 'iframe', 'svg'}

    def __init__(self):
        super().__init__()
        self.result = []
        self._skip = 0
        self._current_tag = ''

    def handle_starttag(self, tag, attrs):
        self._current_tag = tag.lower()
        if tag.lower() in self.SKIP_TAGS:
            self._skip += 1
        if tag.lower() in ('p', 'br', 'div', 'li', 'h1', 'h2',
                            'h3', 'h4', 'h5', 'h6', 'tr'):
            self.result.append('\n')

    def handle_endtag(self, tag):
        if tag.lower() in self.SKIP_TAGS:
            self._skip = max(0, self._skip - 1)

    def handle_data(self, data):
        if self._skip == 0:
            stripped = data.strip()
            if stripped:
                self.result.append(stripped + ' ')

    def get_text(self):
        raw = ''.join(self.result)
        # Collapse excess whitespace / blank lines
        raw = re.sub(r' {2,}', ' ', raw)
        raw = re.sub(r'\n{3,}', '\n\n', raw)
        return raw.strip()


def _clean_text(text: str) -> str:
    """Normalise whitespace and remove non-printable characters."""
    text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', text)
    text = re.sub(r' {2,}', ' ', text)
    text = re.sub(r'\n{4,}', '\n\n\n', text)
    return text.strip()


# ── PDF extractor (pure Python, no deps) ─────────────────────────────────────
def extract_pdf(path: str) -> str:
    """
    Extract text from a PDF using pure Python.
    Handles most text-layer PDFs. Scanned/image PDFs will return a notice.
    """
    try:
        with open(path, 'rb') as f:
            data = f.read()

        # Extract all text from stream objects
        texts = []
        # Find all stream contents
        for m in re.finditer(rb'BT(.*?)ET', data, re.DOTALL):
            block = m.group(1)
            # Extract strings from Tj, TJ, ' and " operators
            for string_m in re.finditer(
                    rb'\(([^)]*)\)\s*(?:Tj|\'|")|'
                    rb'\[([^\]]*)\]\s*TJ', block):
                if string_m.group(1):
                    raw = string_m.group(1)
                else:
                    raw = re.sub(rb'\(([^)]*)\)', lambda x: x.group(1),
                                 string_m.group(2) or b'')
                try:
                    decoded = raw.decode('latin-1')
                    # Remove PDF escape sequences
                    decoded = decoded.replace('\\n', '\n').replace('\\r', '\n')
                    decoded = decoded.replace('\\t', '\t')
                    decoded = re.sub(r'\\([0-7]{3})',
                                     lambda m: chr(int(m.group(1), 8)), decoded)
                    texts.append(decoded)
                except Exception:
                    pass

        result = ' '.join(texts)
        result = _clean_text(result)

        if len(result.strip()) < 50:
            return (f"[PDF: {os.path.basename(path)}]\n"
                    "Note: This PDF appears to be image-based or heavily encoded. "
                    "Text could not be extracted automatically. "
                    "Please copy the key content manually and paste it into the "
                    "intake/product or intake/client folder as a .txt file.")
        return f"[PDF: {os.path.basename(path)}]\n\n{result}"

    except Exception as e:
        return (f"[PDF: {os.path.basename(path)}]\n"
                f"Could not extract text: {e}\n"
                "Try saving the PDF content as a .txt file instead.")


# ── DOCX extractor ────────────────────────────────────────────────────────────
def extract_docx(path: str) -> str:
    """Extract text from a .docx file (ZIP of XML)."""
    try:
        with zipfile.ZipFile(path, 'r') as z:
            if 'word/document.xml' not in z.namelist():
                return f"[DOCX: {os.path.basename(path)}]\nCould not find document content."

            with z.open('word/document.xml') as f:
                xml_content = f.read()

        # Parse XML and extract text
        root = ET.fromstring(xml_content)
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

        paragraphs = []
        for para in root.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p'):
            texts = []
            for run in para.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t'):
                if run.text:
                    texts.append(run.text)
            if texts:
                paragraphs.append(''.join(texts))

        result = '\n'.join(paragraphs)
        result = _clean_text(result)
        return f"[DOCX: {os.path.basename(path)}]\n\n{result}"

    except zipfile.BadZipFile:
        return (f"[DOCX: {os.path.basename(path)}]\n"
                "File appears corrupted or is not a valid .docx file.")
    except Exception as e:
        return f"[DOCX: {os.path.basename(path)}]\nCould not extract text: {e}"


# ── Plain text / Markdown ─────────────────────────────────────────────────────
def extract_text(path: str) -> str:
    """Read .txt, .md, .csv, .json files."""
    try:
        with open(path, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
        ext = Path(path).suffix.lower()
        label = Path(path).name
        return f"[{ext.upper().lstrip('.')}: {label}]\n\n{_clean_text(content)}"
    except Exception as e:
        return f"[File: {os.path.basename(path)}]\nCould not read: {e}"


# ── URL fetcher ───────────────────────────────────────────────────────────────
def fetch_url(url: str, timeout: int = 15) -> str:
    """
    Fetch a URL and return its text content.
    Handles redirects, common encodings, and basic error cases.
    """
    if not url.startswith(('http://', 'https://')):
        url = 'https://' + url

    headers = {
        'User-Agent': (
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/120.0.0.0 Safari/537.36'
        ),
        'Accept': 'text/html,application/xhtml+xml,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
    }

    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            content_type = resp.headers.get('Content-Type', '').lower()
            raw = resp.read()

            # Detect encoding
            encoding = 'utf-8'
            if 'charset=' in content_type:
                encoding = content_type.split('charset=')[-1].split(';')[0].strip()

            try:
                html_content = raw.decode(encoding, errors='replace')
            except (LookupError, UnicodeDecodeError):
                html_content = raw.decode('utf-8', errors='replace')

            # Extract title
            title_m = re.search(r'<title[^>]*>(.*?)</title>',
                                 html_content, re.IGNORECASE | re.DOTALL)
            title = html.unescape(title_m.group(1).strip()) if title_m else url

            # Strip HTML
            extractor = HTMLTextExtractor()
            extractor.feed(html_content)
            text = extractor.get_text()

            # Truncate very long pages (keep first ~8000 chars of useful content)
            if len(text) > 8000:
                text = text[:8000] + '\n\n[... content truncated for brevity ...]'

            return f"[URL: {url}]\nPage title: {title}\n\n{_clean_text(text)}"

    except urllib.error.HTTPError as e:
        return f"[URL: {url}]\nHTTP error {e.code}: {e.reason}"
    except urllib.error.URLError as e:
        return (f"[URL: {url}]\n"
                f"Could not reach URL: {e.reason}\n"
                "Check your internet connection or try a different URL.")
    except Exception as e:
        return f"[URL: {url}]\nFailed to fetch: {e}"


# ── Directory scanner ─────────────────────────────────────────────────────────
def ingest_folder(folder: str, label: str = '') -> str:
    """
    Scan a folder and extract text from all supported files.
    Returns a combined string with file labels.
    """
    folder_path = Path(folder)
    if not folder_path.exists():
        return ''

    files = sorted([
        f for f in folder_path.iterdir()
        if f.is_file() and f.suffix.lower() in SUPPORTED_EXTENSIONS
        and not f.name.startswith('.')
        and f.name != 'README.md'
    ])

    if not files:
        return ''

    parts = []
    if label:
        parts.append(f"{'='*60}\n{label}\n{'='*60}\n")

    for f in files:
        ext = f.suffix.lower()
        print(f"    Reading: {f.name}")
        if ext == '.pdf':
            parts.append(extract_pdf(str(f)))
        elif ext == '.docx':
            parts.append(extract_docx(str(f)))
        else:
            parts.append(extract_text(str(f)))
        parts.append('\n\n')

    return '\n'.join(parts)


# ── URL list reader ───────────────────────────────────────────────────────────
def ingest_url_file(url_file: str, label: str = '') -> str:
    """
    Read a file of URLs (one per line, # = comment) and fetch each.
    """
    path = Path(url_file)
    if not path.exists():
        return ''

    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    urls = [
        line.strip() for line in lines
        if line.strip() and not line.strip().startswith('#')
    ]

    if not urls:
        return ''

    parts = []
    if label:
        parts.append(f"{'='*60}\n{label}\n{'='*60}\n")

    for url in urls:
        print(f"    Fetching: {url}")
        parts.append(fetch_url(url))
        parts.append('\n\n')

    return '\n'.join(parts)


# ── Single file ingestion (interactive) ───────────────────────────────────────
def ingest_single_file(path: str) -> str:
    """Ingest a single file by path."""
    p = Path(path)
    if not p.exists():
        return f"[ERROR] File not found: {path}"
    ext = p.suffix.lower()
    if ext == '.pdf':
        return extract_pdf(path)
    elif ext == '.docx':
        return extract_docx(path)
    elif ext in SUPPORTED_EXTENSIONS:
        return extract_text(path)
    else:
        return (f"[ERROR] Unsupported file type: {ext}\n"
                f"Supported types: {', '.join(SUPPORTED_EXTENSIONS)}")


# ── Main ingestion pipeline ───────────────────────────────────────────────────
def run_ingestion(base_dir: str, mode: str = 'both') -> dict:
    """
    Run the full ingestion pipeline.

    mode: 'product' | 'client' | 'both'

    Returns dict with keys:
        'product_docs'  - text from intake/product/
        'product_urls'  - text from intake/urls/product_urls.txt
        'client_docs'   - text from intake/client/
        'client_urls'   - text from intake/urls/client_urls.txt
        'has_product'   - bool
        'has_client'    - bool
    """
    result = {
        'product_docs': '',
        'product_urls': '',
        'client_docs':  '',
        'client_urls':  '',
        'has_product':  False,
        'has_client':   False,
    }

    intake_dir = Path(base_dir) / 'intake'

    if mode in ('product', 'both'):
        product_folder = str(intake_dir / 'product')
        product_url_file = str(intake_dir / 'urls' / 'product_urls.txt')

        print("  Scanning product documents...")
        result['product_docs'] = ingest_folder(
            product_folder, '== PRODUCT DOCUMENTS ==')
        print("  Fetching product URLs...")
        result['product_urls'] = ingest_url_file(
            product_url_file, '== PRODUCT URLS ==')

        result['has_product'] = bool(
            result['product_docs'].strip() or result['product_urls'].strip())

    if mode in ('client', 'both'):
        client_folder = str(intake_dir / 'client')
        client_url_file = str(intake_dir / 'urls' / 'client_urls.txt')

        print("  Scanning client documents...")
        result['client_docs'] = ingest_folder(
            client_folder, '== CLIENT DOCUMENTS ==')
        print("  Fetching client URLs...")
        result['client_urls'] = ingest_url_file(
            client_url_file, '== CLIENT URLS ==')

        result['has_client'] = bool(
            result['client_docs'].strip() or result['client_urls'].strip())

    return result


if __name__ == '__main__':
    # Quick test when run directly
    base = os.path.join(os.path.dirname(__file__), '..')
    print("Running ingestion test...")
    r = run_ingestion(base, 'both')
    print(f"Product docs: {len(r['product_docs'])} chars")
    print(f"Product URLs: {len(r['product_urls'])} chars")
    print(f"Client docs:  {len(r['client_docs'])} chars")
    print(f"Client URLs:  {len(r['client_urls'])} chars")
