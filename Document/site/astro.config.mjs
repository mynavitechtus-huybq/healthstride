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
            { label: 'Nhật ký Mobile', items: [{ autogenerate: { directory: 'daily/mobile' } }] },
            { label: 'Nhật ký Backend', items: [{ autogenerate: { directory: 'daily/backend' } }] },
          ],
        },
        {
          label: 'Business & BA',
          items: [
            { label: 'Tổng quan bộ tài liệu', slug: 'library/business' },
            { label: 'Hiểu bài toán nghiệp vụ', slug: 'library/business/business-understanding' },
            { label: 'Nhật ký quyết định', slug: 'library/business/decision-log' },
            { label: 'Tổng quan Use Case', slug: 'library/business/usecase-overview' },
            { label: 'Thực thể nghiệp vụ', slug: 'library/business/business-entities' },
            { label: 'Sơ đồ màn hình', slug: 'library/business/screen-flow' },
            { label: 'Backlog', slug: 'library/business/backlog' },
            { label: 'Danh sách chức năng & MVP', slug: 'library/business/function-list' },
            { label: 'Đặc tả màn hình', items: [{ autogenerate: { directory: 'library/business/screens' } }] },
          ],
        },
        {
          label: 'Kiến trúc & Kế hoạch kỹ thuật',
          items: [
            { label: 'Design System', slug: 'library/design-system' },
            { label: 'Kế hoạch triển khai', items: [{ autogenerate: { directory: 'library/plans' } }] },
            { label: 'Kiến trúc kỹ thuật', items: [{ autogenerate: { directory: 'library/engineering' } }] },
          ],
        },
        {
          label: 'Vlog & nhật ký mở rộng',
          items: [{ autogenerate: { directory: 'library/journal' } }],
        },
        {
          label: 'Báo cáo',
          items: [{ autogenerate: { directory: 'library/reports' } }],
        },
      ],
    }),
  ],
});
