-- Create a temp table for all NYC account ids
DROP TABLE acctids;
CREATE TEMP TABLE acctids AS
SELECT a.id
  FROM accounts a
  JOIN profiles p on a.id = p.account_id
 WHERE ST_DWithin(p.location, 'SRID=4326;POINT(-73.895639 40.725088)', 12 * 1609.34)
   AND DATE_PART('day', current_date - p.seen) < 182 -- Logged in within last 6 months
   AND a.deleted = False
   AND a.locale = 'en_US';

-- Accounts
SELECT a.id, a.email, a.fb_id, a.locale, a.device
  FROM accounts a
 WHERE a.id in (SELECT id FROM acctids)
 ORDER BY a.created ASC;

-- Account settings
SELECT *
  FROM settings s
 WHERE account_id in (SELECT id FROM acctids);

-- Account profiles
SELECT *
  FROM profiles p
 WHERE account_id in (SELECT id FROM acctids);
 
-- Reported accounts
SELECT *
  FROM reports r
  LEFT JOIN report_reasons rr ON rr.id = r.reason_id
 WHERE r.reporting_user_id in (SELECT id FROM acctids)
   AND r.reported_user_id in (SELECT id FROM acctids);

-- Swipes
SELECT *
  FROM swipes
 WHERE from_account_id in (SELECT id FROM acctids)
   AND to_account_id in (SELECT id FROM acctids);