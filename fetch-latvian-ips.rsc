# Update Latvian IP address-list

:local url "https://ip.netpro.lv/latvian-ips.txt"
:local listName "latvian-ips"
:local tmpFile "latvian-ips.txt"

# 1. Download
:do {
    /tool fetch url=$url dst-path=$tmpFile
} on-error={
    :log error "[$listName] failed to download $url — existing entries preserved"
    :error "download failed"
}

# 2. Read file
:local content ""
:do {
    :set content [/file get $tmpFile contents]
} on-error={
    :do { /file remove $tmpFile } on-error={}
    :log error "[$listName] failed to read $tmpFile — existing entries preserved"
    :error "file read failed"
}

# 3. Guard: do not wipe list if file is empty
:if ([:len $content] = 0) do={
    :do { /file remove $tmpFile } on-error={}
    :log error "[$listName] file is empty — existing entries preserved"
    :error "empty file"
}

# 4. Count and remove existing entries
:local prevCount [:len [/ip firewall address-list find list=$listName]]
/ip firewall address-list remove [find list=$listName]

# 5. Add entries line by line
:local pos 0
:local contentLen [:len $content]
:local added 0
:local errors 0

:while ($pos < $contentLen) do={
    :local lineEnd [:find $content "\n" $pos]
    :if ([:typeof $lineEnd] = "nil") do={ :set lineEnd $contentLen }

    :local line [:pick $content $pos $lineEnd]

    :local lineLen [:len $line]
    :if ($lineLen > 0) do={
        :do {
            /ip firewall address-list add list=$listName address=$line
            :set added ($added + 1)
        } on-error={
            :set errors ($errors + 1)
        }
    }

    :set pos ($lineEnd + 1)
}

# 6. Cleanup
:do { /file remove $tmpFile } on-error={}

# 7. Log results
:log info "[$listName] updated: $prevCount -> $added addresses"
:if ($errors > 0) do={
    :log error "[$listName] $errors lines skipped due to errors"
}
