/* =========================================================
   Stone Arch Silicon course site engine
   Lessons live in Pages/page_1.md, Pages/page_2.md, ... and are
   rendered in the browser by the markdown parser below.

   CONFIG: the only block you need to edit per repo
   ========================================================= */
/*__CONFIG_START__*/
const CONFIG = {
  title: "RTL 101",
  tagline: "Digital design with Verilog and SystemVerilog, simulated and synthesized with open tools.",
  repo: "https://github.com/Stone-Arch-Silicon/RTL_101",
  mainSite: "https://stone-arch-silicon.github.io/stone-arch-silicon/",
  org: "Stone Arch Silicon",
  orgMark: "STONE ARCH SILICON",
  branch: "main",
  pagesDir: "Pages",
  maxPages: 60,
  unitWord: "Lesson",
  tracks: [
    {
      title: "ASIC 101",
      url: "https://stone-arch-silicon.github.io/ASIC_101/"
    },
    {
      title: "RTL 101",
      url: "https://stone-arch-silicon.github.io/RTL_101/"
    },
    {
      title: "Verification 101",
      url: "https://stone-arch-silicon.github.io/Verification_101/"
    },
    {
      title: "PD 101",
      url: "https://stone-arch-silicon.github.io/PD_101/"
    },
    {
      title: "Analog 101",
      url: "https://stone-arch-silicon.github.io/Analog_101/"
    }
  ]
};
/*__CONFIG_END__*/

/* third-party libraries, loaded only on pages that need them */
const LIB = {
  katexCss: "https://cdn.jsdelivr.net/npm/katex@0.19.0/dist/katex.min.css",
  katexJs:  "https://cdn.jsdelivr.net/npm/katex@0.19.0/dist/katex.min.js",
  hljs:     "https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.12.0/highlight.min.js",
  hljsLang: "https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@11.12.0/languages/",
  mermaid:  "https://cdn.jsdelivr.net/npm/mermaid@12.1.0/dist/mermaid.min.js",
  waveSkinDefault: "https://cdn.jsdelivr.net/npm/wavedrom@3.7.0/skins/default.js",
  waveSkinDark:    "https://cdn.jsdelivr.net/npm/wavedrom@3.7.0/skins/dark.js",
  wavedrom: "https://cdn.jsdelivr.net/npm/wavedrom@3.7.0/wavedrom.min.js"
};

/* ---------- dom refs + boilerplate ---------- */
const $id = s => document.getElementById(s);
const content = $id("content"), pageNav = $id("page-nav"), pager = $id("pager"),
      metaEl = $id("doc-meta"), tocNav = $id("toc-nav"), tocBox = $id("toc"),
      tbTitle = $id("tb-title"), trackNav = $id("track-nav");

document.title = CONFIG.title + " · " + CONFIG.org;
$id("brand-sub").textContent = CONFIG.title;
document.querySelectorAll(".wm").forEach(el => { el.textContent = CONFIG.orgMark; });
document.querySelectorAll(".unit-word").forEach(el => { el.textContent = CONFIG.unitWord + "s"; });
document.querySelectorAll(".track-title").forEach(el => { el.textContent = CONFIG.title; });
document.querySelectorAll(".track-tagline").forEach(el => { el.textContent = CONFIG.tagline; });
$id("nav-home").href = CONFIG.mainSite;
$id("nav-main").href = CONFIG.mainSite;
$id("nav-repo").href = CONFIG.repo;
$id("f-repo").href = CONFIG.repo;

/* scroll progress */
(function(){
  const bar = $id("progress");
  function upd(){
    const h = document.documentElement;
    const max = h.scrollHeight - h.clientHeight;
    bar.style.transform = "scaleX(" + (max > 0 ? h.scrollTop / max : 0) + ")";
  }
  addEventListener("scroll", upd, { passive: true });
  addEventListener("resize", upd);
  upd();
})();

/* drawer (mobile) */
(function(){
  const body = document.body;
  $id("drawer-btn").addEventListener("click", () => body.classList.toggle("drawer-open"));
  $id("backdrop").addEventListener("click", () => body.classList.remove("drawer-open"));
  $id("sidebar").addEventListener("click", e => { if (e.target.closest("a")) body.classList.remove("drawer-open"); });
})();

/* other tracks */
(function(){
  if (!trackNav) return;
  if (!CONFIG.tracks || !CONFIG.tracks.length){ trackNav.parentNode.style.display = "none"; return; }
  trackNav.innerHTML = CONFIG.tracks.map(t =>
    '<a href="' + t.url + '"' + (t.title === CONFIG.title ? ' class="here" aria-current="page"' : "") + ">"
    + escHtml(t.title) + "</a>").join("");
})();

