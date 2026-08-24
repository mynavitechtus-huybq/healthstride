import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://healthstride-docs.vercel.app',
  integrations: [
    starlight({
      title: 'HealthStride Learning Journal',
      customCss: ['./src/styles/custom.css'],
      sidebar: [
        {
          label: 'Nhật ký hành trình',
          items: [
            { label: 'Tổng quan dự án', slug: 'index' },
            {
              label: 'Nhật ký Mobile',
              items: [
                { label: 'Tổng quan Mobile', slug: 'daily/mobile' },
                { autogenerate: { directory: 'daily/mobile' } },
              ],
            },
            {
              label: 'Nhật ký Backend',
              items: [
                { label: 'Tổng quan Backend', slug: 'daily/backend' },
                { autogenerate: { directory: 'daily/backend' } },
              ],
            },
          ],
        },
        {
          label: 'Business & BA',
          items: [
            { label: 'Tổng quan bộ tài liệu', slug: 'library/business' },
            {
              label: 'Screen specifications',
              items: [{ autogenerate: { directory: 'library/business/screens' } }],
            },
            {
              label: 'Tài liệu nghiệp vụ',
              items: [{ autogenerate: { directory: 'library/business' } }],
            },
          ],
        },
        {
          label: 'Kế hoạch triển khai',
          items: [{ autogenerate: { directory: 'library/plans' } }],
        },
        {
          label: 'Vlog & nhật ký mở rộng',
          items: [{ autogenerate: { directory: 'library/journal' } }],
        },
        {
          label: 'Kiến trúc & Design System',
          items: [
            { label: 'Design System', slug: 'library/design-system' },
            {
              label: 'Kiến trúc kỹ thuật',
              items: [{ autogenerate: { directory: 'library/engineering' } }],
            },
          ],
        },
        {
          label: 'Báo cáo',
          items: [{ autogenerate: { directory: 'library/reports' } }],
        },
      ],
    }),
  ],
});
