param (
[int]$TotalGB,
[string]$location="D:\"
)

$KB = 1024
$MB = $KB * 1024
$GB = $MB * 1024
$MIN_FSIZE = $MB
$maxFileSize = 5 * $GB
$freeSpace = $TotalGB * $GB

[int]$i = 0
while ($maxFileSize -gt $MIN_FSIZE -and $freeSpace -gt 0)
{
    [Uint64]$candidateFileSize = Get-Random -minimum $MIN_FSIZE -maximum $maxFileSize
    if ($candidateFileSize -ge $freeSpace)
    {
        $maxFileSize = $maxFileSize / 2
    }
    else
    {

        $fileName = $location + "Random-" + ($i -as [string]) + ".rnd"
        $i+=1

        $fileSize = $candidateFileSize
        Write-Host "---------------------------"
        Write-Host "Creating"$fileName" of "$fileSize" bytes"

        $fstream  = New-Object System.IO.FileStream($fileName,[io.filemode]::OpenOrCreate)
        $w = New-Object System.IO.BinaryWriter($fstream)
        $consumed = 0
        
        while ($consumed -lt $fileSize)
        {
            $out = New-Object Byte[] $MB
            (New-Object Random).NextBytes($out)
            $w.Write($out)
            $consumed += $MB
            $out.Clear()
        }
        Write-Host "Write Complete.  Closing streams"
        $w.Close()
        $fstream.Close()
        $freeSpace -= $fileSize
        Write-Host "Remaining to Consume:  "$freeSpace
    }

}