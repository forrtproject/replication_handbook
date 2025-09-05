-- disclaimer.lua — inject disclaimer as callout in every chapter

local ver, email, gh

function Meta(m)
  ver   = pandoc.utils.stringify(m.version or "0.1")
  email = pandoc.utils.stringify(m.feedback_email or "info@forrt.org")
  gh    = pandoc.utils.stringify(m.feedback_github or "https://github.com/URL")
end

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

-- Use only Header hook (works for HTML & PDF)
function Header(el)
  if el.level == 1 then
    return { el, callout_block() }
  end
end
