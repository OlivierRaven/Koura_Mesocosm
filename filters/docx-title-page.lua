-- docx-title-page.lua
--
-- Pandoc's docx writer only stringifies author names; it drops affiliations,
-- ORCID, and the corresponding-author marker that the html/pdf writers render
-- automatically. This filter reads the same `author`/`abstract`/`keywords`
-- metadata used by the other formats and builds an equivalent title block
-- for docx, with numbered affiliations assigned in first-appearance order.

local stringify = pandoc.utils.stringify

local function get_name(author)
  if author.name then
    if author.name.given or author.name.family then
      local given = author.name.given and stringify(author.name.given) or ""
      local family = author.name.family and stringify(author.name.family) or ""
      return (given .. " " .. family):gsub("^%s+", ""):gsub("%s+$", "")
    else
      return stringify(author.name)
    end
  end
  return ""
end

local function affil_key(affil)
  local parts = {}
  for _, field in ipairs({"name", "department", "address", "country"}) do
    if affil[field] then table.insert(parts, stringify(affil[field])) end
  end
  return table.concat(parts, ", ")
end

function Pandoc(doc)
  if not quarto.doc.is_format("docx") then
    return doc
  end

  local meta = doc.meta
  if not meta.author then
    return doc
  end

  -- Build affiliation registry in first-appearance order
  local affil_order = {}
  local affil_number = {}

  local function register_affil(affil)
    local key = affil_key(affil)
    if not affil_number[key] then
      table.insert(affil_order, key)
      affil_number[key] = #affil_order
    end
    return affil_number[key]
  end

  local new_blocks = {}
  local corresponding_email = nil

  -- Author lines, each on its own line via a hard line break
  local author_inlines = {}
  for _, author in ipairs(meta.author) do
    local name = get_name(author)
    local nums = {}
    if author.affiliations then
      for _, affil in ipairs(author.affiliations) do
        table.insert(nums, tostring(register_affil(affil)))
      end
    end

    local sup_inlines = {}
    for i, n in ipairs(nums) do
      if i > 1 then table.insert(sup_inlines, pandoc.Str(",")) end
      table.insert(sup_inlines, pandoc.Str(n))
    end
    if author.corresponding then
      table.insert(sup_inlines, pandoc.Str("*"))
      if author.email then corresponding_email = stringify(author.email) end
    end

    table.insert(author_inlines, pandoc.Str(name))
    if #sup_inlines > 0 then
      table.insert(author_inlines, pandoc.Superscript(sup_inlines))
    end
    if author.orcid then
      table.insert(author_inlines, pandoc.Str(", " .. stringify(author.orcid)))
    end
    table.insert(author_inlines, pandoc.LineBreak())
  end
  table.remove(author_inlines) -- drop trailing line break
  table.insert(new_blocks, pandoc.Para(author_inlines))

  -- Numbered affiliation list
  local affil_inlines = {}
  for i, key in ipairs(affil_order) do
    if i > 1 then table.insert(affil_inlines, pandoc.LineBreak()) end
    table.insert(affil_inlines, pandoc.Superscript({ pandoc.Str(tostring(i)) }))
    table.insert(affil_inlines, pandoc.Str(" " .. key))
  end
  table.insert(new_blocks, pandoc.Para(affil_inlines))

  -- Corresponding author line
  if corresponding_email then
    table.insert(new_blocks, pandoc.Para({
      pandoc.Str("*Corresponding author: " .. corresponding_email)
    }))
  end

  -- Abstract (kept as parsed inlines so *italics* etc. are preserved)
  if meta.abstract then
    table.insert(new_blocks, pandoc.Header(2, { pandoc.Str("Abstract") }))
    table.insert(new_blocks, pandoc.Para(meta.abstract))
  end

  -- Keywords
  if meta.keywords then
    local kw_inlines = { pandoc.Strong({ pandoc.Str("Key words:") }), pandoc.Str(" ") }
    for i, kw in ipairs(meta.keywords) do
      if i > 1 then table.insert(kw_inlines, pandoc.Str("; ")) end
      table.insert(kw_inlines, pandoc.Span(kw))
    end
    table.insert(new_blocks, pandoc.Para(kw_inlines))
  end

  -- Prepend the generated title block to the document body
  for i = #new_blocks, 1, -1 do
    table.insert(doc.blocks, 1, new_blocks[i])
  end

  -- Suppress pandoc's own plain title-block fields so they aren't duplicated
  meta.author = nil
  meta.date = nil
  meta.abstract = nil

  return pandoc.Pandoc(doc.blocks, meta)
end
