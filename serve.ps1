# Minimal static server for the portfolio site (no dependencies)
$root = $PSScriptRoot
$port = 4173
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root at http://localhost:$port/  (Ctrl+C to stop)"
$mime = @{ ".html"="text/html"; ".js"="text/javascript"; ".css"="text/css"; ".jpg"="image/jpeg"; ".png"="image/png"; ".svg"="image/svg+xml"; ".pdf"="application/pdf"; ".ico"="image/x-icon" }
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
    $file = Join-Path $root ($path -replace '/', '\')
    if ((Test-Path $file -PathType Leaf) -and $file.StartsWith($root)) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      $ctx.Response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" }
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
  } catch { }
}
