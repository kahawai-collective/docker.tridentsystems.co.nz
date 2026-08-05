begin;
create temp table _r as
with recent as (
  select j.report, max(j.received_at)
  from job j
  join report r on j.report = r.code
               and r.deleted is null
  where j.received_at is not null
  and j.received_at > current_timestamp - interval '1 year'
  group by j.report
  order by max desc
)
select code, repository, branch, directory
from report r
join recent c on r.code = c.report
order by c.max desc;

\copy _r to stdout delimiter E'|';
rollback;
