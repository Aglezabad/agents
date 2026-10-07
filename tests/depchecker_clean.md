# Test Input: DEPCHECKER — clean dependency state

Analyze this project. Report findings only — do not modify anything.

Project license: Apache-2.0 (file `LICENSE` in the repo root). No network access is available.

**package.json**

```json
{
  "name": "acme-cli",
  "version": "1.0.0",
  "license": "Apache-2.0",
  "dependencies": {
    "commander": "^12.0.0",
    "picocolors": "^1.0.0"
  },
  "devDependencies": {
    "vitest": "^2.0.0"
  }
}
```

A `package-lock.json` is committed and pins: commander 12.1.0 (MIT), picocolors 1.0.1 (MIT), vitest 2.0.5 (MIT).

**src/cli.js**

```javascript
import { Command } from "commander";
import colors from "picocolors";

const program = new Command();
program.name("acme-cli").action(() => {
  console.log(colors.green("acme-cli ready"));
});
program.parse();
```

Notes:

- Every dependency is imported somewhere in `src/` (`vitest` in `tests/`).
- The project ships `THIRD-PARTY-NOTICES` containing each dependency's name, version, copyright, and full MIT license text.
- The Apache-2.0 NOTICE file content is preserved, and modified third-party files are flagged per Apache-2.0 section 4(b).
- An in-app `acme-cli licenses` command prints the same acknowledgements content.
- The distribution model is an open-source npm package (source release, not a distributed binary).
