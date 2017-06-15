CREATE OR REPLACE FUNCTION ASOIAFtimeToIntArray(t text) RETURNS int[7] AS $func$
DECLARE
  int_ar int[7];
  match text[];
  gr text;
BEGIN
  IF t IS NULL THEN
    RETURN array[NULL, NULL, NULL, NULL, NULL, NULL, NULL];
  END IF;

  match = regexp_matches(t, '^([0-9]{1,5}|\?)/([0-9]{1,2}|\?)/([0-9]{1,2}|\?)(?:\s([0-9]{2}|\?):([0-9]{2}|\?):([0-9]{2}|\?))?(?:\s(до З.Э.|от З.Э.))|(Рассветная эпоха|Долгая Ночь|Век Героев|Вторжение андалов|Не наступило)$');
  
  IF match IS NULL THEN
    RAISE EXCEPTION $$Неверный формат даты, формат даты: 
    (<year>|?)['/'(<month>|?)['/'(<day>|?)]][' '(<hour>|?)[':'(<minutes>|?)[':'(<seconds>|?)]]]('до З.Э.'|'от З.Э.')$$;
  END IF;

  IF match[8] = 'Рассветная эпоха' THEN
    RETURN array[12000, NULL, NULL, NULL, NULL, NULL, -1];
  ELSEIF match[8] = 'Долгая Ночь' OR match[8] = 'Век Героев' THEN
    RETURN array[8000, NULL, NULL, NULL, NULL, NULL, -1];
  ELSEIF match[8] = 'Вторжение андалов' THEN
    RETURN array[4000, NULL, NULL, NULL, NULL, NULL, -1];
  ELSEIF match[8] = 'Не наступило' THEN
    RETURN array[301, 12, 30, 23, 59, 59, 1];
  END IF;

  FOR i IN 1..3 LOOP
    IF match[i] IS NOT NULL AND match[i] != '?' THEN
      int_ar[i] = match[i]::int;
    ELSE
      int_ar[i] = NULL;
    END IF;
  END LOOP;

  FOR i IN 4..6 LOOP
    IF match[i] IS NOT NULL AND match[i] != '?' THEN
      int_ar[i] = match[i]::int;
    ELSE
      int_ar[i] = NULL;
    END IF;
  END LOOP;

  IF match[7] = 'до З.Э.' THEN
    int_ar[7] = -1;
  ELSE
    int_ar[7] = 1;
  END IF;

  IF int_ar[1]*int_ar[7] < -12000 OR int_ar[1]*int_ar[7] > 300 OR
     int_ar[2] < 1 OR int_ar[2] > 12 OR
     int_ar[3] < 1 OR int_ar[3] > 30 OR
     int_ar[4] > 23 OR
     int_ar[5] > 59 OR
     int_ar[6] > 59 THEN
       RAISE EXCEPTION 'Время или дата вне допустимого диапозона'
         USING HINT = 'Допустимый диапозон: 12000/12/30 23:59:59 до З.Э. - 300/12/30 23:59:59 от З.Э.';
  END IF;

  RETURN int_ar;
END
$func$ language plpgsql;

CREATE OR REPLACE FUNCTION ASOIAFfindMaxComparablePartIndex(t1_arr int[7], t2_arr int[7]) RETURNS int AS $$
DECLARE
  min1 int = 0; min2 int = 0;
  NULLFound bool = false;
  asoiafTmstmp bigint = 0;
BEGIN
  WHILE (NOT NULLFound) AND min1 < 6 LOOP
    min1 = min1 + 1;
    IF t1_arr[min1] IS NULL THEN
      NULLFound = true;
    END IF;
  END LOOP;

  NULLFound = false;
  WHILE (NOT NULLFound) AND min2 < 6 LOOP
    min2 = min2 + 1;
    IF t2_arr[min2] IS NULL THEN
      NULLFound = true;
    END IF;
  END LOOP;

  IF min1 < min2 THEN
    RETURN min1-1;
  ELSE
    RETURN min2-1;
  END IF;
END
$$ language plpgsql;

