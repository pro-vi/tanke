# Battle City Stage Files — Attribution

The 35 ASCII stage files in this directory (`1` through `35`) are vendored
from the [krystiankaluzny/Tanks](https://github.com/krystiankaluzny/Tanks)
project under the MIT License.

## Source

- Repository: https://github.com/krystiankaluzny/Tanks
- Original path: `resources/stages/{1..35}`
- Vendored: 2026-05-19 (arc 3, PR #3 review-fix)

## Why vendored

These files are loaded at runtime by `scripts/LevelLoader.gd` to render
Battle City NES stages 1-35 in the Originals game mode. They are checked
into this repo so fresh clones can run Originals mode without first
cloning the research source separately (which is gitignored under
`.research/repos/`).

## License

The original copyright notice and permission notice (per MIT requirement):

```
MIT License

Copyright (c) 2025 Krystian Kałużny

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Format

Each stage file is a 26-row × 26-column ASCII grid:

```
.  empty       — no cell placed
#  brick       — destructible
@  steel       — indestructible
%  forest      — decorative + hide
~  water       — blocks tanks
-  ice         — pass-through (arc-3 PHASE-1 decision)
```

See `scripts/LevelLoader.gd` for the full parse logic.
