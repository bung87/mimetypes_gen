import std/[strutils, strformat]
import puppy

iterator fetchData(): string =
  const SourceUrl = "http://svn.apache.org/viewvc/httpd/httpd/trunk/docs/conf/mime.types?view=co"
  let response = get(SourceUrl)
  for line in response.body.splitLines:
    if line.startsWith("#"):
      continue
    else:
      let data = line.splitWhitespace(1)
      # mime, exts
      if data.len == 2:
        for ext in data[1].splitWhitespace():
          yield &""""{ext}": "{data[0]}","""

proc fetchSource(): (string, int, int) =
  const MimeFileUrl = "https://raw.githubusercontent.com/nim-lang/Nim/devel/lib/pure/mimetypes.nim"
  let response = get(MimeFileUrl)
  const leftFlag = "const mimes* = {"
  let left = response.body.find(leftFlag) + leftFlag.len + 1
  let right = response.body.find("}", left)
  return (response.body, left, right)

when isMainModule:
  var (body, left , right) = fetchSource()
  var content: string
  for data in fetchData():
    content.add &"  {data}\n"
  body[left ..< right] = content

  writeFile("mimetypes.nim",body)