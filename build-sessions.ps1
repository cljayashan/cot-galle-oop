# Build 32 unified sessions (alternating 3h / 2h) from lesson source files
# Block 0: Basic Java (lesson-01) | Block 1: Paradigm bridge (lesson-02) | Blocks 2-3: OOP (lessons 03-10)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDir = Join-Path $root 'sessions'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

# 32 sessions = 16 x 3h + 16 x 2h = 80 contact hours
$schedule = @(
  # --- Basic Java (slots 1-5) ---
  @{ n=1;  hrs=3; title='Hello World, JDK & Java Program Anatomy'; type='Integrated'; sources=@('lesson-01/session-01.html','lesson-01/session-02.html') }
  @{ n=2;  hrs=2; title='Variables, Data Types & Console Input/Output'; type='Integrated'; sources=@('lesson-01/session-03.html') }
  @{ n=3;  hrs=3; title='Operators & Decision Structures (if/else/switch)'; type='Integrated'; sources=@('lesson-01/session-04.html','lesson-01/session-05.html') }
  @{ n=4;  hrs=2; title='Loops — while, do-while & for'; type='Integrated'; sources=@('lesson-01/session-06.html') }
  @{ n=5;  hrs=3; title='Methods & Procedural Rectangle Capstone'; type='Practical'; sources=@('lesson-01/session-07.html') }
  # --- Paradigm bridge (slots 6-7) ---
  @{ n=6;  hrs=2; title='The Paradigm Shift — Procedural vs Object-Oriented'; type='Integrated'; sources=@('lesson-02/session-01.html') }
  @{ n=7;  hrs=3; title='Java Review & Rectangle — Flowchart to Object'; type='Integrated'; sources=@('lesson-02/session-02.html','lesson-02/session-03.html') }
  # --- Core OOP + Library (slots 8-19) ---
  @{ n=8;  hrs=2; title='Classes & Objects — Fields and the Vehicle Example'; type='Integrated'; sources=@('lesson-03/session-04.html') }
  @{ n=9;  hrs=3; title='Methods (BankAccount) & Library Phase 1: Book Class'; type='Integrated'; sources=@('lesson-03/session-05.html','lesson-03/session-06.html') }
  @{ n=10; hrs=2; title='Access Modifiers — public, private, Data Hiding'; type='Integrated'; sources=@('lesson-04/session-07.html') }
  @{ n=11; hrs=3; title='Getters/Setters & Library Phase 2'; type='Integrated'; sources=@('lesson-04/session-08.html','lesson-04/session-09.html') }
  @{ n=12; hrs=2; title='Constructors — Default & Parameterized'; type='Integrated'; sources=@('lesson-05/session-10.html') }
  @{ n=13; hrs=3; title='Method Overloading & Library Phase 3'; type='Integrated'; sources=@('lesson-05/session-11.html','lesson-05/session-12.html') }
  @{ n=14; hrs=2; title='Memory & Object Lifecycle — Stack, Heap, GC'; type='Integrated'; sources=@('lesson-06/session-13.html') }
  @{ n=15; hrs=3; title='Inheritance Basics + Inheritance in Depth'; type='Integrated'; sources=@('lesson-07/session-14.html','lesson-07/session-15.html') }
  @{ n=16; hrs=2; title='Library System — Phase 4: LibraryItem Hierarchy'; type='Practical'; sources=@('lesson-07/session-16.html') }
  @{ n=17; hrs=3; title='Polymorphism — @Override & Library Phase 5'; type='Integrated'; sources=@('lesson-08/session-17.html','lesson-08/session-18.html') }
  @{ n=18; hrs=2; title='Abstraction — Abstract Classes & Interfaces'; type='Integrated'; sources=@('lesson-09/session-19.html') }
  @{ n=19; hrs=3; title='Library System — Phase 6: Final Assembly'; type='Practical'; sources=@('lesson-09/session-20.html') }
  # --- Relationships + School (slots 20-24) ---
  @{ n=20; hrs=2; title='Object Relationships — Theory (Part 1)'; type='Integrated'; sources=@('lesson-10/session-21.html'); part='first' }
  @{ n=21; hrs=3; title='Object Relationships — Theory & Labs (Part 2)'; type='Integrated'; sources=@('lesson-10/session-21.html'); part='second' }
  @{ n=22; hrs=2; title='School Project — Teacher & Classroom (Part 1)'; type='Practical'; sources=@('lesson-10/session-22.html'); part='first' }
  @{ n=23; hrs=3; title='School Project — Teacher & Classroom (Part 2)'; type='Practical'; sources=@('lesson-10/session-22.html'); part='second' }
  @{ n=24; hrs=2; title='School Project — Desks, Composition & Full Assembly'; type='Practical'; sources=@('lesson-10/session-23.html') }
  # --- Revision & assessment (slots 25-32) ---
  @{ n=25; hrs=3; title='Revision — Basic Java & OOP Pillars Overview'; type='Revision'; sources=@('lesson-01/session-05.html','lesson-02/session-01.html'); revision=$true }
  @{ n=26; hrs=2; title='Revision — Classes, Encapsulation & Constructors'; type='Revision'; sources=@('lesson-03/session-05.html','lesson-05/session-10.html'); revision=$true }
  @{ n=27; hrs=3; title='Revision — Inheritance & Polymorphism Drills'; type='Revision'; sources=@('lesson-08/session-17.html'); revision=$true }
  @{ n=28; hrs=2; title='Practical Revision — Class Design Practice'; type='Revision'; sources=@('lesson-03/session-06.html'); revision=$true }
  @{ n=29; hrs=3; title='Mock Practical Test Preparation'; type='Revision'; sources=@('lesson-07/session-16.html'); revision=$true }
  @{ n=30; hrs=2; title='Mock Practical — Timed Lab Exercise'; type='Practical Test'; sources=@('lesson-03/session-06.html'); revision=$true }
  @{ n=31; hrs=3; title='Semester Exam Theory Revision + Full Mock Review'; type='Revision'; sources=@('lesson-09/session-19.html','lesson-10/session-21.html'); revision=$true }
  @{ n=32; hrs=2; title='Final Q&A, CA Clinic & Assessment Briefing'; type='Revision'; sources=@('lesson-09/session-20.html'); revision=$true }
)

