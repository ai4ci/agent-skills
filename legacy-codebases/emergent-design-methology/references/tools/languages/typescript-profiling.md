
When  debugging a standard TypeScript application and basic logging statements are not enough, you need runtime performance data.

## The Optimized AI Profiling Workflow

```unset
┌────────────────────────────────────────────────────────┐
│ 1. Modify Code to Inject a Profiler Tracing Point      │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ 2. App runs under V8 Profiler -> Outputs Profile JSON  │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ 3. Script Simplifies Profile to Top CPU Heavy Paths    │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ 4. Analyzes Trace text + Source Code to fix the Bug    │
└───────────────────────────┬────────────────────────────┘
```

---

## Step 1: use Node's native `inspector` module 

Start and stop precise CPU profiling right around the problematic function by wrapping the buggy code block with the native inspector API:

```typescript
import inspector from 'node:inspector';
import fs from 'node:fs';

async function debugTargetFunction() {
  const session = new inspector.Session();
  session.connect();

  // 1. Enable the CPU profiler
  session.post('Profiler.enable');
  session.post('Profiler.start');

  console.log('AI-Profiling started...');
  
  // === RUN THE BUGGY COMPONENT HERE ===
  await executeSuspectCodePipeline(); 
  // ====================================

  // 2. Stop profiling and save the raw structural trace
  session.post('Profiler.stop', (err, { profile }) => {
    if (!err) {
      fs.writeFileSync('./cpu-profile.json', JSON.stringify(profile, null, 2));
      console.log('AI-Profiling dump complete.');
    }
  });
}
```

---

## Step 2: Flatten the Profile into easily consumed text

The resulting `cpu-profile.json` file is a massive, nested tree structure that is difficult to assimilate. You must use a quick helper script to flatten the JSON into a clean markdown table showing where CPU cycles were spent.

Create a script named `summarize-profile.ts` for your project:

```typescript
import fs from 'node:fs';

interface ProfileNode {
  id: number;
  callFrame: { functionName: string; url: string; lineNumber: number };
  hitCount: number;
  children?: number[];
}

const rawData = JSON.parse(fs.readFileSync('./cpu-profile.json', 'utf8'));
const nodes: ProfileNode[] = rawData.nodes;

// Aggregate hits to find total processing time per function line
const summary = nodes
  .filter(node => node.hitCount > 0 && !node.callFrame.url.includes('node_modules'))
  .map(node => ({
    function: node.callFrame.functionName || '(anonymous)',
    location: `${node.callFrame.url.split('/').pop()}:${node.callFrame.lineNumber}`,
    cpuHits: node.hitCount
  }))
  .sort((a, b) => b.cpuHits - a.cpuHits)
  .slice(0, 10); // Keep only top 10 heavy locations

console.log('| Function Name | File Location | CPU Samples (Hits) |');
console.log('|---|---|---|');
summary.forEach(row => {
  console.log(`| ${row.function} | ${row.location} | ${row.cpuHits} |`);
});
```

---

## Step 3: Feeding the Profile to the AI for Debugging

Now, run this script on the `cpu-profile.json` and use this markdown table to diagnose where the original source code is problematic. The profiling evidence allows you to diagnose three types of bugs that regular log messages completely miss:
## 1. The Blocked Event-Loop Bug

- The Evidence: The markdown table shows 10,000+ CPU hits sitting on a single line number inside a sorting or array mutation routine (like `.map()` or `.filter()`).
- Logging statements show the function starts and finishes, but the profiler shows it is consuming 95% of the total CPU runtime. Refactor this processing logic into a `Worker` thread or process it in smaller, asynchronous chunks.
## 2. The Unintentional Recursion / Re-render Bug

- The Evidence: The profile shows massive CPU hit distributions shared evenly across a sequence of internal hooks or state setters.
- Logs didn't catch this because nothing is throwing an error, but the profiler reveals these three functions are continuously calling each other in a loop. Modify the code to break this re-evaluation cycle.
## 3. Stale Event Listeners / Promise Leaks

- The Evidence: Over repeated simulation runs, the total number of CPU hits on helper routines climbs exponentially rather than staying flat.
- The code is adding execution listeners but never tearing them down, or similar problem. Add a `.off()` or cleanup destructor method to prevent execution stacks from accumulating.

---
