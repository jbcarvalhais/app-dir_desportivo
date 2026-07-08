param(
  [int]$Port = 8080,
  [string]$Root = (Get-Location).Path
)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $Root on http://localhost:$Port/"

$mimeMap = @{
  ".html" = "text/html"; ".htm" = "text/html"; ".js" = "application/javascript";
  ".css" = "text/css"; ".json" = "application/json"; ".png" = "image/png";
  ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"; ".svg" = "image/svg+xml";
  ".ico" = "image/x-icon"; ".txt" = "text/plain"
}

while ($listener.IsListening) {
  try {
    $context = $listener.GetContext()
  } catch {
    break
  }
  $req = $context.Request
  $res = $context.Response
  try {
    try {
      $path = $req.Url.AbsolutePath
      if ($path -eq "/") { $path = "/index.html" }
      $filePath = Join-Path $Root ($path.TrimStart("/"))
      if (Test-Path $filePath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $mime = $mimeMap[$ext]
        if (-not $mime) { $mime = "application/octet-stream" }
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $res.ContentType = $mime
        $res.ContentLength64 = $bytes.Length
        if ($req.HttpMethod -ne "HEAD" -and $bytes.Length -gt 0) {
          $res.OutputStream.Write($bytes, 0, $bytes.Length)
        }
      } else {
        $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
        $res.StatusCode = 404
        $res.ContentLength64 = $msg.Length
        if ($req.HttpMethod -ne "HEAD") {
          $res.OutputStream.Write($msg, 0, $msg.Length)
        }
      }
    } catch {
      try { $res.StatusCode = 500 } catch {}
    }
  } finally {
    try { $res.OutputStream.Close() } catch {}
  }
}

$listener.Stop()
