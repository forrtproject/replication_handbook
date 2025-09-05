-- disclaimer.lua — inject callout after every H1; safe defaults prevent nil concat

-- Safe defaults (used if metadata not provided)
local ver   = "0.1"
local email = "lukas.roeseler@uni-muenster.de"
local gh    = "https://github.com/forrtproject/replication_handbook/issues"

-- Optional: skip the very first H1 (index/preface)
local SKIP_FIRST = false
local seen_h1 = false

local function callout_block()
  local title = pandoc.Para({ pandoc.Strong(pandoc.Str("Preliminary Version " .. ver)) })
  local body = pandoc.Para({
    pandoc.Str("We welcome feedback — email "),
    pandoc.Link({ pandoc.Str(email) }, "mailto:" .. email),
    pandoc.Str(" or open an issue on "),
    pandoc.Link({ pandoc.Str("GitHub") }, gh),
    pandoc.Str(".")
  })
  return pandoc.Div(
    { title, body },
    pandoc.Attr("", { "callout", "callout-warning" }, { collapse = "false" })
  )
end

function Meta(m)
  -- Override defaults if provided in project/book YAML
  if m.version then
    ver = pandoc.utils.stringify(m.version)
  end
  if m.feedback_email then
    email = pandoc.utils.stringify(m.feedback_email)
  end
  if m.feedback_github then
    gh = pandoc.utils.stringify(m.feedback_github)
  end
end

function Header(el)
  if el.level == 1 then
    if SKIP_FIRST and not seen_h1 then
      seen_h1 = true
      return nil
    end
    seen_h1 = true
    return { el, callout_block() }
  end
end
