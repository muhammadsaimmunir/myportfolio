$port = 8080
$folder = "d:\MyProjects\myportfolio"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host "✨ Server running at http://localhost:$port/" -ForegroundColor Green
Write-Host "🎨 Portfolio loaded! Open the URL in your browser." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server." -ForegroundColor Yellow
Write-Host ""

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $filePath = $folder + $request.RawUrl
        if ($request.RawUrl -eq "/") {
            $filePath = $folder + "/index.html"
        }

        $filePath = $filePath -replace "\?.*$", ""  # Remove query string

        try {
            if (Test-Path $filePath -PathType Leaf) {
                $extension = [System.IO.Path]::GetExtension($filePath)
                
                switch($extension) {
                    ".html" { $contentType = "text/html" }
                    ".css" { $contentType = "text/css" }
                    ".js" { $contentType = "application/javascript" }
                    ".json" { $contentType = "application/json" }
                    ".png" { $contentType = "image/png" }
                    ".jpg" { $contentType = "image/jpeg" }
                    ".jpeg" { $contentType = "image/jpeg" }
                    ".gif" { $contentType = "image/gif" }
                    ".svg" { $contentType = "image/svg+xml" }
                    default { $contentType = "text/plain" }
                }
                
                $response.ContentType = $contentType
                $response.StatusCode = 200
                $content = [System.IO.File]::ReadAllBytes($filePath)
                $response.OutputStream.Write($content, 0, $content.Length)
                
                Write-Host "📄 [200] $($request.RawUrl)" -ForegroundColor Green
            } else {
                $response.StatusCode = 404
                $response.ContentType = "text/html"
                $content = [System.Text.Encoding]::UTF8.GetBytes("<h1>404 - File Not Found</h1>")
                $response.OutputStream.Write($content, 0, $content.Length)
                
                Write-Host "❌ [404] $($request.RawUrl)" -ForegroundColor Red
            }
        } catch {
            $response.StatusCode = 500
            $response.ContentType = "text/html"
            $content = [System.Text.Encoding]::UTF8.GetBytes("<h1>500 - Internal Server Error</h1>")
            $response.OutputStream.Write($content, 0, $content.Length)
            
            Write-Host "⚠️ [500] Error: $_" -ForegroundColor Red
        }
        
        $response.OutputStream.Close()
    }
} finally {
    $listener.Stop()
    $listener.Dispose()
    Write-Host "✋ Server stopped." -ForegroundColor Yellow
}
