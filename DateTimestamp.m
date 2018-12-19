function str_datetime = DateTimestamp()
str_datetime = [datestr(date, 'yyyymmdd') '-' datestr(now, 'HHMMSS')];
