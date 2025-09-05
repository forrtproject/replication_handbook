-- disclaimer.lua — Quarto-style orange "Note" in HTML; orange tcolorbox in PDF
-- Inserts AFTER EVERY chapter H1 (skips parts). Works when Quarto concatenates files for PDF.

local ver   = "0.1"
local email = "info@forrt.org"
local gh    = "https://github.com/URL"

-- Set true to skip the very first chapter header (e.g., index/preface)
local SKIP_FIRST = false
local seen_h1 = false

function Meta(m)
  if m.version         then ver   = pandoc.utils.stringify(m.version) end
  if m.feedback_email  then email = pandoc.utils.stringify(m.feedback_email) end
  if m.feedback_github then gh    = pandoc.utils.stringify(m.feedback_github) end
end

-- Heuristics to avoid firing on "Part" titles
local function has_class(el, name)
  if not el or not el.classes then return false end
  for _, c in ipairs(el.classes) do if c == name then return true end end
  return false
end
local function is_part_header(h)
  return h.level == 1 and (has_class(h, "part") or has_class(h, "part-title"))
end
local function is_raw_part_block(b)
  return b.t == "RawBlock"
     and b.format == "latex"
     and b.text:match("\\part%s*%b{}") ~= nil
end

local function html_box()
  -- Orange style via callout-warning; title label reads "Note"
  local html = ([[<div class="callout callout-style-default callout-warning callout-titled" style="margin-top:1rem">
<div class="callout-header d-flex align-content-center">
  <div class="callout-icon-container"><i class="callout-icon"></i></div>
  <div class="callout-title-container flex-fill">
    <span class="screen-reader-only">Note</span> — Preliminary Version %s
  </div>
</div>
<div class="callout-body-container callout-body">
  <p>This is a preliminary version. Feedback welcome:
  <a href="mailto:%s">%s</a> or <a href="%s">GitHub</a>.</p>
</div>
</div>]]):format(ver, email, email, gh)
  return pandoc.RawBlock("html", html)
end

local function latex_box()
  -- Orange tcolorbox (requires \usepackage[skins,breakable]{tcolorbox})
  local tex = ([[\begin{tcolorbox}[breakable,enhanced,skin=enhancedmiddle,
  colback=orange!5, colframe=orange!60!black, title={Note — Preliminary Version %s}]
This is a preliminary version. Feedback welcome: \href{mailto:%s}{%s} or \href{%s}{GitHub}.
\end{tcolorbox}]]):format(ver, email, email, gh)
  return pandoc.RawBlock("latex", tex)
end

local function make_box()
  if FORMAT:match("html") then return html_box()
  elseif FORMAT:match("latex") then return latex_box()
  else
    return pandoc.Para{
      pandoc.Strong{ pandoc.Str("Note — Preliminary Version " .. ver .. ": ") },
      pandoc.Str("Feedback — " .. email .. " or " .. gh)
    }
  end
end

function Pandoc(doc)
  local blocks = pandoc.List(doc.blocks)
  -- If document starts with a LaTeX \part{...}, don't inject there
  if #blocks > 0 and is_raw_part_block(blocks[1]) then
    -- continue; we’ll still inject after chapter H1s below
  end

  -- Walk headers and insert after EVERY chapter-level H1 that isn’t a Part
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    if b.t == "Header" and b.level == 1 and not is_part_header(b) then
      if SKIP_FIRST and not seen_h1 then
        seen_h1 = true
        -- skip injection for the very first H1 only
      else
        blocks:insert(i + 1, make_box())
      end
      seen_h1 = true
      i = i + 1 -- skip over the inserted box
    end
    i = i + 1
  end

  -- If a chapter file had no H1 at all (title only in YAML), prepend once
  if not seen_h1 then
    blocks:insert(1, make_box())
  end

  doc.blocks = blocks
  return doc
end
