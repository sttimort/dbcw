CREATE OR REPLACE FUNCTION check_serial_insertion() RETURNS trigger AS $csi$
DECLARE
  serial_val integer;
BEGIN
  EXECUTE 'SELECT ($1).' || TG_ARGV[0] INTO serial_val USING NEW;
  BEGIN
    IF serial_val <> currval(TG_ARGV[1]) THEN
      RAISE EXCEPTION 'Нельзя явно указывать значение атрибута % таблицы %',
        TG_ARGV[0], TG_TABLE_NAME
        USING HINT = 'Не указывайте значение поля, либо укажите значение DEFAULT';
    END IF;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
      RAISE EXCEPTION 'Нельзя явно указывать значение атрибута % таблицы %',
        TG_ARGV[0], TG_TABLE_NAME
        USING HINT = 'Не указывайте значение поля, либо укажите значение DEFAULT';
  END;
  RETURN NEW;
END
$csi$ LANGUAGE plpgsql;


-- Триггер-функция, предназначенная для защиты изменения генерируемых значений
CREATE OR REPLACE FUNCTION check_serial_update() RETURNS trigger AS $csu$
DECLARE
  old_serial integer;
  new_serial integer;
BEGIN
  EXECUTE 'SELECT ($1).' || TG_ARGV[0] INTO new_serial USING NEW;
  EXECUTE 'SELECT ($1).' || TG_ARGV[0] INTO old_serial USING OLD;
  IF new_serial <> old_serial THEN
    RAISE EXCEPTION 'Нельзя изменять значение поля % таблицы %',
      TG_ARGV[0], TG_TABLE_NAME;
  END IF;
  RETURN NEW;
END
$csu$ LANGUAGE plpgsql;

-- Key entities ###############################################################
-- * Виды событий -------------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Виды_событий
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'Виды_событий_ИД_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Виды_событий
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * Виды ГО ------------------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Виды_ГО
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'Виды_ГО_ИД_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Виды_ГО
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * Виды организаций ---------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Виды_организаций
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'Виды_организаций_ИД_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Виды_организаций
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * Религии ------------------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Религии
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'Религии_ИД_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Религии
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * Роли ---------------------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Роли
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'Роли_ИД_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Роли
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------
-- #############################################################################

-- Associations ###############################################################
-- * Географиские объекты -----------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Гео_объекты
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'Гео_объекты_ИД_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Гео_объекты
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * События ------------------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON События
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'События_ИД_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON События
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * Организации --------------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Организации
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'acting_entities_id_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Организации
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * Дома ---------------------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Дома
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'acting_entities_id_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Дома
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * Действующие лица ---------------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Действ_лица
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'acting_entities_id_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Действ_лица
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------

-- * Типы действующих лиц -----------------------------------------------------
CREATE TRIGGER check_id_insertion BEFORE INSERT ON Типы_действ_лиц
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_insertion('ИД', 'acting_entities_id_seq');

CREATE TRIGGER check_id_update BEFORE UPDATE OF ИД ON Типы_действ_лиц
  FOR EACH ROW
  EXECUTE PROCEDURE check_serial_update('ИД');
-------------------------------------------------------------------------------
-- #############################################################################