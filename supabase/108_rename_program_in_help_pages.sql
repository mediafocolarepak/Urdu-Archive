-- 108: the program is now called "Digital Urdu Archive" (DUA); update the name inside the guides.
--
-- The in-app Help pages live in the database (help_pages.html_content, seeded by 51/51b/56 and
-- possibly edited since), so renaming the program in the code does not reach them. This replaces the
-- old names in place, in a fixed order so that nothing is replaced twice. It is safe to run again:
-- after the first run none of the old forms is left, and step 4 refuses to touch a name that is
-- already preceded by "Digital ". Start Here cards and Announcements are separate tables edited by
-- Communication in the app; they are NOT touched here.

update public.help_pages
set html_content =
      regexp_replace(
        replace(
          replace(
            replace(
              replace(html_content,
                'l''Urdu Archive Manager', 'il Digital Urdu Archive'),
              'Focolare Urdu Archive Manager', 'Digital Urdu Archive'),
            'Urdu Archive Manager', 'Digital Urdu Archive'),
          'Focolare Movement — Urdu Archive', 'Digital Urdu Archive · Focolare Movement'),
        '(?<!Digital )Urdu Archive — ', 'Digital Urdu Archive — ', 'g'),
    updated_at = now(),
    updated_by_email = 'migration 108'
where (html_content like '%Urdu Archive Manager%'
       or html_content like '%Focolare Movement — Urdu Archive%'
       or html_content ~ '(?<!Digital )Urdu Archive — ');

-- ============================================================================
-- Self-test (run separately). All rows must be true.
-- ============================================================================
select 'no "Urdu Archive Manager" left in help pages' as item,
       (select count(*) = 0 from public.help_pages where html_content like '%Urdu Archive Manager%') as ok
union all select 'no "Focolare Movement — Urdu Archive" footer left',
       (select count(*) = 0 from public.help_pages where html_content like '%Focolare Movement — Urdu Archive%')
union all select 'no un-renamed "Urdu Archive — " left',
       (select count(*) = 0 from public.help_pages where html_content ~ '(?<!Digital )Urdu Archive — ')
union all select 'help pages still present (not emptied)',
       (select count(*) >= 1 and min(length(html_content)) > 500 from public.help_pages);
