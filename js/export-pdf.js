/**
 * Session PDF export using pdfmake (offline, zero network requests).
 * SVG diagrams rendered at 5× resolution for sharp zoom.
 * College of Technology Galle
 */
(function () {
  'use strict';

  var AUTHOR = 'Jayashan Liyanage';
  var INSTITUTE = 'College of Technology Galle';
  var SVG_PIXEL_RATIO = 5;
  var MAX_IMG_WIDTH = 470;

  var BOX_STYLE = {
    // All callouts use the same full-border card layout for reliable PDF rendering
    'definition-box': { fill: '#f3e5f5', border: '#8e24aa', label: '#8e24aa', fullBorder: true },
    'info-box':       { fill: '#e3f2fd', border: '#1e88e5', label: '#1e88e5', fullBorder: true },
    'note-box':       { fill: '#e8f5e9', border: '#43a047', label: '#43a047', fullBorder: true },
    'tip-box':        { fill: '#e3f2fd', border: '#1e88e5', label: '#1e88e5', fullBorder: true },
    'warn-box':       { fill: '#fff8e1', border: '#f9a825', label: '#f57f17', fullBorder: true },
    'warning-box':    { fill: '#fff8e1', border: '#f9a825', label: '#f57f17', fullBorder: true },
    'exam-box':       { fill: '#fff3e0', border: '#e65100', label: '#e65100', fullBorder: true },
    'lab-box':        { fill: '#e8f5e9', border: '#2e7d32', label: '#2e7d32', fullBorder: true },
    'logic-box':      { fill: '#fce4ec', border: '#c2185b', label: '#c2185b', fullBorder: true },
    'summary-box':    { fill: '#1a3a5c', border: '#1565c0', label: '#f9a825', lightText: true, fullBorder: true },
    'outcomes-box':   { fill: '#e3f2fd', border: '#1e88e5', label: '#0277bd', fullBorder: true }
  };

  var CARD_BORDER = {
    'green': '#2e7d32', 'orange': '#e65100', 'yellow': '#f9a825', 'blue': '#0277bd'
  };

  var sectionTitleCount = 0;
  var lastBlockWasSectionTitle = false;

  function ready() {
    return typeof pdfMake !== 'undefined' && typeof pdfMake.createPdf === 'function';
  }

  function mentionsHours(t) {
    return /\b\d+\s*(Hours?|hrs?)\b/i.test(t);
  }

  function getModuleLine() {
    var fp = document.querySelector('footer p');
    if (!fp) return '';
    var parts = fp.textContent.split('|').map(function (s) { return s.trim(); });
    return parts.length > 1 ? parts.slice(1).join(' | ') : parts[0];
  }

  function filename() {
    var t = document.querySelector('.session-banner h2');
    var raw = t ? t.textContent : document.title;
    return raw.replace(/[^\w\s-]/g, '').trim().replace(/\s+/g, '-').substring(0, 60) + '.pdf';
  }

  function btnLoading(btn, on) {
    if (!btn) return;
    if (on) {
      btn.dataset.prevHtml = btn.innerHTML;
      btn.disabled = true;
      btn.innerHTML = '<span>Exporting…</span>';
    } else {
      btn.disabled = false;
      if (btn.dataset.prevHtml) btn.innerHTML = btn.dataset.prevHtml;
    }
  }

  function mergeRuns(runs) {
    var out = [];
    runs.forEach(function (r) {
      if (typeof r === 'string') r = { text: r };
      if (!r.text) return;
      var prev = out[out.length - 1];
      if (prev && prev.bold === r.bold && prev.italics === r.italics && prev.color === r.color &&
          prev.fontSize === r.fontSize && prev.link === r.link && prev.decoration === r.decoration) {
        prev.text += r.text;
      } else {
        out.push(r);
      }
    });
    return out;
  }

  function inline(node, style) {
    style = style || {};
    var res = [];
    node.childNodes.forEach(function (c) {
      if (c.nodeType === 3) {
        var t = c.textContent.replace(/\s+/g, ' ');
        if (t.trim()) res.push(Object.assign({ text: t }, style));
      } else if (c.nodeType === 1) {
        var tag = c.tagName;
        // Decorative icons/emoji often fail in PDF fonts (show as ??). Skip them —
        // list items already get a plain pdfmake bullet.
        if (c.classList && c.classList.contains('res-icon')) {
          return;
        }
        if (tag === 'STRONG' || tag === 'B') res = res.concat(inline(c, Object.assign({}, style, { bold: true })));
        else if (tag === 'EM' || tag === 'I') res = res.concat(inline(c, Object.assign({}, style, { italics: true })));
        else if (tag === 'CODE') res.push({ text: c.textContent, fontSize: 9, background: '#eceff1' });
        else if (tag === 'BR') res.push({ text: '\n' });
        else if (tag === 'A') {
          var href = (c.getAttribute('href') || '').trim();
          if (href && href.charAt(0) !== '#' && href.toLowerCase().indexOf('javascript:') !== 0) {
            res = res.concat(inline(c, Object.assign({}, style, {
              link: href,
              color: '#1565c0',
              decoration: 'underline'
            })));
          } else {
            res = res.concat(inline(c, style));
          }
        }
        else res = res.concat(inline(c, style));
      }
    });
    return mergeRuns(res);
  }

  function prefixSvgIds(svg, prefix) {
    var map = {};
    svg.querySelectorAll('[id]').forEach(function (n) {
      map[n.id] = prefix + n.id;
      n.id = prefix + n.id;
    });
    svg.querySelectorAll('*').forEach(function (n) {
      ['href', 'xlink:href', 'marker-end', 'marker-start', 'fill', 'stroke', 'filter', 'clip-path', 'mask'].forEach(function (a) {
        var v = n.getAttribute(a);
        if (!v) return;
        if (v.indexOf('url(#') === 0) {
          var id = v.slice(5, -1);
          if (map[id] || svg.querySelector('#' + id)) {
            n.setAttribute(a, 'url(#' + (map[id] || prefix + id) + ')');
          }
        }
      });
    });
  }

  function svgToPng(svgEl) {
    var prefix = 'p' + Math.random().toString(36).slice(2, 9);
    var clone = svgEl.cloneNode(true);
    prefixSvgIds(clone, prefix);

    var vb = clone.getAttribute('viewBox');
    var w = 780, h = 400;
    if (vb) {
      var p = vb.trim().split(/[\s,]+/);
      if (p.length >= 4) { w = parseFloat(p[2]) || w; h = parseFloat(p[3]) || h; }
    }

    var cw = Math.round(w * SVG_PIXEL_RATIO);
    var ch = Math.round(h * SVG_PIXEL_RATIO);
    clone.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
    clone.setAttribute('width', String(cw));
    clone.setAttribute('height', String(ch));

    var xml = '<?xml version="1.0" encoding="UTF-8"?>' + new XMLSerializer().serializeToString(clone);
    var url = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(xml);

    return new Promise(function (resolve, reject) {
      var img = new Image();
      img.onload = function () {
        var canvas = document.createElement('canvas');
        canvas.width = cw;
        canvas.height = ch;
        var ctx = canvas.getContext('2d');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, cw, ch);
        ctx.drawImage(img, 0, 0, cw, ch);
        resolve({
          dataUrl: canvas.toDataURL('image/png'),
          w: w,
          h: h
        });
      };
      img.onerror = function () { reject(new Error('Diagram render failed')); };
      img.src = url;
    });
  }

  function tokenizeCodeLine(line) {
    var KW = {
      public:1, private:1, protected:1, static:1, void:1, class:1, interface:1, abstract:1,
      extends:1, implements:1, return:1, if:1, else:1, for:1, while:1, do:1, switch:1, case:1,
      break:1, continue:1, new:1, this:1, super:1, import:1, package:1, try:1, catch:1,
      finally:1, throw:1, throws:1, final:1, true:1, false:1, null:1, boolean:1, int:1,
      long:1, double:1, float:1, char:1, byte:1, short:1, String:1, var:1, const:1
    };
    var DEF = '#d4d4d4', KW_C = '#569cd6', STR = '#ce9178', CM = '#6a9955', NUM = '#b5cea8';
    var runs = [];
    var i = 0;
    var n = line.length;

    function push(text, color) {
      if (!text) return;
      runs.push({ text: text, color: color, fontSize: 8.5 });
    }

    // Full-line or trailing // comment
    var cmt = line.indexOf('//');
    var codePart = cmt >= 0 ? line.slice(0, cmt) : line;
    var commentPart = cmt >= 0 ? line.slice(cmt) : '';

    while (i < codePart.length) {
      var ch = codePart.charAt(i);
      if (ch === '"' || ch === "'") {
        var q = ch;
        var j = i + 1;
        while (j < codePart.length) {
          if (codePart.charAt(j) === '\\') { j += 2; continue; }
          if (codePart.charAt(j) === q) { j++; break; }
          j++;
        }
        push(codePart.slice(i, j), STR);
        i = j;
      } else if (/[0-9]/.test(ch)) {
        var j2 = i + 1;
        while (j2 < codePart.length && /[0-9.xXa-fA-F]/.test(codePart.charAt(j2))) j2++;
        push(codePart.slice(i, j2), NUM);
        i = j2;
      } else if (/[A-Za-z_$]/.test(ch)) {
        var j3 = i + 1;
        while (j3 < codePart.length && /[A-Za-z0-9_$]/.test(codePart.charAt(j3))) j3++;
        var word = codePart.slice(i, j3);
        push(word, KW[word] ? KW_C : DEF);
        i = j3;
      } else {
        var j4 = i + 1;
        while (j4 < codePart.length && !/[A-Za-z0-9_$"']/.test(codePart.charAt(j4))) j4++;
        push(codePart.slice(i, j4), DEF);
        i = j4;
      }
    }
    if (commentPart) push(commentPart, CM);
    if (!runs.length) push(' ', DEF);
    // Preserve leading spaces for indentation
    return runs;
  }

  function codeBlock(el) {
    var raw = el.textContent.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    if (raw.endsWith('\n')) raw = raw.slice(0, -1);
    var lines = raw.length ? raw.split('\n') : [''];
    var stack = lines.map(function (line) {
      return {
        text: tokenizeCodeLine(line),
        margin: [0, 0.5, 0, 0.5],
        preserveLeadingSpaces: true
      };
    });
    return {
      table: {
        widths: ['*'],
        body: [[{
          stack: stack,
          fillColor: '#000000',
          margin: [12, 12, 12, 12]
        }]]
      },
      layout: {
        hLineWidth: function () { return 0; },
        vLineWidth: function () { return 0; },
        paddingLeft: function () { return 0; },
        paddingRight: function () { return 0; },
        paddingTop: function () { return 0; },
        paddingBottom: function () { return 0; }
      },
      margin: [0, 8, 0, 8],
      unbreakable: lines.length <= 18
    };
  }

  function boxKey(el) {
    return Object.keys(BOX_STYLE).find(function (k) { return el.classList.contains(k); });
  }

  function cardBorder(el) {
    var k = Object.keys(CARD_BORDER).find(function (c) { return el.classList.contains(c); });
    return k ? CARD_BORDER[k] : '#1a3a5c';
  }

  function borderedBox(inner, style) {
    var textColor = style.lightText ? '#ffffff' : '#212529';
    inner.forEach(function (b) {
      if (b.text && !b.color) b.color = textColor;
    });

    if (style.fullBorder) {
      return {
        table: { widths: ['*'], body: [[{ stack: inner, fillColor: style.fill, margin: [10, 10, 10, 10] }]] },
        layout: {
          hLineWidth: function () { return 1.5; },
          vLineWidth: function () { return 1.5; },
          hLineColor: function () { return style.border; },
          vLineColor: function () { return style.border; }
        },
        margin: [0, 6, 0, 6],
        unbreakable: inner.length <= 8
      };
    }

    return {
      table: {
        widths: [5, '*'],
        body: [[
          { fillColor: style.border, text: '', border: [false, false, false, false] },
          { stack: inner, fillColor: style.fill, margin: [10, 10, 10, 10] }
        ]]
      },
      layout: 'noBorders',
      margin: [0, 6, 0, 6],
      unbreakable: inner.length <= 8
    };
  }

  function listBlock(el, type) {
    var items = Array.from(el.querySelectorAll(':scope > li')).map(function (li) {
      var t = inline(li, {});
      if (!t.length) return li.textContent.replace(/\s+/g, ' ').trim();
      return t.length === 1 && Object.keys(t[0]).length === 1 ? t[0].text : { text: t };
    });
    var b = type === 'ul' ? { ul: items } : { ol: items };
    // Plain ASCII-safe bullet — emoji/icons from .res-icon are skipped in inline()
    if (type === 'ul') {
      b.type = 'disc';
      b.markerColor = '#1a3a5c';
    }
    b.margin = [0, 4, 0, 8];
    return b;
  }

  function tableBlock(table) {
    var head = table.querySelectorAll('thead tr');
    var body = table.querySelectorAll('tbody tr');
    var rows = head.length ? Array.from(head).concat(Array.from(body)) : Array.from(table.querySelectorAll('tr'));
    var skip = [];
    if (head.length) {
      Array.from(head[0].children).forEach(function (th, i) {
        if (/^\s*Hours?\s*$/i.test(th.textContent.trim())) skip.push(i);
      });
    }
    skip.sort(function (a, b) { return b - a; });

    var bodyRows = rows.map(function (tr, ri) {
      var cells = Array.from(tr.children);
      skip.forEach(function (i) { if (cells[i]) cells.splice(i, 1); });
      var isHead = ri < head.length && head.length;
      return cells.map(function (td) {
        var t = inline(td, isHead ? { bold: true, color: '#ffffff' } : {});
        return {
          text: t.length ? t : td.textContent.trim(),
          fillColor: isHead ? '#1a3a5c' : (ri % 2 === 0 && !isHead ? '#f8f9fa' : null)
        };
      });
    });

    return {
      table: {
        headerRows: head.length || 0,
        widths: bodyRows[0] ? bodyRows[0].map(function () { return '*'; }) : ['*'],
        body: bodyRows
      },
      layout: {
        hLineWidth: function () { return 0.5; },
        vLineWidth: function () { return 0.5; },
        hLineColor: function () { return '#dde3ea'; },
        vLineColor: function () { return '#dde3ea'; }
      },
      margin: [0, 8, 0, 8],
      unbreakable: bodyRows.length <= 10
    };
  }

  async function figBlock(el) {
    var stack = [];
    var svg = el.querySelector('svg');
    if (svg) {
      try {
        var img = await svgToPng(svg);
        var dw = Math.min(MAX_IMG_WIDTH, img.w);
        stack.push({ image: img.dataUrl, width: dw, alignment: 'center', margin: [0, 6, 0, 4] });
      } catch (e) {
        stack.push({ text: '[Diagram]', alignment: 'center', color: '#888', italics: true });
      }
    }
    var cap = el.querySelector('.cap');
    if (cap) {
      stack.push({ text: cap.textContent.trim(), fontSize: 9, color: '#555', alignment: 'center', italics: true });
    }
    return { stack: stack, unbreakable: true, margin: [0, 8, 0, 8] };
  }

  async function elementBlocks(el) {
    if (!el || el.nodeType !== 1) return [];
    if (el.classList.contains('no-print') || el.classList.contains('botnav')) return [];
    if (el.classList.contains('lesson-meta') || el.classList.contains('prac-meta')) return [];

    var tag = el.tagName;
    if (tag === 'P') {
      lastBlockWasSectionTitle = false;
      var t = inline(el, {});
      return t.length ? [{ text: t, margin: [0, 4, 0, 4] }] : [];
    }
    if (/^H[1-4]$/.test(tag)) {
      var b = { text: el.textContent.trim(), margin: [0, 8, 0, 6] };
      if (el.classList.contains('section-title')) {
        sectionTitleCount++;
        b.style = 'sectionTitle';
        // Avoid empty pages when a merge part-break title is immediately
        // followed by the real section heading (both are section-title).
        if (sectionTitleCount > 1 && !lastBlockWasSectionTitle) b.pageBreak = 'before';
        lastBlockWasSectionTitle = true;
      } else if (el.classList.contains('sub-title')) {
        b.style = 'subTitle';
        lastBlockWasSectionTitle = false;
      } else {
        b.style = 'heading';
        lastBlockWasSectionTitle = false;
      }
      return [b];
    }
    // Leaf content clears the consecutive-title flag. Wrapper divs must NOT
    // clear it, or a part-break title + next section-title still double-break.
    if (tag === 'UL') { lastBlockWasSectionTitle = false; return [listBlock(el, 'ul')]; }
    if (tag === 'OL') { lastBlockWasSectionTitle = false; return [listBlock(el, 'ol')]; }
    if (tag === 'TABLE') { lastBlockWasSectionTitle = false; return [tableBlock(el)]; }
    if (tag === 'PRE') {
      lastBlockWasSectionTitle = false;
      return [codeBlock(el)];
    }
    if (tag === 'HR') {
      lastBlockWasSectionTitle = false;
      return [{ canvas: [{ type: 'line', x1: 0, y1: 0, x2: 511, y2: 0, lineWidth: 0.5, lineColor: '#dde3ea' }], margin: [0, 10, 0, 10] }];
    }

    if (el.classList.contains('fig')) {
      lastBlockWasSectionTitle = false;
      return [await figBlock(el)];
    }

    var bk = boxKey(el);
    if (bk) {
      lastBlockWasSectionTitle = false;
      var st = BOX_STYLE[bk];
      var inner = [];
      var labelTaken = false;
      var pending = [];

      function flushInlinePending() {
        if (!pending.length) return;
        var tmp = document.createElement('span');
        pending.forEach(function (n) { tmp.appendChild(n.cloneNode(true)); });
        var runs = inline(tmp, {});
        if (runs.length) inner.push({ text: runs, margin: [0, 2, 0, 2] });
        pending = [];
      }

      function isBlockEl(node) {
        if (node.nodeType !== 1) return false;
        var t = node.tagName;
        return t === 'P' || t === 'UL' || t === 'OL' || t === 'PRE' || t === 'TABLE' ||
          t === 'DIV' || t === 'FIGURE' || /^H[1-6]$/.test(t) ||
          node.classList.contains('fig') || boxKey(node);
      }

      for (var i = 0; i < el.childNodes.length; i++) {
        var ch = el.childNodes[i];
        if (ch.nodeType === 1 && ch.tagName === 'STRONG' && !labelTaken) {
          flushInlinePending();
          inner.push({ text: ch.textContent.trim(), bold: true, color: st.label, fontSize: 9, margin: [0, 0, 0, 4] });
          labelTaken = true;
        } else if (isBlockEl(ch)) {
          flushInlinePending();
          inner = inner.concat(await elementBlocks(ch));
        } else if (ch.nodeType === 3) {
          if (ch.textContent.replace(/\s+/g, ' ').trim()) pending.push(ch);
        } else if (ch.nodeType === 1) {
          pending.push(ch);
        }
      }
      flushInlinePending();

      if (!inner.length) {
        var fallback = el.textContent.replace(/\s+/g, ' ').trim();
        if (fallback) inner.push({ text: fallback });
      }
      // Skip empty/broken boxes rather than exporting blank cards
      if (!inner.length) return [];
      return [borderedBox(inner, st)];
    }

    if (el.classList.contains('card')) {
      lastBlockWasSectionTitle = false;
      var cardInner = [];
      var h4 = el.querySelector('h4');
      if (h4) cardInner.push({ text: h4.textContent.trim(), bold: true, color: '#1a3a5c', margin: [0, 0, 0, 4] });
      for (var j = 0; j < el.children.length; j++) {
        if (el.children[j].tagName === 'H4') continue;
        cardInner = cardInner.concat(await elementBlocks(el.children[j]));
      }
      return [{
        table: { widths: ['*'], body: [[{ stack: cardInner, margin: [8, 8, 8, 8] }]] },
        layout: {
          hLineWidth: function (i, n) { return i === 0 ? 3 : 0; },
          vLineWidth: function () { return 0; },
          hLineColor: function () { return cardBorder(el); }
        },
        margin: [0, 4, 0, 4],
        unbreakable: true
      }];
    }

    if (el.classList.contains('card-grid')) {
      var cards = [];
      var els = el.querySelectorAll(':scope > .card');
      for (var c = 0; c < els.length; c++) {
        cards = cards.concat(await elementBlocks(els[c]));
      }
      return cards;
    }

    var blocks = [];
    for (var k = 0; k < el.children.length; k++) {
      blocks = blocks.concat(await elementBlocks(el.children[k]));
    }
    return blocks;
  }

  function coverPage() {
    var banner = document.querySelector('.session-banner');
    var title = banner ? (banner.querySelector('h2') || {}).textContent : document.title;
    var snum = banner ? (banner.querySelector('.snum') || {}).textContent : '';
    var tags = banner
      ? Array.from(banner.querySelectorAll('.stag')).filter(function (t) { return !mentionsHours(t.textContent); }).map(function (t) { return t.textContent.trim(); })
      : [];

    return [
      { text: INSTITUTE, style: 'coverInst', margin: [0, 90, 0, 8] },
      { text: getModuleLine(), style: 'coverModule', margin: [0, 0, 0, 28] },
      { text: title || '', style: 'coverTitle', margin: [0, 0, 0, 14] },
      snum ? { text: snum.trim(), style: 'coverSession', margin: [0, 0, 0, 8] } : {},
      tags.length ? { text: tags.join('  |  '), style: 'coverTags', margin: [0, 0, 0, 28] } : {},
      { text: 'Author: ' + AUTHOR, style: 'coverAuthor', margin: [0, 36, 0, 0] },
      { text: '', pageBreak: 'after' }
    ];
  }

  async function mainContent() {
    var main = document.querySelector('main');
    if (!main) throw new Error('No page content found.');
    sectionTitleCount = 0;
    lastBlockWasSectionTitle = false;
    var blocks = [];
    for (var i = 0; i < main.children.length; i++) {
      var ch = main.children[i];
      if (ch.classList.contains('botnav') || ch.classList.contains('no-print')) continue;
      blocks = blocks.concat(await elementBlocks(ch));
    }
    return blocks;
  }

  function docDef(content) {
    return {
      info: { title: document.title, author: AUTHOR },
      pageSize: 'A4',
      pageMargins: [42, 48, 42, 52],
      defaultStyle: { font: 'Roboto', fontSize: 10, lineHeight: 1.35, color: '#212529' },
      styles: {
        coverInst: { fontSize: 9, color: '#666666', alignment: 'center' },
        coverModule: { fontSize: 9, color: '#1a3a5c', alignment: 'center' },
        coverTitle: { fontSize: 17, bold: true, color: '#1a3a5c', alignment: 'center' },
        coverSession: { fontSize: 10, color: '#555555', alignment: 'center' },
        coverTags: { fontSize: 9, color: '#1565c0', alignment: 'center' },
        coverAuthor: { fontSize: 10, color: '#444444', alignment: 'center' },
        sectionTitle: { fontSize: 14, bold: true, color: '#1a3a5c' },
        subTitle: { fontSize: 12, bold: true, color: '#333333' },
        heading: { fontSize: 11, bold: true }
      },
      footer: function (cp, tp) {
        return {
          text: INSTITUTE + '  |  ' + AUTHOR + '  |  Page ' + cp + ' of ' + tp,
          alignment: 'center', fontSize: 8, color: '#888888', margin: [0, 8, 0, 0]
        };
      },
      content: content
    };
  }

  window.exportSessionPdf = async function (btn) {
    if (!ready()) {
      alert('PDF library failed to load. Refresh the page and try again.');
      return;
    }
    btnLoading(btn, true);
    try {
      var content = coverPage().concat(await mainContent());
      pdfMake.createPdf(docDef(content)).download(filename());
    } catch (err) {
      console.error('PDF export error:', err);
      alert('PDF export failed: ' + (err.message || err));
    } finally {
      btnLoading(btn, false);
    }
  };
})();
