USE test;

DROP TABLE IF EXISTS A;

SELECT CAST(1 as DateTime64('abc')); -- { serverError 43 } # Invalid scale parameter type
SELECT CAST(1 as DateTime64(100)); -- { serverError 69 } # too big scale
SELECT CAST(1 as DateTime64(-1)); -- { serverError 43 } # signed scale parameter type
SELECT CAST(1 as DateTime64(3, 'qqq')); -- { serverError 1000 } # invalid timezone

CREATE TABLE A(t DateTime64(3, 'UTC')) ENGINE = MergeTree() ORDER BY t;
INSERT INTO A(t) VALUES (1556879125123456789), ('2019-05-03 11:25:25.123456789'), (now64(3)), (now64(6)), (now64(0));

SELECT toString(t, 'UTC'), toDate(t), toStartOfDay(t), toStartOfQuarter(t), toTime(t), toStartOfMinute(t) FROM A ORDER BY t;

DROP TABLE A;
 -- issue toDate does a reinterpret_cast of the datetime64 which is incorrect
-- for the example above, it returns 2036-08-23 which is 0x5F15 days after epoch
-- the datetime64 is 0x159B2550CB345F15