CREATE OR REPLACE FUNCTION ASOIAFtimeCmp(t1 text, t2 text) RETURNS int AS $$
DECLARE
  t1_arr int[6]; t2_arr int[6];
  i int = 1;
  NULLFound bool = false;
  asoiafTmstmp1 bigint = 0; asoiafTmstmp2 bigint = 0;
  minCPart int;
BEGIN
  t1_arr = ASOIAFtimeToIntArray(t1);
  t2_arr = ASOIAFtimeToIntArray(t2);

  WHILE (NOT NULLFound) AND i <= 6 LOOP 
    IF t1_arr[i] IS NULL THEN
      NULLFound = true;
    END IF;
    i = i + 1;
  END LOOP;
  
  i = 1;
  WHILE (NOT NULLFound) AND i <= 6 LOOP 
    IF t2_arr[i] IS NULL THEN
      NULLFound = true;
    END IF;
    i = i + 1;
  END LOOP;

  IF NULLFound THEN -- if at least one of the time string is not specified
    IF t1_arr[7] > t2_arr[7] THEN -- means time1 is AC and time2 is BC
      RETURN 1;
    ELSE IF t1_arr[7] < t2_arr[7] THEN -- means time1 is BC and time is AC
      RETURN 2;
    END IF; END IF;

    minCPart = ASOIAFfindMaxComparablePartIndex(t1_arr, t2_arr);
    IF minCPart = 0 THEN
      RETURN -1; -- -1 means ambigues
    END IF;

    FOR i IN 1..minCPart LOOP
      asoiafTmstmp1 = asoiafTmstmp1 * 10^2 + t1_arr[i];
      asoiafTmstmp2 = asoiafTmstmp2 * 10^2 + t2_arr[i];
    END LOOP;

    asoiafTmstmp1 = asoiafTmstmp1 * t1_arr[7];
    asoiafTmstmp2 = asoiafTmstmp2 * t2_arr[7];

    IF asoiafTmstmp1 > asoiafTmstmp2 THEN
      RETURN 1;
    ELSE IF asoiafTmstmp1 = asoiafTmstmp2 THEN
      RETURN -1; -- ambigues
    ELSE
      RETURN 2;
    END IF; END IF;
  END IF;

  asoiafTmstmp1 = (t1_arr[1]*10^10 + t1_arr[2]*10^8 + t1_arr[3]*10^6 + t1_arr[4]*10^4 + t1_arr[5]*10^2 + t1_arr[6])*t1_arr[7];
  asoiafTmstmp2 = (t2_arr[1]*10^10 + t2_arr[2]*10^8 + t2_arr[3]*10^6 + t2_arr[4]*10^4 + t2_arr[5]*10^2 + t2_arr[6])*t2_arr[7];

  IF asoiafTmstmp1 > asoiafTmstmp2 THEN
    RETURN 1;
  ELSE IF asoiafTmstmp1 = asoiafTmstmp2 THEN
    RETURN 0; -- means equal
  ELSE
    RETURN 2;
  END IF;
  END IF;
END
$$ language plpgsql;


ALTER TABLE События ADD CONSTRAINT invalid_datetime_check CHECK (ASOIAFtimeCmp(Время_начала, Время_окончания) != 1);
ALTER TABLE Организации ADD CONSTRAINT invalid_datetime_check CHECK (ASOIAFtimeCmp(Время_появления, Время_исчезновения) != 1);
ALTER TABLE Гео_объекты ADD CONSTRAINT invalid_datetime_check CHECK (ASOIAFtimeCmp(Время_появления, Время_исчезновения) != 1);
ALTER TABLE Типы_действ_лиц ADD CONSTRAINT invalid_datetime_check CHECK (ASOIAFtimeCmp(Время_появления, Время_исчезновения) != 1);
ALTER TABLE Действ_лица ADD CONSTRAINT invalid_datetime_check CHECK (ASOIAFtimeCmp(Время_рождения, Время_смерти) != 1);
ALTER TABLE Дома ADD CONSTRAINT invalid_datetime_check CHECK (ASOIAFtimeCmp(Время_появления, Время_исчезновения) != 1);
ALTER TABLE Религии ADD CONSTRAINT invalid_datetime_check CHECK (ASOIAFtimeCmp(Время_появления, Время_исчезновения) !=1);