function Get-PartTitle($html) {
  if ($html -match '(?s)<div class="session-banner">.*?<h2>(.*?)</h2>') { return $matches[1].Trim() }
  return 'Continued'
}

function Extract-MainBody($html, $isLast, $isRevision) {
  if ($html -notmatch '(?s)<main>(.*?)</main>') { return '' }
  $body = $matches[1]
  $body = $body -replace '(?s)<div class="botnav.*?</div>\s*', ''
  if ($isRevision) {
    $body = $body -replace '(?s)<div class="lesson-header">.*?</div>\s*', ''
    $body = $body -replace '(?s)<div class="outcomes-box">.*?</div>\s*', ''
    $rev = @"
<div class="note-box">
  <strong>Revision Session</strong>
  <p>Re-read the sections below, redo lab tasks without looking at solutions, and test yourself using the summary boxes.</p>
</div>
"@
    return $rev + $body.Trim()
  }
  $body = $body -replace '(?s)<div class="lesson-header">.*?</div>\s*', ''
  $body = $body -replace '(?s)<div class="outcomes-box">.*?</div>\s*', ''
  if (-not $isLast) {
    $body = $body -replace '(?s)<div class="summary-box">.*?</div>\s*', ''
    $body = $body -replace '(?s)<div class="exam-box">.*?</div>\s*', ''
  }
  return $body.Trim()
}

function Split-BodyHalves($body) {
  $sections = [regex]::Split($body, '(?=<div class="section")')
  $sections = $sections | Where-Object { $_.Trim() -ne '' }
  if ($sections.Count -le 1) {
    $mid = [math]::Floor($body.Length / 2)
    return @{ first = $body.Substring(0, $mid); second = $body.Substring($mid) }
  }
  $half = [math]::Ceiling($sections.Count / 2)
  return @{
    first  = ($sections[0..($half - 1)] -join '')
    second = ($sections[$half..($sections.Count - 1)] -join '')
  }
}

