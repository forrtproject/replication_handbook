-- disclaimer.lua — exactly one box per chapter file

local ver   = "0.1"
local email = "info@forrt.org"
local gh    = "https://github.com/URL"

function Meta(m)
  if m.version then ver = pandoc.utils.stringify(m.version) end
  if m.feedback_email then email = pandoc.utils.stringify(m.feedback_email) end
  if m.feedback_github then gh = pandoc.utils.stringify(m.feedback_github) end
end

local function html_box()
  local html = ([[<div class="callout callout-warning">
  <div class="callout-header">Preliminary Version %s</div>
  <div class="callout-body">
    This is a preliminary version. Feedback welcome —
    <a href="mailto:%s">%s</a> or <a href="%s">GitHub</a>.
  </div>
</div>]]):format(ver, email, email, gh)
  return pandoc.RawBlock("html", html)
end

local function latex_box()
  local tex = ([[\begin{tcolorbox}[breakable,enhanced,skin=enhancedmiddle,
  colback=white, colframe=black, title={Preliminary Version %s}]
This is a preliminary version. Feedback welcome — \href{mailto:%s}{%s} or \href{%s}{GitHub}.
\end{tcolorbox}]]):format(ver, email, email, gh)
  return pandoc.RawBlock("latex", tex)
end

local function make_box()
  if FORMAT:match("html") then return html_box()
  elseif FORMAT:match("latex") then return latex_box()
  else
    return pandoc.Para{
      pandoc.Strong{ pandoc.Str("Preliminary Version " .. ver .. ": ") },
      pandoc.Str("Feedback — " .. email .. " or " .. gh)
    }
  end
end

function Pandoc(doc)
  local blocks = doc.blocks
  local inserted = false

  -- find first H1; insert right after it
  for i, blk in ipairs(blocks) do
    if blk.t == "Header" and blk.level == 1 then
      table.insert(blocks, i + 1, make_box())
      inserted = true
      break
    end
  end

  -- if no H1 in this file, insert at top
  if not inserted then
    table.insert(blocks, 1, make_box())
  end

  doc.blocks = blocks
  return doc
end
