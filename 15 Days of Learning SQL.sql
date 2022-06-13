SELECT sub.submission_date, sub.cnt, ranked.hacker_id, c.name from
(   /* date and distinct hackers with atleast one submission each day */
    SELECT submission_date, count(distinct hacker_id) as cnt from 
    (   /* fetch the rows with cumulative submission rank = number of days. If rn < day, atleast one day without submission, hence doesn't qualify */
        SELECT hacker_id, submission_date, dense_rank() over(order by submission_date) as day, dense_rank() over(partition by hacker_id order by submission_date) as rn from Submissions) a
    WHERE a.rn = a.day
    GROUP BY submission_date) sub

inner join
(   /* max submissions by a hacker on any particular day */
    SELECT * FROM 
    (   /* nested query to fetch the rank = 1 row */
        SELECT submission_date, hacker_id, count(submission_id) as cnt, rank() over (partition by submission_date order by submission_date, count(submission_id) desc, hacker_id) rnk 
        from Submissions
        GROUP BY submission_date, hacker_id) a
    WHERE a.rnk = 1) ranked
on sub.submission_date = ranked.submission_date

inner join Hackers c
on ranked.hacker_id = c.hacker_id
