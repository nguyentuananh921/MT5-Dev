import { realpathSync } from 'node:fs';
import { defineConfig } from 'vite';

// The folder is reached through a junction too (MQL5\Experts\Anhnt -> D:\MT5-Dev\Experts\Anhnt): the root is its real path, as the files Vite reads
export default defineConfig({
  root: realpathSync.native(process.cwd()),
});
