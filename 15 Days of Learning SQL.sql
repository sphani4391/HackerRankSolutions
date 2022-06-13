SELECT sub.submission_date, sub.cnt, ranked.hacker_id, c.name
FROM
(   /* date and distinct hackers with atleast one submission each day */
    SELECT submission_date, count(distinct hacker_id) as cnt
    FROM 
    (   /* fetch the rows with cumulative submission rank = number of days. If rn < day, atleast one day without submission. */
        SELECT hacker_id, submission_date, dense_rank() over(order by submission_date) as day, 
        dense_rank() over(partition by hacker_id order by submission_date) as rn 
        FROM Submissions) a
    WHERE a.rn = a.day
    GROUP BY submission_date) sub

JOIN
(   /* max submissions by a hacker on any particular day */
    SELECT * FROM 
    (   SELECT submission_date, hacker_id, count(submission_id) as cnt, 
        rank() over (partition by submission_date order by submission_date, count(submission_id) desc, hacker_id) rnk 
        FROM Submissions
        GROUP BY submission_date, hacker_id) a
    WHERE a.rnk = 1) ranked
ON sub.submission_date = ranked.submission_date

JOIN Hackers c
ON ranked.hacker_id = c.hacker_id
