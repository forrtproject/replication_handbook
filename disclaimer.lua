-- Inject a callout at the start of each top-level chapter
function Pandoc(doc)
  local meta = doc.meta
  local ver = pandoc.utils.stringify(meta.version or "0.1")
  local email = pandoc.utils.stringify(meta.feedback_email or "lukas.roeseler@uni-muenster.de")
  local gh = pandoc.utils.stringify(meta.feedback_github or "https://github.com/forrtproject/replication_handbook/issues")

  local md = ([[
::: {.callout-warning collapse="false"}
**Preliminary Version %s**

We welcome feedback — email [%s](mailto:%s) or open an issue on [GitHub](%s).
:::
]]):format(ver, email, email, gh)

  local callout_blocks = pandoc.read(md, "markdown").blocks

  -- Prepend to each top-level file (chapters)
  local new_blocks = pandoc.List()
  -- Optionally skip index.qmd: detect by title if you want
  for i, blk in ipairs(doc.blocks) do
    if i == 1 then
      for _, b in ipairs(callout_blocks) do new_blocks:insert(b) end
    end
    new_blocks:insert(blk)
  end
  doc.blocks = new_blocks
  return doc
end
