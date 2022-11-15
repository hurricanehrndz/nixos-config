local has_comment, comment = pcall(require, "Comment")

if not has_comment then
  return
end
comment.setup()