/* =========================================================
   markdown renderer
   blocks: headings, paragraphs, fenced code, lists (nested, with
   code inside items), task lists, tables, block quotes, GitHub
   callouts (> [!NOTE]), <details>/<summary>, display math,
   figures with captions and credit lines, hr.
   inline: code, math, links, autolinks, images, emphasis,
   backslash escapes, hard breaks.
   Raw HTML is escaped (only details/summary are understood).
   ========================================================= */
/*__MD_START__*/
var MD_BASE = "", MD_REPO = "", MD_BRANCH = "main";
function setMdBase(base, repo, branch){ MD_BASE = base || ""; MD_REPO = repo || ""; MD_BRANCH = branch || "main"; }

var ESC_MAP = {"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"};
function escHtml(s){ return String(s).replace(/[&<>"']/g, function(m){ return ESC_MAP[m]; }); }

var slugCounts = Object.create(null);
function resetSlugs(){ slugCounts = Object.create(null); }
function slug(text){
  var s = String(text).toLowerCase()
    .replace(/<[^>]*>/g, "")
    .replace(/&[a-z0-9#]+;/g, "")
    .replace(/[`$\\]/g, "")
    .replace(/[^a-z0-9À-ɏ]+/g, "-")
    .replace(/^-+|-+$/g, "") || "section";
  var n = slugCounts[s] || 0; slugCounts[s] = n + 1;
  return n ? s + "-" + n : s;
}

/* ---- paths ---- */
function normPath(p){
  var out = [], trailing = /\/$/.test(p);
  p.split("/").forEach(function(seg){
    if (seg === "" || seg === ".") return;
    if (seg === "..") { out.pop(); return; }
    out.push(seg);
  });
  return out.join("/") + (trailing && out.length ? "/" : "");
}
function isAbsUrl(u){ return /^(?:[a-z][a-z0-9+.-]*:|\/\/|\/|#)/i.test(u); }
function resolveAsset(u){ return isAbsUrl(u) ? u : normPath(MD_BASE + u); }
function resolveLink(u){
  if (isAbsUrl(u)) return u;
  var pm = u.match(/^(?:\.\/)?page[_-]?(\d+)\.md(?:#(.*))?$/i);
  if (pm) return "#page_" + pm[1] + (pm[2] ? "--" + pm[2] : "");
  var hashAt = u.indexOf("#");
  var anchor = hashAt >= 0 ? u.slice(hashAt) : "";
  var path = normPath(MD_BASE + (hashAt >= 0 ? u.slice(0, hashAt) : u));
  if (!MD_REPO) return path + anchor;
  var isDir = /\/$/.test(u.replace(/#.*$/, "")) || !/\.[a-z0-9]+$/i.test(path);
  return MD_REPO + (isDir ? "/tree/" : "/blob/") + MD_BRANCH + "/" + path.replace(/\/$/, "") + anchor;
}

/* ---- inline ---- */
function emphasize(s){
  s = s.replace(/\*\*\*([^*\n]+)\*\*\*/g, "<strong><em>$1</em></strong>");
  s = s.replace(/\*\*([^*\n]+)\*\*/g, "<strong>$1</strong>");
  s = s.replace(/(^|[^\w*])\*([^*\s](?:[^*\n]*[^*\s])?)\*(?![\w*])/g, "$1<em>$2</em>");
  s = s.replace(/(^|[^\w_])_([^_\s](?:[^_\n]*[^_\s])?)_(?![\w_])/g, "$1<em>$2</em>");
  s = s.replace(/~~([^~\n]+)~~/g, "<del>$1</del>");
  return s;
}
function inline(raw){
  var stash = [];
  function keep(h){ stash.push(h); return "\u0001" + (stash.length - 1) + "\u0001"; }
  var s = escHtml(raw);

  /* code spans, any number of backticks */
  s = s.replace(/(`+)([\s\S]*?[^`])\1(?!`)/g, function(m, ticks, code){
    if (/^ [\s\S]* $/.test(code) && /\S/.test(code)) code = code.slice(1, -1);
    return keep("<code>" + code + "</code>");
  });
  /* literal dollar, then inline math */
  s = s.replace(/\\\$/g, function(){ return keep("$"); });
  s = s.replace(/\$(?!\$)([^\s$](?:[^$\n]*?[^\s$\\])?)\$(?![\d$])/g, function(m, tex){
    return keep('<span class="math" data-display="0">' + tex + "</span>");
  });
  /* backslash escapes */
  s = s.replace(/\\(&lt;|&gt;|&amp;|&quot;|&#39;)/g, function(m, e){ return keep(e); });
  s = s.replace(/\\([\\`*_{}\[\]()#+\-.!|~])/g, function(m, ch){ return keep(ch); });
  /* images */
  s = s.replace(/!\[([^\]]*)\]\(\s*(&lt;[^\n]*?&gt;|[^)\s]+)(?:\s+&quot;([^\n]*?)&quot;)?\s*\)/g, function(m, alt, src, title){
    src = src.replace(/^&lt;|&gt;$/g, "");
    return keep('<img src="' + resolveAsset(src) + '" alt="' + alt + '"' + (title ? ' title="' + title + '"' : "")
      + ' loading="lazy" decoding="async" referrerpolicy="no-referrer">');
  });
  /* links (text may hold one level of brackets, e.g. an image) */
  s = s.replace(/\[((?:[^\[\]\n]|\[[^\[\]\n]*\])+)\]\(\s*(&lt;[^\n]*?&gt;|[^)\s]+)(?:\s+&quot;([^\n]*?)&quot;)?\s*\)/g, function(m, text, href, title){
    href = href.replace(/^&lt;|&gt;$/g, "");
    var url = resolveLink(href);
    var ext = /^https?:/i.test(url);
    return keep('<a href="' + url + '"' + (title ? ' title="' + title + '"' : "")
      + (ext ? ' target="_blank" rel="noopener"' : "") + ">" + emphasize(text) + "</a>");
  });
  /* autolinks <https://...> and bare urls */
  s = s.replace(/&lt;(https?:\/\/[^\s<>]+?)&gt;/g, function(m, u){
    return keep('<a href="' + u + '" target="_blank" rel="noopener">' + u + "</a>");
  });
  s = s.replace(/(^|[\s(])(https?:\/\/[^\s<\u0001]*[^\s<\u0001.,;:!?)\]'"])/g, function(m, pre, u){
    return pre + keep('<a href="' + u + '" target="_blank" rel="noopener">' + u + "</a>");
  });
  s = emphasize(s);
  s = s.replace(/\u0002/g, "<br>");
  for (var pass = 0; pass < 6 && s.indexOf("\u0001") !== -1; pass++){
    s = s.replace(/\u0001(\d+)\u0001/g, function(m, i){ return stash[+i]; });
  }
  return s;
}

/* ---- block helpers ---- */
function indentOf(line){
  var n = 0;
  for (var k = 0; k < line.length; k++){
    var c = line.charAt(k);
    if (c === " ") n++;
    else if (c === "\t") n += 4 - (n % 4);
    else break;
  }
  return n;
}
function dedent(line, n){
  var col = 0, k = 0;
  while (k < line.length && col < n){
    var c = line.charAt(k);
    if (c === " "){ col++; k++; }
    else if (c === "\t"){
      var w = 4 - (col % 4);
      if (col + w > n) return new Array(col + w - n + 1).join(" ") + line.slice(k + 1);
      col += w; k++;
    } else break;
  }
  return line.slice(k);
}
function isBlank(l){ return /^\s*$/.test(l); }

var RE_FENCE   = /^( {0,3})(`{3,}|~{3,})\s*([^\s`]*)[^`]*$/;
var RE_HEAD    = /^ {0,3}(#{1,6})[ \t]+(.*?)(?:[ \t]+#+)?[ \t]*$/;
var RE_HR      = /^ {0,3}(?:(?:-[ \t]*){3,}|(?:\*[ \t]*){3,}|(?:_[ \t]*){3,})$/;
var RE_LI      = /^(\s*)([-*+]|\d{1,9}[.)])(?:([ \t]+)(.*))?$/;
var RE_QUOTE   = /^ {0,3}>/;
var RE_DOPEN   = /^\s*<details(\s+open)?\s*>\s*$/i;
var RE_DCLOSE  = /^\s*<\/details>\s*$/i;
var RE_SUMMARY = /^\s*<summary>(.*?)<\/summary>\s*$/i;
var RE_MATH    = /^\s*\$\$/;
var RE_IMGLINE = /^\s*!\[([^\]]*)\]\(\s*(<[^\n]*?>|[^)\s]+)(?:\s+"([^"\n]*)")?\s*\)\s*$/;
var RE_CREDIT  = /^\s*(?:Credit|Image credit|Source):\s+\S/i;
var RE_TABLESEP = /^\s*\|?\s*:?-+:?\s*(?:\|\s*:?-+:?\s*)*\|?\s*$/;
var CALLOUT = { note: "Note", tip: "Tip", important: "Important", warning: "Warning", caution: "Caution" };

function liMatch(line){
  var m = line.match(RE_LI);
  if (!m || RE_HR.test(line)) return null;
  var ind = indentOf(m[1]);
  var ordered = /^\d/.test(m[2]);
  var gap = m[3] ? indentOf(m[1] + m[2] + m[3]) - indentOf(m[1] + m[2]) : 1;
  if (!m[3] && m[4] === undefined) gap = 1;
  if (gap > 4) gap = 1;                       /* indented code inside an item: treat as text */
  return {
    ind: ind, ordered: ordered,
    start: ordered ? parseInt(m[2], 10) : 1,
    delim: ordered ? m[2].slice(-1) : m[2],
    contentInd: ind + m[2].length + gap,
    text: m[4] || ""
  };
}
function startsBlock(line, inPara){
  if (RE_FENCE.test(line) || RE_HEAD.test(line) || RE_HR.test(line) || RE_QUOTE.test(line)
      || RE_DOPEN.test(line) || RE_MATH.test(line)) return true;
  var li = liMatch(line);
  if (li && li.ind < 4){
    if (!inPara) return true;
    return li.text !== "" && (!li.ordered || li.start === 1);
  }
  return false;
}
function splitRow(row){
  var r = row.trim().replace(/\\\|/g, "\u0003");
  if (r.charAt(0) === "|") r = r.slice(1);
  if (r.charAt(r.length - 1) === "|") r = r.slice(0, -1);
  return r.split("|").map(function(c){ return c.trim().replace(/\u0003/g, "|"); });
}
function codeBlock(lang, code){
  var l = (lang || "").toLowerCase();
  if (l === "math") return '<div class="math math-display" data-display="1">' + escHtml(code) + "</div>";
  if (l === "mermaid") return '<div class="diagram mermaid-wrap"><pre class="mermaid">' + escHtml(code) + "</pre></div>";
  if (l === "wavedrom") return '<div class="diagram wavedrom-wrap"><pre class="wavedrom-src">' + escHtml(code) + "</pre></div>";
  return '<figure class="codeblock"><figcaption><span class="dot"></span><span class="lang">' + escHtml(lang || "text")
    + '</span><button type="button" class="copy">copy</button></figcaption><pre><code'
    + (l ? ' class="language-' + escHtml(l) + '"' : "") + ">" + escHtml(code) + "</code></pre></figure>";
}

/* ---- block parser ---- */
function renderBlocks(lines){
  var out = [], para = [], i = 0, n = lines.length;
  function flush(){
    if (!para.length) return;
    var txt = para.map(function(l, k){
      var hard = k < para.length - 1 && (/ {2,}$/.test(l) || /\\$/.test(l));
      l = l.replace(/^\s+/, "");
      if (hard) l = l.replace(/(?: {2,}|\\)$/, "") + "\u0002";
      else l = l.replace(/\s+$/, "");
      return l;
    }).join("\n").replace(/\u0002\n/g, "\u0002").replace(/\n/g, " ");
    out.push("<p>" + inline(txt) + "</p>");
    para = [];
  }

  while (i < n){
    var line = lines[i];

    /* fenced code */
    var f = line.match(RE_FENCE);
    if (f){
      flush();
      var fInd = f[1].length, fch = f[2].charAt(0), flen = f[2].length, lang = f[3] || "", buf = [];
      i++;
      while (i < n){
        var cl = lines[i].match(/^ {0,3}(`{3,}|~{3,})\s*$/);
        if (cl && cl[1].charAt(0) === fch && cl[1].length >= flen) { i++; break; }
        buf.push(dedent(lines[i], fInd));
        i++;
      }
      out.push(codeBlock(lang, buf.join("\n")));
      continue;
    }

    if (isBlank(line)){ flush(); i++; continue; }

    /* <details> */
    if (RE_DOPEN.test(line)){
      flush();
      var open = /open/i.test(line), depth = 1, body = [];
      i++;
      while (i < n){
        if (RE_DOPEN.test(lines[i])) depth++;
        else if (RE_DCLOSE.test(lines[i])){ depth--; if (depth === 0){ i++; break; } }
        body.push(lines[i]); i++;
      }
      var summary = "Details";
      for (var b = 0; b < body.length; b++){
        if (isBlank(body[b])) continue;
        var sm = body[b].match(RE_SUMMARY);
        if (sm){ summary = sm[1]; body.splice(b, 1); }
        break;
      }
      out.push('<details class="fold"' + (open ? " open" : "") + "><summary>" + inline(summary)
        + '</summary><div class="fold-body">' + renderBlocks(body) + "</div></details>");
      continue;
    }

    /* display math $$ ... $$ */
    if (RE_MATH.test(line)){
      flush();
      var t = line.trim(), tex;
      if (t.length > 4 && /\$\$$/.test(t)){ tex = t.slice(2, -2); i++; }
      else {
        var mb = [t.slice(2)]; i++;
        while (i < n && !/\$\$\s*$/.test(lines[i])){ mb.push(lines[i]); i++; }
        if (i < n){ mb.push(lines[i].replace(/\$\$\s*$/, "")); i++; }
        tex = mb.join("\n");
      }
      out.push('<div class="math math-display" data-display="1">' + escHtml(tex.trim()) + "</div>");
      continue;
    }

    /* heading */
    var h = line.match(RE_HEAD);
    if (h){
      flush();
      var lvl = h[1].length, htxt = h[2].trim(), hid = slug(htxt);
      out.push("<h" + lvl + ' id="' + hid + '">' + inline(htxt) + '<a class="hlink" href="#' + hid + '" aria-hidden="true">#</a></h' + lvl + ">");
      i++; continue;
    }

    /* table */
    if (!para.length && line.indexOf("|") !== -1 && i + 1 < n && lines[i + 1].indexOf("-") !== -1 && RE_TABLESEP.test(lines[i + 1])){
      var head = splitRow(line);
      var aligns = splitRow(lines[i + 1]).map(function(c){
        var al = /^:/.test(c), ar = /:$/.test(c);
        return al && ar ? "center" : ar ? "right" : "";
      });
      i += 2;
      var rows = [];
      while (i < n && lines[i].indexOf("|") !== -1 && !isBlank(lines[i])){ rows.push(splitRow(lines[i])); i++; }
      var alAttr = function(k){ return aligns[k] ? ' style="text-align:' + aligns[k] + '"' : ""; };
      out.push('<div class="tablewrap"><table><thead><tr>'
        + head.map(function(c, k){ return "<th" + alAttr(k) + ">" + inline(c) + "</th>"; }).join("")
        + "</tr></thead><tbody>"
        + rows.map(function(r){ return "<tr>" + head.map(function(_, k){ return "<td" + alAttr(k) + ">" + inline(r[k] || "") + "</td>"; }).join("") + "</tr>"; }).join("")
        + "</tbody></table></div>");
      continue;
    }

    /* horizontal rule */
    if (RE_HR.test(line)){ flush(); out.push("<hr>"); i++; continue; }

    /* block quote and callouts */
    if (RE_QUOTE.test(line)){
      flush();
      var q = [];
      while (i < n && RE_QUOTE.test(lines[i])){ q.push(lines[i].replace(/^ {0,3}> ?/, "")); i++; }
      var kind = q.length && q[0].match(/^\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*$/i);
      if (kind){
        var kk = kind[1].toLowerCase();
        out.push('<div class="callout callout-' + kk + '"><p class="callout-title">' + CALLOUT[kk] + "</p>" + renderBlocks(q.slice(1)) + "</div>");
      } else {
        out.push("<blockquote>" + renderBlocks(q) + "</blockquote>");
      }
      continue;
    }

    /* lists */
    var li = liMatch(line);
    if (li && li.ind < 4 && (!para.length || startsBlock(line, true))){
      flush();
      var first = li, items = [], cur = null, loose = false;
      while (i < n){
        var ln = lines[i], m2 = liMatch(ln);
        if (m2 && m2.ordered === first.ordered && m2.delim === first.delim
            && m2.ind < (cur ? cur.contentInd : first.contentInd) && m2.ind >= first.ind - 3){
          cur = { lines: [m2.text], contentInd: m2.contentInd, blankInside: false };
          items.push(cur); i++; continue;
        }
        if (isBlank(ln)){
          var j = i + 1;
          while (j < n && isBlank(lines[j])) j++;
          if (j >= n) break;
          var nx = liMatch(lines[j]);
          var nextIsItem = nx && nx.ordered === first.ordered && nx.delim === first.delim && nx.ind < cur.contentInd && nx.ind >= first.ind - 3;
          if (indentOf(lines[j]) >= cur.contentInd){
            for (var bb = i; bb < j; bb++) cur.lines.push("");
            cur.blankInside = true; i = j; continue;
          }
          if (nextIsItem){ loose = true; i = j; continue; }
          break;
        }
        if (indentOf(ln) >= cur.contentInd){ cur.lines.push(dedent(ln, cur.contentInd)); i++; continue; }
        /* lazy paragraph continuation */
        var prev = cur.lines[cur.lines.length - 1];
        if (prev !== undefined && !isBlank(prev) && !startsBlock(ln, true) && !RE_FENCE.test(prev)){
          cur.lines.push(ln.trim()); i++; continue;
        }
        break;
      }
      var tag = first.ordered ? "ol" : "ul";
      var html = "<" + tag + (first.ordered && first.start !== 1 ? ' start="' + first.start + '"' : "") + ">";
      items.forEach(function(it){
        if (it.blankInside) loose = true;
      });
      items.forEach(function(it){
        var task = it.lines[0].match(/^\[([ xX])\]\s+(.*)$/);
        if (task) it.lines[0] = task[2];
        var inner = renderBlocks(it.lines);
        if (!loose) inner = inner.replace(/^<p>([\s\S]*?)<\/p>/, "$1");
        html += task
          ? '<li class="task"><input type="checkbox" disabled' + (/x/i.test(task[1]) ? " checked" : "") + "><div>" + inner + "</div></li>"
          : "<li>" + inner + "</li>";
      });
      out.push(html + "</" + tag + ">");
      continue;
    }

    /* figure: an image alone on its line, optional credit line below */
    var im = !para.length && line.match(RE_IMGLINE);
    if (im){
      var src = im[2].replace(/^<|>$/g, ""), alt = im[1], cap = im[3] || alt, credit = "";
      var k2 = i + 1;
      if (k2 < n && isBlank(lines[k2])) k2++;
      if (k2 < n && RE_CREDIT.test(lines[k2])){ credit = lines[k2].trim(); i = k2 + 1; }
      else i++;
      var url = escHtml(resolveAsset(src));
      out.push('<figure class="img"><a class="img-link" href="' + url + '" target="_blank" rel="noopener"><img src="' + url
        + '" alt="' + escHtml(alt) + '" loading="lazy" decoding="async" referrerpolicy="no-referrer"></a>'
        + (cap || credit ? "<figcaption>" + (cap ? '<span class="cap">' + inline(cap) + "</span>" : "")
        + (credit ? '<span class="credit">' + inline(credit) + "</span>" : "") + "</figcaption>" : "")
        + "</figure>");
      continue;
    }

    /* paragraph text */
    if (para.length && startsBlock(line, true)){ flush(); continue; }
    para.push(line); i++;
  }
  flush();
  return out.join("\n");
}
function mdToHtml(src){
  src = String(src).replace(/^﻿/, "").replace(/\r\n?/g, "\n").replace(/<!--[\s\S]*?-->/g, "");
  return renderBlocks(src.split("\n"));
}
/*__MD_END__*/

/* =========================================================
   lazy loaders + page enhancements
   ========================================================= */
const loaded = {};
function loadScript(url){
  if (!loaded[url]) loaded[url] = new Promise((res, rej) => {
    const s = document.createElement("script");
    s.src = url; s.async = true; s.crossOrigin = "anonymous";
    s.onload = () => res(); s.onerror = () => rej(new Error("failed to load " + url));
    document.head.appendChild(s);
  });
  return loaded[url];
}
function loadCss(url){
  if (!loaded[url]) loaded[url] = new Promise(res => {
    const l = document.createElement("link");
    l.rel = "stylesheet"; l.href = url; l.crossOrigin = "anonymous";
    l.onload = () => res(); l.onerror = () => res();
    document.head.appendChild(l);
  });
  return loaded[url];
}

function renderMath(root){
  loadCss(LIB.katexCss);
  return loadScript(LIB.katexJs).then(() => {
    root.querySelectorAll(".math").forEach(el => {
      if (el.dataset.done) return;
      const tex = el.textContent;
      try {
        window.katex.render(tex, el, { displayMode: el.dataset.display === "1", throwOnError: false, output: "htmlAndMathml" });
        el.dataset.done = "1";
        el.classList.add("rendered");
      } catch (e) { /* leave the TeX source visible */ }
    });
  });
}

const HL_ALIAS = { v: "verilog", sv: "verilog", verilog: "verilog", systemverilog: "verilog", vlog: "verilog",
  sh: "bash", bash: "bash", shell: "bash", console: "bash", zsh: "bash",
  py: "python", python: "python", tcl: "tcl", sdc: "tcl", xdc: "tcl",
  json: "json", yaml: "yaml", yml: "yaml", make: "makefile", makefile: "makefile", ini: "ini", cfg: "ini", toml: "ini" };
function highlightCode(root){
  const blocks = [...root.querySelectorAll("pre code[class*='language-']")];
  const wanted = new Set();
  blocks.forEach(c => { const l = HL_ALIAS[c.className.replace(/^.*language-/, "")]; if (l) wanted.add(l); });
  if (!wanted.size) return Promise.resolve();
  return loadScript(LIB.hljs).then(() => {
    const extra = ["verilog", "tcl"].filter(l => wanted.has(l)).map(l => loadScript(LIB.hljsLang + l + ".min.js"));
    return Promise.all(extra.map(p => p.catch(() => null)));
  }).then(() => {
    blocks.forEach(c => {
      const l = HL_ALIAS[c.className.replace(/^.*language-/, "")];
      if (!l || !window.hljs || !window.hljs.getLanguage(l)) return;
      c.className = "language-" + l;
      try { window.hljs.highlightElement(c); } catch (e) {}
    });
  });
}

let mermaidReady = false;
function renderMermaid(root){
  return loadScript(LIB.mermaid).then(() => {
    if (!mermaidReady){
      window.mermaid.initialize({
        startOnLoad: false, securityLevel: "strict", theme: "base",
        fontFamily: "Karla, system-ui, sans-serif",
        themeVariables: {
          background: "#1C1216", primaryColor: "#2A1218", primaryTextColor: "#F7EFE9",
          primaryBorderColor: "#FFCC33", lineColor: "#D8A93F", secondaryColor: "#180F12",
          tertiaryColor: "#1C1216", textColor: "#F7EFE9", mainBkg: "#2A1218", nodeBorder: "#FFCC33",
          clusterBkg: "#180F12", clusterBorder: "#4A3138", edgeLabelBackground: "#1C1216",
          labelBackground: "#1C1216", stateBkg: "#2A1218", transitionColor: "#D8A93F",
          stateLabelColor: "#F7EFE9", nodeTextColor: "#F7EFE9", titleColor: "#F7EFE9"
        }
      });
      mermaidReady = true;
    }
    const nodes = [...root.querySelectorAll("pre.mermaid")].filter(n => !n.dataset.processed);
    return nodes.length ? window.mermaid.run({ nodes: nodes }) : null;
  }).then(() => {
    root.querySelectorAll(".mermaid-wrap").forEach(w => { if (w.querySelector("svg")) w.classList.add("rendered"); });
  });
}

let waveCount = 0;
function renderWavedrom(root){
  return loadScript(LIB.waveSkinDefault)
    .then(() => loadScript(LIB.waveSkinDark))
    .then(() => loadScript(LIB.wavedrom))
    .then(() => {
      root.querySelectorAll(".wavedrom-wrap").forEach(w => {
        if (w.classList.contains("rendered")) return;
        const srcText = w.querySelector(".wavedrom-src").textContent;
        let obj;
        try { obj = (new Function("return (" + srcText + ");"))(); }
        catch (e) { w.classList.add("diagram-error"); return; }
        obj.config = obj.config || {};
        if (!obj.config.skin) obj.config.skin = "dark";
        const idx = waveCount++;
        const out = document.createElement("div");
        out.className = "wavedrom-out";
        out.id = "wavedrom-out-" + idx;
        w.appendChild(out);
        try { window.WaveDrom.RenderWaveForm(idx, obj, "wavedrom-out-"); w.classList.add("rendered"); }
        catch (e) { out.remove(); w.classList.add("diagram-error"); }
      });
    });
}

function bindImages(root){
  root.querySelectorAll("img").forEach(img => {
    const fail = () => {
      if (img.dataset.failed) return;
      img.dataset.failed = "1";
      const box = document.createElement("span");
      box.className = "img-missing";
      box.innerHTML = "This image did not load. <a href=\"" + escHtml(img.src) + "\" target=\"_blank\" rel=\"noopener\">Open it at the source</a>.";
      (img.closest("a.img-link") || img).replaceWith(box);
    };
    img.addEventListener("error", fail, { once: true });
    if (img.complete && img.naturalWidth === 0 && img.getAttribute("src")) setTimeout(() => { if (img.naturalWidth === 0 && img.complete) fail(); }, 0);
  });
}

function bindCopy(){
  content.querySelectorAll(".codeblock .copy").forEach(btn => {
    btn.addEventListener("click", () => {
      const code = btn.closest(".codeblock").querySelector("code").textContent;
      const done = () => { btn.textContent = "copied"; setTimeout(() => { btn.textContent = "copy"; }, 1400); };
      if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(code).then(done, () => {});
    });
  });
}

function enhance(root){
  const jobs = [];
  if (root.querySelector(".math")) jobs.push(renderMath(root));
  if (root.querySelector("pre code[class*='language-']")) jobs.push(highlightCode(root));
  if (root.querySelector("pre.mermaid")) jobs.push(renderMermaid(root));
  if (root.querySelector(".wavedrom-wrap")) jobs.push(renderWavedrom(root));
  bindImages(root);
  return Promise.all(jobs.map(p => p.catch(e => { console.warn("[course]", e.message || e); })));
}

/* =========================================================
   pages: discovery, rendering, routing
   ========================================================= */
const PDIR = CONFIG.pagesDir ? CONFIG.pagesDir.replace(/\/+$/, "") + "/" : "";
setMdBase(PDIR, CONFIG.repo, CONFIG.branch);

function titleOf(src, n){
  const m = String(src).replace(/\r/g, "").match(/^#\s+(.+)$/m);
  return m ? m[1].replace(/\s+#+\s*$/, "").trim() : "Page " + n;
}
function plainTitle(t){ return t.replace(/[`*_]/g, "").replace(/\$([^$]+)\$/g, "$1"); }

async function discoverPages(){
  const pages = [];
  const B = 6;
  for (let s = 1; s <= CONFIG.maxPages; s += B){
    const ns = [];
    for (let k = 0; k < B && s + k <= CONFIG.maxPages; k++) ns.push(s + k);
    const got = await Promise.all(ns.map(n =>
      fetch(PDIR + "page_" + n + ".md", { cache: "no-cache" })
        .then(r => r.ok ? r.text() : null)
        .catch(() => null)));
    let gap = false;
    got.forEach((txt, k) => {
      if (gap) return;
      if (txt == null){ gap = true; return; }
      pages.push({ n: ns[k], src: txt, title: plainTitle(titleOf(txt, ns[k])) });
    });
    if (gap) break;
  }
  return pages;
}

let PAGES = [], CUR = -1;
const pad = n => String(n).padStart(2, "0");
const shortTitle = t => t.replace(/^(lesson|page)\s+\d+\s*[:.\-]\s*/i, "");

function renderNav(active){
  pageNav.innerHTML = PAGES.map((p, k) =>
    '<a href="#page_' + p.n + '"' + (k === active ? ' class="active" aria-current="page"' : "") + ">"
    + '<span class="pn">' + pad(p.n) + "</span><span>" + escHtml(shortTitle(p.title)) + "</span></a>").join("");
}
function renderPager(k){
  const prev = PAGES[k - 1], next = PAGES[k + 1];
  pager.innerHTML =
    (prev ? '<a class="pg prev" href="#page_' + prev.n + '"><span>&larr; Previous</span><b>' + escHtml(shortTitle(prev.title)) + "</b></a>" : "<span></span>")
    + (next ? '<a class="pg next" href="#page_' + next.n + '"><span>Next &rarr;</span><b>' + escHtml(shortTitle(next.title)) + "</b></a>" : "<span></span>");
}
let spy = null;
function buildToc(pn){
  const hs = Array.from(content.querySelectorAll("h2, h3"));
  tocBox.style.display = hs.length ? "" : "none";
  tocNav.innerHTML = hs.map(h => {
    const c = h.cloneNode(true);
    const a = c.querySelector(".hlink"); if (a) a.remove();
    return '<a class="t-' + h.tagName.toLowerCase() + '" data-id="' + h.id + '" href="#page_' + pn + "--" + h.id + '">' + escHtml(c.textContent.trim()) + "</a>";
  }).join("");
  if (spy) spy.disconnect();
  if (!("IntersectionObserver" in window) || !hs.length) return;
  const links = tocNav.querySelectorAll("a");
  spy = new IntersectionObserver(es => {
    es.forEach(e => {
      if (e.isIntersecting) links.forEach(l => l.classList.toggle("active", l.dataset.id === e.target.id));
    });
  }, { rootMargin: "-80px 0px -70% 0px" });
  hs.forEach(h => spy.observe(h));
}
function localizeAnchors(pn){
  content.querySelectorAll('a[href^="#"]').forEach(a => {
    const h = a.getAttribute("href");
    if (/^#page[_-]\d+/i.test(h) || h === "#") return;
    a.setAttribute("href", "#page_" + pn + "--" + h.slice(1));
  });
}
function scrollToAnchor(id){
  if (!id) return false;
  const el = document.getElementById(decodeURIComponent(id));
  if (el){ el.scrollIntoView(); return true; }
  return false;
}
function renderPage(k, anchor){
  const p = PAGES[k];
  CUR = k;
  resetSlugs();
  content.innerHTML = mdToHtml(p.src);
  localizeAnchors(p.n);
  document.title = shortTitle(p.title) + " · " + CONFIG.title;
  tbTitle.textContent = shortTitle(p.title);
  metaEl.style.display = "";
  metaEl.innerHTML = '<span class="pgno">' + CONFIG.unitWord + " " + pad(p.n) + " / " + pad(PAGES[PAGES.length - 1].n) + "</span>"
    + '<a class="edit" target="_blank" rel="noopener" href="' + CONFIG.repo + "/edit/" + CONFIG.branch + "/" + PDIR + "page_" + p.n + '.md">edit this page on github &nearr;</a>';
  renderNav(k); renderPager(k); buildToc(p.n); bindCopy();
  if (!scrollToAnchor(anchor)) { try { window.scrollTo(0, 0); } catch (e) {} }
  enhance(content).then(() => { if (anchor) scrollToAnchor(anchor); });
}
function renderEmpty(){
  const isFile = location.protocol === "file:";
  pageNav.innerHTML = "";
  metaEl.style.display = "none";
  tocBox.style.display = "none";
  tbTitle.textContent = "No lessons yet";
  content.innerHTML = '<div class="state-card"><h2>Start the first lesson</h2>'
    + "<p>This site builds itself from <code>Pages/page_1.md</code>, <code>Pages/page_2.md</code>, &hellip; Copy <code>Pages/TEMPLATE.md</code> to <code>Pages/page_1.md</code>, write the lesson, and reload. Numbering has to run in sequence with no gaps.</p>"
    + (isFile ? "<p>You opened this file directly. <code>fetch()</code> needs a server: run <code>python3 -m http.server</code> in this folder and open <code>http://localhost:8000</code>.</p>" : "")
    + "</div>";
}

/* ---------- routing: #page_3 or #page_3--heading-id ---------- */
function parseHash(){
  const m = location.hash.match(/^#page[_-](\d+)(?:--(.+))?$/i);
  return m ? { n: +m[1], anchor: m[2] || "" } : null;
}
function route(){
  if (!PAGES.length) return;
  const h = parseHash();
  if (!h){
    if (location.hash && scrollToAnchor(location.hash.slice(1))) return;
    if (CUR < 0) renderPage(0);
    return;
  }
  const k = PAGES.findIndex(p => p.n === h.n);
  const idx = k >= 0 ? k : 0;
  if (idx !== CUR) renderPage(idx, h.anchor);
  else if (!scrollToAnchor(h.anchor)) { try { window.scrollTo(0, 0); } catch (e) {} }
}
addEventListener("hashchange", route);

(async function init(){
  PAGES = await discoverPages();
  if (!PAGES.length){ renderEmpty(); return; }
  route();
  if (CUR < 0) renderPage(0);
})();
