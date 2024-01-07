-- Link for the database: postgres://Test:bQNxVzJL4g6u@ep-noisy-flower-846766-pooler.us-east-2.aws.neon.tech/Metrocar

-- APP_DOWNLOADED
SELECT   platform,
         Count(*)
FROM     app_downloads
GROUP BY platform;

-- SIGNED_UP
SELECT   a.platform,
         Count(DISTINCT s.user_id)
FROM     signups s
JOIN     app_downloads a
ON       s.session_id = a.app_download_key
GROUP BY a.platform;

-- USERS_REQUESTED_RIDE
SELECT   a.platform,
         Count(DISTINCT r.user_id)
FROM     ride_requests r
JOIN     signups s
ON       r.user_id = s.user_id
JOIN     app_downloads a
ON       s.session_id = a.app_download_key
GROUP BY a.platform;

-- DRIVER_ACCEPTANCE
SELECT   a.platform,
         Count(DISTINCT r.user_id)
FROM     ride_requests r
JOIN     signups s
ON       r.user_id = s.user_id
JOIN     app_downloads a
ON       s.session_id = a.app_download_key
WHERE    r.accept_ts IS NOT NULL
GROUP BY a.platform;

-- RIDES
SELECT   a.platform,
         Count(DISTINCT r.user_id)
FROM     ride_requests r
JOIN     signups s
ON       r.user_id = s.user_id
JOIN     app_downloads a
ON       s.session_id = a.app_download_key
WHERE    r.dropoff_ts IS NOT NULL
GROUP BY a.platform;

-- PAYMENT
SELECT   a.platform,
         Count (*)
FROM     (
                         SELECT DISTINCT user_id
                         FROM            ride_requests
                         WHERE           ride_id IN
                                                     (
                                                     SELECT DISTINCT ride_id
                                                     FROM            transactions
                                                     WHERE           charge_status = 'Approved')) AS sub_query
JOIN     signups s
ON       sub_query.user_id = s.user_id
JOIN     app_downloads a
ON       s.session_id = a.app_download_key
GROUP BY a.platform;

-- REVIEW
SELECT   a.platform,
         Count(DISTINCT r.user_id)
FROM     reviews r
JOIN     signups s
ON       r.user_id = s.user_id
JOIN     app_downloads a
ON       s.session_id = a.app_download_key
GROUP BY a.platform;

-- Division by ages
-- APP_DOWNLOADED
SELECT    s.age_range,
          Count(DISTINCT a.app_download_key)
FROM      app_downloads a
LEFT JOIN signups s
ON        a.app_download_key = s.session_id
GROUP BY  s.age_range;

-- SIGNED_UP
SELECT   age_range,
         Count(DISTINCT user_id)
FROM     signups
GROUP BY age_range;

-- USERS_REQUESTED_RIDE
SELECT   s.age_range,
         Count(DISTINCT r.user_id)
FROM     ride_requests r
JOIN     signups s
ON       r.user_id = s.user_id
GROUP BY s.age_range;

-- DRIVER_ACCEPTANCE
SELECT   s.age_range,
         Count(DISTINCT r.user_id)
FROM     ride_requests r
JOIN     signups s
ON       r.user_id = s.user_id
WHERE    r.accept_ts IS NOT NULL
GROUP BY s.age_range;

-- RIDES
SELECT   s.age_range,
         Count(DISTINCT r.user_id)
FROM     ride_requests r
JOIN     signups s
ON       r.user_id = s.user_id
WHERE    r.dropoff_ts IS NOT NULL
GROUP BY s.age_range;

-- PAYMENT
SELECT   s.age_range,
         Count (*)
FROM     (
                         SELECT DISTINCT user_id
                         FROM            ride_requests
                         WHERE           ride_id IN
                                                     (
                                                     SELECT DISTINCT ride_id
                                                     FROM            transactions
                                                     WHERE           charge_status = 'Approved')) AS sub_query
JOIN     signups s
ON       sub_query.user_id = s.user_id
GROUP BY s.age_range;

-- REVIEW
SELECT   s.age_range,
         Count(DISTINCT r.user_id)
FROM     reviews r
JOIN     signups s
ON       r.user_id = s.user_id
GROUP BY s.age_range;

-- Rides
-- Rides requestet
SELECT Count(*)
FROM   ride_requests 

-- Rides canceled
SELECT Count (*)
FROM   ride_requests
WHERE  cancel_ts IS NOT NULL;

-- Time didn`t cancel
SELECT Avg(accept_ts - request_ts) AS time_accept,
       Avg(pickup_ts - request_ts) AS time_waiting
FROM   ride_requests
WHERE  cancel_ts IS NULL;

-- Time cancel and not accepted
SELECT Avg(accept_ts - request_ts) AS time_accept,
       Avg(cancel_ts - request_ts) AS time_waiting
FROM   ride_requests
WHERE  cancel_ts IS NOT NULL
AND    accept_ts IS NULL;

-- Time cancel, but accepted
SELECT Avg(accept_ts - request_ts) AS time_accept,
       Avg(cancel_ts - request_ts) AS time_waiting
FROM   ride_requests
WHERE  cancel_ts IS NOT NULL
AND    accept_ts IS NOT NULL;

-- Hours requested
SELECT   Date_part ('hour',request_ts) AS hour_requested,
         Count (*)
FROM     ride_requests
GROUP BY hour_requested
ORDER BY Count(*) DESC;

-- Payment
SELECT   Count (r.ride_id),
         t.charge_status
FROM     ride_requests r
JOIN     transactions t
ON       r.ride_id = t.ride_id
WHERE    r.dropoff_ts IS NOT NULL
GROUP BY t.charge_status;

-- Reviews
SELECT   Count (r.ride_id),
         w.rating
FROM     ride_requests r
JOIN     reviews w
ON       r.ride_id = w.ride_id
WHERE    r.dropoff_ts IS NOT NULL
GROUP BY w.rating;
