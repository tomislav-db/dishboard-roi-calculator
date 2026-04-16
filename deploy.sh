#!/bin/bash
cd /Users/tomislavkostanjevac/dishboard-roi
cp dishboard-roi-calculator.html index.html
git add dishboard-roi-calculator.html index.html CLAUDE.md
git commit -m "Update calculator"
git push origin main
echo "Done — site will update in ~1 minute at https://tomislav-db.github.io/dishboard-roi-calculator"
