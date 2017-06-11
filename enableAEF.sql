-- Проверка корректности добавления экземпляра сущности ------------------------
CREATE OR REPLACE FUNCTION check_reference_on_insert() RETURNS trigger as $cr$
DECLARE
 t record;
BEGIN
  FOR t IN EXECUTE format('SELECT * FROM %I WHERE ИД = %s', NEW.tblname, NEW.ИД) LOOP
    IF t.ИД = NEW.ИД THEN
      RETURN NEW;
    END IF;
  END LOOP;
  RAISE EXCEPTION 'Не существует записи с ИД % в таблице %', NEW.ИД, NEW.tblname;
END
$cr$ language plpgsql;

-- Проверка корректности удаления экземпляра действующей сущности
CREATE OR REPLACE FUNCTION check_reference_on_delete() RETURNS trigger as $cr$
DECLARE
 t record;
BEGIN
  FOR t IN EXECUTE format('SELECT * FROM %I WHERE ИД = %s', OLD.tblname, OLD.ИД) LOOP
    IF t.ИД = OLD.ИД THEN
       RAISE EXCEPTION 'Удаление невозможно. Существует объект c ИД % в таблице %',
         OLD.ИД, OLD.tblname;
    END IF;
  END LOOP;
  RETURN OLD;
END
$cr$ language plpgsql;

-- Автоматическое создание действующих сущностей
CREATE OR REPLACE FUNCTION add_acting_entity() RETURNS trigger AS $aae$
BEGIN
  INSERT INTO Действ_сущности (ИД, tblname) values (NEW.ИД, TG_TABLE_NAME);
  PERFORM * FROM Действ_сущности WHERE ИД = NEW.ИД;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Что-то пошло не так';
  END IF;
  RETURN NEW;
END
$aae$ language plpgsql;

-- Автоматическое удаление действующих сущностей
CREATE OR REPLACE FUNCTION delete_acting_entity() RETURNS trigger AS $aae$
BEGIN
  DELETE FROM Действ_сущности WHERE ИД = OLD.ИД;
  PERFORM * FROM Действ_сущности WHERE ИД = OLD.ИД;
  IF FOUND THEN
    RAISE EXCEPTION 'Что-то пошло не так';
  END IF;
  RETURN NULL;
END
$aae$ language plpgsql;


-- Проверка значений при вставке и удалении записей --------------------
CREATE TRIGGER check_reference_on_insert AFTER INSERT ON Действ_сущности
  FOR EACH ROW
  EXECUTE PROCEDURE check_reference();

CREATE TRIGGER check_reference_on_delete BEFORE DELETE ON Действ_сущности
  FOR EACH ROW
  EXECUTE PROCEDURE check_reference_on_delete();
------------------------------------------------------------------------


-- Автоматическое добавление действующих сущностей ---------------------
CREATE TRIGGER add_acting_entity AFTER INSERT ON Дома
  FOR EACH ROW
  EXECUTE PROCEDURE add_acting_entity();

CREATE TRIGGER add_acting_entity AFTER INSERT ON Типы_действ_лиц
  FOR EACH ROW
  EXECUTE PROCEDURE add_acting_entity();

CREATE TRIGGER add_acting_entity AFTER INSERT ON Действ_лица
  FOR EACH ROW
  EXECUTE PROCEDURE add_acting_entity();

CREATE TRIGGER add_acting_entity AFTER INSERT ON Организации
  FOR EACH ROW
  EXECUTE PROCEDURE add_acting_entity();
------------------------------------------------------------------------

-- Автоматическое удаление действующих сущностей -----------------------
CREATE TRIGGER delete_acting_entity AFTER DELETE ON Дома
  FOR EACH ROW
  EXECUTE PROCEDURE delete_acting_entity();

CREATE TRIGGER delete_acting_entity AFTER DELETE ON Типы_действ_лиц
  FOR EACH ROW
  EXECUTE PROCEDURE delete_acting_entity();

CREATE TRIGGER delete_acting_entity AFTER DELETE ON Действ_лица
  FOR EACH ROW
  EXECUTE PROCEDURE delete_acting_entity();

CREATE TRIGGER delete_acting_entity AFTER DELETE ON Организации
  FOR EACH ROW
  EXECUTE PROCEDURE delete_acting_entity();
------------------------------------------------------------------------