foreach ($s in $schedule) {
  $num = '{0:D2}' -f $s.n
  $prev = if ($s.n -gt 1) { "session-{0:D2}.html" -f ($s.n - 1) } else { '' }
  $next = if ($s.n -lt 32) { "session-{0:D2}.html" -f ($s.n + 1) } else { '' }
  $hrsLabel = if ($s.hrs -eq 3) { '3 Hours' } else { '2 Hours' }
  $slotLabel = if ($s.hrs -eq 3) { '3-Hour Session' } else { '2-Hour Session' }

  $mainParts = @()
  $si = 0
  $lastIdx = $s.sources.Count - 1
  $isRev = [bool]$s.revision

  foreach ($src in $s.sources) {
    $path = Join-Path $root $src
    if (-not (Test-Path $path)) { throw "Missing: $path" }
    $html = Get-Content $path -Raw -Encoding UTF8
    $isLast = ($si -eq $lastIdx)
    $body = Extract-MainBody $html $isLast $isRev

    if ($s.part) {
      $halves = Split-BodyHalves $body
      $body = if ($s.part -eq 'first') { $halves.first } else { $halves.second }
    }

    if ($si -gt 0) {
      $partTitle = Get-PartTitle $html
      $body = "<div class=`"section part-break`"><h2 class=`"section-title`">$partTitle</h2></div>`n" + $body
    }
    $mainParts += $body
    $si++
  }
  $mainContent = $mainParts -join "`n`n"

  $stagStyle = switch -Regex ($s.type) {
    'Practical Test' { 'background:#fce4ec;color:#c2185b;' }
    'Practical' { 'background:#e8f5e9;color:#2e7d32;' }
    'Revision' { 'background:#f3e5f5;color:#6a1b9a;' }
    default { 'background:#fff8e1;color:#b28704;' }
  }

  $botPrev = if ($prev) { "<a href=`"$prev`" class=`"btn btn-secondary`">&larr; Session $($s.n - 1)</a>" } else { '<span></span>' }
  $botNext = if ($next) { "<a href=`"$next`" class=`"btn btn-primary`">Session $($s.n + 1) &rarr;</a>" } else { '<span></span>' }

  $page = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Session $num - $($s.title)</title>
  <link rel="stylesheet" href="../style.css" />
  <style>
    .part-break { margin-top: 28px; padding-top: 8px; border-top: 3px solid var(--primary); }
    @media print { .topnav,.botnav,.no-print,footer { display:none !important; } @page { margin:18mm 15mm; } }
  </style>
</head>
<body>

<div class="session-banner">
  <div class="snum">Session $num of 32 &nbsp;&bull;&nbsp; $slotLabel &nbsp;&bull;&nbsp; Object Oriented Programming</div>
  <h2>$($s.title)</h2>
  <div class="smeta">
    <span class="stag">&#9203; $hrsLabel</span>
    <span class="stag stag-type" style="$stagStyle">$($s.type)</span>
  </div>
</div>

<div class="topnav no-print">
  <a href="../index.html">&#127968; Home</a>
  <a href="index.html">&#128218; Sessions</a>
  <span class="crumb">&#9656; Session $num of 32</span>
  <button class="pdf-btn" type="button" onclick="exportSessionPdf(this)" title="Download PDF"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg> PDF</button>
</div>

<main>

$mainContent

  <div class="botnav no-print">
    $botPrev
    $botNext
  </div>

</main>

<footer>
  <p>College of Technology Galle &nbsp;|&nbsp; Object Oriented Programming &ndash; Module K72T004M03 &nbsp;|&nbsp; Level 05</p>
  <p style="margin-top:6px;font-size:0.8rem;">Session $num &nbsp;|&nbsp; $hrsLabel &nbsp;|&nbsp; Sequence position $num of 32</p>
  <p style="margin-top:6px;font-size:0.8rem;"><strong>Author:</strong> Jayashan Liyanage</p>
</footer>

<script src="../js/vendor/pdfmake.min.js"></script>
<script src="../js/vendor/vfs_fonts.js"></script>
<script src="../js/export-pdf.js"></script>
</body>
</html>
"@

  Set-Content (Join-Path $outDir "session-$num.html") $page -Encoding UTF8 -NoNewline
  Write-Host "Built session-$num.html ($hrsLabel)"
}

Write-Host "Done: 32 sessions (16x3h + 16x2h = 80 hours)"
