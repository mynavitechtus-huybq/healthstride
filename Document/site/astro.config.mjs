import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://healthstride-docs.vercel.app',
  integrations: [
    starlight({
      title: 'HealthStride Learning Journal',
      sidebar: [
        {
          label: 'Journal',
          items: [
            { label: 'Overview', slug: 'index' },
            { label: 'Mobile Track', slug: 'daily/mobile' },
            { label: 'Backend Track', slug: 'daily/backend' },
          ],
        },
      ],
    }),
  ],
});
